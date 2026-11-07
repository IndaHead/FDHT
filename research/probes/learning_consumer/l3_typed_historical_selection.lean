import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4

open KernelExprContext

namespace LearningConsumerL3

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# L₃ Minimal Typed Historical Selection

Tests whether a later consumer can select an already-preserved proof-bearing
episode applicable to its current request WITHOUT being supplied the
applicable episode's address.

Key principle: finite typed selection without caller-supplied address.
-/

/-! ============================================================
    Shared definitions
============================================================ -/

structure FirstReturnRequest (X : Type) where
  step  : X → X
  state : X
  k     : Nat

inductive FirstReturnResult
    {X : Type}
    (req : FirstReturnRequest X) where

  | established :
      FirstPositiveReturnAt req.step req.state req.k →
      FirstReturnResult req

  | refuted :
      (FirstPositiveReturnAt req.step req.state req.k → False) →
      FirstReturnResult req

  | unresolved :
      FirstReturnResult req

structure Episode (X : Type) where
  request : FirstReturnRequest X
  result  : FirstReturnResult request

structure History (X : Type) where
  episodes : List (Episode X)

def req_n8 (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 8

/-! ============================================================
    Request-indexed recovery result
============================================================ -/

inductive RecoveryResultReq (req : FirstReturnRequest (Fin 8)) where
  | found : FirstPositiveReturnAt req.step req.state req.k → RecoveryResultReq req
  | notFound : RecoveryResultReq req

/-! ============================================================
    Typed selection result
============================================================ -/

inductive SelectionResult where
  | selected : (req : FirstReturnRequest (Fin 8)) → RecoveryResultReq req → SelectionResult
  | noMatch : SelectionResult

/-! ============================================================
    Finite typed selection (recursive)
    Traverses history looking for applicable established episode
============================================================ -/

def selectFromList (target : FirstReturnRequest (Fin 8)) (episodes : List (Episode (Fin 8))) :
    SelectionResult :=
  match episodes with
  | [] => .noMatch
  | ep :: rest =>
    if hreq : ep.request = target then
      match ep.result with
      | .established h => .selected ep.request (.found h)
      | .refuted _ => selectFromList target rest
      | .unresolved => selectFromList target rest
    else
      selectFromList target rest

def selectApplicable (hist : History (Fin 8)) (target : FirstReturnRequest (Fin 8)) :
    SelectionResult :=
  selectFromList target hist.episodes

/-! ============================================================
    Consumer from selection
============================================================ -/

def consumeSelection (s : SelectionResult) (target : FirstReturnRequest (Fin 8)) :
    FirstReturnResult target :=
  match s with
  | .selected req r =>
    if hreq : req = target then
      match r with
      | .found h => .established (by rw [hreq] at h; exact h)
      | .notFound => .unresolved
    else
      .unresolved
  | .noMatch => .unresolved

/-! ============================================================
    APPLICABLE-ONLY HISTORY
============================================================ -/

def history_applicable_only (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .established hQ }]

theorem applicable_only_selects (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    selectApplicable (history_applicable_only i hQ) (req_n8 i) =
      .selected (req_n8 i) (.found hQ) := by
  unfold selectApplicable selectFromList history_applicable_only
  rfl

#print axioms applicable_only_selects

theorem applicable_only_consumer (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    consumeSelection (selectApplicable (history_applicable_only i hQ) (req_n8 i)) (req_n8 i) =
      .established hQ := by
  unfold consumeSelection
  rw [applicable_only_selects]
  rfl

#print axioms applicable_only_consumer

/-! ============================================================
    EMPTY HISTORY
============================================================ -/

def history_empty : History (Fin 8) where
  episodes := []

theorem empty_no_match (i : Fin 8) :
    selectApplicable history_empty (req_n8 i) = .noMatch := by
  unfold selectApplicable selectFromList history_empty
  rfl

#print axioms empty_no_match

theorem empty_consumer_unresolved (i : Fin 8) :
    consumeSelection (selectApplicable history_empty (req_n8 i)) (req_n8 i) = .unresolved := by
  unfold consumeSelection
  rw [empty_no_match]
  rfl

#print axioms empty_consumer_unresolved

/-! ============================================================
    UNRESOLVED-ONLY HISTORY
============================================================ -/

def history_unresolved_only (i : Fin 8) : History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .unresolved }]

