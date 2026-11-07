import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4

open KernelExprContext

namespace VerificationConsumerV0

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# V₀ Evidence-Gated Verification

Tests whether a concrete verification consumer can distinguish between
cases where required historical evidence is absent vs present.

Consumer demand first. Historical supply second.
-/

/-! ============================================================
    Verification case: FirstPositiveReturnAt
============================================================ -/

structure FirstReturnRequest (X : Type) where
  step  : X → X
  state : X
  k     : Nat

def req_n8 (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 8

/-! ============================================================
    Verification request
    Requires exact prerequisite evidence
============================================================ -/

structure VerificationRequest (i : Fin 8) where
  prerequisite : FirstPositiveReturnAt eightThreadCycle.toFun i 8

/-! ============================================================
    Verification result
============================================================ -/

inductive VerificationResult (i : Fin 8) where
  | verified : FirstPositiveReturnAt eightThreadCycle.toFun i 8 → VerificationResult i
  | unresolved : VerificationResult i

/-! ============================================================
    Historical evidence (fixture-local)
============================================================ -/

structure EvidenceEpisode (i : Fin 8) where
  proof : FirstPositiveReturnAt eightThreadCycle.toFun i 8

structure EvidenceHistory where
  episodes : List (Σ i, EvidenceEpisode i)

/-! ============================================================
    Historical selection (using List.find?)
============================================================ -/

def selectEvidence (hist : EvidenceHistory) (i : Fin 8) :
    Option (EvidenceEpisode i) :=
  match hist.episodes.find? fun ⟨j, _⟩ => j = i with
  | some ⟨j, ep⟩ =>
    if h : j = i then
      some (by rw [h] at ep; exact ep)
    else
      none
  | none => none

/-! ============================================================
    Verification admission
============================================================ -/

def admitVerification (hist : EvidenceHistory) (i : Fin 8) :
    VerificationResult i :=
  match selectEvidence hist i with
  | some ep => .verified ep.proof
  | none => .unresolved

/-! ============================================================
    BASELINE: No evidence
============================================================ -/

def history_empty : EvidenceHistory where
  episodes := []

theorem baseline_unresolved (i : Fin 8) :
    admitVerification history_empty i = .unresolved := by
  unfold admitVerification selectEvidence history_empty
  rfl

#print axioms baseline_unresolved

/-! ============================================================
    APPLICABLE EVIDENCE
============================================================ -/

def history_applicable (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    EvidenceHistory where
  episodes := [⟨i, ⟨hP⟩⟩]

theorem applicable_verified (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    admitVerification (history_applicable i hP) i = .verified hP := by
  unfold admitVerification selectEvidence history_applicable
  simp only [List.find?_cons, List.find?_nil]
  rfl

#print axioms applicable_verified

/-! ============================================================
    KNOCKOUT
============================================================ -/

def history_knockout : EvidenceHistory where
  episodes := []

theorem knockout_unresolved (i : Fin 8) :
    admitVerification history_knockout i = .unresolved := by
  unfold admitVerification selectEvidence history_knockout
  rfl

#print axioms knockout_unresolved

/-! ============================================================
    CONCRETE POSITIVE PATH
============================================================ -/

def history_concrete (i : Fin 8) : EvidenceHistory where
  episodes := [⟨i, ⟨n8_index_first_return i⟩⟩]

theorem concrete_verified (i : Fin 8) :
    admitVerification (history_concrete i) i = .verified (n8_index_first_return i) := by
  unfold admitVerification selectEvidence history_concrete
  simp only [List.find?_cons, List.find?_nil]
  rfl

#print axioms concrete_verified

/-! ============================================================
    VERIFICATION REQUEST CONSTRUCTION
============================================================ -/

def constructVerificationRequest (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    VerificationRequest i where
  prerequisite := hP

theorem verification_request_requires_proof (i : Fin 8) (hP : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    (constructVerificationRequest i hP).prerequisite = hP := rfl

#print axioms verification_request_requires_proof

end VerificationConsumerV0
