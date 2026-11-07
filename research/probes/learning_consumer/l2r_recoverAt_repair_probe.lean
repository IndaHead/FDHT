import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4

open KernelExprContext

namespace LearningConsumerL2R

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# L₂-R recoverAt Repair / Falsification Probe

Attempts to reformulate recoverAt to remove sorryAx while preserving
all required L₂ semantics.

This is a diagnostic probe. It does not modify L₂. It tests whether
a clean equivalent encoding exists.
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

inductive RecoveryResult (i : Fin 8) where
  | found : FirstPositiveReturnAt eightThreadCycle.toFun i 8 → RecoveryResult i
  | notFound : RecoveryResult i

/-! ============================================================
    DIRTY CONTROL: Original recoverAt
============================================================ -/

def recover_control (i : Fin 8) (hist : History (Fin 8)) (idx : Fin hist.episodes.length) :
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

def history_unresolved (i : Fin 8) : History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .unresolved }]

theorem control_unresolved_dirty (i : Fin 8) :
    recover_control i (history_unresolved i) ⟨0, by simp [history_unresolved]⟩ = .notFound := by
  unfold recover_control history_unresolved
  simp only [List.get_cons_zero]
  rfl

#print axioms control_unresolved_dirty

/-! ============================================================
    VARIANT A: Extract episode first
============================================================ -/

def episodeAt (hist : History (Fin 8)) (idx : Fin hist.episodes.length) :
    Episode (Fin 8) :=
  hist.episodes.get idx

theorem variant_a_episodeAt (i : Fin 8) :
    (episodeAt (history_unresolved i) ⟨0, by simp [history_unresolved]⟩).result = .unresolved := by
  unfold episodeAt history_unresolved
  simp only [List.get_cons_zero]
  rfl

#print axioms variant_a_episodeAt

/-! ============================================================
    VARIANT B: Result-only classification
============================================================ -/

inductive ResultTag where
  | isEstablished
  | isRefuted
  | isUnresolved

def classifyResult {X : Type} {req : FirstReturnRequest X} (r : FirstReturnResult req) : ResultTag :=
  match r with
  | .established _ => .isEstablished
  | .refuted _ => .isRefuted
  | .unresolved => .isUnresolved

theorem variant_b_classify (i : Fin 8) :
    classifyResult (episodeAt (history_unresolved i) ⟨0, by simp [history_unresolved]⟩).result = .isUnresolved := by
  unfold classifyResult episodeAt history_unresolved
  simp only [List.get_cons_zero]
  rfl

#print axioms variant_b_classify

/-! ============================================================
    VARIANT C: Parametric established extraction with external equality
============================================================ -/

def recoverEstablishedGivenEq (i : Fin 8) (ep : Episode (Fin 8))
    (hreq : ep.request = req_n8 i) :
    RecoveryResult i :=
  match ep.result with
  | .established h => .found (by rw [hreq] at h; exact h)
  | .refuted _ => .notFound
  | .unresolved => .notFound

theorem variant_c_unresolved (i : Fin 8) :
    recoverEstablishedGivenEq i (episodeAt (history_unresolved i) ⟨0, by simp [history_unresolved]⟩)
      (by simp [episodeAt, history_unresolved]) = .notFound := by
  unfold recoverEstablishedGivenEq episodeAt history_unresolved
  simp only [List.get_cons_zero]
  rfl

#print axioms variant_c_unresolved

/-! ============================================================
    VARIANT D: Request-indexed recovery
============================================================ -/

inductive RecoveryResultReq (req : FirstReturnRequest (Fin 8)) where
  | found : FirstPositiveReturnAt req.step req.state req.k → RecoveryResultReq req
  | notFound : RecoveryResultReq req

def recoverReqIndexed (ep : Episode (Fin 8)) : RecoveryResultReq ep.request :=
  match ep.result with
  | .established h => .found h
  | .refuted _ => .notFound
  | .unresolved => .notFound

theorem variant_d_unresolved (i : Fin 8) :
    recoverReqIndexed (episodeAt (history_unresolved i) ⟨0, by simp [history_unresolved]⟩) = .notFound := by
  unfold recoverReqIndexed episodeAt history_unresolved
  simp only [List.get_cons_zero]
  rfl

#print axioms variant_d_unresolved

/-! ============================================================
    VARIANT E: Two-stage recovery (episode-local then transport)
============================================================ -/

