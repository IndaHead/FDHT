import AggregateFamilyTransform
import ClassifierFactorisation

open KernelExprContext

namespace ConsumerC14

/-!
# C₁₄ — Same-Source Convergent Derivation

Same-source convergent derivation routes test.
One source P establishes same exact Q through two distinct routes.
Probe-local only. Not a generic Evidence Engine.
-/

/-! ============================================================
    Same-source convergence fixture
============================================================ -/

-- P := AggregateFoldedTrivialClassifierWitness resolve C
-- Q := ¬ FamilyClassifierFactorsThroughProjections resolve C
--
-- Route A (direct):
--   P → aggregateFoldedTrivial_refutes_factorisation → Q
--
-- Route B (staged):
--   P → aggregateFoldedTrivial_implies_independent
--     → FamilyClassifierIndependentWitness resolve C
--     → familyClassifierIndependentWitness_blocks_factorisation
--     → Q
--
-- Classification: SAME-SOURCE CONVERGENCE

/-! ============================================================
    Source request for P
============================================================ -/

structure AggregateWitnessRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)

def AggregateWitnessRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : AggregateWitnessRequest resolve n) : Prop :=
  AggregateFoldedTrivialClassifierWitness resolve req.classifier

/-! ============================================================
    Route A: direct derivation
============================================================ -/

def derive_q_via_route_a
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C :=
  aggregateFoldedTrivial_refutes_factorisation resolve C hP

/-! ============================================================
    Route B: staged derivation with intermediate
============================================================ -/

def derive_independent_witness
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    FamilyClassifierIndependentWitness resolve C :=
  aggregateFoldedTrivial_implies_independent resolve C hP

def derive_q_via_route_b
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C :=
  familyClassifierIndependentWitness_blocks_factorisation resolve C
    (derive_independent_witness resolve n C hP)

/-! ============================================================
    Downstream request requiring Q
============================================================ -/

structure NonFactorisationRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)
  notFactors : ¬ FamilyClassifierFactorsThroughProjections resolve classifier

def NonFactorisationRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : NonFactorisationRequest resolve n) : Prop :=
  ¬ FamilyClassifierFactorsThroughProjections resolve req.classifier

/-! ============================================================
    Route A admission
============================================================ -/

def non_factorisation_from_route_a
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    NonFactorisationRequest resolve n where
  classifier := C
  notFactors := derive_q_via_route_a resolve n C hP

/-! ============================================================
    Route B admission
============================================================ -/

def non_factorisation_from_route_b
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    NonFactorisationRequest resolve n where
  classifier := C
  notFactors := derive_q_via_route_b resolve n C hP

/-! ============================================================
    Same-source convergence theorem
============================================================ -/

theorem same_source_both_routes
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    (non_factorisation_from_route_a resolve n C hP).classifier = C ∧
    (non_factorisation_from_route_b resolve n C hP).classifier = C :=
  ⟨rfl, rfl⟩

/-! ============================================================
    Same-source convergent trajectory
============================================================ -/

structure SameSourceConvergentTrajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  sourceRequest    : AggregateWitnessRequest resolve n
  routeAEvidence   : ¬ FamilyClassifierFactorsThroughProjections resolve sourceRequest.classifier
  intermediateR1   : FamilyClassifierIndependentWitness resolve sourceRequest.classifier
  routeBEvidence   : ¬ FamilyClassifierFactorsThroughProjections resolve sourceRequest.classifier
  downstreamA      : NonFactorisationRequest resolve n
  downstreamB      : NonFactorisationRequest resolve n

def same_source_trajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    SameSourceConvergentTrajectory resolve n where
  sourceRequest  := ⟨C⟩
  routeAEvidence := derive_q_via_route_a resolve n C hP
  intermediateR1 := derive_independent_witness resolve n C hP
  routeBEvidence := derive_q_via_route_b resolve n C hP
  downstreamA    := non_factorisation_from_route_a resolve n C hP
  downstreamB    := non_factorisation_from_route_b resolve n C hP

-- Same source P. Route A direct. Route B staged with intermediate.
-- Same Q established by both. Intermediate retained.
-- Classification: SAME SOURCE ≠ SAME DERIVATION ROUTE

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms same_source_both_routes

end ConsumerC14
