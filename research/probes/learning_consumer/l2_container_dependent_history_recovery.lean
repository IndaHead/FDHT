import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4

open KernelExprContext

namespace LearningConsumerL2

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# L₂ Container-Dependent History Recovery

Adversarial refinement of L₁ demonstrating that proof recovery
depends on the actual historical container, not on fixture shortcuts.

Key properties:
- Recovery indexes the actual History container
- Non-established cells return none (no theorem fallback)
- Empty history has no valid index
- n8_index_first_return appears ONLY in historical fixture population
-/

/-! ============================================================
    Request and Result (recreated probe-locally)
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

def establishFirstReturn
    {X : Type}
    (req : FirstReturnRequest X)
    (h : FirstPositiveReturnAt req.step req.state req.k) :
    FirstReturnResult req :=
  .established h

/-! ============================================================
    Episode and History
============================================================ -/

structure Episode (X : Type) where
  request : FirstReturnRequest X
  result  : FirstReturnResult request

structure History (X : Type) where
  episodes : List (Episode X)

/-! ============================================================
    L₂ Fixture: n=8 first-return
============================================================ -/

def req_n8 (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 8

/-! ============================================================
    Historical episode containing established proof
    NOTE: n8_index_first_return appears ONLY here
============================================================ -/

/--
This episode is populated with the original theorem.
This is the ONLY place n8_index_first_return appears.
-/
def historical_established (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result  := establishFirstReturn (req_n8 i) (n8_index_first_return i)

/-! ============================================================
    Unresolved episode (no proof)
============================================================ -/

def historical_unresolved (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result  := .unresolved

/-! ============================================================
    Good history containing established episode
============================================================ -/

def history_good (i : Fin 8) : History (Fin 8) where
  episodes := [historical_established i]

/-! ============================================================
    Empty history
============================================================ -/

def history_empty : History (Fin 8) where
  episodes := []

/-! ============================================================
    History with only unresolved episode
============================================================ -/

def history_unresolved (i : Fin 8) : History (Fin 8) where
  episodes := [historical_unresolved i]

/-! ============================================================
    Container-dependent recovery result (parameterized by i)
============================================================ -/

inductive RecoveryResult (i : Fin 8) where
  | found : FirstPositiveReturnAt eightThreadCycle.toFun i 8 → RecoveryResult i
  | notFound : RecoveryResult i

/-! ============================================================
    Container-dependent recovery
    Returns RecoveryResult to represent honest success/failure
    NO theorem fallback in non-success branches
============================================================ -/

/--
Recover proof from actual historical container at explicit position.
Returns notFound if episode is not established.

NO theorem fallback. NO re-proving.
-/
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

/-! ============================================================
    Recovery from good history succeeds
============================================================ -/

theorem recovery_from_good_history (i : Fin 8) :
    recoverAt i (history_good i) ⟨0, by simp [history_good]⟩ =
      .found (n8_index_first_return i) := by
  unfold recoverAt history_good historical_established establishFirstReturn
  simp only [List.get_cons_zero]
  rfl

/-! ============================================================
    Empty history has no valid index
============================================================ -/

theorem empty_history_has_no_index :
    history_empty.episodes.length = 0 := by
  simp [history_empty]

/-! ============================================================
    Recovery from unresolved history fails
============================================================ -/

theorem recovery_from_unresolved_history (i : Fin 8) :
    recoverAt i (history_unresolved i) ⟨0, by simp [history_unresolved]⟩ = .notFound := by
  unfold recoverAt history_unresolved historical_unresolved
  simp only [List.get_cons_zero]
  rfl

/-! ============================================================
    Later episode from recovered proof
============================================================ -/

/--
Later episode constructed from proof recovered from history.
Does NOT directly reference n8_index_first_return.
-/
def later_episode_from_recovery (i : Fin 8) (hist : History (Fin 8))
    (idx : Fin hist.episodes.length) : Episode (Fin 8) :=
  match recoverAt i hist idx with
  | .found h => {
      request := req_n8 i
      result := establishFirstReturn (req_n8 i) h
    }
  | .notFound => {
      request := req_n8 i
      result := .unresolved
    }

/-! ============================================================
    Later episode from good history is established
============================================================ -/

theorem later_from_good_is_established (i : Fin 8) :
    (later_episode_from_recovery i (history_good i) ⟨0, by simp [history_good]⟩).result =
      .established (n8_index_first_return i) := by
  unfold later_episode_from_recovery
  rw [recovery_from_good_history]
  rfl

/-! ============================================================
    Later episode from unresolved history is unresolved
============================================================ -/

theorem later_from_unresolved_is_unresolved (i : Fin 8) :
    (later_episode_from_recovery i (history_unresolved i) ⟨0, by simp [history_unresolved]⟩).result =
      .unresolved := by
  unfold later_episode_from_recovery
  rw [recovery_from_unresolved_history]
  rfl

/-! ============================================================
    Removed evidence destroys recovery path
============================================================ -/

/--
Removing the established episode from history destroys the recovery path.
-/
def history_removed (i : Fin 8) : History (Fin 8) where
  episodes := []  -- evidence removed

theorem removed_evidence_has_no_index (i : Fin 8) :
    (history_removed i).episodes.length = 0 := by
  simp [history_removed]

/-! ============================================================
    Same-request invariant
============================================================ -/

theorem same_request (i : Fin 8) (hist : History (Fin 8)) (idx : Fin hist.episodes.length) :
    (later_episode_from_recovery i hist idx).request = req_n8 i := by
  unfold later_episode_from_recovery
  split <;> rfl

/-! ============================================================
    Compile-time surface checks
============================================================ -/

#check recoverAt
#check later_episode_from_recovery
#check recovery_from_good_history
#check recovery_from_unresolved_history
#check later_from_good_is_established
#check later_from_unresolved_is_unresolved

/-! ============================================================
    Trust audit targets
============================================================ -/

#print axioms recovery_from_good_history
#print axioms recovery_from_unresolved_history
#print axioms later_from_good_is_established
#print axioms later_from_unresolved_is_unresolved

end LearningConsumerL2
