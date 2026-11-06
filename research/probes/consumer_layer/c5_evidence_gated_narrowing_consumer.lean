import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC5

/-!
# C₅ — Evidence-Gated Narrowing Without Ranking or Destructive Pruning

Post-branch requirement test.
Later requirement distinguishes branch capabilities without ranking or deletion.
Probe-local only. Not a generic Consumer API.
-/

/-! ============================================================
    TASK 2 — Minimum C₄ shapes (duplicated, C₄ unchanged)
============================================================ -/

structure ChiralityDescriptionRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  family : ThreadFamily resolve n
  value  : ChiralityValue

def ChiralityDescriptionRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n) : Prop :=
  ChiralityValueDescribes resolve req.family req.value

inductive ChiralityDescriptionResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n) where
  | established : req.claim → ChiralityDescriptionResult req
  | refuted     : (req.claim → False) → ChiralityDescriptionResult req
  | unresolved  : ChiralityDescriptionResult req

structure BranchBRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  transform      : AggregateFamilyTransform resolve n
  input          : ThreadFamily resolve n
  fromValue      : ChiralityValue
  toValue        : ChiralityValue
  prerequisite   : ChiralityValueDescribes resolve input fromValue

def BranchBRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : BranchBRequest resolve n) : Prop :=
  FoldedTrivialChiralityTransition
    resolve req.transform req.input req.fromValue req.toValue

structure BranchCRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  transform      : AggregateFamilyTransform resolve n
  input          : ThreadFamily resolve n
  fromValue      : ChiralityValue
  toValue        : ChiralityValue
  prerequisite   : ChiralityValueDescribes resolve input fromValue

def BranchCRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : BranchCRequest resolve n) : Prop :=
  RelationalAggregateChiralityTransition
    resolve req.transform req.input req.fromValue req.toValue

inductive BranchBResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : BranchBRequest resolve n) where
  | established : req.claim → BranchBResult req
  | refuted     : (req.claim → False) → BranchBResult req
  | unresolved  : BranchBResult req

inductive BranchCResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : BranchCRequest resolve n) where
  | established : req.claim → BranchCResult req
  | refuted     : (req.claim → False) → BranchCResult req
  | unresolved  : BranchCResult req

/-! ============================================================
    TASK 3 — Branch asymmetry verification
============================================================ -/

-- Branch B claim: FoldedTrivialChiralityTransition
--   = ThreadFamilyKernel ∧ ChiralityTransition
--
-- Branch C claim: RelationalAggregateChiralityTransition
--   = IsRelationallyAggregate ∧ FoldedTrivialChiralityTransition
--
-- C is strictly stronger: it requires relational-aggregate structure
-- in addition to folded-trivial transition.
--
-- B evidence cannot derive C requirement without additional theorem.
-- Classification: GENUINE ASYMMETRY

/-! ============================================================
    TASK 4 — Later requirement R
============================================================ -/

structure RelationalContinuationRequest
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) where
  relationalEvidence :
    RelationalAggregateChiralityTransition
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      .separated
      .aligned

/-! ============================================================
    TASK 5 — Branch C admission
============================================================ -/

theorem relational_continuation_from_c
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RelationalContinuationRequest resolve h :=
  {
    relationalEvidence :=
      neighbourCompose_relationalAggregate_chiralityTransition_n2 resolve h
  }

/-! ============================================================
    TASK 6 — Branch B non-admission
============================================================ -/

-- Attempting to construct RelationalContinuationRequest from Branch B evidence:
--
-- def invalid_continuation_from_b
--     (resolve : KernelExpr → Store → Location)
--     (h : 1 < 2)
--     (hB : FoldedTrivialChiralityTransition
--             resolve
--             (neighbourComposeTransform resolve h)
--             (familyUnequal resolve 2 h)
--             .separated
--             .aligned) :
--     RelationalContinuationRequest resolve h :=
--   {
--     relationalEvidence := by
--       -- hB does not provide IsRelationallyAggregate
--       -- Type mismatch: FoldedTrivial ≠ RelationalAggregate
--       exact hB  -- TYPE REJECTION
--   }
--
-- Classification: TYPE REJECTION
-- Branch B does not provide the evidence required by R.
-- Branch B is NOT refuted. Branch B is NOT invalid.
-- Branch B merely lacks the specific evidence R requires.

/-! ============================================================
    TASK 7 — Preserve Branch B
============================================================ -/

def branch_b_request
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    BranchBRequest resolve 2 :=
  {
    transform := neighbourComposeTransform resolve h
    input := familyUnequal resolve 2 h
    fromValue := .separated
    toValue := .aligned
    prerequisite := familyUnequal_chiralityValue_separated_n2 resolve h
  }

def result_branch_b
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    BranchBResult (branch_b_request resolve h) :=
  .established
    (neighbourCompose_foldedTrivial_chiralityTransition_n2 resolve h)

theorem branch_b_still_established
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    FoldedTrivialChiralityTransition
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      .separated
      .aligned :=
  neighbourCompose_foldedTrivial_chiralityTransition_n2 resolve h

/-! ============================================================
    TASK 8 — Preserve Branch C
============================================================ -/

def branch_c_request
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    BranchCRequest resolve 2 :=
  {
    transform := neighbourComposeTransform resolve h
    input := familyUnequal resolve 2 h
    fromValue := .separated
    toValue := .aligned
    prerequisite := familyUnequal_chiralityValue_separated_n2 resolve h
  }

def result_branch_c
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    BranchCResult (branch_c_request resolve h) :=
  .established
    (neighbourCompose_relationalAggregate_chiralityTransition_n2 resolve h)

theorem branch_c_still_established
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RelationalAggregateChiralityTransition
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      .separated
      .aligned :=
  neighbourCompose_relationalAggregate_chiralityTransition_n2 resolve h

/-! ============================================================
    TASK 9 — Narrowing view (non-destructive)
============================================================ -/

structure NarrowingView
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) where
  branchBRequest      : BranchBRequest resolve 2
  branchBResult       : BranchBResult branchBRequest
  branchCRequest      : BranchCRequest resolve 2
  branchCResult       : BranchCResult branchCRequest
  continuationFromC   : RelationalContinuationRequest resolve h

def narrowing_view_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    NarrowingView resolve h where
  branchBRequest    := branch_b_request resolve h
  branchBResult     := result_branch_b resolve h
  branchCRequest    := branch_c_request resolve h
  branchCResult     := result_branch_c resolve h
  continuationFromC := relational_continuation_from_c resolve h

/-! ============================================================
    TASK 12 — Same-status/different-capability
============================================================ -/

-- Both Branch B and Branch C are ESTABLISHED.
-- Status alone cannot distinguish which satisfies R.
-- Only C carries the relational-aggregate proof.
-- Classification: SAME STATUS ≠ SAME DOWNSTREAM CAPABILITY

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms branch_b_still_established
#print axioms branch_c_still_established

end ConsumerC5
