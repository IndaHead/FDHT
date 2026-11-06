import AggregateFamilyTransform
import ClassifierFactorisation

open KernelExprContext

namespace ConsumerC13

/-!
# C₁₃ — Convergent Derivation Routes

Same-conclusion multiplicity test.
Two distinct sources establish the same exact proposition Q.
Probe-local only. Not a generic Evidence Engine.
-/

/-! ============================================================
    Distinct-source convergence fixture
============================================================ -/

-- Q := ¬ FamilyClassifierFactorsThroughProjections resolve C
--
-- Route A:
--   P₁ := FamilyClassifierIndependentWitness resolve C
--   theorem := familyClassifierIndependentWitness_blocks_factorisation
--   P₁ → Q
--
-- Route B:
--   P₂ := AggregateFoldedTrivialClassifierWitness resolve C
--   theorem := aggregateFoldedTrivial_refutes_factorisation
--   P₂ → Q
--
-- Classification: DISTINCT-SOURCE CONVERGENCE

/-! ============================================================
    Source request for Route A
============================================================ -/

structure IndependentWitnessRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)

def IndependentWitnessRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : IndependentWitnessRequest resolve n) : Prop :=
  FamilyClassifierIndependentWitness resolve req.classifier

/-! ============================================================
    Source request for Route B
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
    Derive Q via Route A
============================================================ -/

def derive_q_via_route_a
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP1 : FamilyClassifierIndependentWitness resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C :=
  familyClassifierIndependentWitness_blocks_factorisation resolve C hP1

/-! ============================================================
    Derive Q via Route B
============================================================ -/

def derive_q_via_route_b
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP2 : AggregateFoldedTrivialClassifierWitness resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C :=
  aggregateFoldedTrivial_refutes_factorisation resolve C hP2

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
    (hP1 : FamilyClassifierIndependentWitness resolve C) :
    NonFactorisationRequest resolve n where
  classifier := C
  notFactors := derive_q_via_route_a resolve n C hP1

/-! ============================================================
    Route B admission
============================================================ -/

def non_factorisation_from_route_b
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP2 : AggregateFoldedTrivialClassifierWitness resolve C) :
    NonFactorisationRequest resolve n where
  classifier := C
  notFactors := derive_q_via_route_b resolve n C hP2

/-! ============================================================
    Same conclusion theorem
============================================================ -/

theorem same_conclusion_both_routes
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP1 : FamilyClassifierIndependentWitness resolve C)
    (hP2 : AggregateFoldedTrivialClassifierWitness resolve C) :
    (non_factorisation_from_route_a resolve n C hP1).classifier = C ∧
    (non_factorisation_from_route_b resolve n C hP2).classifier = C :=
  ⟨rfl, rfl⟩

/-! ============================================================
    Convergent derivation trajectory
============================================================ -/

structure ConvergentDerivationTrajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  sourceRequestA   : IndependentWitnessRequest resolve n
  sourceRequestB   : AggregateWitnessRequest resolve n
  routeAEvidence   : ¬ FamilyClassifierFactorsThroughProjections resolve sourceRequestA.classifier
  routeBEvidence   : ¬ FamilyClassifierFactorsThroughProjections resolve sourceRequestB.classifier
  downstreamA      : NonFactorisationRequest resolve n
  downstreamB      : NonFactorisationRequest resolve n

def convergent_trajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP1 : FamilyClassifierIndependentWitness resolve C)
    (hP2 : AggregateFoldedTrivialClassifierWitness resolve C) :
    ConvergentDerivationTrajectory resolve n where
  sourceRequestA := ⟨C⟩
  sourceRequestB := ⟨C⟩
  routeAEvidence := derive_q_via_route_a resolve n C hP1
  routeBEvidence := derive_q_via_route_b resolve n C hP2
  downstreamA    := non_factorisation_from_route_a resolve n C hP1
  downstreamB    := non_factorisation_from_route_b resolve n C hP2

-- Route A retained. Route B retained. Same Q established by both.
-- Classification: SAME CONCLUSION ≠ SAME DERIVATION HISTORY

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms same_conclusion_both_routes

end ConsumerC13
