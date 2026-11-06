import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC10

/-!
# C₁₀ — Transitive Derivation

Multi-step theorem-mediated evidence propagation.
P → theorem₁ → Q → theorem₂ → R → downstream request.
Probe-local only. Not a generic Evidence Engine.
-/

/-! ============================================================
    Transitive chain fixture
============================================================ -/

-- P := RelationallyAggregateFoldedTrivialClassifierWitness resolve C
-- Q := AggregateFoldedTrivialClassifierWitness resolve C
-- R := FamilyClassifierIndependentWitness resolve C
--
-- theorem₁ := relationallyAggregateWitness_implies_aggregateWitness
--   : P → Q
--
-- theorem₂ := aggregateFoldedTrivial_implies_independent
--   : Q → R
--
-- Transitive chain:
-- P → theorem₁ → Q → theorem₂ → R
--
-- Classification: GENUINE TRANSITIVE DERIVATION

/-! ============================================================
    Upstream request for P
============================================================ -/

structure RelationalWitnessRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)

def RelationalWitnessRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : RelationalWitnessRequest resolve n) : Prop :=
  RelationallyAggregateFoldedTrivialClassifierWitness resolve req.classifier

/-! ============================================================
    Upstream result
============================================================ -/

inductive RelationalWitnessResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : RelationalWitnessRequest resolve n) where
  | established : req.claim → RelationalWitnessResult req
  | refuted     : (req.claim → False) → RelationalWitnessResult req
  | unresolved  : RelationalWitnessResult req

/-! ============================================================
    Step 1: P → Q via theorem₁
============================================================ -/

def derive_aggregate_witness
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    AggregateFoldedTrivialClassifierWitness resolve C :=
  relationallyAggregateWitness_implies_aggregateWitness resolve C hP

/-! ============================================================
    Step 2: Q → R via theorem₂
============================================================ -/

def derive_independent_witness
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hQ : AggregateFoldedTrivialClassifierWitness resolve C) :
    FamilyClassifierIndependentWitness resolve C :=
  aggregateFoldedTrivial_implies_independent resolve C hQ

/-! ============================================================
    Transitive derivation: P → Q → R
============================================================ -/

def transitive_derive_independent
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    FamilyClassifierIndependentWitness resolve C :=
  derive_independent_witness resolve n C
    (derive_aggregate_witness resolve n C hP)

/-! ============================================================
    Downstream request requiring R
============================================================ -/

structure IndependenceRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)
  independentWitness : FamilyClassifierIndependentWitness resolve classifier

def IndependenceRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : IndependenceRequest resolve n) : Prop :=
  FamilyClassifierIndependentWitness resolve req.classifier

/-! ============================================================
    Transitive admission
============================================================ -/

def independence_from_transitive
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    IndependenceRequest resolve n where
  classifier := C
  independentWitness := transitive_derive_independent resolve n C hP

theorem transitive_admits_downstream
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    (independence_from_transitive resolve n C hP).classifier = C :=
  rfl

/-! ============================================================
    Transitive trajectory
============================================================ -/

structure TransitiveDerivationTrajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  sourceRequest     : RelationalWitnessRequest resolve n
  sourceResult      : RelationalWitnessResult sourceRequest
  intermediateQ     : AggregateFoldedTrivialClassifierWitness resolve sourceRequest.classifier
  derivedR          : FamilyClassifierIndependentWitness resolve sourceRequest.classifier
  downstreamRequest : IndependenceRequest resolve n

def transitive_trajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    TransitiveDerivationTrajectory resolve n where
  sourceRequest     := ⟨C⟩
  sourceResult      := .established hP
  intermediateQ     := derive_aggregate_witness resolve n C hP
  derivedR          := transitive_derive_independent resolve n C hP
  downstreamRequest := independence_from_transitive resolve n C hP

-- P retained. Q retained. R retained. Downstream admitted.
-- Classification: TRANSITIVE DERIVATION ≠ DESTRUCTIVE TRANSFORMATION

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms transitive_admits_downstream

end ConsumerC10
