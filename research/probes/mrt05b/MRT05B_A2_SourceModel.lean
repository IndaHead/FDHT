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

-- Probe-local helpers for C0 membership sufficiency
theorem zipIdx_cons
    {α : Type} (x : α) (xs : List α) (n : Nat) :
    (x :: xs).zipIdx n = (x, n) :: xs.zipIdx (n + 1) := by
  rfl

theorem filter_map_snd_isEmpty_iff_no_match
    (r : Identity)
    (pairs : List (SourceRecord × Nat)) :
    ((pairs.filter (fun ⟨rec, _⟩ => rec.exactIdentity = r)).map Prod.snd).isEmpty =
      (pairs.filter (fun ⟨rec, _⟩ => rec.exactIdentity = r)).isEmpty := by
  induction pairs with
  | nil => rfl
  | cons p ps ih =>
    match p with
    | (rec, idx) =>
      by_cases h : rec.exactIdentity = r
      · simp [h]
      · simp [h, ih]

theorem zipIdx_filter_empty_iff_source_no_match
    (offset : Nat)
    (r : Identity)
    (source : SourceState) :
    (source.zipIdx offset |>.filter (fun ⟨rec, _⟩ => rec.exactIdentity = r)).isEmpty =
      !(source.any (fun rec => rec.exactIdentity = r)) := by
  induction source generalizing offset with
  | nil =>
    simp
  | cons head tail ih =>
    rw [zipIdx_cons]
    simp [List.filter_cons, List.any_cons]
    by_cases h : head.exactIdentity = r
    · simp [h]
    · simp [h, ih (offset + 1)]

theorem candidateT_isEmpty_eq_not_membership
    (r : Identity)
    (source : SourceState) :
    (candidateT r source).isEmpty = !(identityMembershipConsumer r source) := by
  unfold candidateT buildExactIndex identityMembershipConsumer
  rw [filter_map_snd_isEmpty_iff_no_match]
  exact zipIdx_filter_empty_iff_source_no_match 0 r source

theorem c0_membership_structural (r : Identity) :
    SufficientFor (candidateT r) (identityMembershipConsumer r) := by
  intro s₁ s₂ hCand
  have h1 := candidateT_isEmpty_eq_not_membership r s₁
  have h2 := candidateT_isEmpty_eq_not_membership r s₂
  have hEmptyEq : (candidateT r s₁).isEmpty = (candidateT r s₂).isEmpty :=
    congrArg List.isEmpty hCand
  rw [h1, h2] at hEmptyEq
  simp only [Bool.not_eq_eq_eq_not, Bool.not_not] at hEmptyEq
  exact hEmptyEq

/-! ## C1: Identity multiplicity consumer -/

def identityMultiplicityConsumer (r : Identity) (source : SourceState) : Nat :=
  (source.filter (fun rec => rec.exactIdentity = r)).length

-- Probe-local helpers for C1 multiplicity sufficiency
theorem map_length_eq
    {α β : Type} (f : α → β) (xs : List α) :
    (xs.map f).length = xs.length := by
  induction xs with
  | nil => rfl
  | cons _ _ ih => simp [ih]

theorem zipIdx_filter_length_eq_source_filter_length
    (offset : Nat)
    (r : Identity)
    (source : SourceState) :
    ((source.zipIdx offset).filter (fun ⟨rec, _⟩ => rec.exactIdentity = r)).length
    =
    (source.filter (fun rec => rec.exactIdentity = r)).length := by
  induction source generalizing offset with
  | nil =>
    simp
  | cons head tail ih =>
    rw [zipIdx_cons]
    simp [List.filter_cons]
    by_cases h : head.exactIdentity = r
    · simp [h, ih (offset + 1)]
    · simp [h, ih (offset + 1)]

theorem zipIdx_filter_map_length_eq_source_filter_length
    (offset : Nat)
    (r : Identity)
    (source : SourceState) :
    (((source.zipIdx offset).filter (fun ⟨rec, _⟩ => rec.exactIdentity = r)).map Prod.snd).length
    =
    (source.filter (fun rec => rec.exactIdentity = r)).length := by
  rw [map_length_eq]
  exact zipIdx_filter_length_eq_source_filter_length offset r source

theorem candidateT_length_eq_multiplicity
    (r : Identity)
    (source : SourceState) :
    (candidateT r source).length = identityMultiplicityConsumer r source := by
  unfold candidateT buildExactIndex identityMultiplicityConsumer
  exact zipIdx_filter_map_length_eq_source_filter_length 0 r source

