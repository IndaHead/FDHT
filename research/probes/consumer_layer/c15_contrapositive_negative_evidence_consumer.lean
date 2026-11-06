import AggregateFamilyTransform
import ClassifierFactorisation
import ClassifierReconciliation

open KernelExprContext

namespace ConsumerC15

/-!
# C₁₅ — Contrapositive Negative-Evidence Propagation

Negative evidence propagation through existing implication.
¬P + (Q → P) → ¬Q via constructive composition.
Probe-local only. Not a generic Evidence Engine.
-/

/-! ============================================================
    Contrapositive fixture
============================================================ -/

-- P := FamilyClassifierInvariant resolve C
-- Q := FamilyClassifierFactorsThroughProjections resolve C
--
-- f := familyClassifier_factorisation_implies_invariant : Q → P
--
-- notP := ¬ FamilyClassifierInvariant resolve C
--   via familyClassifierIndependentWitness_refutes_invariant
--
-- Contrapositive:
--   notQ := fun hQ => notP (f hQ)
--
-- Direct route (reference, not tested):
--   familyClassifierIndependentWitness_blocks_factorisation
--
-- Classification: CONTRAPOSITIVE NEGATIVE-EVIDENCE PROPAGATION

/-! ============================================================
    Source request for P
============================================================ -/

structure InvariantRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)

def InvariantRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : InvariantRequest resolve n) : Prop :=
  FamilyClassifierInvariant resolve req.classifier

/-! ============================================================
    Source result
============================================================ -/

inductive InvariantResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : InvariantRequest resolve n) where
  | established : req.claim → InvariantResult req
  | refuted     : (req.claim → False) → InvariantResult req
  | unresolved  : InvariantResult req

/-! ============================================================
    Derive notP from independent witness
============================================================ -/

def derive_not_invariant
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hIndependent : FamilyClassifierIndependentWitness resolve C) :
    ¬ FamilyClassifierInvariant resolve C :=
  familyClassifierIndependentWitness_refutes_invariant resolve C hIndependent

/-! ============================================================
    Contrapositive derivation: notQ from notP and f
============================================================ -/

def derive_not_factorisation_contrapositive
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (notP : ¬ FamilyClassifierInvariant resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C :=
  fun hQ => notP (familyClassifier_factorisation_implies_invariant resolve C hQ)

/-! ============================================================
    Direct route (reference, not tested)
============================================================ -/

def derive_not_factorisation_direct
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hIndependent : FamilyClassifierIndependentWitness resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C :=
  familyClassifierIndependentWitness_blocks_factorisation resolve C hIndependent

/-! ============================================================
    Downstream request requiring ¬Q
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
    Admit downstream from contrapositive
============================================================ -/

def non_factorisation_from_contrapositive
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (notP : ¬ FamilyClassifierInvariant resolve C) :
    NonFactorisationRequest resolve n where
  classifier := C
  notFactors := derive_not_factorisation_contrapositive resolve n C notP

/-! ============================================================
    Contrapositive trajectory
============================================================ -/

structure ContrapositiveEvidenceTrajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  sourceRequest         : InvariantRequest resolve n
  sourceResult          : InvariantResult sourceRequest
  notP                  : ¬ FamilyClassifierInvariant resolve sourceRequest.classifier
  notQContrapositive    : ¬ FamilyClassifierFactorsThroughProjections resolve sourceRequest.classifier
  downstreamRequest     : NonFactorisationRequest resolve n

def contrapositive_trajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hIndependent : FamilyClassifierIndependentWitness resolve C) :
    ContrapositiveEvidenceTrajectory resolve n where
  sourceRequest      := ⟨C⟩
  sourceResult       := .refuted (derive_not_invariant resolve n C hIndependent)
  notP               := derive_not_invariant resolve n C hIndependent
  notQContrapositive := derive_not_factorisation_contrapositive resolve n C
                          (derive_not_invariant resolve n C hIndependent)
  downstreamRequest  := non_factorisation_from_contrapositive resolve n C
                          (derive_not_invariant resolve n C hIndependent)

-- REFUTED P → notP → (Q→P) → notQ → downstream.
-- Classification: CONTRAPOSITIVE PROPAGATION ≠ FAILURE CASCADE

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms derive_not_factorisation_contrapositive

end ConsumerC15