theorem unresolved_only_no_match (i : Fin 8) :
    selectApplicable (history_unresolved_only i) (req_n8 i) = .noMatch := by
  unfold selectApplicable selectFromList history_unresolved_only
  rfl

#print axioms unresolved_only_no_match

theorem unresolved_only_consumer_unresolved (i : Fin 8) :
    consumeSelection (selectApplicable (history_unresolved_only i) (req_n8 i)) (req_n8 i) =
      .unresolved := by
  unfold consumeSelection
  rw [unresolved_only_no_match]
  rfl

#print axioms unresolved_only_consumer_unresolved

/-! ============================================================
    IRRELEVANT-FIRST HISTORY
============================================================ -/

def history_irrelevant_first (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    History (Fin 8) where
  episodes := [
    { request := req_n8 ⟨0, by decide⟩, result := .unresolved },
    { request := req_n8 i, result := .established hQ }
  ]

theorem irrelevant_first_selects (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8)
    (hne : i ≠ ⟨0, by decide⟩) :
    selectApplicable (history_irrelevant_first i hQ) (req_n8 i) =
      .selected (req_n8 i) (.found hQ) := by
  unfold selectApplicable selectFromList history_irrelevant_first
  rfl

#print axioms irrelevant_first_selects

/-! ============================================================
    APPLICABLE-FIRST HISTORY
============================================================ -/

def history_applicable_first (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    History (Fin 8) where
  episodes := [
    { request := req_n8 i, result := .established hQ },
    { request := req_n8 ⟨0, by decide⟩, result := .unresolved }
  ]

theorem applicable_first_selects (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    selectApplicable (history_applicable_first i hQ) (req_n8 i) =
      .selected (req_n8 i) (.found hQ) := by
  unfold selectApplicable selectFromList history_applicable_first
  rfl

#print axioms applicable_first_selects

/-! ============================================================
    UNRESOLVED-FIRST HISTORY
============================================================ -/

def history_unresolved_first (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    History (Fin 8) where
  episodes := [
    { request := req_n8 i, result := .unresolved },
    { request := req_n8 i, result := .established hQ }
  ]

theorem unresolved_first_selects (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    selectApplicable (history_unresolved_first i hQ) (req_n8 i) =
      .selected (req_n8 i) (.found hQ) := by
  unfold selectApplicable selectFromList history_unresolved_first
  rfl

#print axioms unresolved_first_selects

/-! ============================================================
    CONTAINER KNOCKOUT
============================================================ -/

def history_knockout (i : Fin 8) : History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .unresolved }]

theorem knockout_no_match (i : Fin 8) :
    selectApplicable (history_knockout i) (req_n8 i) = .noMatch := by
  unfold selectApplicable selectFromList history_knockout
  rfl

#print axioms knockout_no_match

/-! ============================================================
    DUPLICATE APPLICABLE EVIDENCE
============================================================ -/

def history_duplicate (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    History (Fin 8) where
  episodes := [
    { request := req_n8 i, result := .established hQ },
    { request := req_n8 i, result := .established hQ }
  ]

theorem duplicate_selects_first (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    selectApplicable (history_duplicate i hQ) (req_n8 i) =
      .selected (req_n8 i) (.found hQ) := by
  unfold selectApplicable selectFromList history_duplicate
  rfl

#print axioms duplicate_selects_first

/-! ============================================================
    CONCRETE POSITIVE PATH
============================================================ -/

def history_concrete (i : Fin 8) : History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .established (n8_index_first_return i) }]

theorem concrete_selects (i : Fin 8) :
    selectApplicable (history_concrete i) (req_n8 i) =
      .selected (req_n8 i) (.found (n8_index_first_return i)) := by
  unfold selectApplicable selectFromList history_concrete
  rfl

#print axioms concrete_selects

theorem concrete_consumer (i : Fin 8) :
    consumeSelection (selectApplicable (history_concrete i) (req_n8 i)) (req_n8 i) =
      .established (n8_index_first_return i) := by
  unfold consumeSelection
  rw [concrete_selects]
  rfl

#print axioms concrete_consumer

end LearningConsumerL3
