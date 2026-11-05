import FDHT_Audit_ArbitraryCollision
import ThreadFamilyWitness
import ClassifierReconciliation
import ClassifierFactorisation
import ChiralitySpec
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Folded-trivial witness consequences
============================================================ -/

theorem foldedTrivialClassifierWitness_implies_independentWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : FoldedTrivialRotationClassifierWitness resolve C) :
    FamilyClassifierIndependentWitness resolve C := by
  rcases h with ⟨r, p, hKernel, hDifferent⟩
  exact ⟨rotateThreadFamily resolve r p, p, hKernel, hDifferent⟩

theorem foldedTrivialClassifierWitness_refutes_invariance
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : FoldedTrivialRotationClassifierWitness resolve C) :
    ¬ FamilyClassifierInvariant resolve C := by
  exact familyClassifierIndependentWitness_refutes_invariant
    resolve C
    (foldedTrivialClassifierWitness_implies_independentWitness resolve C h)

theorem foldedTrivialClassifierWitness_blocks_factorisation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : FoldedTrivialRotationClassifierWitness resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C := by
  exact familyClassifierIndependentWitness_blocks_factorisation
    resolve C
    (foldedTrivialClassifierWitness_implies_independentWitness resolve C h)

/-! ============================================================
    ChiralitySpecification consequences
============================================================ -/

theorem chiralitySpecification_classifier_noninvariant
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : ChiralitySpecification resolve n) :
    ¬ FamilyClassifierInvariant resolve spec.classifier := by
  exact foldedTrivialClassifierWitness_refutes_invariance
    resolve spec.classifier spec.foldedTrivialSensitive

theorem chiralitySpecification_classifier_nonfactorising
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : ChiralitySpecification resolve n) :
    ¬ FamilyClassifierFactorsThroughProjections
      resolve
      spec.classifier := by
  exact foldedTrivialClassifierWitness_blocks_factorisation
    resolve spec.classifier spec.foldedTrivialSensitive

theorem chiralitySpecification_has_classifierWitness
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : ChiralitySpecification resolve n) :
    FamilyClassifierIndependentWitness resolve spec.classifier := by
  exact foldedTrivialClassifierWitness_implies_independentWitness
    resolve spec.classifier spec.foldedTrivialSensitive

theorem chiralitySpecificationExists_implies_nonfactorisingClassifier
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : ChiralitySpecificationExists resolve n) :
    ∃ C : RelationalClassifier (ThreadFamily resolve n),
      ¬ FamilyClassifierFactorsThroughProjections resolve C := by
  rcases h with ⟨spec⟩
  exact ⟨spec.classifier,
    chiralitySpecification_classifier_nonfactorising resolve n spec⟩

/-! ============================================================
    Rotation sensitivity from folded-trivial
============================================================ -/

theorem foldedTrivial_implies_rotationSensitive
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : FoldedTrivialRotationClassifierWitness resolve C) :
    RotationSensitiveClassifierWitness resolve C := by
  rcases h with ⟨r, p, _, hDifferent⟩
  exact ⟨r, p, hDifferent⟩

/-! ============================================================
    Minimal specification
============================================================ -/

structure MinimalChiralitySpecification
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier :
    RelationalClassifier (ThreadFamily resolve n)
  foldedTrivialSensitive :
    FoldedTrivialRotationClassifierWitness resolve classifier

def chiralitySpecification_to_minimal
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : ChiralitySpecification resolve n) :
    MinimalChiralitySpecification resolve n :=
{
  classifier := spec.classifier
  foldedTrivialSensitive := spec.foldedTrivialSensitive
}

def minimal_to_chiralitySpecification
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : MinimalChiralitySpecification resolve n) :
    ChiralitySpecification resolve n :=
{
  classifier := spec.classifier
  rotationSensitive :=
    foldedTrivial_implies_rotationSensitive
      resolve spec.classifier spec.foldedTrivialSensitive
  foldedTrivialSensitive := spec.foldedTrivialSensitive
}

theorem chiralitySpecification_iff_minimal_nonempty
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    Nonempty (ChiralitySpecification resolve n)
    ↔
    Nonempty (MinimalChiralitySpecification resolve n) := by
  constructor
  · intro ⟨spec⟩
    exact ⟨chiralitySpecification_to_minimal resolve n spec⟩
  · intro ⟨spec⟩
    exact ⟨minimal_to_chiralitySpecification resolve n spec⟩

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check foldedTrivialClassifierWitness_implies_independentWitness
#check foldedTrivialClassifierWitness_refutes_invariance
#check foldedTrivialClassifierWitness_blocks_factorisation
#check chiralitySpecification_classifier_noninvariant
#check chiralitySpecification_classifier_nonfactorising
#check chiralitySpecification_has_classifierWitness
#check chiralitySpecificationExists_implies_nonfactorisingClassifier
#check foldedTrivial_implies_rotationSensitive
#check chiralitySpecification_iff_minimal_nonempty

#print axioms foldedTrivialClassifierWitness_implies_independentWitness
#print axioms foldedTrivialClassifierWitness_refutes_invariance
#print axioms foldedTrivialClassifierWitness_blocks_factorisation
#print axioms chiralitySpecification_classifier_noninvariant
#print axioms chiralitySpecification_classifier_nonfactorising
#print axioms chiralitySpecification_has_classifierWitness
#print axioms chiralitySpecificationExists_implies_nonfactorisingClassifier
#print axioms foldedTrivial_implies_rotationSensitive
#print axioms chiralitySpecification_iff_minimal_nonempty
