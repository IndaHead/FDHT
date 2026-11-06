import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC4

/-!
# C₄ — Evidence-Gated Branching Without Forced Choice

Dependent reasoning fan-out test.
One established prerequisite admits two distinct downstream requests.
Probe-local only. Not a generic Consumer API.
-/

/-! ============================================================
    TASK 1 — Minimum C₂/C₃ shapes (duplicated, C₂/C₃ unchanged)
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

def establishChiralityDescription
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n)
    (h : req.claim) :
    ChiralityDescriptionResult req :=
  .established h

/-! ============================================================
    TASK 3 — Upstream request and result
============================================================ -/

def branching_prerequisite_request
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionRequest resolve 2 where
  family := familyUnequal resolve 2 h
  value  := .separated

def branching_prerequisite_result
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionResult (branching_prerequisite_request resolve h) :=
  establishChiralityDescription
    (branching_prerequisite_request resolve h)
    (familyUnequal_chiralityValue_separated_n2 resolve h)

/-! ============================================================
    TASK 4 — Branch B request (FoldedTrivial)
============================================================ -/

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
    resolve
    req.transform
    req.input
    req.fromValue
    req.toValue

/-! ============================================================
    TASK 5 — Branch C request (RelationalAggregate)
============================================================ -/

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
    resolve
    req.transform
    req.input
    req.fromValue
    req.toValue

/-! ============================================================
    TASK 6 — Construct both requests from one proof
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

/-! ============================================================
    TASK 7 — Branch-specific results
============================================================ -/

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

def establishBranchB
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : BranchBRequest resolve n)
    (h : req.claim) :
    BranchBResult req :=
  .established h

def establishBranchC
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : BranchCRequest resolve n)
    (h : req.claim) :
    BranchCResult req :=
  .established h

def result_branch_b
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    BranchBResult (branch_b_request resolve h) :=
  establishBranchB
    (branch_b_request resolve h)
    (neighbourCompose_foldedTrivial_chiralityTransition_n2 resolve h)

def result_branch_c
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    BranchCResult (branch_c_request resolve h) :=
  establishBranchC
    (branch_c_request resolve h)
    (neighbourCompose_relationalAggregate_chiralityTransition_n2 resolve h)

/-! ============================================================
    TASK 8 — Preserve both branches
============================================================ -/

structure BranchingTrajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  prerequisiteRequest : ChiralityDescriptionRequest resolve n
  prerequisiteResult  : ChiralityDescriptionResult prerequisiteRequest
  branchBRequest      : BranchBRequest resolve n
  branchBResult       : BranchBResult branchBRequest
  branchCRequest      : BranchCRequest resolve n
  branchCResult       : BranchCResult branchCRequest

def branching_trajectory_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    BranchingTrajectory resolve 2 where
  prerequisiteRequest := branching_prerequisite_request resolve h
  prerequisiteResult  := branching_prerequisite_result resolve h
  branchBRequest      := branch_b_request resolve h
  branchBResult       := result_branch_b resolve h
  branchCRequest      := branch_c_request resolve h
  branchCResult       := result_branch_c resolve h

/-! ============================================================
    TASK 9 — Proof payload retention
============================================================ -/

theorem upstream_proof_recovered
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityValueDescribes
      resolve
      (familyUnequal resolve 2 h)
      .separated :=
  familyUnequal_chiralityValue_separated_n2 resolve h

theorem branch_b_payload_retained
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    FoldedTrivialChiralityTransition
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      .separated
      .aligned :=
  neighbourCompose_foldedTrivial_chiralityTransition_n2 resolve h

theorem branch_c_payload_retained
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
    TASK 17 — Admission ≠ determination
============================================================ -/

-- Branch requests are constructible from prerequisite proof.
-- Their claims are independently established by permanent theorems.
-- Admission does not imply determination; determination requires separate evidence.
-- Classification: ADMISSION ≠ DETERMINATION

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms upstream_proof_recovered
#print axioms branch_b_payload_retained
#print axioms branch_c_payload_retained

end ConsumerC4
