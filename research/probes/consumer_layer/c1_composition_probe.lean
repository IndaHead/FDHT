import FDHTFirstPositiveReturn
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression4
import FDHTPermutationRotation
import AggregateFamilyTransform

open KernelExprContext

/-! Import C₀ definitions by duplicating the minimal required types.
    C₀ remains unchanged. C₁ reuses the same shapes. -/

namespace ConsumerC1

/-! ============================================================
    C₀ types (reused shapes, not imported to avoid coupling)
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

def refuteFirstReturn
    {X : Type}
    (req : FirstReturnRequest X)
    (h : FirstPositiveReturnAt req.step req.state req.k → False) :
    FirstReturnResult req :=
  .refuted h

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
    TASK 1 — Projected positive request
============================================================ -/

def req_n8_projected_yes
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstReturnRequest (Fin 8 → TrajectoryBoundary resolve) where
  step  := ThreadPermutation.projectedAction resolve eightThreadCycle
  state := projectThreadFamily resolve (familyUnequal resolve 8 h)
  k     := 1

def result_n8_projected_yes
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstReturnResult (req_n8_projected_yes resolve h) :=
  establishFirstReturn
    (req_n8_projected_yes resolve h)
    (familyUnequal_n8_raw_projected_first_return_contrast resolve h).2

/-! ============================================================
    TASK 2 — Raw established result (reused shape)
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
    TASK 3 — Typed composition
============================================================ -/

structure FirstReturnPair
    {X Y : Type}
    (leftReq : FirstReturnRequest X)
    (rightReq : FirstReturnRequest Y) where
  left  : FirstReturnResult leftReq
  right : FirstReturnResult rightReq

def n8_raw_projected_pair
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstReturnPair (req_n8_raw resolve h) (req_n8_projected_yes resolve h) where
  left  := result_n8_raw resolve h
  right := result_n8_projected_yes resolve h

/-! ============================================================
    TASK 4 — Proof payloads survive
============================================================ -/

theorem extract_raw_proof
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstPositiveReturnAt
      (permuteThreadFamily resolve eightThreadCycle)
      (familyUnequal resolve 8 h)
      8 :=
  (familyUnequal_n8_raw_projected_first_return_contrast resolve h).1

theorem extract_projected_proof
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstPositiveReturnAt
      (ThreadPermutation.projectedAction resolve eightThreadCycle)
      (projectThreadFamily resolve (familyUnequal resolve 8 h))
      1 :=
  (familyUnequal_n8_raw_projected_first_return_contrast resolve h).2

theorem raw_proof_recovered
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstPositiveReturnAt
      (permuteThreadFamily resolve eightThreadCycle)
      (familyUnequal resolve 8 h)
      8 :=
  extract_raw_proof resolve h

theorem projected_proof_recovered
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstPositiveReturnAt
      (ThreadPermutation.projectedAction resolve eightThreadCycle)
      (projectThreadFamily resolve (familyUnequal resolve 8 h))
      1 :=
  extract_projected_proof resolve h

/-! ============================================================
    TASK 5 — Joint proposition from composition
============================================================ -/

theorem joint_raw_projected_from_composition
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstPositiveReturnAt
      (permuteThreadFamily resolve eightThreadCycle)
      (familyUnequal resolve 8 h)
      8
    ∧
    FirstPositiveReturnAt
      (ThreadPermutation.projectedAction resolve eightThreadCycle)
      (projectThreadFamily resolve (familyUnequal resolve 8 h))
      1 :=
  ⟨raw_proof_recovered resolve h, projected_proof_recovered resolve h⟩

/-! ============================================================
    TASK 6 — No contradiction (type separation)
============================================================ -/

-- Uniqueness applies only when step AND state are the same.
-- Raw and projected requests have distinct types:
--   raw:      FirstReturnRequest (ThreadFamily resolve 8)
--   projected: FirstReturnRequest (Fin 8 → TrajectoryBoundary resolve)
--
-- The following is intentionally ill-typed and commented:
--
-- have heq := firstPositiveReturnAt_unique
--   (raw_proof_recovered resolve h)
--   (projected_proof_recovered resolve h)
--
-- Type error: step and state types do not match.
-- Classification: TYPE-LEVEL SEPARATION SUFFICIENT

/-! ============================================================
    TASK 13 — ESTABLISHED + REFUTED
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

def n8_raw_established_projected_refuted
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstReturnPair (req_n8_raw resolve h) (req_n8_projected_wrong resolve h) where
  left  := result_n8_raw resolve h
  right := result_n8_projected_wrong resolve h

/-! ============================================================
    TASK 14 — ESTABLISHED + UNRESOLVED
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

def established_unresolved_pair
    (resolve : KernelExpr → Store → Location)
    (h8 : 1 < 8)
    (h4 : 1 < 4) :
    FirstReturnPair (req_n8_raw resolve h8) (req_unresolved_n4_halfpower_raw resolve h4) where
  left  := result_n8_raw resolve h8
  right := result_unresolved_n4_halfpower_raw resolve h4

/-! ============================================================
    TASK 15 — REFUTED + UNRESOLVED
============================================================ -/

def refuted_unresolved_pair
    (resolve : KernelExpr → Store → Location)
    (h8 : 1 < 8)
    (h4 : 1 < 4) :
    FirstReturnPair (req_n8_projected_wrong resolve h8) (req_unresolved_n4_halfpower_raw resolve h4) where
  left  := result_n8_projected_wrong resolve h8
  right := result_unresolved_n4_halfpower_raw resolve h4

/-! ============================================================
    Mixed-state proof retention
============================================================ -/

theorem mixed_established_refuted_payloads
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    (n8_raw_established_projected_refuted resolve h).left.status = .established
    ∧
    (n8_raw_established_projected_refuted resolve h).right.status = .refuted := by
  constructor <;> rfl

theorem mixed_established_unresolved_payloads
    (resolve : KernelExpr → Store → Location)
    (h8 : 1 < 8)
    (h4 : 1 < 4) :
    (established_unresolved_pair resolve h8 h4).left.status = .established
    ∧
    (established_unresolved_pair resolve h8 h4).right.status = .unresolved := by
  constructor <;> rfl

theorem mixed_refuted_unresolved_payloads
    (resolve : KernelExpr → Store → Location)
    (h8 : 1 < 8)
    (h4 : 1 < 4) :
    (refuted_unresolved_pair resolve h8 h4).left.status = .refuted
    ∧
    (refuted_unresolved_pair resolve h8 h4).right.status = .unresolved := by
  constructor <;> rfl

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms raw_proof_recovered
#print axioms projected_proof_recovered
#print axioms joint_raw_projected_from_composition
#print axioms n8_projected_not_first_return_8
#print axioms mixed_established_refuted_payloads
#print axioms mixed_established_unresolved_payloads
#print axioms mixed_refuted_unresolved_payloads

end ConsumerC1
