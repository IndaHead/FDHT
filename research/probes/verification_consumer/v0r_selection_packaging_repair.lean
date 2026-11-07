import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4

open KernelExprContext

namespace VerificationConsumerV0R

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# V₀-R Selection Packaging Repair

Tests whether the exact V₀ evidence-gated verification semantics can be
implemented cleanly using target-indexed selection.

Key principle: preserve target index through selection.
-/

/-! ============================================================
    T0: Trivial baseline
============================================================ -/

theorem T0_true : True := trivial

#print axioms T0_true

/-! ============================================================
    T1: State equality on Fin 8
============================================================ -/

theorem T1_state_eq (i : Fin 8) : i = i := rfl

#print axioms T1_state_eq

/-! ============================================================
    T2: EvidenceEpisode constructor/projection
============================================================ -/

structure EvidenceEpisode (i : Fin 8) where
  proof : FirstPositiveReturnAt eightThreadCycle.toFun i 8

theorem T2_evidence_episode (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    (EvidenceEpisode.mk hP).proof = hP := rfl

#print axioms T2_evidence_episode

/-! ============================================================
    T3: VerificationRequest constructor/projection
============================================================ -/

structure VerificationRequest (i : Fin 8) where
  prerequisite : FirstPositiveReturnAt eightThreadCycle.toFun i 8

theorem T3_verification_request (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    (VerificationRequest.mk hP).prerequisite = hP := rfl

#print axioms T3_verification_request

/-! ============================================================
    T4: VerificationResult constructors
============================================================ -/

inductive VerificationResult (i : Fin 8) where
  | verified : FirstPositiveReturnAt eightThreadCycle.toFun i 8 → VerificationResult i
  | unresolved : VerificationResult i

theorem T4_verification_result_verified (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    VerificationResult.verified hP = VerificationResult.verified hP := rfl

#print axioms T4_verification_result_verified

/-! ============================================================
    T5: n8_index_first_return
============================================================ -/

#print axioms n8_index_first_return

/-! ============================================================
    Target-indexed selection result
============================================================ -/

inductive EvidenceSelection (i : Fin 8) where
  | found : FirstPositiveReturnAt eightThreadCycle.toFun i 8 → EvidenceSelection i
  | noMatch : EvidenceSelection i

/-! ============================================================
    Fixture-local evidence history (non-Sigma)
============================================================ -/

structure EvidenceEpisodeN8 where
  state : Fin 8
  proof : FirstPositiveReturnAt eightThreadCycle.toFun state 8

structure EvidenceHistory where
  episodes : List EvidenceEpisodeN8

/-! ============================================================
    Target-indexed structural recursion selector
============================================================ -/

def selectFor (i : Fin 8) (episodes : List EvidenceEpisodeN8) :
    EvidenceSelection i :=
  match episodes with
  | [] => .noMatch
  | ep :: rest =>
    if h : ep.state = i then
      .found (by cases h; exact ep.proof)
    else
      selectFor i rest

def selectEvidence (hist : EvidenceHistory) (i : Fin 8) :
    EvidenceSelection i :=
  selectFor i hist.episodes

/-! ============================================================
    Verification admission
============================================================ -/

def admitVerification (hist : EvidenceHistory) (i : Fin 8) :
    VerificationResult i :=
  match selectEvidence hist i with
  | .found hP => .verified hP
  | .noMatch => .unresolved

/-! ============================================================
    BASELINE: Empty history
============================================================ -/

def history_empty : EvidenceHistory where
  episodes := []

theorem baseline_noMatch (i : Fin 8) :
    selectEvidence history_empty i = .noMatch := by
  unfold selectEvidence selectFor history_empty
  rfl

#print axioms baseline_noMatch

theorem baseline_unresolved (i : Fin 8) :
    admitVerification history_empty i = .unresolved := by
  unfold admitVerification
  rw [baseline_noMatch]
  rfl

#print axioms baseline_unresolved

/-! ============================================================
    APPLICABLE PARAMETRIC HISTORY (using simp)
============================================================ -/

def history_applicable (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    EvidenceHistory where
  episodes := [{ state := i, proof := hP }]

theorem applicable_found (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    selectEvidence (history_applicable i hP) i = .found hP := by
  unfold selectEvidence selectFor history_applicable
  simp only [List.head?]
  rfl

#print axioms applicable_found

theorem applicable_verified (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    admitVerification (history_applicable i hP) i = .verified hP := by
  unfold admitVerification
  rw [applicable_found]
  rfl

#print axioms applicable_verified

/-! ============================================================
    CONCRETE HISTORY (using simp)
============================================================ -/

def history_concrete (i : Fin 8) : EvidenceHistory where
  episodes := [{ state := i, proof := n8_index_first_return i }]

theorem concrete_found (i : Fin 8) :
    selectEvidence (history_concrete i) i = .found (n8_index_first_return i) := by
  unfold selectEvidence selectFor history_concrete
  simp only [List.head?]
  rfl

#print axioms concrete_found

theorem concrete_verified (i : Fin 8) :
    admitVerification (history_concrete i) i = .verified (n8_index_first_return i) := by
  unfold admitVerification
  rw [concrete_found]
  rfl

#print axioms concrete_verified

/-! ============================================================
    KNOCKOUT
============================================================ -/

def history_knockout : EvidenceHistory where
  episodes := []

theorem knockout_noMatch (i : Fin 8) :
    selectEvidence history_knockout i = .noMatch := by
  unfold selectEvidence selectFor history_knockout
  rfl

#print axioms knockout_noMatch

theorem knockout_unresolved (i : Fin 8) :
    admitVerification history_knockout i = .unresolved := by
  unfold admitVerification
  rw [knockout_noMatch]
  rfl

#print axioms knockout_unresolved

/-! ============================================================
    VERIFICATION REQUEST CONSTRUCTION
============================================================ -/

def constructVerificationRequest (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    VerificationRequest i where
  prerequisite := hP

theorem verification_request_requires_proof (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    (constructVerificationRequest i hP).prerequisite = hP := rfl

#print axioms verification_request_requires_proof

/-! ============================================================
    PROOF LINEAGE
============================================================ -/

theorem proof_lineage (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    (constructVerificationRequest i hP).prerequisite = hP := rfl

#print axioms proof_lineage

end VerificationConsumerV0R