def recoverLocal (ep : Episode (Fin 8)) : RecoveryResultReq ep.request :=
  match ep.result with
  | .established h => .found h
  | .refuted _ => .notFound
  | .unresolved => .notFound

def transportRecovery (i : Fin 8) (ep : Episode (Fin 8))
    (hreq : ep.request = req_n8 i)
    (r : RecoveryResultReq ep.request) :
    RecoveryResult i :=
  match r with
  | .found h => .found (by rw [hreq] at h; exact h)
  | .notFound => .notFound

def recoverTwoStage (i : Fin 8) (hist : History (Fin 8)) (idx : Fin hist.episodes.length) :
    RecoveryResult i :=
  let ep := hist.episodes.get idx
  if hreq : ep.request = req_n8 i then
    transportRecovery i ep hreq (recoverLocal ep)
  else
    .notFound

theorem variant_e_unresolved (i : Fin 8) :
    recoverTwoStage i (history_unresolved i) ⟨0, by simp [history_unresolved]⟩ = .notFound := by
  unfold recoverTwoStage transportRecovery recoverLocal history_unresolved
  simp only [List.get_cons_zero]
  rfl

#print axioms variant_e_unresolved

/-! ============================================================
    PARAMETRIC POSITIVE TEST
============================================================ -/

def history_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .established hQ }]

theorem variant_d_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    recoverReqIndexed (episodeAt (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩) =
      .found hQ := by
  unfold recoverReqIndexed episodeAt history_parametric
  simp only [List.get_cons_zero]
  rfl

#print axioms variant_d_parametric

theorem variant_e_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    recoverTwoStage i (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩ = .found hQ := by
  unfold recoverTwoStage transportRecovery recoverLocal history_parametric
  simp only [List.get_cons_zero]
  rfl

#print axioms variant_e_parametric

/-! ============================================================
    CONCRETE POSITIVE TEST
============================================================ -/

def history_concrete (i : Fin 8) : History (Fin 8) where
  episodes := [{ request := req_n8 i, result := .established (n8_index_first_return i) }]

theorem variant_d_concrete (i : Fin 8) :
    recoverReqIndexed (episodeAt (history_concrete i) ⟨0, by simp [history_concrete]⟩) =
      .found (n8_index_first_return i) := by
  unfold recoverReqIndexed episodeAt history_concrete
  simp only [List.get_cons_zero]
  rfl

#print axioms variant_d_concrete

theorem variant_e_concrete (i : Fin 8) :
    recoverTwoStage i (history_concrete i) ⟨0, by simp [history_concrete]⟩ =
      .found (n8_index_first_return i) := by
  unfold recoverTwoStage transportRecovery recoverLocal history_concrete
  simp only [List.get_cons_zero]
  rfl

#print axioms variant_e_concrete

/-! ============================================================
    LATER CONSUMER TEST
============================================================ -/

def laterFromRecovery (i : Fin 8) (hist : History (Fin 8)) (idx : Fin hist.episodes.length) :
    Episode (Fin 8) :=
  match recoverTwoStage i hist idx with
  | .found h => { request := req_n8 i, result := .established h }
  | .notFound => { request := req_n8 i, result := .unresolved }

theorem later_unresolved (i : Fin 8) :
    (laterFromRecovery i (history_unresolved i) ⟨0, by simp [history_unresolved]⟩).result = .unresolved := by
  unfold laterFromRecovery
  rw [variant_e_unresolved]
  rfl

#print axioms later_unresolved

theorem later_parametric (i : Fin 8) (hQ : FirstPositiveReturnAt eightThreadCycle.toFun i 8) :
    (laterFromRecovery i (history_parametric i hQ) ⟨0, by simp [history_parametric]⟩).result =
      .established hQ := by
  unfold laterFromRecovery
  rw [variant_e_parametric]
  rfl

#print axioms later_parametric

theorem later_concrete (i : Fin 8) :
    (laterFromRecovery i (history_concrete i) ⟨0, by simp [history_concrete]⟩).result =
      .established (n8_index_first_return i) := by
  unfold laterFromRecovery
  rw [variant_e_concrete]
  rfl

#print axioms later_concrete

/-! ============================================================
    CONTAINER KNOCKOUT
============================================================ -/

def history_removed (i : Fin 8) : History (Fin 8) where
  episodes := []

theorem removed_has_no_index (i : Fin 8) :
    (history_removed i).episodes.length = 0 := by
  simp [history_removed]

#print axioms removed_has_no_index

end LearningConsumerL2R