theorem c1_multiplicity_structural (r : Identity) :
    SufficientFor (candidateT r) (identityMultiplicityConsumer r) := by
  intro s₁ s₂ hCandidates
  have hLength : (candidateT r s₁).length = (candidateT r s₂).length :=
    congrArg List.length hCandidates
  rw [candidateT_length_eq_multiplicity r s₁, candidateT_length_eq_multiplicity r s₂] at hLength
  exact hLength

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

-- Probe-local helpers for C4 verified membership sufficiency
theorem find?_none_iff_any_false
    (r : Identity)
    (source : SourceState) :
    source.find? (fun rec => rec.exactIdentity = r) = none
    ↔
    source.any (fun rec => rec.exactIdentity = r) = false := by
  induction source with
  | nil =>
    simp
  | cons head tail ih =>
    by_cases h : head.exactIdentity = r
    · simp [h]
    · simp [h, ih]

theorem find?_some_implies_any_true
    (r : Identity)
    (source : SourceState)
    (record : SourceRecord)
    (hFind : source.find? (fun rec => rec.exactIdentity = r) = some record) :
    source.any (fun rec => rec.exactIdentity = r) = true := by
  induction source with
  | nil =>
    cases hFind
  | cons head tail ih =>
    by_cases h : head.exactIdentity = r
    · have : (head :: tail).any (fun rec => rec.exactIdentity = r) = true := by
        rw [List.any_cons]
        simp [h]
      exact this
    · have hFindTail : tail.find? (fun rec => rec.exactIdentity = r) = some record := by
        rw [List.find?_cons] at hFind
        simp [h] at hFind
        exact hFind
      have hAnyTail := ih hFindTail
      rw [List.any_cons]
      simp [h, hAnyTail]

def verifiedPresence : VerifiedResult → Bool
  | VerifiedResult.verifiedPresent _ => true
  | VerifiedResult.verifiedAbsent => false

theorem verifiedPresence_verifiedQueryT
    (r : Identity)
    (source : SourceState) :
    verifiedPresence (verifiedQueryT r source) = verifiedIdentityConsumer r source := by
  unfold verifiedQueryT verifiedIdentityConsumer verifiedPresence
  cases hFind : source.find? (fun rec => rec.exactIdentity = r) with
  | none =>
    have hAny := (find?_none_iff_any_false r source).mp hFind
    rw [hAny]
  | some rec =>
    have hAny := find?_some_implies_any_true r source rec hFind
    rw [hAny]

theorem c4_verified_structural (r : Identity) :
    SufficientFor (verifiedQueryT r) (verifiedIdentityConsumer r) := by
  intro s₁ s₂ hVerified
  have hPresence : verifiedPresence (verifiedQueryT r s₁) = verifiedPresence (verifiedQueryT r s₂) :=
    congrArg verifiedPresence hVerified
  rw [verifiedPresence_verifiedQueryT r s₁, verifiedPresence_verifiedQueryT r s₂] at hPresence
  exact hPresence

/-! ## C5: Verified complete record -/

-- Probe-local encoding for C5 verified complete-record sufficiency
def encodeVerified : Option SourceRecord → VerifiedResult
  | some record => VerifiedResult.verifiedPresent record
  | none => VerifiedResult.verifiedAbsent

theorem encodeVerified_injective : Function.Injective encodeVerified := by
  intro a b h
  cases a with
  | none =>
    cases b with
    | none => rfl
    | some record => cases h
  | some record₁ =>
    cases b with
    | none => cases h
    | some record₂ =>
      cases h
      rfl

theorem verifiedQueryT_eq_encodeVerified
    (r : Identity)
    (source : SourceState) :
    verifiedQueryT r source = encodeVerified (completeRecordConsumer r source) := by
  unfold verifiedQueryT completeRecordConsumer encodeVerified
  split <;> rfl

theorem c5_verified_completeRecord_structural (r : Identity) :
    SufficientFor (verifiedQueryT r) (completeRecordConsumer r) := by
  intro s₁ s₂ hVerified
  have hEncoded :
      encodeVerified (completeRecordConsumer r s₁)
      = encodeVerified (completeRecordConsumer r s₂) := by
    rw [← verifiedQueryT_eq_encodeVerified r s₁, ← verifiedQueryT_eq_encodeVerified r s₂]
    exact hVerified
  exact encodeVerified_injective hEncoded

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
#print axioms candidateT_isEmpty_eq_not_membership
