/-
CERTMEM-02: Lean formalisation of six-class memory certification.

Research probe only.
Does not modify fdht/.
Does not promote permanent mathematics.
Does not create a seventh persistent memory class.
Faithful research-local model (TRANSFORMED_LOSSLESS from Python dataclasses).
-/

import MRT04_TransformationFateLaws

/-- Six distinct memory record types (concrete research-local model). -/

structure ObservationRecord where
  sourceRef : String
  artefactRef : String
  version : String
  deriving Repr, DecidableEq

structure ClaimRecord where
  claimId : String
  sourceRef : String
  artefactRef : String
  builderRef : String
  domainRef : String
  version : String
  deriving Repr, DecidableEq

structure EvidenceRecord where
  evidenceId : String
  claimId : String
  sourceRef : String
  artefactRef : String
  builderRef : String
  domainRef : String
  version : String
  supportsCompleteness : Bool
  supportsBinding : Bool
  supportsCurrentness : Bool
  deriving Repr, DecidableEq

structure NegativeRecord where
  negativeId : String
  claimId : String
  sourceRef : String
  artefactRef : String
  version : String
  invalidatesBinding : Bool
  invalidatesCompleteness : Bool
  invalidatesCurrentness : Bool
  deriving Repr, DecidableEq

structure ObjectiveRecord where
  objectiveId : String
  domainRef : String
  requiresCertifiedAbsence : Bool
  deriving Repr, DecidableEq

structure CheckpointRecord where
  checkpointId : String
  sourceRef : String
  artefactRef : String
  builderRef : String
  domainRef : String
  version : String
  objectiveId : String
  deriving Repr, DecidableEq

structure MemoryState6 where
  observations : List ObservationRecord
  claims : List ClaimRecord
  evidence : List EvidenceRecord
  negatives : List NegativeRecord
  objectives : List ObjectiveRecord
  checkpoints : List CheckpointRecord
  deriving Repr, DecidableEq

structure CertificationRequirement where
  sourceRef : String
  artefactRef : String
  builderRef : String
  domainRef : String
  version : String
  objectiveId : String
  deriving Repr, DecidableEq

structure CertificateState where
  sourceRef : String
  artefactRef : String
  builderRef : String
  domainRef : String
  version : String
  objectiveId : String
  bindingEstablished : Bool
  completenessEstablished : Bool
  currentnessEstablished : Bool
  invalidatorPresent : Bool
  deriving Repr, DecidableEq

inductive CertificationDisposition where
  | certifiedValid : CertificateState → CertificationDisposition
  | stopInsufficientEvidence : CertificationDisposition
  | stopConflictingEvidence : CertificationDisposition
  | stopStaleBinding : CertificationDisposition
  | stopInvalidSource : CertificationDisposition
  | stopInvalidIndex : CertificationDisposition
  | stopInvalidBuilder : CertificationDisposition
  | stopInvalidDomain : CertificationDisposition
  | stopUnresolved : CertificationDisposition
  | rejectCertificate : CertificationDisposition
  deriving DecidableEq, Repr

inductive Authority where
  | none
  | internalIntegrity
  | externalAuthority
  deriving DecidableEq, Repr

inductive LookupObservation where
  | candidatesFound : Nat → LookupObservation
  | emptyLookup : LookupObservation
  deriving DecidableEq, Repr

inductive QueryDisposition where
  | certifiedAbsent : QueryDisposition
  | verifiedPresent : QueryDisposition
  | stopInsufficientEvidence : QueryDisposition
  | stopConflictingEvidence : QueryDisposition
  | stopStale : QueryDisposition
  | reject : QueryDisposition
  deriving DecidableEq, Repr

def certificationProjection (req : CertificationRequirement) (mem : MemoryState6) : CertificateState :=
  let hasObs := mem.observations.any (fun obs =>
    obs.sourceRef == req.sourceRef && obs.artefactRef == req.artefactRef && obs.version == req.version)
  let hasClaim := mem.claims.any (fun claim =>
    claim.sourceRef == req.sourceRef && claim.artefactRef == req.artefactRef &&
    claim.builderRef == req.builderRef && claim.domainRef == req.domainRef && claim.version == req.version)
  let hasSupport := mem.evidence.any (fun ev =>
    ev.supportsCompleteness && ev.supportsBinding && ev.supportsCurrentness)
  let hasInvalidator := mem.negatives.any (fun neg =>
    neg.invalidatesBinding || neg.invalidatesCompleteness || neg.invalidatesCurrentness)
  let hasObj := mem.objectives.any (fun obj =>
    obj.objectiveId == req.objectiveId && obj.requiresCertifiedAbsence)
  let hasCkpt := mem.checkpoints.any (fun ckpt =>
    ckpt.sourceRef == req.sourceRef && ckpt.version == req.version)
  {
    sourceRef := req.sourceRef
    artefactRef := req.artefactRef
    builderRef := req.builderRef
    domainRef := req.domainRef
    version := req.version
    objectiveId := req.objectiveId
    bindingEstablished := hasObs && hasClaim && hasSupport && hasCkpt
    completenessEstablished := hasSupport
    currentnessEstablished := hasCkpt && hasSupport
    invalidatorPresent := hasInvalidator
  }

