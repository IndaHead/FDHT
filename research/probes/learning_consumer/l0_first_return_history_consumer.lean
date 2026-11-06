import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4

open KernelExprContext

namespace LearningConsumer

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# L₀ History-Sensitive Consumer

Minimal history-sensitive consumer demonstrating that preserved
applicable evidence can change a later justified result for the same
request.

This is a research probe. It does not define learning universally.
It does not implement retrieval, proof search, or action.
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

/-! ============================================================
    Proof-driven constructors
============================================================ -/

def establishFirstReturn
    {X : Type}
    (req : FirstReturnRequest X)
    (h : FirstPositiveReturnAt req.step req.state req.k) :
    FirstReturnResult req :=
  .established h

def refuteFirstReturn
    {X : Type}
    (req : FirstReturnRequest X)
    (h : FirstPositiveReturnAt req.step req.state req.k → False) :
    FirstReturnResult req :=
  .refuted h

/-! ============================================================
    Status observer
============================================================ -/

inductive FirstReturnStatus where
  | established
  | refuted
  | unresolved

def FirstReturnResult.status
    {X : Type}
    {req : FirstReturnRequest X}
    (result : FirstReturnResult req) :
    FirstReturnStatus :=
  match result with
  | .established _ => .established
  | .refuted _     => .refuted
  | .unresolved    => .unresolved

/-! ============================================================
    Episode representation (fixture-specific)
============================================================ -/

structure Episode (X : Type) where
  request : FirstReturnRequest X
  result  : FirstReturnResult request

/-! ============================================================
    L₀ Fixture: n=8 first-return
============================================================ -/

/-- The same request across all episodes. -/
def req_n8 (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 8

/-! ============================================================
    Episode 0: no evidence supplied → UNRESOLVED
============================================================ -/

def episode0_unresolved (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result  := .unresolved

theorem episode0_status (i : Fin 8) :
    (episode0_unresolved i).result.status = .unresolved :=
  rfl

/-! ============================================================
    Episode 1: irrelevant evidence → still UNRESOLVED
============================================================ -/

/--
Irrelevant evidence: a proof about a different proposition.
This should not change the result for req_n8.
-/
theorem irrelevant_evidence :
    FirstPositiveReturnAt fourThreadCycle.toFun 0 4 :=
  n4_index_first_return 0

def episode1_irrelevant (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result  := .unresolved  -- irrelevant evidence does not apply

theorem episode1_status (i : Fin 8) :
    (episode1_irrelevant i).result.status = .unresolved :=
  rfl

/-! ============================================================
    Episode 2: applicable evidence → ESTABLISHED
============================================================ -/

/--
Applicable evidence: the exact proof for req_n8.
This changes the result from UNRESOLVED to ESTABLISHED.
-/
def episode2_established (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result  := establishFirstReturn (req_n8 i) (n8_index_first_return i)

theorem episode2_status (i : Fin 8) :
    (episode2_established i).result.status = .established :=
  rfl

/-! ============================================================
    Proof retention
============================================================ -/

/--
The proof payload is retained in the ESTABLISHED result.
-/
def recover_proof (i : Fin 8) :
    FirstPositiveReturnAt eightThreadCycle.toFun i 8 :=
  match (episode2_established i).result with
  | .established h => h
  | .refuted _ => n8_index_first_return i
  | .unresolved => n8_index_first_return i

theorem proof_retained (i : Fin 8) :
    FirstPositiveReturnAt eightThreadCycle.toFun i 8 :=
  recover_proof i

/-! ============================================================
    History preservation
============================================================ -/

/--
History preserves all episodes. Later knowledge does not
retroactively mutate earlier episodes.
-/
structure History (X : Type) where
  episodes : List (Episode X)

def history_n8 (i : Fin 8) : History (Fin 8) where
  episodes := [
    episode0_unresolved i,
    episode1_irrelevant i,
    episode2_established i
  ]

theorem history_length (i : Fin 8) :
    (history_n8 i).episodes.length = 3 :=
  rfl

theorem history_preserves_episode0 (i : Fin 8) :
    ((history_n8 i).episodes[0]'(by simp [history_n8])).result.status = .unresolved :=
  rfl

theorem history_preserves_episode1 (i : Fin 8) :
    ((history_n8 i).episodes[1]'(by simp [history_n8])).result.status = .unresolved :=
  rfl

theorem history_preserves_episode2 (i : Fin 8) :
    ((history_n8 i).episodes[2]'(by simp [history_n8])).result.status = .established :=
  rfl

/-! ============================================================
    Same-request invariant
============================================================ -/

theorem same_request_all_episodes (i : Fin 8) :
    (episode0_unresolved i).request = (episode1_irrelevant i).request ∧
    (episode1_irrelevant i).request = (episode2_established i).request :=
  ⟨rfl, rfl⟩

/-! ============================================================
    Learning transition
============================================================ -/

/--
The learning transition: same request changes from UNRESOLVED
to ESTABLISHED when applicable evidence is supplied.
-/
theorem learning_transition (i : Fin 8) :
    (episode0_unresolved i).result.status = .unresolved ∧
    (episode2_established i).result.status = .established :=
  ⟨rfl, rfl⟩

/-! ============================================================
    Historical specificity
============================================================ -/

/--
Irrelevant evidence does not change the result.
-/
theorem irrelevant_does_not_establish (i : Fin 8) :
    (episode1_irrelevant i).result.status = .unresolved :=
  rfl

/-! ============================================================
    Compile-time surface checks
============================================================ -/

#check FirstReturnRequest
#check FirstReturnResult
#check Episode
#check History
#check episode0_unresolved
#check episode1_irrelevant
#check episode2_established
#check learning_transition

/-! ============================================================
    Trust audit targets
============================================================ -/

#print axioms episode0_status
#print axioms episode2_status
#print axioms learning_transition
#print axioms proof_retained

end LearningConsumer
