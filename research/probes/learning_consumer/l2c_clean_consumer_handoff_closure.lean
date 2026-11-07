import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4

open KernelExprContext

namespace LearningConsumerL2C

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# L₂-C Clean Consumer Handoff Closure

Tests whether the clean Variant D request-indexed recovery can be consumed
by the later consumer with a clean end-to-end trust footprint.

Key principle: preserve request information until the handoff actually
requires transport.
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
    VARIANT D: Request-indexed recovery (from L₂-R)
============================================================ -/

inductive RecoveryResultReq (req : FirstReturnRequest (Fin 8)) where
  | found : FirstPositiveReturnAt req.step req.state req.k → RecoveryResultReq req
  | notFound : RecoveryResultReq req

def episodeAt (hist : History (Fin 8)) (idx : Fin hist.episodes.length) :
    Episode (Fin 8) :=
  hist.episodes.get idx

def recoverReqIndexed (ep : Episode (Fin 8)) : RecoveryResultReq ep.request :=
  match ep.result with
  | .established h => .found h
  | .refuted _ => .notFound
  | .unresolved => .notFound

/-! ============================================================
    REQUEST-INDEXED CONSUMER
    Consumes recovery result without transport
============================================================ -/

def consumeRecovered {req : FirstReturnRequest (Fin 8)}
    (r : RecoveryResultReq req) : FirstReturnResult req :=
  match r with
  | .found h => .established h
  | .notFound => .unresolved

/-! ============================================================
    UNRESOLVED PATH
============================================================ -/

def history_unresolved (i : Fin 8) : History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .unresolved }]

theorem unresolved_recovery (i : Fin 8) :
    recoverReqIndexed (episodeAt (history_unresolved i) ⟨0, by simp [history_unresolved]⟩) = .notFound := by
  unfold recoverReqIndexed episodeAt history_unresolved
  simp only [List.get_cons_zero]
  rfl

#print axioms unresolved_recovery

theorem unresolved_consumer (i : Fin 8) :
    consumeRecovered (recoverReqIndexed (episodeAt (history_unresolved i) ⟨0, by simp [history_unresolved]⟩)) =
      .unresolved := by
  unfold consumeRecovered
  rw [unresolved_recovery]
  rfl

#print axioms unresolved_consumer

/-! ============================================================
    PARAMETRIC POSITIVE PATH
============================================================ -/

def history_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .established hQ }]

theorem parametric_recovery (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    recoverReqIndexed (episodeAt (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩) =
      .found hQ := by
  unfold recoverReqIndexed episodeAt history_parametric
  simp only [List.get_cons_zero]
  rfl

#print axioms parametric_recovery

theorem parametric_consumer (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    consumeRecovered (recoverReqIndexed (episodeAt (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩)) =
      .established hQ := by
  unfold consumeRecovered
  rw [parametric_recovery]
  rfl

#print axioms parametric_consumer

/-! ============================================================
    CONCRETE POSITIVE PATH
============================================================ -/

def history_concrete (i : Fin 8) : History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .established (n8_index_first_return i) }]

theorem concrete_recovery (i : Fin 8) :
    recoverReqIndexed (episodeAt (history_concrete i) ⟨0, by simp [history_concrete]⟩) =
      .found (n8_index_first_return i) := by
  unfold recoverReqIndexed episodeAt history_concrete
  simp only [List.get_cons_zero]
  rfl

#print axioms concrete_recovery

theorem concrete_consumer (i : Fin 8) :
    consumeRecovered (recoverReqIndexed (episodeAt (history_concrete i) ⟨0, by simp [history_concrete]⟩)) =
      .established (n8_index_first_return i) := by
  unfold consumeRecovered
  rw [concrete_recovery]
  rfl

#print axioms concrete_consumer

/-! ============================================================
    END-TO-END CONSUMER
    Combines recovery and consumption
============================================================ -/

def laterConsumer (i : Fin 8) (hist : History (Fin 8)) (idx : Fin hist.episodes.length) :
    FirstReturnResult (episodeAt hist idx).request :=
  consumeRecovered (recoverReqIndexed (episodeAt hist idx))

theorem later_unresolved (i : Fin 8) :
    laterConsumer i (history_unresolved i) ⟨0, by simp [history_unresolved]⟩ = .unresolved := by
  unfold laterConsumer
  exact unresolved_consumer i

#print axioms later_unresolved

theorem later_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    laterConsumer i (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩ = .established hQ := by
  unfold laterConsumer
  exact parametric_consumer i hQ

#print axioms later_parametric

theorem later_concrete (i : Fin 8) :
    laterConsumer i (history_concrete i) ⟨0, by simp [history_concrete]⟩ =
      .established (n8_index_first_return i) := by
  unfold laterConsumer
  exact concrete_consumer i

#print axioms later_concrete

/-! ============================================================
    PROOF RETENTION
============================================================ -/

theorem proof_retained_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    laterConsumer i (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩ = .established hQ :=
  later_parametric i hQ

#print axioms proof_retained_parametric

theorem proof_retained_concrete (i : Fin 8) :
    laterConsumer i (history_concrete i) ⟨0, by simp [history_concrete]⟩ =
      .established (n8_index_first_return i) :=
  later_concrete i

#print axioms proof_retained_concrete

/-! ============================================================
    CONTAINER KNOCKOUT
============================================================ -/

def history_removed (i : Fin 8) : History (Fin 8) where
  episodes := []

theorem removed_has_no_index (i : Fin 8) :
    (history_removed i).episodes.length = 0 := by
  simp [history_removed]

#print axioms removed_has_no_index

/-! ============================================================
    SAME-REQUEST INVARIANT
============================================================ -/

theorem same_request_unresolved (i : Fin 8) :
    (episodeAt (history_unresolved i) ⟨0, by simp [history_unresolved]⟩).request = req_n8 i := by
  unfold episodeAt history_unresolved
  simp only [List.get_cons_zero]
  rfl

#print axioms same_request_unresolved

theorem same_request_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    (episodeAt (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩).request = req_n8 i := by
  unfold episodeAt history_parametric
  simp only [List.get_cons_zero]
  rfl

#print axioms same_request_parametric

theorem same_request_concrete (i : Fin 8) :
    (episodeAt (history_concrete i) ⟨0, by simp [history_concrete]⟩).request = req_n8 i := by
  unfold episodeAt history_concrete
  simp only [List.get_cons_zero]
  rfl

#print axioms same_request_concrete

end LearningConsumerL2C
