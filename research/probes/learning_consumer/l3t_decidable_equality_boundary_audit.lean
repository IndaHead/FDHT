import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4

open KernelExprContext

namespace LearningConsumerL3T

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# L₃-T Decidable Equality / Selection Trust-Boundary Bisection

Diagnostic probe to identify where sorryAx first enters the L₃ dependency
chain.

This is a diagnostic probe. It does not modify L₃. It does not repair L₃.
It only measures and classifies.
-/

/-! ============================================================
    T0: Trivial baseline
============================================================ -/

theorem T0_true : True := trivial

#print axioms T0_true

/-! ============================================================
    T1: Request construction
============================================================ -/

structure FirstReturnRequest (X : Type) where
  step  : X → X
  state : X
  k     : Nat

def req_n8 (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 8

theorem T1_req_n8_k (i : Fin 8) : (req_n8 i).k = 8 := rfl

#print axioms T1_req_n8_k

/-! ============================================================
    T2: Request reflexive equality
============================================================ -/

theorem T2_req_n8_rfl (i : Fin 8) : req_n8 i = req_n8 i := rfl

#print axioms T2_req_n8_rfl

/-! ============================================================
    T3: Isolated request equality decision
============================================================ -/

theorem T3_req_eq_decision (i : Fin 8) :
    (if h : req_n8 i = req_n8 i then True else False) = True := by
  simp

#print axioms T3_req_eq_decision

/-! ============================================================
    T4: State-key equality
============================================================ -/

theorem T4_state_eq (i : Fin 8) : (req_n8 i).state = i := rfl

#print axioms T4_state_eq

/-! ============================================================
    T5: Result-only match
============================================================ -/

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

def episode_unresolved (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result  := .unresolved

theorem T5_result_match (i : Fin 8) :
    (episode_unresolved i).result = .unresolved := rfl

#print axioms T5_result_match

/-! ============================================================
    T6: List traversal only
============================================================ -/

structure History (X : Type) where
  episodes : List (Episode X)

def history_empty : History (Fin 8) where
  episodes := []

def countEpisodes (hist : History (Fin 8)) : Nat :=
  hist.episodes.length

theorem T6_count_empty : countEpisodes history_empty = 0 := rfl

#print axioms T6_count_empty

/-! ============================================================
    T7: Equality + traversal, no proof payload
============================================================ -/

def matchesTarget (target : FirstReturnRequest (Fin 8)) (episodes : List (Episode (Fin 8))) :
    Bool :=
  match episodes with
  | [] => false
  | ep :: rest =>
    if ep.request = target then true else matchesTarget target rest

theorem T7_matches_empty (i : Fin 8) :
    matchesTarget (req_n8 i) [] = false := rfl

#print axioms T7_matches_empty

/-! ============================================================
    T8: Dependent payload with supplied equality
============================================================ -/

theorem T8_dependent_transport (i : Fin 8)
    (ep : Episode (Fin 8))
    (hreq : ep.request = req_n8 i)
    (h : FirstPositiveReturnAt ep.request.step ep.request.state ep.request.k) :
    FirstPositiveReturnAt eightThreadCycle.toFun i 8 := by
  rw [hreq] at h
  exact h

#print axioms T8_dependent_transport

/-! ============================================================
    T9: Single-cell current-style selection
============================================================ -/

inductive RecoveryResultReq (req : FirstReturnRequest (Fin 8)) where
  | found : FirstPositiveReturnAt req.step req.state req.k → RecoveryResultReq req
  | notFound : RecoveryResultReq req

inductive SelectionResult where
  | selected : (req : FirstReturnRequest (Fin 8)) → RecoveryResultReq req → SelectionResult
  | noMatch : SelectionResult

def selectSingle (target : FirstReturnRequest (Fin 8)) (ep : Episode (Fin 8)) :
    SelectionResult :=
  if hreq : ep.request = target then
    match ep.result with
    | .established h => .selected ep.request (.found h)
    | .refuted _ => .noMatch
    | .unresolved => .noMatch
  else
    .noMatch

theorem T9_select_single_unresolved (i : Fin 8) :
    selectSingle (req_n8 i) (episode_unresolved i) = .noMatch := by
  unfold selectSingle episode_unresolved
  rfl

#print axioms T9_select_single_unresolved

/-! ============================================================
    T10: Recursive current-style selection
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

theorem T10_select_empty (i : Fin 8) :
    selectFromList (req_n8 i) [] = .noMatch := rfl

#print axioms T10_select_empty

/-! ============================================================
    T11: selectApplicable
============================================================ -/

def selectApplicable (hist : History (Fin 8)) (target : FirstReturnRequest (Fin 8)) :
    SelectionResult :=
  selectFromList target hist.episodes

theorem T11_select_applicable_empty (i : Fin 8) :
    selectApplicable history_empty (req_n8 i) = .noMatch := by
  unfold selectApplicable selectFromList history_empty
  rfl

#print axioms T11_select_applicable_empty

/-! ============================================================
    T12: consumeSelection selected-case
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

theorem T12_consume_noMatch (i : Fin 8) :
    consumeSelection .noMatch (req_n8 i) = .unresolved := rfl

#print axioms T12_consume_noMatch

/-! ============================================================
    T13: consumeSelection noMatch
============================================================ -/

theorem T13_consume_noMatch_explicit (i : Fin 8) :
    consumeSelection (SelectionResult.noMatch) (req_n8 i) = .unresolved := rfl

#print axioms T13_consume_noMatch_explicit

/-! ============================================================
    T14: Target-indexed SelectionResult candidate
============================================================ -/

inductive SelectionResultReq (target : FirstReturnRequest (Fin 8)) where
  | selected : FirstPositiveReturnAt target.step target.state target.k → SelectionResultReq target
  | noMatch : SelectionResultReq target

def consumeSelectionReq (s : SelectionResultReq (req_n8 i)) :
    FirstReturnResult (req_n8 i) :=
  match s with
  | .selected h => .established h
  | .noMatch => .unresolved

theorem T14_consume_req_noMatch (i : Fin 8) :
    consumeSelectionReq (SelectionResultReq.noMatch : SelectionResultReq (req_n8 i)) = .unresolved := rfl

#print axioms T14_consume_req_noMatch

/-! ============================================================
    T15: Target-indexed single-cell selector
============================================================ -/

def selectSingleReq (target : FirstReturnRequest (Fin 8)) (ep : Episode (Fin 8)) :
    SelectionResultReq target :=
  if hreq : ep.request = target then
    match ep.result with
    | .established h => .selected (by rw [hreq] at h; exact h)
    | .refuted _ => .noMatch
    | .unresolved => .noMatch
  else
    .noMatch

theorem T15_select_single_req_unresolved (i : Fin 8) :
    selectSingleReq (req_n8 i) (episode_unresolved i) = .noMatch := by
  unfold selectSingleReq episode_unresolved
  rfl

#print axioms T15_select_single_req_unresolved

/-! ============================================================
    T16: Target-indexed recursive selector
============================================================ -/

def selectFromListReq (target : FirstReturnRequest (Fin 8)) (episodes : List (Episode (Fin 8))) :
    SelectionResultReq target :=
  match episodes with
  | [] => .noMatch
  | ep :: rest =>
    if hreq : ep.request = target then
      match ep.result with
      | .established h => .selected (by rw [hreq] at h; exact h)
      | .refuted _ => selectFromListReq target rest
      | .unresolved => selectFromListReq target rest
    else
      selectFromListReq target rest

theorem T16_select_req_empty (i : Fin 8) :
    selectFromListReq (req_n8 i) [] = .noMatch := rfl

#print axioms T16_select_req_empty

/-! ============================================================
    T17: Empty target-indexed path
============================================================ -/

theorem T17_empty_req (i : Fin 8) :
    selectFromListReq (req_n8 i) history_empty.episodes = .noMatch := by
  unfold selectFromListReq history_empty
  rfl

#print axioms T17_empty_req

/-! ============================================================
    T18: Unresolved target-indexed path
============================================================ -/

def history_unresolved (i : Fin 8) : History (Fin 8) where
  episodes := [episode_unresolved i]

theorem T18_unresolved_req (i : Fin 8) :
    selectFromListReq (req_n8 i) (history_unresolved i).episodes = .noMatch := by
  unfold selectFromListReq history_unresolved episode_unresolved
  rfl

#print axioms T18_unresolved_req

/-! ============================================================
    T19: Irrelevant-first target-indexed path
============================================================ -/

def history_irrelevant_first (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    History (Fin 8) where
  episodes := [
    { request := req_n8 ⟨0, by decide⟩, result := .unresolved },
    { request := req_n8 i, result := .established hQ }
  ]

theorem T19_irrelevant_first_req (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8)
    (hne : i ≠ ⟨0, by decide⟩) :
    selectFromListReq (req_n8 i) (history_irrelevant_first i hQ).episodes =
      .selected hQ := by
  unfold selectFromListReq history_irrelevant_first
  rfl

#print axioms T19_irrelevant_first_req

/-! ============================================================
    T20: Concrete source theorem
============================================================ -/

#print axioms n8_index_first_return

end LearningConsumerL3T
