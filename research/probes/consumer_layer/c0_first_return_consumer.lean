import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4
import FDHTPermutationRotation
import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC0

/-!
# C₀ — Microscopic First-Return Query Consumer

Domain-specific first-return consumer.
Probe-local only. Not a generic Consumer API.
-/

/-! ============================================================
    Request type
============================================================ -/

structure FirstReturnRequest (X : Type) where
  step  : X → X
  state : X
  k     : Nat

/-! ============================================================
    Result type
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
    R1: ESTABLISHED (n=8 index k=8)
============================================================ -/

def req_n8_yes (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 8

def result_n8_yes (i : Fin 8) : FirstReturnResult (req_n8_yes i) :=
  establishFirstReturn (req_n8_yes i) (n8_index_first_return i)

/-! ============================================================
    R2: REFUTED (n=8 index k=4)
============================================================ -/

def req_n8_wrong (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 4

theorem n8_not_first_return_4
    (i : Fin 8) :
    ¬ FirstPositiveReturnAt eightThreadCycle.toFun i 4 := by
  intro h4
  have h8 := n8_index_first_return i
  have heq : (4 : Nat) = 8 :=
    firstPositiveReturnAt_unique
      (step := eightThreadCycle.toFun)
      (x := i)
      (k := 4)
      (m := 8)
      h4
      h8
  omega

def result_n8_wrong (i : Fin 8) : FirstReturnResult (req_n8_wrong i) :=
  refuteFirstReturn (req_n8_wrong i) (n8_not_first_return_4 i)

/-! ============================================================
    R3: RAW ESTABLISHED
============================================================ -/

def req_n8_raw
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstReturnRequest (ThreadFamily resolve 8) where
  step  := permuteThreadFamily resolve eightThreadCycle
  state := familyUnequal resolve 8 h
  k     := 8

def result_n8_raw
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstReturnResult (req_n8_raw resolve h) :=
  establishFirstReturn
    (req_n8_raw resolve h)
    (familyUnequal_n8_raw_projected_first_return_contrast resolve h).1

/-! ============================================================
    R4: PROJECTED REFUTED
============================================================ -/

def req_n8_projected_wrong
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstReturnRequest (Fin 8 → TrajectoryBoundary resolve) where
  step  := ThreadPermutation.projectedAction resolve eightThreadCycle
  state := projectThreadFamily resolve (familyUnequal resolve 8 h)
  k     := 8

theorem n8_projected_not_first_return_8
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    ¬ FirstPositiveReturnAt
        (ThreadPermutation.projectedAction resolve eightThreadCycle)
        (projectThreadFamily resolve (familyUnequal resolve 8 h))
        8 := by
  intro h8
  have h1 := (familyUnequal_n8_raw_projected_first_return_contrast resolve h).2
  have heq : (8 : Nat) = 1 :=
    firstPositiveReturnAt_unique
      (step := ThreadPermutation.projectedAction resolve eightThreadCycle)
      (x := projectThreadFamily resolve (familyUnequal resolve 8 h))
      (k := 8)
      (m := 1)
      h8
      h1
  omega

def result_n8_projected_wrong
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstReturnResult (req_n8_projected_wrong resolve h) :=
  refuteFirstReturn
    (req_n8_projected_wrong resolve h)
    (n8_projected_not_first_return_8 resolve h)

/-! ============================================================
    R5: UNRESOLVED
============================================================ -/

def req_unresolved_n4_halfpower_raw
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 4) :
    FirstReturnRequest (ThreadFamily resolve 4) where
  step  := permuteThreadFamily resolve fourThreadCycle
  state := familyUnequal resolve 4 h
  k     := 2

def result_unresolved_n4_halfpower_raw
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 4) :
    FirstReturnResult (req_unresolved_n4_halfpower_raw resolve h) :=
  .unresolved

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
    : FirstReturnResult req → FirstReturnStatus
  | .established _ => .established
  | .refuted _     => .refuted
  | .unresolved    => .unresolved

/-! ============================================================
    Proof retention
============================================================ -/

def has_established_proof
    {X : Type}
    {req : FirstReturnRequest X}
    (r : FirstReturnResult req) : Prop :=
  match r with
  | .established _ => True
  | .refuted _     => False
  | .unresolved    => False

def has_refuted_proof
    {X : Type}
    {req : FirstReturnRequest X}
    (r : FirstReturnResult req) : Prop :=
  match r with
  | .established _ => False
  | .refuted _     => True
  | .unresolved    => False

theorem proof_retention_r1 (i : Fin 8) :
    has_established_proof (result_n8_yes i) :=
  trivial

theorem proof_retention_r2 (i : Fin 8) :
    has_refuted_proof (result_n8_wrong i) :=
  trivial

/-! ============================================================
    Status sequence
============================================================ -/

def status_sequence
    (i : Fin 8)
    (resolve : KernelExpr → Store → Location)
    (h8 : 1 < 8)
    (h4 : 1 < 4) :
    List FirstReturnStatus :=
  [
    (result_n8_yes i).status,
    (result_n8_wrong i).status,
    (result_n8_raw resolve h8).status,
    (result_n8_projected_wrong resolve h8).status,
    (result_unresolved_n4_halfpower_raw resolve h4).status
  ]

theorem status_sequence_expected
    (i : Fin 8)
    (resolve : KernelExpr → Store → Location)
    (h8 : 1 < 8)
    (h4 : 1 < 4) :
    status_sequence i resolve h8 h4 =
    [
      .established,
      .refuted,
      .established,
      .refuted,
      .unresolved
    ] :=
  rfl

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms n8_not_first_return_4
#print axioms n8_projected_not_first_return_8
#print axioms proof_retention_r1
#print axioms proof_retention_r2
#print axioms status_sequence_expected

end ConsumerC0
