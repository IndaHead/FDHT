/-
MRT-05B: A2 Exact-Address Domain Adapter

Research probe only.
Does not modify fdht/.
Does not promote MRT-04.
Does not add permanent retrieval/address/memory semantics.

Classification: B — A2 COMPOSITE ADAPTER VERIFIED;
CANDIDATE ADDRESSING ALONE IS CONSUMER-LIMITED.
-/

import MRT04_TransformationFateLaws

/-! ## Source carrier -/

abbrev Identity := String
abbrev Payload := String
abbrev Lineage := String
abbrev Position := Nat

structure SourceRecord where
  recordId : String
  exactIdentity : Identity
  payload : Payload
  lineage : Lineage
  deriving DecidableEq, Repr

abbrev SourceState := List SourceRecord

/-! ## Exact index -/

abbrev ExactIndex := Identity → List Position

def buildExactIndex (source : SourceState) : ExactIndex :=
  fun ident =>
    (source.zipIdx.filter (fun ⟨rec, _⟩ => rec.exactIdentity = ident)).map Prod.snd

/-! ## Candidate transformation -/

def candidateT (r : Identity) (source : SourceState) : List Position :=
  buildExactIndex source r

/-! ## C0: Identity membership consumer -/

def identityMembershipConsumer (r : Identity) (source : SourceState) : Bool :=
  source.any (fun rec => rec.exactIdentity = r)

theorem c0_membership_structural (r : Identity) :
    SufficientFor (candidateT r) (identityMembershipConsumer r) := by
  intro s₁ s₂ h
  -- Membership is determined by non-empty position list
  simp [identityMembershipConsumer, candidateT, buildExactIndex] at h ⊢
  -- The position list equality determines membership
  cases s₁ with
  | nil =>
    cases s₂ with
    | nil => rfl
    | cons _ _ => simp at h
  | cons rec₁ rest₁ =>
    cases s₂ with
    | nil => simp at h
    | cons rec₂ rest₂ =>
      simp [List.any_cons] at *
      exact h

/-! ## C1: Identity multiplicity consumer -/

def identityMultiplicityConsumer (r : Identity) (source : SourceState) : Nat :=
  (source.filter (fun rec => rec.exactIdentity = r)).length

theorem c1_multiplicity_structural (r : Identity) :
    SufficientFor (candidateT r) (identityMultiplicityConsumer r) := by
  intro s₁ s₂ h
  -- Multiplicity equals candidate list length
  simp [identityMultiplicityConsumer, candidateT, buildExactIndex] at h ⊢
  -- The position list equality determines multiplicity
  cases s₁ with
  | nil =>
    cases s₂ with
    | nil => rfl
    | cons _ _ => simp at h
  | cons rec₁ rest₁ =>
    cases s₂ with
    | nil => simp at h
    | cons rec₂ rest₂ =>
      simp [List.filter_cons] at *
      exact h

/-! ## C2: Complete record consumer (negative) -/

def completeRecordConsumer (r : Identity) (source : SourceState) : Option SourceRecord :=
  source.find? (fun rec => rec.exactIdentity = r)

theorem c2_observableLoss_completeRecord :
    ObservableLoss (candidateT "id1") (completeRecordConsumer "id1") := by
  let s₁ : SourceState := [⟨"r1", "id1", "payload1", "lineage1"⟩]
  let s₂ : SourceState := [⟨"r2", "id1", "payload2", "lineage2"⟩]
  refine ⟨s₁, s₂, ?_, ?_⟩
  · simp [candidateT, buildExactIndex]; rfl
  · simp [completeRecordConsumer]; native_decide

/-! ## C3: Provenance consumer (negative) -/

def provenanceConsumer (r : Identity) (source : SourceState) : Option Lineage :=
  (source.find? (fun rec => rec.exactIdentity = r)).map (·.lineage)

theorem c3_observableLoss_provenance :
    ObservableLoss (candidateT "id1") (provenanceConsumer "id1") := by
  let s₁ : SourceState := [⟨"r1", "id1", "payload1", "lineage1"⟩]
  let s₂ : SourceState := [⟨"r2", "id1", "payload2", "lineage2"⟩]
  refine ⟨s₁, s₂, ?_, ?_⟩
  · simp [candidateT, buildExactIndex]; rfl
  · simp [provenanceConsumer]; native_decide

/-! ## Verified query transformation -/

inductive VerifiedResult where
  | verifiedPresent : SourceRecord → VerifiedResult
  | verifiedAbsent : VerifiedResult
  deriving DecidableEq, Repr

def verifiedQueryT (r : Identity) (source : SourceState) : VerifiedResult :=
  match source.find? (fun rec => rec.exactIdentity = r) with
  | some rec => VerifiedResult.verifiedPresent rec
  | none => VerifiedResult.verifiedAbsent

/-! ## C4: Verified identity outcome -/

def verifiedIdentityConsumer (r : Identity) (source : SourceState) : Bool :=
  source.any (fun rec => rec.exactIdentity = r)

theorem c4_verified_structural (r : Identity) :
    SufficientFor (verifiedQueryT r) (verifiedIdentityConsumer r) := by
  intro s₁ s₂ h
  simp [verifiedIdentityConsumer, verifiedQueryT] at h ⊢
  cases h₁ : List.find? (fun rec => rec.exactIdentity = r) s₁ with
  | none =>
    cases h₂ : List.find? (fun rec => rec.exactIdentity = r) s₂ with
    | none => simp [h₁, h₂]
    | some _ => simp [h₁, h₂] at h
  | some rec₁ =>
    cases h₂ : List.find? (fun rec => rec.exactIdentity = r) s₂ with
    | none => simp [h₁, h₂] at h
    | some rec₂ =>
      simp [h₁, h₂] at h
      simp [List.any_eq_true]
      exact ⟨rec₁, by simp [List.mem_of_find?_eq_some h₁], rfl⟩

/-! ## C5: Verified complete record -/

theorem c5_verified_completeRecord_structural (r : Identity) :
    SufficientFor (verifiedQueryT r) (completeRecordConsumer r) := by
  intro s₁ s₂ h
  simp [completeRecordConsumer, verifiedQueryT] at h ⊢
  cases h₁ : List.find? (fun rec => rec.exactIdentity = r) s₁ with
  | none =>
    cases h₂ : List.find? (fun rec => rec.exactIdentity = r) s₂ with
    | none => simp [h₁, h₂]
    | some _ => simp [h₁, h₂] at h
  | some rec₁ =>
    cases h₂ : List.find? (fun rec => rec.exactIdentity = r) s₂ with
    | none => simp [h₁, h₂] at h
    | some rec₂ =>
      simp [h₁, h₂] at h
      exact h

/-! ## Key negative results (compiled) -/

-- C2 and C3 establish that candidate addressing alone is insufficient
-- for complete record and provenance consumers.

/-! ## Axiom audit -/

#print axioms c0_membership_structural
#print axioms c1_multiplicity_structural
#print axioms c2_observableLoss_completeRecord
#print axioms c3_observableLoss_provenance
#print axioms c4_verified_structural
#print axioms c5_verified_completeRecord_structural
