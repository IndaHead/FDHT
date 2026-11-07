import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4

open KernelExprContext

namespace LearningConsumerL2T

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# L₂-T SorryAx Boundary Bisection Audit

Diagnostic probe to identify where sorryAx first enters the dependency
chain used by L₂.

This is a diagnostic probe. It does not modify L₂. It does not repair L₂.
It only measures and classifies.
-/

/-! ============================================================
    T0: Trivial baseline
============================================================ -/

theorem T0_true : True := trivial

#print axioms T0_true

/-! ============================================================
    T1: Request structure
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
    T2: Result packaging
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

theorem T2_unresolved_constructor (i : Fin 8) :
    (FirstReturnResult.unresolved : FirstReturnResult (req_n8 i)).1 = () := rfl

#print axioms T2_unresolved_constructor

/-! ============================================================
    T3: Unresolved episode
============================================================ -/

structure Episode (X : Type) where
  request : FirstReturnRequest X
  result  : FirstReturnResult request

def historical_unresolved (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result  := .unresolved

theorem T3_unresolved_episode (i : Fin 8) :
    (historical_unresolved i).result = .unresolved := rfl

#print axioms T3_unresolved_episode

/-! ============================================================
    T4: Unresolved history
============================================================ -/

structure History (X : Type) where
  episodes : List (Episode X)

def history_unresolved (i : Fin 8) : History (Fin 8) where
  episodes := [historical_unresolved i]

theorem T4_unresolved_history_length (i : Fin 8) :
    (history_unresolved i).episodes.length = 1 := rfl

#print axioms T4_unresolved_history_length

/-! ============================================================
    T5: List.get
============================================================ -/

theorem T5_list_get (i : Fin 8) :
    ((history_unresolved i).episodes.get ⟨0, by simp [history_unresolved]⟩).result = .unresolved := rfl

#print axioms T5_list_get

/-! ============================================================
    T6: RecoveryResult
============================================================ -/

inductive RecoveryResult (i : Fin 8) where
  | found : FirstPositiveReturnAt eightThreadCycle.toFun i 8 → RecoveryResult i
  | notFound : RecoveryResult i

theorem T6_notFound (i : Fin 8) :
    (RecoveryResult.notFound : RecoveryResult i) = .notFound := rfl

#print axioms T6_notFound

/-! ============================================================
    T7: Request equality
============================================================ -/

theorem T7_request_equality (i : Fin 8) :
    (historical_unresolved i).request = req_n8 i := rfl

#print axioms T7_request_equality

/-! ============================================================
    T8: Dependent transport
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
    T9: recoverAt unresolved path
============================================================ -/

def recoverAt (i : Fin 8) (hist : History (Fin 8)) (idx : Fin hist.episodes.length) :
    RecoveryResult i :=
  let ep := hist.episodes.get idx
  match ep.result with
  | .established h =>
    if hreq : ep.request = req_n8 i then
      .found (by rw [hreq] at h; exact h)
    else
      .notFound
  | .refuted _ => .notFound
  | .unresolved => .notFound

theorem T9_recoverAt_unresolved (i : Fin 8) :
    recoverAt i (history_unresolved i) ⟨0, by simp [history_unresolved]⟩ = .notFound := by
  unfold recoverAt history_unresolved historical_unresolved
  simp only [List.get_cons_zero]
  rfl

#print axioms T9_recoverAt_unresolved

/-! ============================================================
    T10: Parametric established episode
============================================================ -/

def parametric_established (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    Episode (Fin 8) where
  request := req_n8 i
  result  := .established hQ

theorem T10_parametric_established (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    (parametric_established i hQ).result = .established hQ := rfl

#print axioms T10_parametric_established

/-! ============================================================
    T11: Parametric recoverAt
============================================================ -/

def history_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    History (Fin 8) where
  episodes := [parametric_established i hQ]

theorem T11_parametric_recoverAt (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    recoverAt i (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩ = .found hQ := by
  unfold recoverAt history_parametric parametric_established
  simp only [List.get_cons_zero]
  rfl

#print axioms T11_parametric_recoverAt

/-! ============================================================
    T12: n8_index_first_return direct
============================================================ -/

#print axioms n8_index_first_return

/-! ============================================================
    T13: Concrete established history
============================================================ -/

def concrete_established (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result  := .established (n8_index_first_return i)

theorem T13_concrete_established (i : Fin 8) :
    (concrete_established i).result = .established (n8_index_first_return i) := rfl

#print axioms T13_concrete_established

/-! ============================================================
    T14: Concrete recoverAt
============================================================ -/

def history_concrete (i : Fin 8) : History (Fin 8) where
  episodes := [concrete_established i]

theorem T14_concrete_recoverAt (i : Fin 8) :
    recoverAt i (history_concrete i) ⟨0, by simp [history_concrete]⟩ =
      .found (n8_index_first_return i) := by
  unfold recoverAt history_concrete concrete_established
  simp only [List.get_cons_zero]
  rfl

#print axioms T14_concrete_recoverAt

/-! ============================================================
    T15: Later parametric consumer
============================================================ -/

def later_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    Episode (Fin 8) :=
  match recoverAt i (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩ with
  | .found h => { request := req_n8 i, result := .established h }
  | .notFound => { request := req_n8 i, result := .unresolved }

theorem T15_later_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    (later_parametric i hQ).result = .established hQ := by
  unfold later_parametric
  rw [T11_parametric_recoverAt]
  rfl

#print axioms T15_later_parametric

/-! ============================================================
    T16: Later concrete consumer
============================================================ -/

def later_concrete (i : Fin 8) : Episode (Fin 8) :=
  match recoverAt i (history_concrete i) ⟨0, by simp [history_concrete]⟩ with
  | .found h => { request := req_n8 i, result := .established h }
  | .notFound => { request := req_n8 i, result := .unresolved }

theorem T16_later_concrete (i : Fin 8) :
    (later_concrete i).result = .established (n8_index_first_return i) := by
  unfold later_concrete
  rw [T14_concrete_recoverAt]
  rfl

#print axioms T16_later_concrete

end LearningConsumerL2T
