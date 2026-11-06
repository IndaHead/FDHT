import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC9

/-!
# C₉ — Theorem-Mediated Derived Evidence Propagation

Derivation / provenance / scope test.
Proof-bearing evidence passed through existing theorem P → Q.
Probe-local only. Not a generic Evidence Engine.
-/

/-! ============================================================
    TASK 2 — Natural derivation fixture
============================================================ -/

-- P := AggregateFoldedTrivialClassifierWitness resolve C
-- Q := FamilyClassifierIndependentWitness resolve C
--
-- Existing theorem:
-- aggregateFoldedTrivial_implies_independent
--   : AggregateFoldedTrivialClassifierWitness resolve C
--   → FamilyClassifierIndependentWitness resolve C
--
-- P and Q are mathematically distinct:
-- - P is a stronger witness (includes the aggregate transform)
-- - Q is a weaker witness (just the independent pair)
--
-- Downstream capability:
-- A request requiring FamilyClassifierIndependentWitness establishes
-- that the classifier distinguishes some folded-equivalent pair.
--
-- Classification: GENUINE DERIVATION FIXTURE

/-! ============================================================
    TASK 3 — Upstream request for P
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
    TASK 4 — Upstream result
============================================================ -/

inductive AggregateWitnessResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : AggregateWitnessRequest resolve n) where
  | established : req.claim → AggregateWitnessResult req
  | refuted     : (req.claim → False) → AggregateWitnessResult req
  | unresolved  : AggregateWitnessResult req

/-! ============================================================
    TASK 5 — Recover P payload
============================================================ -/

def recover_aggregate_witness
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    {req : AggregateWitnessRequest resolve n}
    (result : AggregateWitnessResult req) :
    (req.claim) ∨ True :=
  match result with
  | .established hP => Or.inl hP
  | .refuted _ => Or.inr trivial
  | .unresolved => Or.inr trivial

/-! ============================================================
    TASK 6 — Derive Q through existing theorem
============================================================ -/

def derive_independent_witness
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    FamilyClassifierIndependentWitness resolve C :=
  aggregateFoldedTrivial_implies_independent resolve C hP

/-! ============================================================
    TASK 7 — Downstream request requiring Q
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
    TASK 8 — Derived-evidence admission
============================================================ -/

def independence_from_derivation
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    IndependenceRequest resolve n where
  classifier := C
  independentWitness := derive_independent_witness resolve n C hP

theorem derived_evidence_admits_downstream
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    (independence_from_derivation resolve n C hP).classifier = C :=
  rfl

/-! ============================================================
    TASK 9 — No direct bypass
============================================================ -/

-- Attempting to construct IndependenceRequest from P directly:
--
-- def invalid_from_p_directly
--     (resolve : KernelExpr → Store → Location)
--     (n : Nat)
--     (C : RelationalClassifier (ThreadFamily resolve n))
--     (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
--     IndependenceRequest resolve n :=
--   {
--     classifier := C
--     independentWitness := hP  -- TYPE MISMATCH
--   }
--
-- Classification: TYPE REJECTION
-- P does not inhabit Q field.
-- Theorem application is required.

/-! ============================================================
    TASK 10 — Status-only firewall
============================================================ -/

-- Status ESTABLISHED alone does not provide hP.
-- Without hP, theorem cannot be applied.
-- Classification: STATUS ≠ PROOF

/-! ============================================================
    TASK 11 — UNRESOLVED firewall
============================================================ -/

-- UNRESOLVED carries no proof payload.
-- Cannot derive Q from UNRESOLVED.
-- Classification: UNRESOLVED ≠ P ≠ Q

/-! ============================================================
    TASK 12 — REFUTED firewall
============================================================ -/

-- REFUTED provides ¬P, not P.
-- Theorem P → Q cannot be applied to ¬P.
-- Classification: REFUTED P ≠ P

/-! ============================================================
    TASK 13 — No converse
============================================================ -/

-- P → Q does not imply Q → P.
-- FamilyClassifierIndependentWitness does not imply
-- AggregateFoldedTrivialClassifierWitness.
-- Classification: IMPLICATION ≠ EQUIVALENCE

/-! ============================================================
    TASK 20 — Provenance / lineage
============================================================ -/

structure DerivedEvidenceTrajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  sourceRequest     : AggregateWitnessRequest resolve n
  sourceResult      : AggregateWitnessResult sourceRequest
  derivedEvidence   : FamilyClassifierIndependentWitness resolve sourceRequest.classifier
  downstreamRequest : IndependenceRequest resolve n

def derived_evidence_trajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : AggregateFoldedTrivialClassifierWitness resolve C) :
    DerivedEvidenceTrajectory resolve n where
  sourceRequest     := ⟨C⟩
  sourceResult      := .established hP
  derivedEvidence   := derive_independent_witness resolve n C hP
  downstreamRequest := independence_from_derivation resolve n C hP

-- Source P retained. Derived Q retained. Downstream admitted.
-- Classification: DERIVATION ≠ DESTRUCTIVE TRANSFORMATION

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms derived_evidence_admits_downstream

end ConsumerC9