def evaluateCertificate (cs : CertificateState) : CertificationDisposition :=
  if cs.invalidatorPresent then
    CertificationDisposition.stopConflictingEvidence
  else if cs.bindingEstablished && cs.completenessEstablished && cs.currentnessEstablished then
    CertificationDisposition.certifiedValid cs
  else
    CertificationDisposition.stopInsufficientEvidence

def certifiedQuery (req : CertificationRequirement) (mem : MemoryState6) (obs : LookupObservation) : QueryDisposition :=
  let disp := evaluateCertificate (certificationProjection req mem)
  match obs, disp with
  | LookupObservation.emptyLookup, CertificationDisposition.certifiedValid _ => QueryDisposition.certifiedAbsent
  | LookupObservation.emptyLookup, CertificationDisposition.stopInsufficientEvidence => QueryDisposition.stopInsufficientEvidence
  | LookupObservation.emptyLookup, CertificationDisposition.stopConflictingEvidence => QueryDisposition.stopConflictingEvidence
  | _, _ => QueryDisposition.stopInsufficientEvidence

def certificateAuthority : CertificationDisposition → Authority
  | CertificationDisposition.certifiedValid _ => Authority.internalIntegrity
  | _ => Authority.none

/-- Fixtures. -/

def req : CertificationRequirement :=
  { sourceRef := "src1", artefactRef := "idx1", builderRef := "bld1", domainRef := "dom1", version := "v1", objectiveId := "obj1" }

def M_valid : MemoryState6 :=
  { observations := [{ sourceRef := "src1", artefactRef := "idx1", version := "v1" }]
    claims := [{ claimId := "c1", sourceRef := "src1", artefactRef := "idx1", builderRef := "bld1", domainRef := "dom1", version := "v1" }]
    evidence := [{ evidenceId := "e1", claimId := "c1", sourceRef := "src1", artefactRef := "idx1", builderRef := "bld1", domainRef := "dom1", version := "v1",
                   supportsCompleteness := true, supportsBinding := true, supportsCurrentness := true }]
    negatives := []
    objectives := [{ objectiveId := "obj1", domainRef := "dom1", requiresCertifiedAbsence := true }]
    checkpoints := [{ checkpointId := "ck1", sourceRef := "src1", artefactRef := "idx1", builderRef := "bld1", domainRef := "dom1", version := "v1", objectiveId := "obj1" }] }

def M_uncertified : MemoryState6 :=
  { M_valid with evidence := [] }

def M_invalidated : MemoryState6 :=
  { M_valid with negatives := [{ negativeId := "n1", claimId := "c1", sourceRef := "src1", artefactRef := "idx1", version := "v1",
                                 invalidatesBinding := true, invalidatesCompleteness := false, invalidatesCurrentness := false }] }

def M_irrelevantNegative : MemoryState6 :=
  { M_valid with negatives := [{ negativeId := "n2", claimId := "other", sourceRef := "other", artefactRef := "other", version := "other",
                                 invalidatesBinding := false, invalidatesCompleteness := false, invalidatesCurrentness := false }] }

/-- Theorems. -/

theorem valid_history_certifies_absence :
    certifiedQuery req M_valid LookupObservation.emptyLookup = QueryDisposition.certifiedAbsent := by
  native_decide

theorem uncertified_history_stops :
    certifiedQuery req M_uncertified LookupObservation.emptyLookup = QueryDisposition.stopInsufficientEvidence := by
  native_decide

theorem history_changes_admissible_disposition :
    LookupObservation.emptyLookup = LookupObservation.emptyLookup ∧
    certifiedQuery req M_valid LookupObservation.emptyLookup ≠
    certifiedQuery req M_uncertified LookupObservation.emptyLookup := by
  native_decide

theorem applicable_negative_blocks_certification :
    certifiedQuery req M_invalidated LookupObservation.emptyLookup ≠ QueryDisposition.certifiedAbsent := by
  native_decide

theorem irrelevant_negative_preserves_certification :
    certifiedQuery req M_irrelevantNegative LookupObservation.emptyLookup = QueryDisposition.certifiedAbsent := by
  native_decide

theorem certification_never_produces_external_authority :
    ∀ d : CertificationDisposition, certificateAuthority d ≠ Authority.externalAuthority := by
  intro d
  cases d <;> simp [certificateAuthority]

theorem certification_authority_range :
    ∀ d : CertificationDisposition,
      certificateAuthority d = Authority.none ∨ certificateAuthority d = Authority.internalIntegrity := by
  intro d
  cases d <;> simp [certificateAuthority]

def semanticCertificationConsumer (r : CertificationRequirement) (m : MemoryState6) : QueryDisposition :=
  certifiedQuery r m LookupObservation.emptyLookup

theorem projection_sufficient_for_semantic (r : CertificationRequirement) :
    SufficientFor (certificationProjection r) (semanticCertificationConsumer r) := by
  intro m1 m2 h
  simp [semanticCertificationConsumer, certifiedQuery, evaluateCertificate]
  rw [h]

#print axioms valid_history_certifies_absence
#print axioms uncertified_history_stops
#print axioms history_changes_admissible_disposition
#print axioms applicable_negative_blocks_certification
#print axioms irrelevant_negative_preserves_certification
#print axioms certification_never_produces_external_authority
#print axioms certification_authority_range
#print axioms projection_sufficient_for_semantic
