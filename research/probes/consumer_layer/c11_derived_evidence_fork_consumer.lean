import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC11

/-!
# C₁₁ — Theorem-Mediated Derived-Evidence Fork

Derived-evidence fan-out / lineage / scope test.
Single source P consumed through two distinct theorems to derive Q and R.
Probe-local only. Not a generic Evidence Engine.
-/

/-! ============================================================
    Fork fixture
============================================================ -/

-- P := RelationallyAggregateFoldedTrivialClassifierWitness resolve C
-- Q := ¬ FamilyClassifierInvariant resolve C
-- R := ¬ FamilyClassifierFactorsThroughProjections resolve C
--
-- f := relationallyAggregateWitness_refutes_invariant
--   : P → Q
--
-- g := relationallyAggregateWitness_refutes_factorisation
--   : P → R
--
-- Fork:
--        f
--      ┌────→ Q
-- P ───┤
--      └────→ R
--        g
--
-- Classification: GENUINE DERIVED-EVIDENCE FORK

/-! ============================================================
    Source request for P
============================================================ -/

structure RelationalAggregateRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)

def RelationalAggregateRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : RelationalAggregateRequest resolve n) : Prop :=
  RelationallyAggregateFoldedTrivialClassifierWitness resolve req.classifier

/-! ============================================================
    Source result
============================================================ -/

inductive RelationalAggregateResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : RelationalAggregateRequest resolve n) where
  | established : req.claim → RelationalAggregateResult req
  | refuted     : (req.claim → False) → RelationalAggregateResult req
  | unresolved  : RelationalAggregateResult req

/-! ============================================================
    Derive Q through f
============================================================ -/

def derive_not_invariant
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    ¬ FamilyClassifierInvariant resolve C :=
  relationallyAggregateWitness_refutes_invariant resolve C hP

/-! ============================================================
    Derive R through g
============================================================ -/

def derive_not_factorisation
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C :=
  relationallyAggregateWitness_refutes_factorisation resolve C hP

/-! ============================================================
    Request Q — Non-invariant capability
============================================================ -/

structure NonInvariantCapabilityRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)
  notInvariant : ¬ FamilyClassifierInvariant resolve classifier

def NonInvariantCapabilityRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : NonInvariantCapabilityRequest resolve n) : Prop :=
  ¬ FamilyClassifierInvariant resolve req.classifier

/-! ============================================================
    Request R — Non-factorisation capability
============================================================ -/

structure NonFactorisationCapabilityRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)
  notFactors : ¬ FamilyClassifierFactorsThroughProjections resolve classifier

def NonFactorisationCapabilityRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : NonFactorisationCapabilityRequest resolve n) : Prop :=
  ¬ FamilyClassifierFactorsThroughProjections resolve req.classifier

/-! ============================================================
    Admit Q branch
============================================================ -/

def non_invariant_from_fork
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    NonInvariantCapabilityRequest resolve n where
  classifier := C
  notInvariant := derive_not_invariant resolve n C hP

/-! ============================================================
    Admit R branch
============================================================ -/

def non_factorisation_from_fork
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    NonFactorisationCapabilityRequest resolve n where
  classifier := C
  notFactors := derive_not_factorisation resolve n C hP

/-! ============================================================
    Coexistence theorem
============================================================ -/

theorem fork_admits_both
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    (non_invariant_from_fork resolve n C hP).classifier = C ∧
    (non_factorisation_from_fork resolve n C hP).classifier = C :=
  ⟨rfl, rfl⟩

/-! ============================================================
    Fork trajectory
============================================================ -/

structure DerivedForkTrajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  sourceRequest  : RelationalAggregateRequest resolve n
  sourceResult   : RelationalAggregateResult sourceRequest
  derivedQ       : ¬ FamilyClassifierInvariant resolve sourceRequest.classifier
  derivedR       : ¬ FamilyClassifierFactorsThroughProjections resolve sourceRequest.classifier
  downstreamQ    : NonInvariantCapabilityRequest resolve n
  downstreamR    : NonFactorisationCapabilityRequest resolve n

def derived_fork_trajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hP : RelationallyAggregateFoldedTrivialClassifierWitness resolve C) :
    DerivedForkTrajectory resolve n where
  sourceRequest := ⟨C⟩
  sourceResult  := .established hP
  derivedQ      := derive_not_invariant resolve n C hP
  derivedR      := derive_not_factorisation resolve n C hP
  downstreamQ   := non_invariant_from_fork resolve n C hP
  downstreamR   := non_factorisation_from_fork resolve n C hP

-- P retained. Q retained. R retained. Both downstream requests admitted.
-- Classification: FAN-OUT ≠ DESTRUCTIVE TRANSFORMATION

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms fork_admits_both

end ConsumerC11
