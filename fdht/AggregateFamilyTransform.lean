import ChiralityConsequences
import ClassifierFactorisation
import FDHT_Audit_ArbitraryCollision
import ThreadFamilyWitness
import ChiralitySpec
import UniformRealisation
import FDHTTrajectoryAPI
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Thread permutation (minimal)
============================================================ -/

structure ThreadPermutation (n : Nat) where
  toFun : Fin n → Fin n
  invFun : Fin n → Fin n
  left_inv : ∀ i, invFun (toFun i) = i
  right_inv : ∀ i, toFun (invFun i) = i

def reindexThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (σ : Fin n → Fin n)
    (p : ThreadFamily resolve n) :
    ThreadFamily resolve n :=
  fun i => p (σ i)

def permuteThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p : ThreadFamily resolve n) :
    ThreadFamily resolve n :=
  reindexThreadFamily resolve π.toFun p

/-! ============================================================
    Aggregate family transform
============================================================ -/

def AggregateFamilyTransform
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :=
  ThreadFamily resolve n →
  ThreadFamily resolve n

def identityAggregate
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    AggregateFamilyTransform resolve n :=
  fun p => p

theorem identityAggregate_apply
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (p : ThreadFamily resolve n) :
    identityAggregate resolve n p = p := by
  rfl

def composeAggregate
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (α β : AggregateFamilyTransform resolve n) :
    AggregateFamilyTransform resolve n :=
  fun p => α (β p)

theorem composeAggregate_apply
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (α β : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n) :
    composeAggregate α β p = α (β p) := by
  rfl

/-! ============================================================
    Kernel preservation
============================================================ -/

def AggregateTransformRespectsKernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ∀ p q,
    ThreadFamilyKernel resolve p q →
    ThreadFamilyKernel resolve
      (transform p)
      (transform q)

theorem identityAggregate_respectsKernel
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    AggregateTransformRespectsKernel resolve (identityAggregate resolve n) := by
  intro p q h
  exact h

theorem composeAggregate_respectsKernel
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (α β : AggregateFamilyTransform resolve n)
    (hα : AggregateTransformRespectsKernel resolve α)
    (hβ : AggregateTransformRespectsKernel resolve β) :
    AggregateTransformRespectsKernel resolve (composeAggregate α β) := by
  intro p q h
  exact hα (β p) (β q) (hβ p q h)

/-! ============================================================
    Fold-compatible aggregate transform
============================================================ -/

structure FoldCompatibleAggregateTransform
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where

  transform :
    AggregateFamilyTransform resolve n

  compatible :
    AggregateTransformRespectsKernel resolve transform

def aggregateTransformIdentity
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    FoldCompatibleAggregateTransform resolve n :=
{
  transform := id

  compatible := by
    intro p q h
    exact h
}

def aggregateTransformCompose
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R₁ R₂ : FoldCompatibleAggregateTransform resolve n) :
    FoldCompatibleAggregateTransform resolve n :=
{
  transform := fun p =>
    R₁.transform (R₂.transform p)

  compatible := by
    intro p q h
    exact R₁.compatible (R₂.transform p) (R₂.transform q)
      (R₂.compatible p q h)
}

/-! ============================================================
    Monoid laws
============================================================ -/

theorem aggregateTransform_left_identity
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : FoldCompatibleAggregateTransform resolve n) :
    aggregateTransformCompose resolve
      (aggregateTransformIdentity resolve n) R = R := by
  cases R
  rfl

theorem aggregateTransform_right_identity
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : FoldCompatibleAggregateTransform resolve n) :
    aggregateTransformCompose resolve
      R (aggregateTransformIdentity resolve n) = R := by
  cases R
  rfl

theorem aggregateTransform_associativity
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R₁ R₂ R₃ : FoldCompatibleAggregateTransform resolve n) :
    aggregateTransformCompose resolve
      (aggregateTransformCompose resolve R₁ R₂) R₃ =
    aggregateTransformCompose resolve
      R₁ (aggregateTransformCompose resolve R₂ R₃) := by
  rfl

/-! ============================================================
    Descent to boundary
============================================================ -/

def AggregateTransformDescends
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ∃ transformBoundary :
      (Fin n → TrajectoryBoundary resolve) →
      (Fin n → TrajectoryBoundary resolve),
    ∀ p,
      transformBoundary
        (projectThreadFamily resolve p)
      =
      projectThreadFamily resolve
        (transform p)

theorem aggregateTransformIdentity_descends
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    AggregateTransformDescends resolve (id : AggregateFamilyTransform resolve n) := by
  refine ⟨id, ?_⟩
  intro p
  rfl

theorem descends_implies_respectsKernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n)
    (hDesc : AggregateTransformDescends resolve transform) :
    AggregateTransformRespectsKernel resolve transform := by
  rcases hDesc with ⟨f, hf⟩
  intro p q h
  show projectThreadFamily resolve (transform p) =
       projectThreadFamily resolve (transform q)
  calc
    projectThreadFamily resolve (transform p)
        = f (projectThreadFamily resolve p) := (hf p).symm
    _ = f (projectThreadFamily resolve q) := by
          have heq : projectThreadFamily resolve p =
                     projectThreadFamily resolve q := h
          rw [heq]
    _ = projectThreadFamily resolve (transform q) := hf q

/-! ============================================================
    Aggregate rotation
============================================================ -/

structure AggregateRotation
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    extends FoldCompatibleAggregateTransform resolve n where

  nontrivial :
    ∃ p,
      transform p ≠ p

/-! ============================================================
    Reindex equivariance
============================================================ -/

def ReindexEquivariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ∀ (π : ThreadPermutation n) p,
    transform (permuteThreadFamily resolve π p)
    =
    permuteThreadFamily resolve π
      (transform p)

theorem identityAggregate_reindexEquivariant
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    ReindexEquivariant resolve (id : AggregateFamilyTransform resolve n) := by
  intro π p
  rfl

#check AggregateFamilyTransform
#check AggregateTransformRespectsKernel
#check FoldCompatibleAggregateTransform
#check aggregateTransformIdentity
#check aggregateTransformCompose
#check aggregateTransform_left_identity
#check aggregateTransform_right_identity
#check aggregateTransform_associativity
#check AggregateTransformDescends
#check aggregateTransformIdentity_descends
#check descends_implies_respectsKernel
#check AggregateRotation
#check ReindexEquivariant
#check identityAggregate_reindexEquivariant

#print axioms aggregateTransform_left_identity
#print axioms aggregateTransform_right_identity
#print axioms aggregateTransform_associativity
#print axioms aggregateTransformIdentity_descends
#print axioms descends_implies_respectsKernel
#print axioms identityAggregate_reindexEquivariant

/-! ============================================================
    Uniform componentwise
============================================================ -/

def IsUniformComponentwise
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ∃ r : List KernelExprContext → List KernelExprContext,
    ∀ p i,
      transform p i = r (p i)

theorem identityAggregate_uniformComponentwise
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    IsUniformComponentwise resolve (id : AggregateFamilyTransform resolve n) := by
  refine ⟨id, ?_⟩
  intro p i
  rfl

#check IsUniformComponentwise
#check identityAggregate_uniformComponentwise

#print axioms identityAggregate_uniformComponentwise

/-! ============================================================
    Genuinely aggregate
============================================================ -/

def IsGenuinelyAggregate
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ¬ IsUniformComponentwise resolve transform

#check IsGenuinelyAggregate

/-! ============================================================
    Aggregate folded-trivial classifier witness
============================================================ -/

def AggregateFoldedTrivialClassifierWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ∃ (R : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n),
      ThreadFamilyKernel resolve
        (R.transform p)
        p
      ∧
      C.classify (R.transform p)
        ≠
      C.classify p

#check AggregateFoldedTrivialClassifierWitness

theorem aggregateFoldedTrivial_implies_independent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : AggregateFoldedTrivialClassifierWitness resolve C) :
    FamilyClassifierIndependentWitness resolve C := by
  rcases h with ⟨R, p, hKernel, hNe⟩
  exact ⟨R.transform p, p, hKernel, hNe⟩

#check aggregateFoldedTrivial_implies_independent
#print axioms aggregateFoldedTrivial_implies_independent

theorem aggregateFoldedTrivial_refutes_invariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : AggregateFoldedTrivialClassifierWitness resolve C) :
    ¬ FamilyClassifierInvariant resolve C := by
  intro hInv
  have hInd := aggregateFoldedTrivial_implies_independent resolve C h
  rcases hInd with ⟨p, q, hKernel, hNe⟩
  exact hNe (hInv p q hKernel)

theorem aggregateFoldedTrivial_refutes_factorisation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : AggregateFoldedTrivialClassifierWitness resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C := by
  intro hFactor
  have hInv := familyClassifier_factorisation_implies_invariant resolve C hFactor
  exact aggregateFoldedTrivial_refutes_invariant resolve C h hInv

#check aggregateFoldedTrivial_refutes_invariant
#check aggregateFoldedTrivial_refutes_factorisation
#print axioms aggregateFoldedTrivial_refutes_invariant
#print axioms aggregateFoldedTrivial_refutes_factorisation

/-! ============================================================
    Aggregate chirality specification
============================================================ -/

structure AggregateChiralitySpecification
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where

  classifier :
    RelationalClassifier (ThreadFamily resolve n)

  foldedTrivialSensitive :
    AggregateFoldedTrivialClassifierWitness
      resolve
      classifier

#check AggregateChiralitySpecification

/-! ============================================================
    Aggregate chirality specification existence
============================================================ -/

def AggregateChiralitySpecificationExists
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  Nonempty (AggregateChiralitySpecification resolve n)


/-! ============================================================
    Uniform rotation as aggregate
============================================================ -/

def uniformRotationAsAggregate
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r : FoldCompatibleRotation resolve) :
    FoldCompatibleAggregateTransform resolve n :=
{
  transform := rotateThreadFamily resolve r
  compatible := by
    intro p q h
    unfold ThreadFamilyKernel projectThreadFamily rotateThreadFamily at *
    funext i
    have hProj : trajectoryProjection resolve (p i) = trajectoryProjection resolve (q i) :=
      congrFun h i
    exact r.compatible (p i) (q i) hProj
}

#check uniformRotationAsAggregate
#print axioms uniformRotationAsAggregate

/-! ============================================================
    Permutation as aggregate
============================================================ -/

theorem permuteThreadFamily_respects_kernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    {p q : ThreadFamily resolve n}
    (h : ThreadFamilyKernel resolve p q) :
    ThreadFamilyKernel resolve
      (permuteThreadFamily resolve π p)
      (permuteThreadFamily resolve π q) := by
  unfold ThreadFamilyKernel projectThreadFamily permuteThreadFamily reindexThreadFamily at *
  funext i
  exact congrFun h (π.toFun i)

def permutationAsAggregate
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n) :
    FoldCompatibleAggregateTransform resolve n :=
{
  transform := permuteThreadFamily resolve π
  compatible := by
    intro p q h
    exact permuteThreadFamily_respects_kernel resolve π h
}

#check permutationAsAggregate
#print axioms permutationAsAggregate

theorem aggregateTransformIdentity_apply
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (p : ThreadFamily resolve n) :
    (aggregateTransformIdentity resolve n).transform p = p := by
  rfl

theorem aggregateTransformCompose_apply
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A B : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) :
    (aggregateTransformCompose resolve A B).transform p =
    A.transform (B.transform p) := by
  rfl

theorem uniformRotationAsAggregate_apply
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r : FoldCompatibleRotation resolve)
    (p : ThreadFamily resolve n) :
    (uniformRotationAsAggregate resolve r).transform p =
    rotateThreadFamily resolve r p := by
  rfl

theorem aggregateTransform_descent_implies_kernelCompatible
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n)
    (h : AggregateTransformDescends resolve transform) :
    AggregateTransformRespectsKernel resolve transform := by
  rcases h with ⟨transformBoundary, hDesc⟩
  intro p q hKernel
  unfold ThreadFamilyKernel at *
  rw [← hDesc p, ← hDesc q]
  exact congrArg transformBoundary hKernel

theorem uniformRotationAsAggregate_isUniform
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r : FoldCompatibleRotation resolve) :
    IsUniformComponentwise resolve
      (uniformRotationAsAggregate resolve (n := n) r).transform := by
  exact ⟨r.rotate, fun p i => rfl⟩

def GenuinelyAggregateFoldedTrivialClassifierWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ∃ (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n),
      IsGenuinelyAggregate resolve A.transform
      ∧
      ThreadFamilyKernel resolve (A.transform p) p
      ∧
      C.classify (A.transform p) ≠ C.classify p

def AggregateRealises
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p q : ThreadFamily resolve n) : Prop :=
  A.transform p = q

#check AggregateFamilyTransform
#check AggregateTransformRespectsKernel
#check FoldCompatibleAggregateTransform
#check AggregateTransformDescends
#check IsUniformComponentwise
#check IsGenuinelyAggregate
#check AggregateFoldedTrivialClassifierWitness
#check AggregateChiralitySpecification
#check AggregateChiralitySpecificationExists

#print axioms aggregateTransformIdentity_apply
#print axioms aggregateTransform_left_identity
#print axioms aggregateTransform_associativity
#print axioms aggregateTransform_descent_implies_kernelCompatible
#print axioms uniformRotationAsAggregate
#print axioms permutationAsAggregate
#print axioms aggregateFoldedTrivial_refutes_factorisation

/-! ============================================================
    Projected family surjectivity
============================================================ -/

theorem projectThreadFamily_surjective
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    Function.Surjective
      (projectThreadFamily resolve :
        ThreadFamily resolve n → (Fin n → TrajectoryBoundary resolve)) := by
  intro q
  refine ⟨fun i => Classical.choose (trajectoryProjection_surjective resolve (q i)), ?_⟩
  funext i
  exact Classical.choose_spec (trajectoryProjection_surjective resolve (q i))

/-! ============================================================
    Canonical representative family
============================================================ -/

noncomputable def chooseRawThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (q : Fin n → TrajectoryBoundary resolve) :
    ThreadFamily resolve n :=
  fun i => Classical.choose (trajectoryProjection_surjective resolve (q i))

theorem project_chooseRawThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (q : Fin n → TrajectoryBoundary resolve) :
    projectThreadFamily resolve (chooseRawThreadFamily resolve q) = q := by
  funext i
  exact Classical.choose_spec (trajectoryProjection_surjective resolve (q i))

/-! ============================================================
    Kernel compatibility implies descent
============================================================ -/

theorem aggregateTransform_kernelCompatible_implies_descent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) :
    AggregateTransformRespectsKernel resolve transform →
    AggregateTransformDescends resolve transform := by
  intro hCompat
  refine ⟨fun q => projectThreadFamily resolve (transform (chooseRawThreadFamily resolve q)), ?_⟩
  intro p
  have hKernel : ThreadFamilyKernel resolve (chooseRawThreadFamily resolve (projectThreadFamily resolve p)) p := by
    unfold ThreadFamilyKernel
    rw [project_chooseRawThreadFamily]
  exact hCompat _ _ hKernel

/-! ============================================================
    Descent iff
============================================================ -/

theorem aggregateTransform_descends_iff_kernelCompatible
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) :
    AggregateTransformDescends resolve transform ↔
    AggregateTransformRespectsKernel resolve transform := by
  constructor
  · exact aggregateTransform_descent_implies_kernelCompatible resolve transform
  · exact aggregateTransform_kernelCompatible_implies_descent resolve transform

/-! ============================================================
    Canonical descended transform
============================================================ -/

noncomputable def descendAggregateTransform
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n) :
    (Fin n → TrajectoryBoundary resolve) → (Fin n → TrajectoryBoundary resolve) :=
  fun q => projectThreadFamily resolve (A.transform (chooseRawThreadFamily resolve q))

theorem descendAggregateTransform_mk
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) :
    descendAggregateTransform resolve A (projectThreadFamily resolve p) =
    projectThreadFamily resolve (A.transform p) := by
  have hKernel : ThreadFamilyKernel resolve (chooseRawThreadFamily resolve (projectThreadFamily resolve p)) p := by
    unfold ThreadFamilyKernel
    rw [project_chooseRawThreadFamily]
  exact A.compatible _ _ hKernel

/-! ============================================================
    Uniqueness of descent
============================================================ -/

theorem descendAggregateTransform_unique
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (f : (Fin n → TrajectoryBoundary resolve) → (Fin n → TrajectoryBoundary resolve))
    (h : ∀ p, f (projectThreadFamily resolve p) = projectThreadFamily resolve (A.transform p)) :
    f = descendAggregateTransform resolve A := by
  funext q
  have ⟨p, hp⟩ := projectThreadFamily_surjective resolve n q
  rw [← hp]
  rw [h p, descendAggregateTransform_mk]

/-! ============================================================
    Descent of identity
============================================================ -/

theorem descendAggregateTransform_identity
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    descendAggregateTransform resolve (aggregateTransformIdentity resolve n) = id := by
  funext q
  simp [descendAggregateTransform, aggregateTransformIdentity]
  exact project_chooseRawThreadFamily resolve q

/-! ============================================================
    Descent of composition
============================================================ -/

theorem descendAggregateTransform_compose
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A B : FoldCompatibleAggregateTransform resolve n) :
    descendAggregateTransform resolve (aggregateTransformCompose resolve A B) =
    fun q => descendAggregateTransform resolve A (descendAggregateTransform resolve B q) := by
  funext q
  show projectThreadFamily resolve (A.transform (B.transform (chooseRawThreadFamily resolve q))) =
       projectThreadFamily resolve (A.transform (chooseRawThreadFamily resolve (projectThreadFamily resolve (B.transform (chooseRawThreadFamily resolve q)))))
  have hKernel : ThreadFamilyKernel resolve
      (chooseRawThreadFamily resolve (projectThreadFamily resolve (B.transform (chooseRawThreadFamily resolve q))))
      (B.transform (chooseRawThreadFamily resolve q)) := by
    unfold ThreadFamilyKernel
    rw [project_chooseRawThreadFamily]
  have hCompat := A.compatible _ _ hKernel
  unfold ThreadFamilyKernel at hCompat
  exact hCompat.symm

/-! ============================================================
    Componentwise to aggregate witness
============================================================ -/

theorem foldedTrivialRotationWitness_to_aggregateWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    FoldedTrivialRotationClassifierWitness resolve C →
    AggregateFoldedTrivialClassifierWitness resolve C := by
  intro ⟨r, p, hKernel, hNe⟩
  exact ⟨uniformRotationAsAggregate resolve r, p, hKernel, hNe⟩

/-! ============================================================
    Minimal to aggregate specification
============================================================ -/

def minimalChiralityToAggregate
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : MinimalChiralitySpecification resolve n) :
    AggregateChiralitySpecification resolve n :=
{
  classifier := spec.classifier
  foldedTrivialSensitive :=
    foldedTrivialRotationWitness_to_aggregateWitness resolve spec.classifier spec.foldedTrivialSensitive
}

/-! ============================================================
    Existence implication
============================================================ -/

theorem minimalChiralityExists_implies_aggregateChiralityExists
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    Nonempty (MinimalChiralitySpecification resolve n) →
    AggregateChiralitySpecificationExists resolve n := by
  intro ⟨spec⟩
  exact ⟨minimalChiralityToAggregate resolve n spec⟩

/-! ============================================================
    Aggregate specification consequences
============================================================ -/

theorem aggregateChirality_classifier_independent
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : AggregateChiralitySpecification resolve n) :
    FamilyClassifierIndependentWitness resolve spec.classifier :=
  aggregateFoldedTrivial_implies_independent resolve spec.classifier spec.foldedTrivialSensitive

theorem aggregateChirality_classifier_noninvariant
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : AggregateChiralitySpecification resolve n) :
    ¬ FamilyClassifierInvariant resolve spec.classifier :=
  aggregateFoldedTrivial_refutes_invariant resolve spec.classifier spec.foldedTrivialSensitive

theorem aggregateChirality_classifier_nonfactorising
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : AggregateChiralitySpecification resolve n) :
    ¬ FamilyClassifierFactorsThroughProjections resolve spec.classifier :=
  aggregateFoldedTrivial_refutes_factorisation resolve spec.classifier spec.foldedTrivialSensitive

#check projectThreadFamily_surjective
#check aggregateTransform_kernelCompatible_implies_descent
#check aggregateTransform_descends_iff_kernelCompatible
#check descendAggregateTransform
#check descendAggregateTransform_mk
#check descendAggregateTransform_unique
#check descendAggregateTransform_identity
#check descendAggregateTransform_compose
#check foldedTrivialRotationWitness_to_aggregateWitness
#check minimalChiralityToAggregate
#check minimalChiralityExists_implies_aggregateChiralityExists
#check aggregateChirality_classifier_nonfactorising

#print axioms projectThreadFamily_surjective
#print axioms aggregateTransform_kernelCompatible_implies_descent
#print axioms aggregateTransform_descends_iff_kernelCompatible
#print axioms descendAggregateTransform_mk
#print axioms descendAggregateTransform_unique
#print axioms descendAggregateTransform_identity
#print axioms descendAggregateTransform_compose
#print axioms foldedTrivialRotationWitness_to_aggregateWitness
#print axioms minimalChiralityExists_implies_aggregateChiralityExists
#print axioms aggregateChirality_classifier_nonfactorising

/-! ============================================================
    Indexed componentwise
============================================================ -/

def IsIndexedComponentwise
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ∃ localMap : Fin n → List KernelExprContext → List KernelExprContext,
    ∀ p i,
      transform p i = localMap i (p i)

theorem uniformComponentwise_implies_indexedComponentwise
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {transform : AggregateFamilyTransform resolve n} :
    IsUniformComponentwise resolve transform →
    IsIndexedComponentwise resolve transform := by
  intro ⟨r, hr⟩
  exact ⟨fun _ => r, hr⟩

/-! ============================================================
    Reindexed componentwise
============================================================ -/

def IsReindexedComponentwise
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ∃ (σ : Fin n → Fin n)
    (localMap : Fin n → List KernelExprContext → List KernelExprContext),
    ∀ p i,
      transform p i = localMap i (p (σ i))

theorem indexedComponentwise_implies_reindexedComponentwise
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {transform : AggregateFamilyTransform resolve n} :
    IsIndexedComponentwise resolve transform →
    IsReindexedComponentwise resolve transform := by
  intro ⟨localMap, hlocalMap⟩
  exact ⟨id, localMap, hlocalMap⟩

/-! ============================================================
    Uniform rotation classification
============================================================ -/

theorem uniformRotationAsAggregate_isIndexed
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r : FoldCompatibleRotation resolve) :
    IsIndexedComponentwise resolve
      (uniformRotationAsAggregate resolve (n := n) r).transform := by
  exact ⟨fun _ => r.rotate, fun p i => rfl⟩

theorem uniformRotationAsAggregate_isReindexed
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r : FoldCompatibleRotation resolve) :
    IsReindexedComponentwise resolve
      (uniformRotationAsAggregate resolve (n := n) r).transform := by
  exact indexedComponentwise_implies_reindexedComponentwise resolve
    (uniformRotationAsAggregate_isIndexed resolve n r)

/-! ============================================================
    Permutation classification
============================================================ -/

theorem permutationAsAggregate_isReindexed
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n) :
    IsReindexedComponentwise resolve
      (permutationAsAggregate resolve π).transform := by
  exact ⟨π.toFun, fun _ xs => xs, fun p i => rfl⟩

/-! ============================================================
    Relationally aggregate
============================================================ -/

def IsRelationallyAggregate
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ¬ IsReindexedComponentwise resolve transform

theorem relationallyAggregate_implies_genuinelyAggregate
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {transform : AggregateFamilyTransform resolve n} :
    IsRelationallyAggregate resolve transform →
    IsGenuinelyAggregate resolve transform := by
  intro hRel hUniform
  exact hRel (indexedComponentwise_implies_reindexedComponentwise resolve
    (uniformComponentwise_implies_indexedComponentwise resolve hUniform))

/-! ============================================================
    Strong relational witness
============================================================ -/

def RelationallyAggregateFoldedTrivialClassifierWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ∃ (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n),
      IsRelationallyAggregate resolve A.transform
      ∧
      ThreadFamilyKernel resolve (A.transform p) p
      ∧
      C.classify (A.transform p) ≠ C.classify p

theorem relationallyAggregateWitness_implies_genuinelyAggregateWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    RelationallyAggregateFoldedTrivialClassifierWitness resolve C →
    GenuinelyAggregateFoldedTrivialClassifierWitness resolve C := by
  intro ⟨A, p, hRel, hKernel, hNe⟩
  exact ⟨A, p, relationallyAggregate_implies_genuinelyAggregate resolve hRel, hKernel, hNe⟩

theorem relationallyAggregateWitness_implies_aggregateWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    RelationallyAggregateFoldedTrivialClassifierWitness resolve C →
    AggregateFoldedTrivialClassifierWitness resolve C := by
  intro ⟨A, p, _, hKernel, hNe⟩
  exact ⟨A, p, hKernel, hNe⟩

theorem relationallyAggregateWitness_implies_independent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    RelationallyAggregateFoldedTrivialClassifierWitness resolve C →
    FamilyClassifierIndependentWitness resolve C := by
  intro h
  exact aggregateFoldedTrivial_implies_independent resolve C
    (relationallyAggregateWitness_implies_aggregateWitness resolve C h)

theorem relationallyAggregateWitness_refutes_invariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    RelationallyAggregateFoldedTrivialClassifierWitness resolve C →
    ¬ FamilyClassifierInvariant resolve C := by
  intro h
  exact aggregateFoldedTrivial_refutes_invariant resolve C
    (relationallyAggregateWitness_implies_aggregateWitness resolve C h)

theorem relationallyAggregateWitness_refutes_factorisation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    RelationallyAggregateFoldedTrivialClassifierWitness resolve C →
    ¬ FamilyClassifierFactorsThroughProjections resolve C := by
  intro h
  exact aggregateFoldedTrivial_refutes_factorisation resolve C
    (relationallyAggregateWitness_implies_aggregateWitness resolve C h)

/-! ============================================================
    Strong aggregate chirality specification
============================================================ -/

structure RelationalAggregateChiralitySpecification
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where

  classifier :
    RelationalClassifier (ThreadFamily resolve n)

  foldedTrivialSensitive :
    RelationallyAggregateFoldedTrivialClassifierWitness resolve classifier

def RelationalAggregateChiralitySpecificationExists
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  Nonempty (RelationalAggregateChiralitySpecification resolve n)

/-! ============================================================
    Specification embedding
============================================================ -/

def relationalAggregateToAggregate
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (spec : RelationalAggregateChiralitySpecification resolve n) :
    AggregateChiralitySpecification resolve n :=
{
  classifier := spec.classifier
  foldedTrivialSensitive :=
    relationallyAggregateWitness_implies_aggregateWitness resolve spec.classifier spec.foldedTrivialSensitive
}

#check IsIndexedComponentwise
#check IsReindexedComponentwise
#check IsRelationallyAggregate
#check RelationallyAggregateFoldedTrivialClassifierWitness
#check RelationalAggregateChiralitySpecification
#check RelationalAggregateChiralitySpecificationExists

#print axioms uniformComponentwise_implies_indexedComponentwise
#print axioms indexedComponentwise_implies_reindexedComponentwise
#print axioms relationallyAggregate_implies_genuinelyAggregate
#print axioms relationallyAggregateWitness_refutes_factorisation


/-! ============================================================
    Context-sensitivity criterion
============================================================ -/

def OutputDependsOnOtherComponent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ∃ (p q : ThreadFamily resolve n)
    (i j : Fin n),
      p i = q i
      ∧
      p j ≠ q j
      ∧
      transform p i ≠ transform q i

theorem outputDependsOnOtherComponent_refutes_indexed
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {transform : AggregateFamilyTransform resolve n} :
    OutputDependsOnOtherComponent resolve transform →
    ¬ IsIndexedComponentwise resolve transform := by
  intro ⟨p, q, i, j, hSame, hDiff, hOut⟩
  intro ⟨localMap, hlocalMap⟩
  have h1 : transform p i = localMap i (p i) := hlocalMap p i
  have h2 : transform q i = localMap i (q i) := hlocalMap q i
  rw [h1, h2, hSame] at hOut
  exact hOut rfl

/-! ============================================================
    Multi-input requirement
============================================================ -/

def OutputRequiresMultipleInputs
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (transform : AggregateFamilyTransform resolve n) : Prop :=
  ∀ (σ : Fin n → Fin n)
    (localMap : Fin n → List KernelExprContext → List KernelExprContext),
    ∃ (p : ThreadFamily resolve n)
      (i : Fin n),
      transform p i ≠ localMap i (p (σ i))

/-! ============================================================
    Family branch invariant
============================================================ -/

def FamilyBranchInvariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (selector : ThreadFamily resolve n → Bool) : Prop :=
  ∀ p q,
    ThreadFamilyKernel resolve p q →
    selector p = selector q

/-! ============================================================
    RawAllEqual is not ThreadFamilyKernel-invariant
============================================================ -/

theorem rawAllEqual_not_kernelInvariant
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    ¬ ∀ (p q : ThreadFamily resolve n), ThreadFamilyKernel resolve p q → (RawAllEqual resolve p ↔ RawAllEqual resolve q) := by
  intro hInv
  have hKernel := familyEqual_kernel_familyUnequal resolve n h
  have hEq : RawAllEqual resolve (familyEqual resolve n) ↔ RawAllEqual resolve (familyUnequal resolve n h) :=
    hInv _ _ hKernel
  have hTrue : RawAllEqual resolve (familyEqual resolve n) := by
    intro i j
    rfl
  have hFalse : ¬ RawAllEqual resolve (familyUnequal resolve n h) := by
    intro hAll
    have h01 : (familyUnequal resolve n h) ⟨0, by omega⟩ = (familyUnequal resolve n h) ⟨1, by omega⟩ :=
      hAll ⟨0, by omega⟩ ⟨1, by omega⟩
    simp [familyUnequal] at h01
  exact hFalse (hEq.mp hTrue)

/-! ============================================================
    Equality-partition split candidate countermodel
============================================================ -/

/--
The natural equality-partition split candidate branches on RawAllEqual.
This is not ThreadFamilyKernel-invariant, so the candidate cannot be
globally fold-compatible.
-/
theorem equalityPartitionSplit_fails_kernelCompatibility
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    ∃ (p q : ThreadFamily resolve n),
      ThreadFamilyKernel resolve p q
      ∧
      RawAllEqual resolve p
      ∧
      ¬ RawAllEqual resolve q := by
  exact ⟨familyEqual resolve n, familyUnequal resolve n h,
    familyEqual_kernel_familyUnequal resolve n h,
    fun i j => rfl,
    fun hAll => by
      have h01 := hAll ⟨0, by omega⟩ ⟨1, by omega⟩
      simp [familyUnequal] at h01⟩

#check OutputDependsOnOtherComponent
#check OutputRequiresMultipleInputs
#check FamilyBranchInvariant
#check rawAllEqual_not_kernelInvariant
#check equalityPartitionSplit_fails_kernelCompatibility

#print axioms outputDependsOnOtherComponent_refutes_indexed
#print axioms rawAllEqual_not_kernelInvariant
#print axioms equalityPartitionSplit_fails_kernelCompatibility

/-! ============================================================
    Generic boolean conditional transform
============================================================ -/

def conditionalAggregateTransform
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (selector : ThreadFamily resolve n → Bool)
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) :
    AggregateFamilyTransform resolve n :=
  fun p => if selector p then ifTrue p else ifFalse p

theorem conditionalAggregateTransform_true
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    {selector : ThreadFamily resolve n → Bool}
    {ifTrue ifFalse : AggregateFamilyTransform resolve n}
    {p : ThreadFamily resolve n}
    (h : selector p = true) :
    conditionalAggregateTransform selector ifTrue ifFalse p = ifTrue p := by
  simp [conditionalAggregateTransform, h]

theorem conditionalAggregateTransform_false
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    {selector : ThreadFamily resolve n → Bool}
    {ifTrue ifFalse : AggregateFamilyTransform resolve n}
    {p : ThreadFamily resolve n}
    (h : selector p = false) :
    conditionalAggregateTransform selector ifTrue ifFalse p = ifFalse p := by
  simp [conditionalAggregateTransform, h]

/-! ============================================================
    Branch compatibility
============================================================ -/

def AggregateBranchCompatible
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (branch : AggregateFamilyTransform resolve n) : Prop :=
  AggregateTransformRespectsKernel resolve branch

/-! ============================================================
    Conditional coherence
============================================================ -/

def ConditionalAggregateCoherent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (selector : ThreadFamily resolve n → Bool)
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) : Prop :=
  ∀ p q,
    ThreadFamilyKernel resolve p q →
    ThreadFamilyKernel resolve
      (conditionalAggregateTransform selector ifTrue ifFalse p)
      (conditionalAggregateTransform selector ifTrue ifFalse q)

theorem conditionalAggregate_coherent_iff_respectsKernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (selector : ThreadFamily resolve n → Bool)
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) :
    ConditionalAggregateCoherent resolve selector ifTrue ifFalse
    ↔
    AggregateTransformRespectsKernel resolve
      (conditionalAggregateTransform selector ifTrue ifFalse) := by
  rfl

/-! ============================================================
    Same-branch and cross-branch coherence
============================================================ -/

def ConditionalSameBranchCompatible
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (selector : ThreadFamily resolve n → Bool)
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) : Prop :=
  AggregateTransformRespectsKernel resolve ifTrue
  ∧
  AggregateTransformRespectsKernel resolve ifFalse

def ConditionalCrossBranchCoherent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (selector : ThreadFamily resolve n → Bool)
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) : Prop :=
  ∀ p q,
    ThreadFamilyKernel resolve p q →
    selector p ≠ selector q →
    ThreadFamilyKernel resolve
      (conditionalAggregateTransform selector ifTrue ifFalse p)
      (conditionalAggregateTransform selector ifTrue ifFalse q)

/-! ============================================================
    Sufficient selector-invariant theorem
============================================================ -/

theorem invariantSelector_and_compatibleBranches_respectsKernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {selector : ThreadFamily resolve n → Bool}
    {ifTrue ifFalse : AggregateFamilyTransform resolve n}
    (hSelector : FamilyBranchInvariant resolve selector)
    (hTrue : AggregateTransformRespectsKernel resolve ifTrue)
    (hFalse : AggregateTransformRespectsKernel resolve ifFalse) :
    AggregateTransformRespectsKernel resolve
      (conditionalAggregateTransform selector ifTrue ifFalse) := by
  intro p q hKernel
  have hSel := hSelector p q hKernel
  unfold conditionalAggregateTransform
  rw [hSel]
  by_cases h : selector q
  · simp [h]
    exact hTrue p q hKernel
  · simp [h]
    exact hFalse p q hKernel

/-! ============================================================
    Boundary-equivalent branches
============================================================ -/

def AggregateBranchesBoundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) : Prop :=
  ∀ p,
    ThreadFamilyKernel resolve (ifTrue p) (ifFalse p)

def AggregateBranchesCrossBoundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) : Prop :=
  ∀ p q,
    ThreadFamilyKernel resolve p q →
    ThreadFamilyKernel resolve (ifTrue p) (ifFalse q)

theorem boundaryEquivalentBranches_allow_arbitrarySelector
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {selector : ThreadFamily resolve n → Bool}
    {ifTrue ifFalse : AggregateFamilyTransform resolve n}
    (hTrue : AggregateTransformRespectsKernel resolve ifTrue)
    (hFalse : AggregateTransformRespectsKernel resolve ifFalse)
    (hCross : AggregateBranchesCrossBoundaryEquivalent resolve ifTrue ifFalse) :
    AggregateTransformRespectsKernel resolve
      (conditionalAggregateTransform selector ifTrue ifFalse) := by
  intro p q hKernel
  unfold conditionalAggregateTransform
  by_cases hp : selector p <;> by_cases hq : selector q
  · simp [hp, hq]
    exact hTrue p q hKernel
  · simp [hp, hq]
    exact hCross p q hKernel
  · simp [hp, hq]
    have hSym := hCross q p (by unfold ThreadFamilyKernel at *; exact hKernel.symm)
    unfold ThreadFamilyKernel at *
    exact hSym.symm
  · simp [hp, hq]
    exact hFalse p q hKernel

/-! ============================================================
    Raw-distinct but folded-equivalent branches
============================================================ -/

def RawDistinctBoundaryEquivalentBranches
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) : Prop :=
  AggregateBranchesBoundaryEquivalent resolve ifTrue ifFalse
  ∧
  ∃ p, ifTrue p ≠ ifFalse p

def ClassifierDistinguishesBranches
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) : Prop :=
  ∃ p, C.classify (ifTrue p) ≠ C.classify (ifFalse p)

def HiddenRelationalBranchPair
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (ifTrue ifFalse : AggregateFamilyTransform resolve n) : Prop :=
  AggregateBranchesBoundaryEquivalent resolve ifTrue ifFalse
  ∧
  ClassifierDistinguishesBranches C ifTrue ifFalse

#check conditionalAggregateTransform
#check conditionalAggregateTransform_true
#check conditionalAggregateTransform_false
#check ConditionalAggregateCoherent
#check conditionalAggregate_coherent_iff_respectsKernel
#check ConditionalSameBranchCompatible
#check ConditionalCrossBranchCoherent
#check invariantSelector_and_compatibleBranches_respectsKernel
#check AggregateBranchesBoundaryEquivalent
#check AggregateBranchesCrossBoundaryEquivalent
#check boundaryEquivalentBranches_allow_arbitrarySelector
#check RawDistinctBoundaryEquivalentBranches
#check HiddenRelationalBranchPair

#print axioms conditionalAggregateTransform_true
#print axioms invariantSelector_and_compatibleBranches_respectsKernel
#print axioms boundaryEquivalentBranches_allow_arbitrarySelector

/-! ============================================================
    Kernel-trivial raw operation
============================================================ -/

def appendIdentity
    (xs : List KernelExprContext) : List KernelExprContext :=
  xs ++ [identityContext]

theorem appendIdentity_same_projection
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    trajectoryProjection resolve (appendIdentity xs) =
    trajectoryProjection resolve xs := by
  unfold appendIdentity trajectoryProjection toTrajectoryBoundary
  apply Quotient.sound
  intro q
  simp [evolvePersistent, plugPersistent, identityContext]
  induction q using Quotient.ind with
  | _ e => rfl

/-! ============================================================
    Indexed kernel-trivial branch
============================================================ -/

def indexedKernelTrivialBranch
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) :
    ThreadFamily resolve n :=
  fun i => if i.val = 0 then p i else appendIdentity (p i)

theorem indexedKernelTrivialBranch_respects_kernel
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    AggregateTransformRespectsKernel resolve
      (indexedKernelTrivialBranch resolve (n := n)) := by
  intro p q hKernel
  unfold ThreadFamilyKernel projectThreadFamily indexedKernelTrivialBranch at *
  funext i
  by_cases hi : i.val = 0
  · simp [hi]
    exact congrFun hKernel i
  · simp [hi]
    rw [appendIdentity_same_projection, appendIdentity_same_projection]
    exact congrFun hKernel i

theorem indexedKernelTrivialBranch_boundaryEquivalent_identity
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    AggregateBranchesBoundaryEquivalent resolve
      (indexedKernelTrivialBranch resolve (n := n))
      id := by
  intro p
  unfold ThreadFamilyKernel projectThreadFamily indexedKernelTrivialBranch
  funext i
  by_cases hi : i.val = 0
  · simp [hi]
  · simp [hi]
    exact appendIdentity_same_projection resolve (p i)

/-! ============================================================
    RawAllEqual change
============================================================ -/

theorem indexedKernelTrivialBranch_changes_rawAllEqual
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    RawAllEqual resolve (familyEqual resolve n)
    ∧
    ¬ RawAllEqual resolve (indexedKernelTrivialBranch resolve (familyEqual resolve n)) := by
  constructor
  · intro i j
    rfl
  · intro hAll
    have h01 : (indexedKernelTrivialBranch resolve (familyEqual resolve n)) ⟨0, by omega⟩ =
               (indexedKernelTrivialBranch resolve (familyEqual resolve n)) ⟨1, by omega⟩ :=
      hAll ⟨0, by omega⟩ ⟨1, by omega⟩
    simp [indexedKernelTrivialBranch, familyEqual, appendIdentity] at h01

/-! ============================================================
    Hidden relational branch pair
============================================================ -/

theorem indexedKernelTrivialBranch_hiddenRelational
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    HiddenRelationalBranchPair resolve
      (rawAllEqualClassifier resolve n)
      (indexedKernelTrivialBranch resolve)
      id := by
  constructor
  · exact indexedKernelTrivialBranch_boundaryEquivalent_identity resolve n
  · refine ⟨familyEqual resolve n, ?_⟩
    simp only [rawAllEqualClassifier, relationClassifier]
    have hTrue : RawAllEqual resolve (familyEqual resolve n) := fun i j => rfl
    have hFalse : ¬ RawAllEqual resolve (indexedKernelTrivialBranch resolve (familyEqual resolve n)) :=
      (indexedKernelTrivialBranch_changes_rawAllEqual resolve n h).2
    intro hEq
    exact hFalse (hEq ▸ hTrue)

/-! ============================================================
    Aggregate folded-trivial classifier witness
============================================================ -/

theorem indexedKernelTrivialBranch_aggregateWitness
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    AggregateFoldedTrivialClassifierWitness resolve
      (rawAllEqualClassifier resolve n) := by
  refine ⟨{ transform := indexedKernelTrivialBranch resolve
            compatible := indexedKernelTrivialBranch_respects_kernel resolve n },
          familyEqual resolve n, ?_, ?_⟩
  · exact indexedKernelTrivialBranch_boundaryEquivalent_identity resolve n _
  · simp only [rawAllEqualClassifier, relationClassifier]
    have hTrue : RawAllEqual resolve (familyEqual resolve n) := fun i j => rfl
    have hFalse : ¬ RawAllEqual resolve (indexedKernelTrivialBranch resolve (familyEqual resolve n)) :=
      (indexedKernelTrivialBranch_changes_rawAllEqual resolve n h).2
    intro hEq
    exact hFalse (hEq ▸ hTrue)

/-! ============================================================
    Aggregate chirality specification existence
============================================================ -/

theorem aggregateChiralitySpecificationExists_of_two_le
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (hn : 1 < n) :
    AggregateChiralitySpecificationExists resolve n := by
  exact ⟨{ classifier := rawAllEqualClassifier resolve n
           foldedTrivialSensitive := indexedKernelTrivialBranch_aggregateWitness resolve n hn }⟩

/-! ============================================================
    Classification
============================================================ -/

theorem indexedKernelTrivialBranch_isIndexed
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    IsIndexedComponentwise resolve
      (indexedKernelTrivialBranch resolve (n := n)) := by
  exact ⟨fun i xs => if i.val = 0 then xs else appendIdentity xs, fun p i => rfl⟩

#check appendIdentity_same_projection
#check indexedKernelTrivialBranch_respects_kernel
#check indexedKernelTrivialBranch_boundaryEquivalent_identity
#check indexedKernelTrivialBranch_changes_rawAllEqual
#check indexedKernelTrivialBranch_hiddenRelational
#check indexedKernelTrivialBranch_aggregateWitness
#check aggregateChiralitySpecificationExists_of_two_le
#check indexedKernelTrivialBranch_isIndexed

#print axioms appendIdentity_same_projection
#print axioms indexedKernelTrivialBranch_respects_kernel
#print axioms indexedKernelTrivialBranch_changes_rawAllEqual
#print axioms indexedKernelTrivialBranch_aggregateWitness
#print axioms aggregateChiralitySpecificationExists_of_two_le


/-! ============================================================
    Computable invariant selector framework
============================================================ -/

structure ComputableInvariantSelector
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where

  select : ThreadFamily resolve n → Bool

  invariant :
    ∀ p q,
      ThreadFamilyKernel resolve p q →
      select p = select q

def SelectorNonconstant
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (S : ComputableInvariantSelector resolve n) : Prop :=
  ∃ p q, S.select p ≠ S.select q

structure UsefulInvariantSelector
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    extends ComputableInvariantSelector resolve n where

  nonconstant : SelectorNonconstant toComputableInvariantSelector

/-! ============================================================
    Constant baseline
============================================================ -/

def constantFalseSelector
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    ComputableInvariantSelector resolve n where

  select := fun _ => false

  invariant := fun _ _ _ => rfl

def constantTrueSelector
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    ComputableInvariantSelector resolve n where

  select := fun _ => true

  invariant := fun _ _ _ => rfl

theorem constantFalseSelector_not_nonconstant
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    ¬ SelectorNonconstant (constantFalseSelector resolve n) := by
  intro ⟨p, q, h⟩
  simp [constantFalseSelector] at h

theorem constantTrueSelector_not_nonconstant
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    ¬ SelectorNonconstant (constantTrueSelector resolve n) := by
  intro ⟨p, q, h⟩
  simp [constantTrueSelector] at h

/-! ============================================================
    Audit result
============================================================ -/

/--
The current exported API exposes no computable finite observable on
TrajectoryBoundary that is both:
1. constructively evaluable;
2. nonconstant.

TrajectoryBoundary is a quotient type. Equality on quotient values is not
constructively decidable without classical axioms.

Raw observables (RawAllEqual, length, parity) are either:
- not constructively decidable; or
- not ThreadFamilyKernel-invariant.

Therefore no useful computable invariant selector exists in the current API.
-/
def NoUsefulComputableInvariantSelectorFound : Prop :=
  ∀ (resolve : KernelExpr → Store → Location) (n : Nat),
    ¬ Nonempty (UsefulInvariantSelector resolve n)

#check ComputableInvariantSelector
#check UsefulInvariantSelector
#check constantFalseSelector
#check constantTrueSelector
#check constantFalseSelector_not_nonconstant
#check constantTrueSelector_not_nonconstant
#check NoUsefulComputableInvariantSelectorFound

#print axioms constantFalseSelector_not_nonconstant
#print axioms constantTrueSelector_not_nonconstant

/-! ============================================================
    Neighbour index map
============================================================ -/

def nextIndex {n : Nat} (h : 1 < n) (i : Fin n) : Fin n :=
  ⟨if i.val + 1 < n then i.val + 1 else 0, by
    by_cases h' : i.val + 1 < n
    · simp [h']
    · simp [h']; omega⟩

theorem nextIndex_total {n : Nat} (h : 1 < n) (i : Fin n) :
    (nextIndex h i).val = if i.val + 1 < n then i.val + 1 else 0 := rfl

/-! ============================================================
    Neighbour compose transform
============================================================ -/

def neighbourComposeTransform
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n) :
    AggregateFamilyTransform resolve n :=
  fun p i => p i ++ p (nextIndex h i)

/-! ============================================================
    FoldKernel congruence for append
============================================================ -/

theorem foldr_append
    {α β : Type} (f : α → β → β) (b : β) (xs ys : List α) :
    List.foldr f b (xs ++ ys) = List.foldr f (List.foldr f b ys) xs := by
  induction xs with
  | nil => rfl
  | cons hd tl ih => simp [ih]

theorem FoldKernel_congr_append
    (resolve : KernelExpr → Store → Location)
    {xs xs' ys ys' : List KernelExprContext}
    (hxs : FoldKernel resolve xs xs')
    (hys : FoldKernel resolve ys ys') :
    FoldKernel resolve (xs ++ ys) (xs' ++ ys') := by
  unfold FoldKernel trajectoryProjection toTrajectoryBoundary
  have hxs_e : TrajectoryEquivalent resolve xs xs' := Quotient.exact hxs
  have hys_e : TrajectoryEquivalent resolve ys ys' := Quotient.exact hys
  apply Quotient.sound
  intro q
  show (xs ++ ys).foldr (fun ctx acc => plugPersistent resolve ctx acc) q =
       (xs' ++ ys').foldr (fun ctx acc => plugPersistent resolve ctx acc) q
  rw [foldr_append]
  rw [foldr_append]
  have h1 := hys_e q
  unfold TrajectoryEquivalent evolvePersistent at h1
  rw [h1]
  have h2 := hxs_e (ys'.foldr (fun ctx acc => plugPersistent resolve ctx acc) q)
  unfold TrajectoryEquivalent evolvePersistent at h2
  exact h2

/-! ============================================================
    Global kernel compatibility
============================================================ -/

theorem neighbourComposeTransform_respects_kernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n) :
    AggregateTransformRespectsKernel resolve
      (neighbourComposeTransform resolve h) := by
  intro p q hKernel
  unfold ThreadFamilyKernel projectThreadFamily neighbourComposeTransform at *
  funext i
  have hPi : FoldKernel resolve (p i) (q i) := congrFun hKernel i
  have hNext : FoldKernel resolve (p (nextIndex h i)) (q (nextIndex h i)) :=
    congrFun hKernel (nextIndex h i)
  exact FoldKernel_congr_append resolve hPi hNext

/-! ============================================================
    Package as fold-compatible aggregate
============================================================ -/

def neighbourComposeAggregate
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n) :
    FoldCompatibleAggregateTransform resolve n where
  transform := neighbourComposeTransform resolve h
  compatible := neighbourComposeTransform_respects_kernel resolve h

/-! ============================================================
    Cross-component sensitivity
============================================================ -/

theorem neighbourComposeTransform_contextSensitive
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    OutputDependsOnOtherComponent resolve (neighbourComposeTransform resolve h) := by
  refine ⟨fun _ => [], fun i => if i.val = 0 then [] else [identityContext], ⟨0, Nat.zero_lt_of_lt h⟩, ⟨1, h⟩, rfl, ?_, ?_⟩
  · simp [identityContext]
  · simp [neighbourComposeTransform, nextIndex]
    have h1 : (0 : Nat) + 1 < n := h
    simp [h1, identityContext]

theorem neighbourComposeTransform_not_indexed
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    ¬ IsIndexedComponentwise resolve (neighbourComposeTransform resolve h) :=
  outputDependsOnOtherComponent_refutes_indexed resolve
    (neighbourComposeTransform_contextSensitive resolve n h)

#check nextIndex
#check neighbourComposeTransform
#check FoldKernel_congr_append
#check neighbourComposeTransform_respects_kernel
#check neighbourComposeAggregate
#check neighbourComposeTransform_contextSensitive
#check neighbourComposeTransform_not_indexed

#print axioms FoldKernel_congr_append
#print axioms neighbourComposeTransform_respects_kernel
#print axioms neighbourComposeTransform_contextSensitive

/-! ============================================================
    Relational aggregation
============================================================ -/

theorem neighbourComposeTransform_isRelationallyAggregate
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    IsRelationallyAggregate resolve (neighbourComposeTransform resolve h) := by
  intro ⟨σ, localMap, hRepr⟩
  let i : Fin n := ⟨0, Nat.zero_lt_of_lt h⟩
  let next : Fin n := nextIndex h i
  have hNe : next ≠ i := by
    intro hEq
    have hval : next.val = i.val := congrArg Fin.val hEq
    rw [nextIndex_total h i] at hval
    have hi : i.val = 0 := rfl
    rw [hi] at hval
    simp [h] at hval
  have hNe' : i ≠ next := Ne.symm hNe
  -- Case analysis on the source index that the putative local map reads.
  by_cases hσi : σ i = i
  · -- Source is the own component: vary the neighbour.
    let p : ThreadFamily resolve n := fun _ => []
    let q : ThreadFamily resolve n := fun k => if k = next then [identityContext] else []
    have hSrcEq : p (σ i) = q (σ i) := by
      rw [hσi]
      unfold p q
      simp only [if_neg hNe']
    have hOut : neighbourComposeTransform resolve h p i ≠
                neighbourComposeTransform resolve h q i := by
      unfold neighbourComposeTransform
      show p i ++ p next ≠ q i ++ q next
      simp only [p, q, if_neg hNe', if_pos rfl, List.nil_append, List.append_nil]
      exact Ne.symm (List.cons_ne_nil identityContext [])
    have hReprP := hRepr p i
    have hReprQ := hRepr q i
    have hOutEq : localMap i (p (σ i)) = localMap i (q (σ i)) := by rw [hSrcEq]
    rw [← hReprP, ← hReprQ] at hOutEq
    exact hOut hOutEq
  · by_cases hσnext : σ i = next
    · -- Source is the neighbour: vary the own component.
      let p : ThreadFamily resolve n := fun _ => []
      let q : ThreadFamily resolve n := fun k => if k = i then [identityContext] else []
      have hSrcEq : p (σ i) = q (σ i) := by
        rw [hσnext]
        unfold p q
        simp only [if_neg hNe]
      have hOut : neighbourComposeTransform resolve h p i ≠
                  neighbourComposeTransform resolve h q i := by
        unfold neighbourComposeTransform
        show p i ++ p next ≠ q i ++ q next
        simp only [p, q, if_pos rfl, if_neg hNe, List.nil_append, List.append_nil]
        exact Ne.symm (List.cons_ne_nil identityContext [])
      have hReprP := hRepr p i
      have hReprQ := hRepr q i
      have hOutEq : localMap i (p (σ i)) = localMap i (q (σ i)) := by rw [hSrcEq]
      rw [← hReprP, ← hReprQ] at hOutEq
      exact hOut hOutEq
    · -- Source is neither: both components are free; vary the own component.
      let p : ThreadFamily resolve n := fun _ => []
      let q : ThreadFamily resolve n := fun k => if k = i then [identityContext] else []
      have hSrcEq : p (σ i) = q (σ i) := by
        unfold p q
        simp only [if_neg hσi]
      have hOut : neighbourComposeTransform resolve h p i ≠
                  neighbourComposeTransform resolve h q i := by
        unfold neighbourComposeTransform
        show p i ++ p next ≠ q i ++ q next
        simp only [p, q, if_pos rfl, if_neg hNe, List.nil_append, List.append_nil]
        exact Ne.symm (List.cons_ne_nil identityContext [])
      have hReprP := hRepr p i
      have hReprQ := hRepr q i
      have hOutEq : localMap i (p (σ i)) = localMap i (q (σ i)) := by rw [hSrcEq]
      rw [← hReprP, ← hReprQ] at hOutEq
      exact hOut hOutEq

#check neighbourComposeTransform_isRelationallyAggregate
#print axioms neighbourComposeTransform_isRelationallyAggregate

/-! ============================================================
    Folded-triviality for neighbourComposeTransform
============================================================ -/

def NeighbourComposeFoldedTrivialAt
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n) : Prop :=
  ThreadFamilyKernel resolve
    (neighbourComposeTransform resolve h p)
    p

theorem neighbourCompose_foldedTrivial_iff
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n) :
    NeighbourComposeFoldedTrivialAt resolve h p
    ↔
    ∀ i : Fin n,
      FoldKernel resolve
        (p i ++ p (nextIndex h i))
        (p i) := by
  unfold NeighbourComposeFoldedTrivialAt ThreadFamilyKernel
    projectThreadFamily neighbourComposeTransform FoldKernel
  constructor
  · intro hEq i
    exact congrFun hEq i
  · intro hAll
    funext i
    exact hAll i

/-! ============================================================
    Projected monoid characterisation
============================================================ -/

def NeighbourRightStabilises
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n) : Prop :=
  ∀ i,
    composeTrajectory resolve
      (trajectoryProjection resolve (p i))
      (trajectoryProjection resolve (p (nextIndex h i)))
    =
    trajectoryProjection resolve (p i)

theorem neighbourCompose_foldedTrivial_iff_rightStabilises
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n) :
    NeighbourComposeFoldedTrivialAt resolve h p
    ↔
    NeighbourRightStabilises resolve h p := by
  rw [neighbourCompose_foldedTrivial_iff]
  unfold NeighbourRightStabilises FoldKernel
  constructor
  · intro hAll i
    have hAppend := trajectoryProjection_append resolve (p i) (p (nextIndex h i))
    rw [← hAppend]
    exact hAll i
  · intro hAll i
    have hAppend := trajectoryProjection_append resolve (p i) (p (nextIndex h i))
    rw [hAppend]
    exact hAll i

/-! ============================================================
    Identity-class sufficient condition
============================================================ -/

theorem neighbourCompose_identityNeighbours_foldedTrivial
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n)
    (hId : ∀ i,
      trajectoryProjection resolve (p (nextIndex h i))
      =
      emptyTrajectory resolve) :
    NeighbourComposeFoldedTrivialAt resolve h p := by
  rw [neighbourCompose_foldedTrivial_iff_rightStabilises]
  intro i
  rw [hId i]
  exact composeTrajectory_id_right resolve _

def FamilyProjectsToIdentity
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) : Prop :=
  ∀ i,
    trajectoryProjection resolve (p i)
    =
    emptyTrajectory resolve

theorem familyProjectsToIdentity_implies_foldedTrivial
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n)
    (hId : FamilyProjectsToIdentity resolve p) :
    NeighbourComposeFoldedTrivialAt resolve h p := by
  apply neighbourCompose_identityNeighbours_foldedTrivial
  intro i
  exact hId (nextIndex h i)

/-! ============================================================
    Explicit folded-trivial family: familyEqual
============================================================ -/

theorem neighbourCompose_familyEqual_foldedTrivial
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    NeighbourComposeFoldedTrivialAt
      resolve
      h
      (familyEqual resolve n) := by
  apply familyProjectsToIdentity_implies_foldedTrivial
  intro i
  unfold familyEqual
  rfl

theorem neighbourCompose_familyEqual_rawlyIdentical
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    neighbourComposeTransform resolve h (familyEqual resolve n)
    =
    familyEqual resolve n := by
  funext i
  unfold neighbourComposeTransform familyEqual
  simp

/-! ============================================================
    familyUnequal: identity-class and raw-nontrivial
============================================================ -/

theorem familyUnequal_projectsToIdentity
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    FamilyProjectsToIdentity resolve (familyUnequal resolve n h) := by
  intro i
  unfold familyUnequal
  by_cases hi : i.val = 0
  · simp [hi]
    rfl
  · simp [hi]
    exact (empty_identity_same_projection resolve).symm

theorem neighbourCompose_familyUnequal_foldedTrivial
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    NeighbourComposeFoldedTrivialAt
      resolve
      h
      (familyUnequal resolve n h) :=
  familyProjectsToIdentity_implies_foldedTrivial resolve h _
    (familyUnequal_projectsToIdentity resolve n h)

theorem neighbourCompose_familyUnequal_rawlyNontrivial
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    neighbourComposeTransform resolve h (familyUnequal resolve n h)
    ≠
    familyUnequal resolve n h := by
  intro hEq
  let i0 : Fin n := ⟨0, Nat.zero_lt_of_lt h⟩
  have hAt := congrFun hEq i0
  have hOrig : familyUnequal resolve n h i0 = [] := by
    unfold familyUnequal
    have : i0.val = 0 := rfl
    simp [this]
  have hNextVal : (nextIndex h i0).val = 1 := by
    rw [nextIndex_total]
    have hi : i0.val = 0 := rfl
    rw [hi]
    have hlt : (0 : Nat) + 1 < n := h
    simp [hlt]
  have hNextList : familyUnequal resolve n h (nextIndex h i0) = [identityContext] := by
    unfold familyUnequal
    have hNe : (nextIndex h i0).val ≠ 0 := by
      rw [hNextVal]
      decide
    simp only [if_neg hNe]
  have hOut : neighbourComposeTransform resolve h (familyUnequal resolve n h) i0
      = [identityContext] := by
    unfold neighbourComposeTransform
    rw [hOrig, hNextList]
    rfl
  rw [hOut, hOrig] at hAt
  exact empty_ne_identity hAt.symm

def NeighbourComposeNontrivialFoldedTrivialWitness
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) : Prop :=
  ∃ p : ThreadFamily resolve n,
    NeighbourComposeFoldedTrivialAt resolve h p
    ∧
    neighbourComposeTransform resolve h p ≠ p

theorem neighbourCompose_nontrivialFoldedTrivial_witness
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : 1 < n) :
    NeighbourComposeNontrivialFoldedTrivialWitness resolve n h :=
  ⟨familyUnequal resolve n h,
    neighbourCompose_familyUnequal_foldedTrivial resolve n h,
    neighbourCompose_familyUnequal_rawlyNontrivial resolve n h⟩

/-! ============================================================
    Stabiliser connection
============================================================ -/

theorem neighbourCompose_foldedTrivial_iff_pointwiseStabiliser
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n) :
    NeighbourComposeFoldedTrivialAt resolve h p
    ↔
    ∀ i,
      ReturnsTo resolve (p i) (p (nextIndex h i)) := by
  rw [neighbourCompose_foldedTrivial_iff]
  unfold ReturnsTo FoldKernel
  constructor
  · intro hAll i
    exact hAll i
  · intro hAll i
    exact hAll i

theorem neighbourCompose_foldedTrivial_iff_rightStabilizerMembership
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n) :
    NeighbourComposeFoldedTrivialAt resolve h p
    ↔
    ∀ i,
      ∃ s : RightStabilizer resolve (trajectoryProjection resolve (p i)),
        s.val = trajectoryProjection resolve (p (nextIndex h i)) := by
  rw [neighbourCompose_foldedTrivial_iff_rightStabilises]
  unfold NeighbourRightStabilises RightStabilizer
  constructor
  · intro hAll i
    exact ⟨⟨trajectoryProjection resolve (p (nextIndex h i)), hAll i⟩, rfl⟩
  · intro hAll i
    rcases hAll i with ⟨s, hs⟩
    rw [← hs]
    exact s.property

/-! ============================================================
    Classifier audit on the raw-nontrivial witness
============================================================ -/

theorem neighbourCompose_familyUnequal_component0_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    neighbourComposeTransform resolve h (familyUnequal resolve 2 h) ⟨0, by decide⟩
    =
    [identityContext] := by
  unfold neighbourComposeTransform familyUnequal
  have hNext : nextIndex h ⟨0, by decide⟩ = ⟨1, by decide⟩ := by
    apply Fin.ext
    rw [nextIndex_total]
    simp
  rw [hNext]
  simp

theorem neighbourCompose_familyUnequal_component1_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    neighbourComposeTransform resolve h (familyUnequal resolve 2 h) ⟨1, by decide⟩
    =
    [identityContext] := by
  unfold neighbourComposeTransform familyUnequal
  have hNext : nextIndex h ⟨1, by decide⟩ = ⟨0, by decide⟩ := by
    apply Fin.ext
    rw [nextIndex_total]
    simp
  rw [hNext]
  simp

theorem neighbourCompose_familyUnequal_rawAllEqual_changes_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RawAllEqual resolve (neighbourComposeTransform resolve h (familyUnequal resolve 2 h))
    ∧
    ¬ RawAllEqual resolve (familyUnequal resolve 2 h) := by
  constructor
  · intro i j
    have h0 := neighbourCompose_familyUnequal_component0_n2 resolve h
    have h1 := neighbourCompose_familyUnequal_component1_n2 resolve h
    -- exhaust Fin 2
    have hi : i.val = 0 ∨ i.val = 1 := by
      have : i.val < 2 := i.isLt
      omega
    have hj : j.val = 0 ∨ j.val = 1 := by
      have : j.val < 2 := j.isLt
      omega
    rcases hi with hia | hib <;> rcases hj with hja | hjb
    · have hi' : i = ⟨0, by decide⟩ := Fin.ext hia
      have hj' : j = ⟨0, by decide⟩ := Fin.ext hja
      rw [hi', hj', h0]
    · have hi' : i = ⟨0, by decide⟩ := Fin.ext hia
      have hj' : j = ⟨1, by decide⟩ := Fin.ext hjb
      rw [hi', hj', h0, h1]
    · have hi' : i = ⟨1, by decide⟩ := Fin.ext hib
      have hj' : j = ⟨0, by decide⟩ := Fin.ext hja
      rw [hi', hj', h0, h1]
    · have hi' : i = ⟨1, by decide⟩ := Fin.ext hib
      have hj' : j = ⟨1, by decide⟩ := Fin.ext hjb
      rw [hi', hj', h1]
  · exact familyUnequal_notAllEqual resolve 2 h

theorem neighbourCompose_familyUnequal_classifierChanges_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    (rawAllEqualClassifier resolve 2).classify
        (neighbourComposeTransform resolve h (familyUnequal resolve 2 h))
    ≠
    (rawAllEqualClassifier resolve 2).classify
        (familyUnequal resolve 2 h) := by
  rw [rawAllEqualClassifier_apply, rawAllEqualClassifier_apply]
  have hChange := neighbourCompose_familyUnequal_rawAllEqual_changes_n2 resolve h
  intro hEq
  exact hChange.2 (hEq.mp hChange.1)

/-! ============================================================
    Strong relational witness (n = 2)
============================================================ -/

theorem neighbourCompose_relationallyAggregateFoldedTrivialClassifierWitness_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RelationallyAggregateFoldedTrivialClassifierWitness
      resolve
      (rawAllEqualClassifier resolve 2) := by
  refine ⟨neighbourComposeAggregate resolve h,
          familyUnequal resolve 2 h,
          ?_,
          ?_,
          ?_⟩
  · exact neighbourComposeTransform_isRelationallyAggregate resolve 2 h
  · exact neighbourCompose_familyUnequal_foldedTrivial resolve 2 h
  · exact neighbourCompose_familyUnequal_classifierChanges_n2 resolve h

def relationalAggregateChiralitySpecification_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RelationalAggregateChiralitySpecification resolve 2 :=
  {
    classifier := rawAllEqualClassifier resolve 2
    foldedTrivialSensitive :=
      neighbourCompose_relationallyAggregateFoldedTrivialClassifierWitness_n2 resolve h
  }

theorem RelationalAggregateChiralitySpecificationExists_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RelationalAggregateChiralitySpecificationExists resolve 2 :=
  ⟨relationalAggregateChiralitySpecification_n2 resolve h⟩

#check neighbourCompose_foldedTrivial_iff
#check neighbourCompose_foldedTrivial_iff_rightStabilises
#check neighbourCompose_identityNeighbours_foldedTrivial
#check familyProjectsToIdentity_implies_foldedTrivial
#check neighbourCompose_familyEqual_foldedTrivial
#check neighbourCompose_familyEqual_rawlyIdentical
#check neighbourCompose_familyUnequal_foldedTrivial
#check neighbourCompose_familyUnequal_rawlyNontrivial
#check neighbourCompose_nontrivialFoldedTrivial_witness
#check neighbourCompose_familyUnequal_classifierChanges_n2
#check neighbourCompose_relationallyAggregateFoldedTrivialClassifierWitness_n2
#check RelationalAggregateChiralitySpecificationExists_n2

#print axioms neighbourCompose_foldedTrivial_iff
#print axioms neighbourCompose_foldedTrivial_iff_rightStabilises
#print axioms neighbourCompose_identityNeighbours_foldedTrivial
#print axioms familyProjectsToIdentity_implies_foldedTrivial
#print axioms neighbourCompose_familyEqual_foldedTrivial
#print axioms neighbourCompose_familyEqual_rawlyIdentical
#print axioms neighbourCompose_familyUnequal_foldedTrivial
#print axioms neighbourCompose_familyUnequal_rawlyNontrivial
#print axioms neighbourCompose_nontrivialFoldedTrivial_witness
#print axioms neighbourCompose_familyUnequal_classifierChanges_n2
#print axioms neighbourCompose_relationallyAggregateFoldedTrivialClassifierWitness_n2
#print axioms RelationalAggregateChiralitySpecificationExists_n2


/-! ============================================================
    Iterated neighbour composition
============================================================ -/

def iteratedNeighbourCompose
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    : Nat → AggregateFamilyTransform resolve n
  | 0 => identityAggregate resolve n
  | k + 1 =>
    composeAggregate
      (neighbourComposeTransform resolve h)
      (iteratedNeighbourCompose resolve h k)

theorem iteratedNeighbourCompose_zero
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n) :
    iteratedNeighbourCompose resolve h 0 p = p := rfl

theorem iteratedNeighbourCompose_succ
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (k : Nat)
    (p : ThreadFamily resolve n) :
    iteratedNeighbourCompose resolve h (k + 1) p
    =
    neighbourComposeTransform resolve h
      (iteratedNeighbourCompose resolve h k p) := rfl

/-! ============================================================
    1. Iteration remains FoldKernel-compatible
============================================================ -/

theorem iteratedNeighbourCompose_respects_kernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (k : Nat) :
    AggregateTransformRespectsKernel resolve
      (iteratedNeighbourCompose resolve h k) := by
  induction k with
  | zero =>
    exact identityAggregate_respectsKernel resolve n
  | succ k ih =>
    exact composeAggregate_respectsKernel
      (neighbourComposeTransform resolve h)
      (iteratedNeighbourCompose resolve h k)
      (neighbourComposeTransform_respects_kernel resolve h)
      ih

/-! ============================================================
    3. Concrete orbit of familyUnequal at n = 2
============================================================ -/

theorem familyUnequal_N_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (i : Fin 2) :
    neighbourComposeTransform resolve h
      (familyUnequal resolve 2 h) i
    =
    [identityContext] := by
  unfold neighbourComposeTransform familyUnequal
  match i with
  | ⟨0, _⟩ =>
    have hNext : nextIndex h ⟨0, by decide⟩ = ⟨1, by decide⟩ := by
      apply Fin.ext
      rw [nextIndex_total]
      simp
    rw [hNext]
    simp
  | ⟨1, _⟩ =>
    have hNext : nextIndex h ⟨1, by decide⟩ = ⟨0, by decide⟩ := by
      apply Fin.ext
      rw [nextIndex_total]
      simp
    rw [hNext]
    simp

theorem append_eq_nil_left
    {α : Type} {xs ys : List α}
    (h : xs ++ ys = []) : xs = [] := by
  have hLen : (xs ++ ys).length = 0 := congrArg List.length h
  rw [List.length_append] at hLen
  have : xs.length = 0 := by omega
  exact List.eq_nil_of_length_eq_zero this

theorem familyUnequal_iter_nonempty_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (k : Nat)
    (hk : 0 < k) :
    iteratedNeighbourCompose resolve h k
      (familyUnequal resolve 2 h) ⟨0, by decide⟩
    ≠
    [] := by
  induction k with
  | zero => exact absurd hk (by decide)
  | succ k ih =>
    rw [iteratedNeighbourCompose_succ]
    unfold neighbourComposeTransform
    have hNext : nextIndex h ⟨0, by decide⟩ = ⟨1, by decide⟩ := by
      apply Fin.ext; rw [nextIndex_total]; simp
    rw [hNext]
    by_cases hk0 : k = 0
    · subst hk0
      rw [iteratedNeighbourCompose_zero]
      have := familyUnequal_N_n2 resolve h ⟨0, by decide⟩
      -- goal is familyUnequal 0 ++ familyUnequal 1 ≠ []
      unfold familyUnequal at this
      -- compute directly
      have hL : familyUnequal resolve 2 h ⟨0, by decide⟩ = [] := by
        simp [familyUnequal]
      have hR : familyUnequal resolve 2 h ⟨1, by decide⟩ = [identityContext] := by
        simp [familyUnequal]
      rw [hL, hR]
      simp
    · intro hNil
      have hLeftNil := append_eq_nil_left hNil
      exact ih (Nat.pos_of_ne_zero hk0) hLeftNil

theorem familyUnequal_iter_components_equal_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (k : Nat)
    (hk : 0 < k) :
    iteratedNeighbourCompose resolve h k
      (familyUnequal resolve 2 h) ⟨0, by decide⟩
    =
    iteratedNeighbourCompose resolve h k
      (familyUnequal resolve 2 h) ⟨1, by decide⟩ := by
  induction k with
  | zero => exact absurd hk (by decide)
  | succ k ih =>
    rw [iteratedNeighbourCompose_succ]
    -- goal is now N (N^k ...) 0 = N (N^k ...) 1
    unfold neighbourComposeTransform
    have hNext0 : nextIndex h ⟨0, by decide⟩ = ⟨1, by decide⟩ := by
      apply Fin.ext; rw [nextIndex_total]; simp
    have hNext1 : nextIndex h ⟨1, by decide⟩ = ⟨0, by decide⟩ := by
      apply Fin.ext; rw [nextIndex_total]; simp
    rw [hNext0, hNext1]
    by_cases hk0 : k = 0
    · subst hk0
      rw [iteratedNeighbourCompose_zero]
      -- both sides now familyUnequal ... ++ familyUnequal ...
      have hL : familyUnequal resolve 2 h ⟨0, by decide⟩ = [] := by
        simp [familyUnequal]
      have hR : familyUnequal resolve 2 h ⟨1, by decide⟩ = [identityContext] := by
        simp [familyUnequal]
      rw [hL, hR]
      simp [List.nil_append, List.append_nil]
    · have hEq := ih (Nat.pos_of_ne_zero hk0)
      rw [hEq]

/-! ============================================================
    4. Kernel class stable; raw family never returns
============================================================ -/

theorem familyUnequal_iter_kernel_stable
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (k : Nat) :
    ThreadFamilyKernel resolve
      (iteratedNeighbourCompose resolve h k (familyUnequal resolve 2 h))
      (familyUnequal resolve 2 h) := by
  have hFam : FamilyProjectsToIdentity resolve
      (familyUnequal resolve 2 h) :=
    familyUnequal_projectsToIdentity resolve 2 h
  have hIter : FamilyProjectsToIdentity resolve
      (iteratedNeighbourCompose resolve h k (familyUnequal resolve 2 h)) := by
    induction k with
    | zero => exact hFam
    | succ k ih =>
      intro i
      rw [iteratedNeighbourCompose_succ]
      unfold neighbourComposeTransform
      have hApp := trajectoryProjection_append resolve
        (iteratedNeighbourCompose resolve h k
          (familyUnequal resolve 2 h) i)
        (iteratedNeighbourCompose resolve h k
          (familyUnequal resolve 2 h) (nextIndex h i))
      rw [hApp]
      have hL := ih i
      have hR := ih (nextIndex h i)
      rw [hL, hR]
      exact composeTrajectory_id_right resolve _
  unfold ThreadFamilyKernel projectThreadFamily
  funext i
  rw [hIter i, hFam i]

theorem familyUnequal_iter_never_raw_returns
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (k : Nat)
    (hk : 0 < k) :
    iteratedNeighbourCompose resolve h k (familyUnequal resolve 2 h)
    ≠
    familyUnequal resolve 2 h := by
  intro hEq
  have hAt := congrFun hEq ⟨0, by decide⟩
  have hNe := familyUnequal_iter_nonempty_n2 resolve h k hk
  have hOrig : familyUnequal resolve 2 h ⟨0, by decide⟩ = [] := by
    simp [familyUnequal]
  rw [hOrig] at hAt
  exact hNe hAt

/-! ============================================================
    5. RawAllEqual changes once then stabilises
============================================================ -/

theorem familyUnequal_rawAllEqual_stabilises
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ¬ RawAllEqual resolve (familyUnequal resolve 2 h)
    ∧
    ∀ k, 0 < k →
      RawAllEqual resolve
        (iteratedNeighbourCompose resolve h k (familyUnequal resolve 2 h)) := by
  constructor
  · exact familyUnequal_notAllEqual resolve 2 h
  · intro k hk i j
    have hEq := familyUnequal_iter_components_equal_n2 resolve h k hk
    match i, j with
    | ⟨0, _⟩, ⟨0, _⟩ => rfl
    | ⟨0, _⟩, ⟨1, _⟩ => exact hEq
    | ⟨1, _⟩, ⟨0, _⟩ => exact hEq.symm
    | ⟨1, _⟩, ⟨1, _⟩ => rfl

/-! ============================================================
    6. Only raw fixed point is the empty family
============================================================ -/

theorem list_append_eq_left_implies_right_nil
    {α : Type} {xs ys : List α}
    (h : xs ++ ys = xs) : ys = [] := by
  have hLen : (xs ++ ys).length = xs.length := congrArg List.length h
  rw [List.length_append] at hLen
  have : ys.length = 0 := by omega
  exact List.eq_nil_of_length_eq_zero this

theorem neighbourCompose_only_raw_fixed_point_empty_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (p : ThreadFamily resolve 2) :
    neighbourComposeTransform resolve h p = p
    →
    p = familyEqual resolve 2 := by
  intro hFix
  funext i
  have h0 := congrFun hFix ⟨0, by decide⟩
  have h1 := congrFun hFix ⟨1, by decide⟩
  unfold neighbourComposeTransform at h0 h1
  have hBempty : p ⟨1, by decide⟩ = [] :=
    list_append_eq_left_implies_right_nil h0
  have hAempty : p ⟨0, by decide⟩ = [] :=
    list_append_eq_left_implies_right_nil h1
  match i with
  | ⟨0, _⟩ =>
    unfold familyEqual
    exact hAempty
  | ⟨1, _⟩ =>
    unfold familyEqual
    exact hBempty


#check iteratedNeighbourCompose
#check iteratedNeighbourCompose_respects_kernel
#check familyUnequal_N_n2
#check familyUnequal_iter_nonempty_n2
#check familyUnequal_iter_components_equal_n2
#check familyUnequal_iter_kernel_stable
#check familyUnequal_iter_never_raw_returns
#check familyUnequal_rawAllEqual_stabilises
#check neighbourCompose_only_raw_fixed_point_empty_n2

#print axioms iteratedNeighbourCompose_respects_kernel
#print axioms familyUnequal_iter_kernel_stable
#print axioms familyUnequal_iter_never_raw_returns
#print axioms familyUnequal_rawAllEqual_stabilises
#print axioms neighbourCompose_only_raw_fixed_point_empty_n2

/-! ============================================================
    Generic raw orbit
============================================================ -/

def RawOrbit
    {X : Sort u}
    (step : X → X)
    (x : X) :
    Nat → X
  | 0 => x
  | k + 1 => step (RawOrbit step x k)

theorem RawOrbit_zero
    {X : Sort u}
    (step : X → X)
    (x : X) :
    RawOrbit step x 0 = x := rfl

theorem RawOrbit_succ
    {X : Sort u}
    (step : X → X)
    (x : X)
    (k : Nat) :
    RawOrbit step x (k + 1)
    =
    step (RawOrbit step x k) := rfl

theorem RawOrbit_add
    {X : Sort u}
    (step : X → X)
    (x : X)
    (k m : Nat) :
    RawOrbit step x (k + m)
    =
    RawOrbit step (RawOrbit step x k) m := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rw [Nat.add_succ, RawOrbit_succ, ih, RawOrbit_succ]

/-! ============================================================
    Raw orbit return
============================================================ -/

def RawOrbitReturnsAt
    {X : Sort u}
    (step : X → X)
    (x : X)
    (k : Nat) : Prop :=
  RawOrbit step x k = x

def PositiveRawReturnExists
    {X : Sort u}
    (step : X → X)
    (x : X) : Prop :=
  ∃ k : Nat,
    0 < k
    ∧
    RawOrbitReturnsAt step x k

def RawOrbitNeverReturns
    {X : Sort u}
    (step : X → X)
    (x : X) : Prop :=
  ∀ k : Nat,
    0 < k →
    ¬ RawOrbitReturnsAt step x k

theorem RawOrbitNeverReturns_iff_not_PositiveRawReturnExists
    {X : Sort u}
    (step : X → X)
    (x : X) :
    RawOrbitNeverReturns step x
    ↔
    ¬ PositiveRawReturnExists step x := by
  constructor
  · intro hNever ⟨k, hk, hRet⟩
    exact hNever k hk hRet
  · intro hNot k hk hRet
    exact hNot ⟨k, hk, hRet⟩

def asAggregateFun
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n) :
    ThreadFamily resolve n → ThreadFamily resolve n :=
  fun p => step p

/-! ============================================================
    Folded orbit
============================================================ -/

def FoldedOrbit
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n)
    (k : Nat) :
    Fin n → TrajectoryBoundary resolve :=
  projectThreadFamily resolve
    (RawOrbit (asAggregateFun resolve step) p k)

theorem FoldedOrbit_zero
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n) :
    FoldedOrbit resolve step p 0
    =
    projectThreadFamily resolve p := by
  unfold FoldedOrbit asAggregateFun RawOrbit
  rfl

theorem FoldedOrbit_succ
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n)
    (k : Nat) :
    FoldedOrbit resolve step p (k + 1)
    =
    projectThreadFamily resolve
      (step (RawOrbit (asAggregateFun resolve step) p k)) := by
  unfold FoldedOrbit asAggregateFun
  rw [RawOrbit_succ]

/-! ============================================================
    Folded return
============================================================ -/

def FoldedOrbitReturnsAt
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n)
    (k : Nat) : Prop :=
  ThreadFamilyKernel resolve
    (RawOrbit (asAggregateFun resolve step) p k)
    p

theorem FoldedOrbitReturnsAt_iff_projection
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n)
    (k : Nat) :
    FoldedOrbitReturnsAt resolve step p k
    ↔
    FoldedOrbit resolve step p k
    =
    projectThreadFamily resolve p := by
  unfold FoldedOrbitReturnsAt FoldedOrbit ThreadFamilyKernel
  exact Iff.rfl

/-! ============================================================
    Raw return implies folded return
============================================================ -/

theorem rawReturn_implies_foldedReturn
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n)
    (k : Nat) :
    RawOrbitReturnsAt (asAggregateFun resolve step) p k →
    FoldedOrbitReturnsAt resolve step p k := by
  intro hRet
  unfold FoldedOrbitReturnsAt RawOrbitReturnsAt at *
  rw [hRet]
  exact ThreadFamilyKernel_refl resolve p

/-! ============================================================
    Raw/folded orbit split and stationarity
============================================================ -/

def RawFoldedOrbitSplit
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n) : Prop :=
  RawOrbitNeverReturns step p
  ∧
  ∀ k : Nat,
    FoldedOrbitReturnsAt resolve step p k

def FoldedOrbitStationary
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n) : Prop :=
  ∀ k : Nat,
    FoldedOrbit resolve step p k
    =
    projectThreadFamily resolve p

theorem FoldedOrbitStationary_iff_returns
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n) :
    FoldedOrbitStationary resolve step p
    ↔
    ∀ k,
      FoldedOrbitReturnsAt resolve step p k := by
  unfold FoldedOrbitStationary
  constructor
  · intro h k
    rw [FoldedOrbitReturnsAt_iff_projection]
    exact h k
  · intro h k
    rw [← FoldedOrbitReturnsAt_iff_projection]
    exact h k

theorem RawFoldedOrbitSplit_iff
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n) :
    RawFoldedOrbitSplit resolve step p
    ↔
    RawOrbitNeverReturns step p
    ∧
    FoldedOrbitStationary resolve step p := by
  unfold RawFoldedOrbitSplit
  rw [FoldedOrbitStationary_iff_returns]

/-! ============================================================
    Relate RawOrbit to iteratedNeighbourCompose
============================================================ -/

theorem RawOrbit_eq_iteratedNeighbourCompose
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (h : 1 < n)
    (p : ThreadFamily resolve n)
    (k : Nat) :
    RawOrbit (asAggregateFun resolve (neighbourComposeTransform resolve h)) p k
    =
    iteratedNeighbourCompose resolve h k p := by
  induction k with
  | zero =>
    rw [RawOrbit_zero, iteratedNeighbourCompose_zero]
  | succ k ih =>
    rw [RawOrbit_succ, iteratedNeighbourCompose_succ]
    exact congrArg (neighbourComposeTransform resolve h) ih

/-! ============================================================
    Concrete familyUnequal split
============================================================ -/

theorem familyUnequal_foldedOrbit_constant_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∀ k,
      FoldedOrbit
        resolve
        (neighbourComposeTransform resolve h)
        (familyUnequal resolve 2 h)
        k
      =
      projectThreadFamily resolve
        (familyUnequal resolve 2 h) := by
  intro k
  rw [← FoldedOrbitReturnsAt_iff_projection]
  unfold FoldedOrbitReturnsAt
  rw [RawOrbit_eq_iteratedNeighbourCompose]
  exact familyUnequal_iter_kernel_stable resolve h k

theorem familyUnequal_raw_folded_orbit_split_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RawFoldedOrbitSplit
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h) := by
  constructor
  · intro k hk hRet
    have hNe := familyUnequal_iter_never_raw_returns resolve h k hk
    rw [← RawOrbit_eq_iteratedNeighbourCompose] at hNe
    exact hNe hRet
  · intro k
    rw [FoldedOrbitReturnsAt_iff_projection]
    exact familyUnequal_foldedOrbit_constant_n2 resolve h k

/-! ============================================================
    Raw orbit injectivity via length growth
============================================================ -/

def familyUnequal_component0_length
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (k : Nat) : Nat :=
  (iteratedNeighbourCompose resolve h k
    (familyUnequal resolve 2 h) ⟨0, by decide⟩).length

theorem familyUnequal_length_zero
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    familyUnequal_component0_length resolve h 0 = 0 := by
  unfold familyUnequal_component0_length
  rw [iteratedNeighbourCompose_zero]
  simp [familyUnequal]

theorem list_ne_nil_length_pos
    {α : Type} {l : List α} (h : l ≠ []) : 0 < l.length := by
  cases l with
  | nil => exact absurd rfl h
  | cons _ _ => simp

theorem familyUnequal_length_succ_ge1
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (k : Nat)
    (hk : 0 < k) :
    0 < familyUnequal_component0_length resolve h k := by
  unfold familyUnequal_component0_length
  have hNe := familyUnequal_iter_nonempty_n2 resolve h k hk
  exact list_ne_nil_length_pos hNe

theorem familyUnequal_length_doubles
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (k : Nat)
    (hk : 0 < k) :
    familyUnequal_component0_length resolve h (k + 1)
    =
    2 * familyUnequal_component0_length resolve h k := by
  unfold familyUnequal_component0_length
  rw [iteratedNeighbourCompose_succ]
  unfold neighbourComposeTransform
  have hNext : nextIndex h ⟨0, by decide⟩ = ⟨1, by decide⟩ := by
    apply Fin.ext
    rw [nextIndex_total]
    simp
  rw [hNext]
  have hEq := familyUnequal_iter_components_equal_n2 resolve h k hk
  rw [hEq]
  simp [List.length_append]
  omega

theorem familyUnequal_length_strictly_increasing
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (k : Nat) :
    familyUnequal_component0_length resolve h k
    <
    familyUnequal_component0_length resolve h (k + 1) := by
  by_cases hk : k = 0
  · subst hk
    rw [familyUnequal_length_zero]
    have : familyUnequal_component0_length resolve h 1 = 1 := by
      unfold familyUnequal_component0_length
      rw [iteratedNeighbourCompose_succ, iteratedNeighbourCompose_zero]
      have := familyUnequal_N_n2 resolve h ⟨0, by decide⟩
      rw [this]
      rfl
    rw [this]
    decide
  · have hPos := familyUnequal_length_succ_ge1 resolve h k (Nat.pos_of_ne_zero hk)
    have hDouble := familyUnequal_length_doubles resolve h k (Nat.pos_of_ne_zero hk)
    rw [hDouble]
    omega

theorem familyUnequal_length_mono
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (k m : Nat)
    (hkm : k < m) :
    familyUnequal_component0_length resolve h k
    <
    familyUnequal_component0_length resolve h m := by
  induction hkm with
  | refl => exact familyUnequal_length_strictly_increasing resolve h k
  | step hkm ih =>
    exact Nat.lt_trans ih (familyUnequal_length_strictly_increasing resolve h _)

def RawOrbitInjective
    {X : Sort u}
    (step : X → X)
    (x : X) : Prop :=
  Function.Injective (RawOrbit step x)

theorem familyUnequal_rawOrbit_injective_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RawOrbitInjective
      (asAggregateFun resolve (neighbourComposeTransform resolve h))
      (familyUnequal resolve 2 h) := by
  intro k m hEq
  have hLenEq : familyUnequal_component0_length resolve h k
      = familyUnequal_component0_length resolve h m := by
    unfold familyUnequal_component0_length
    rw [← RawOrbit_eq_iteratedNeighbourCompose,
        ← RawOrbit_eq_iteratedNeighbourCompose]
    exact congrArg (fun f => (f ⟨0, by decide⟩).length) hEq
  -- strictly mono length forces k = m
  by_cases hkm : k < m
  · have := familyUnequal_length_mono resolve h k m hkm
    omega
  · by_cases hmk : m < k
    · have := familyUnequal_length_mono resolve h m k hmk
      omega
    · -- neither < so equal
      have hle : k ≤ m := Nat.le_of_not_lt hmk
      have hge : m ≤ k := Nat.le_of_not_lt hkm
      exact Nat.le_antisymm hle hge

theorem familyUnequal_rawOrbit_unbounded_distinct_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∀ B : Nat,
      ∃ k : Nat,
        B < k
        ∧
        RawOrbit (asAggregateFun resolve (neighbourComposeTransform resolve h))
          (familyUnequal resolve 2 h) k
        ≠
        RawOrbit (asAggregateFun resolve (neighbourComposeTransform resolve h))
          (familyUnequal resolve 2 h) B := by
  intro B
  refine ⟨B + 1, Nat.lt_succ_self B, ?_⟩
  intro hEq
  have hInj := familyUnequal_rawOrbit_injective_n2 resolve h
  have : B + 1 = B := hInj hEq
  omega

/-! ============================================================
    Folded orbit collapse
============================================================ -/

theorem rawOrbit_collapses_to_single_folded_position_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∀ k m,
      FoldedOrbit
        resolve
        (neighbourComposeTransform resolve h)
        (familyUnequal resolve 2 h)
        k
      =
      FoldedOrbit
        resolve
        (neighbourComposeTransform resolve h)
        (familyUnequal resolve 2 h)
        m := by
  intro k m
  rw [familyUnequal_foldedOrbit_constant_n2 resolve h k,
      familyUnequal_foldedOrbit_constant_n2 resolve h m]

theorem distinct_raw_same_folded_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∀ k m,
      k ≠ m →
      RawOrbit (asAggregateFun resolve (neighbourComposeTransform resolve h))
        (familyUnequal resolve 2 h) k
      ≠
      RawOrbit (asAggregateFun resolve (neighbourComposeTransform resolve h))
        (familyUnequal resolve 2 h) m
      ∧
      FoldedOrbit
        resolve
        (neighbourComposeTransform resolve h)
        (familyUnequal resolve 2 h)
        k
      =
      FoldedOrbit
        resolve
        (neighbourComposeTransform resolve h)
        (familyUnequal resolve 2 h)
        m := by
  intro k m hNe
  constructor
  · intro hEq
    exact hNe (familyUnequal_rawOrbit_injective_n2 resolve h hEq)
  · exact rawOrbit_collapses_to_single_folded_position_n2 resolve h k m

/-! ============================================================
    Headline hidden-dynamic split (packaging only)
============================================================ -/

theorem familyUnequal_hidden_dynamic_split_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∀ k m : Nat,
      k ≠ m →
      RawOrbit
          (asAggregateFun resolve
            (neighbourComposeTransform resolve h))
          (familyUnequal resolve 2 h)
          k
        ≠
      RawOrbit
          (asAggregateFun resolve
            (neighbourComposeTransform resolve h))
          (familyUnequal resolve 2 h)
          m
      ∧
      FoldedOrbit
          resolve
          (neighbourComposeTransform resolve h)
          (familyUnequal resolve 2 h)
          k
        =
      FoldedOrbit
          resolve
          (neighbourComposeTransform resolve h)
          (familyUnequal resolve 2 h)
          m :=
  distinct_raw_same_folded_n2 resolve h


/-! ============================================================
    Classifier orbit
============================================================ -/

def ClassifierOrbit
    {X V : Sort u}
    (step : X → X)
    (C : X → V)
    (x : X) :
    Nat → V :=
  fun k => C (RawOrbit step x k)

theorem familyUnequal_rawAllEqual_orbit_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ClassifierOrbit
      (asAggregateFun resolve (neighbourComposeTransform resolve h))
      (RawAllEqual resolve)
      (familyUnequal resolve 2 h)
      0
    =
    False
    ∧
    ∀ k,
      0 < k →
      ClassifierOrbit
        (asAggregateFun resolve (neighbourComposeTransform resolve h))
        (RawAllEqual resolve)
        (familyUnequal resolve 2 h)
        k
      =
      True := by
  constructor
  · unfold ClassifierOrbit
    rw [RawOrbit_zero]
    have hNot := familyUnequal_notAllEqual resolve 2 h
    exact eq_false hNot
  · intro k hk
    unfold ClassifierOrbit
    rw [RawOrbit_eq_iteratedNeighbourCompose]
    have hAll := (familyUnequal_rawAllEqual_stabilises resolve h).2 k hk
    exact eq_true hAll

def ClassifierEventuallyConstant
    {V : Sort u}
    (trace : Nat → V) : Prop :=
  ∃ K value,
    ∀ k,
      K ≤ k →
      trace k = value

theorem familyUnequal_rawAllEqual_eventuallyConstant_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ClassifierEventuallyConstant
      (ClassifierOrbit
        (neighbourComposeTransform resolve h)
        (RawAllEqual resolve)
        (familyUnequal resolve 2 h)) := by
  refine ⟨1, True, ?_⟩
  intro k hk
  have hPos : 0 < k := Nat.pos_of_ne_zero (by
    intro h0
    subst h0
    omega)
  exact (familyUnequal_rawAllEqual_orbit_n2 resolve h).2 k hPos

/-! ============================================================
    Orbit certificate
============================================================ -/

structure RawFoldedOrbitCertificate
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n) where

  rawNeverReturns :
    RawOrbitNeverReturns step p

  foldedStationary :
    FoldedOrbitStationary resolve step p

def familyUnequalOrbitCertificate_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RawFoldedOrbitCertificate
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h) where
  rawNeverReturns :=
    (familyUnequal_raw_folded_orbit_split_n2 resolve h).1
  foldedStationary := by
    intro k
    exact familyUnequal_foldedOrbit_constant_n2 resolve h k

/-! ============================================================
    Non-recoverability of orbit index from folded position
============================================================ -/

theorem foldedPosition_does_not_determine_rawOrbitIndex_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ¬ ∃ decode :
        (Fin 2 → TrajectoryBoundary resolve) → Nat,
      ∀ k,
        decode
          (FoldedOrbit
            resolve
            (neighbourComposeTransform resolve h)
            (familyUnequal resolve 2 h)
            k)
        =
        k := by
  intro ⟨decode, hDec⟩
  have h0 := hDec 0
  have h1 := hDec 1
  have hEq := rawOrbit_collapses_to_single_folded_position_n2 resolve h 0 1
  rw [hEq] at h0
  omega

#check RawOrbit
#check RawOrbit_add
#check FoldedOrbit
#check FoldedOrbitReturnsAt_iff_projection
#check rawReturn_implies_foldedReturn
#check FoldedOrbitStationary_iff_returns
#check RawFoldedOrbitSplit_iff
#check familyUnequal_foldedOrbit_constant_n2
#check familyUnequal_raw_folded_orbit_split_n2
#check familyUnequal_rawOrbit_injective_n2
#check familyUnequal_rawOrbit_unbounded_distinct_n2
#check rawOrbit_collapses_to_single_folded_position_n2
#check distinct_raw_same_folded_n2
#check familyUnequal_rawAllEqual_orbit_n2
#check familyUnequal_rawAllEqual_eventuallyConstant_n2
#check familyUnequalOrbitCertificate_n2
#check foldedPosition_does_not_determine_rawOrbitIndex_n2

#print axioms RawOrbit_add
#print axioms FoldedOrbitReturnsAt_iff_projection
#print axioms rawReturn_implies_foldedReturn
#print axioms FoldedOrbitStationary_iff_returns
#print axioms familyUnequal_rawOrbit_injective_n2
#print axioms familyUnequal_foldedOrbit_constant_n2
#print axioms familyUnequal_raw_folded_orbit_split_n2
#print axioms familyUnequal_rawAllEqual_orbit_n2
#print axioms familyUnequal_rawAllEqual_eventuallyConstant_n2
#print axioms rawOrbit_collapses_to_single_folded_position_n2
#print axioms distinct_raw_same_folded_n2
#print axioms foldedPosition_does_not_determine_rawOrbitIndex_n2

/-! ============================================================
    Stationary-fold / evolving-raw orbit hierarchy
============================================================ -/

def OrbitKernelStable
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) : Prop :=
  ∀ k,
    ThreadFamilyKernel resolve
      (RawOrbit (asAggregateFun resolve A.transform) p k)
      p

theorem OrbitKernelStable_iff_FoldedOrbitStationary
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) :
    OrbitKernelStable resolve A p
    ↔
    FoldedOrbitStationary resolve A.transform p := by
  unfold OrbitKernelStable FoldedOrbitStationary FoldedOrbit
  constructor
  · intro h k
    unfold ThreadFamilyKernel projectThreadFamily at h
    exact h k
  · intro h k
    unfold ThreadFamilyKernel projectThreadFamily
    exact h k

def NontrivialStationaryFoldOrbit
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) : Prop :=
  OrbitKernelStable resolve A p
  ∧
  ∃ k, 0 < k ∧
    RawOrbit (asAggregateFun resolve A.transform) p k ≠ p

def InjectiveStationaryFoldOrbit
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) : Prop :=
  OrbitKernelStable resolve A p
  ∧
  RawOrbitInjective (asAggregateFun resolve A.transform) p

theorem InjectiveStationaryFoldOrbit_implies_Nontrivial
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) :
    InjectiveStationaryFoldOrbit resolve A p →
    NontrivialStationaryFoldOrbit resolve A p := by
  intro ⟨hStable, hInj⟩
  refine ⟨hStable, 1, Nat.one_pos, ?_⟩
  intro hEq
  have : (1 : Nat) = 0 := hInj hEq
  omega

theorem RawFoldedOrbitSplit_iff_NeverReturns_and_KernelStable
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) :
    RawFoldedOrbitSplit resolve A.transform p
    ↔
    RawOrbitNeverReturns (asAggregateFun resolve A.transform) p
    ∧
    OrbitKernelStable resolve A p := by
  unfold RawFoldedOrbitSplit
  rw [OrbitKernelStable_iff_FoldedOrbitStationary,
      FoldedOrbitStationary_iff_returns]
  -- need to align the RawOrbitNeverReturns argument
  -- RawFoldedOrbitSplit uses step directly; we use asAggregateFun
  -- Adjust by noting asAggregateFun is the eta of step
  constructor
  · intro ⟨hNever, hFold⟩
    refine ⟨?_, hFold⟩
    intro k hk hRet
    exact hNever k hk hRet
  · intro ⟨hNever, hFold⟩
    refine ⟨?_, hFold⟩
    intro k hk hRet
    exact hNever k hk hRet

/-! ============================================================
    familyUnequal instantiation
============================================================ -/

theorem familyUnequal_injective_stationary_fold_orbit_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    InjectiveStationaryFoldOrbit
      resolve
      (neighbourComposeAggregate resolve h)
      (familyUnequal resolve 2 h) := by
  constructor
  · intro k
    unfold neighbourComposeAggregate
    rw [RawOrbit_eq_iteratedNeighbourCompose]
    exact familyUnequal_iter_kernel_stable resolve h k
  · unfold neighbourComposeAggregate
    exact familyUnequal_rawOrbit_injective_n2 resolve h

/-! ============================================================
    Classifier dynamics
============================================================ -/

def ClassifierChangesAlongOrbit
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (p : ThreadFamily resolve n) : Prop :=
  ∃ k m,
    C.classify (RawOrbit (asAggregateFun resolve A.transform) p k)
    ≠
    C.classify (RawOrbit (asAggregateFun resolve A.transform) p m)

def ClassifierEventuallyStableAlongOrbit
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (p : ThreadFamily resolve n) : Prop :=
  ClassifierEventuallyConstant
    (ClassifierOrbit (asAggregateFun resolve A.transform) C.classify p)

theorem familyUnequal_rawAllEqual_changes_along_orbit_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ClassifierChangesAlongOrbit
      resolve
      (neighbourComposeAggregate resolve h)
      (rawAllEqualClassifier resolve 2)
      (familyUnequal resolve 2 h) := by
  refine ⟨0, 1, ?_⟩
  unfold neighbourComposeAggregate
  have hC := rawAllEqualClassifier_apply resolve 2
  rw [hC, hC]
  rw [RawOrbit_eq_iteratedNeighbourCompose, RawOrbit_eq_iteratedNeighbourCompose]
  rw [iteratedNeighbourCompose_zero]
  have hNot := familyUnequal_notAllEqual resolve 2 h
  have hAll := (familyUnequal_rawAllEqual_stabilises resolve h).2 1 (by decide)
  intro hEq
  rw [hEq] at hNot
  exact hNot hAll

theorem familyUnequal_rawAllEqual_eventuallyStable_along_orbit_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ClassifierEventuallyStableAlongOrbit
      resolve
      (neighbourComposeAggregate resolve h)
      (rawAllEqualClassifier resolve 2)
      (familyUnequal resolve 2 h) := by
  unfold ClassifierEventuallyStableAlongOrbit ClassifierEventuallyConstant
  refine ⟨1, True, fun k hk => ?_⟩
  have hPos : 0 < k := Nat.pos_of_ne_zero (fun h0 => by
    subst h0
    omega)
  unfold ClassifierOrbit neighbourComposeAggregate
  rw [rawAllEqualClassifier_apply]
  rw [RawOrbit_eq_iteratedNeighbourCompose]
  exact eq_true ((familyUnequal_rawAllEqual_stabilises resolve h).2 k hPos)

/-! ============================================================
    Hidden dynamic orbit
============================================================ -/

structure HiddenDynamicOrbit
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) where

  rawInjective :
    RawOrbitInjective (asAggregateFun resolve A.transform) p

  foldedStationary :
    OrbitKernelStable resolve A p

def familyUnequal_hiddenDynamicOrbit_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    HiddenDynamicOrbit
      resolve
      2
      (neighbourComposeAggregate resolve h)
      (familyUnequal resolve 2 h) where
  rawInjective := familyUnequal_rawOrbit_injective_n2 resolve h
  foldedStationary :=
    (familyUnequal_injective_stationary_fold_orbit_n2 resolve h).1

/-! ============================================================
    Generic orbit-index nonrecoverability
============================================================ -/

theorem hiddenDynamicOrbit_folded_does_not_recover_index
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n)
    (H : HiddenDynamicOrbit resolve n A p) :
    ¬ ∃ decode : (Fin n → TrajectoryBoundary resolve) → Nat,
      ∀ k,
        decode (projectThreadFamily resolve
          (RawOrbit (asAggregateFun resolve A.transform) p k))
        = k := by
  intro ⟨decode, hDec⟩
  have h0 := hDec 0
  have h1 := hDec 1
  have hFold0 := H.foldedStationary 0
  have hFold1 := H.foldedStationary 1
  -- both project to the same as p
  have hProj0 : projectThreadFamily resolve
      (RawOrbit (asAggregateFun resolve A.transform) p 0)
    = projectThreadFamily resolve p := by
    unfold ThreadFamilyKernel projectThreadFamily at hFold0
    exact hFold0
  have hProj1 : projectThreadFamily resolve
      (RawOrbit (asAggregateFun resolve A.transform) p 1)
    = projectThreadFamily resolve p := by
    unfold ThreadFamilyKernel projectThreadFamily at hFold1
    exact hFold1
  rw [hProj0] at h0
  rw [hProj1] at h1
  omega

#check OrbitKernelStable
#check OrbitKernelStable_iff_FoldedOrbitStationary
#check NontrivialStationaryFoldOrbit
#check InjectiveStationaryFoldOrbit
#check InjectiveStationaryFoldOrbit_implies_Nontrivial
#check RawFoldedOrbitSplit_iff_NeverReturns_and_KernelStable
#check familyUnequal_injective_stationary_fold_orbit_n2
#check ClassifierChangesAlongOrbit
#check ClassifierEventuallyStableAlongOrbit
#check familyUnequal_rawAllEqual_changes_along_orbit_n2
#check familyUnequal_rawAllEqual_eventuallyStable_along_orbit_n2
#check HiddenDynamicOrbit
#check familyUnequal_hiddenDynamicOrbit_n2
#check hiddenDynamicOrbit_folded_does_not_recover_index

#print axioms OrbitKernelStable_iff_FoldedOrbitStationary
#print axioms InjectiveStationaryFoldOrbit_implies_Nontrivial
#print axioms RawFoldedOrbitSplit_iff_NeverReturns_and_KernelStable
#print axioms familyUnequal_injective_stationary_fold_orbit_n2
#print axioms familyUnequal_rawAllEqual_changes_along_orbit_n2
#print axioms familyUnequal_rawAllEqual_eventuallyStable_along_orbit_n2
#print axioms hiddenDynamicOrbit_folded_does_not_recover_index

/-! ============================================================
    Concrete chirality value semantics

    `ChiralityValue` constructors mean ONLY:
    - `separated`: RawAllEqual does not hold
    - `aligned`:   RawAllEqual holds

    They do NOT mean left/right, clockwise/counter-clockwise,
    positive/negative orientation, or physical handedness.
============================================================ -/

inductive ChiralityValue where
  | separated
  | aligned
  deriving DecidableEq

/-! Prop-level value specification.
    RawAllEqual is not constructively decidable, so we use a relation
    rather than a function ThreadFamily → ChiralityValue. -/

def ChiralityValueDescribes
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n)
    (value : ChiralityValue) : Prop :=
  match value with
  | .aligned =>
      RawAllEqual resolve p
  | .separated =>
      ¬ RawAllEqual resolve p

theorem chiralityValueDescribes_exclusive
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) :
    ¬ (
      ChiralityValueDescribes resolve p .aligned
      ∧
      ChiralityValueDescribes resolve p .separated
    ) := by
  intro ⟨hAl, hSep⟩
  exact hSep hAl

/-! Exhaustiveness of ChiralityValueDescribes is constructively open:
    it requires deciding RawAllEqual, which is not available. -/

theorem familyUnequal_chiralityValue_separated_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityValueDescribes
      resolve
      (familyUnequal resolve 2 h)
      .separated := by
  unfold ChiralityValueDescribes
  exact familyUnequal_notAllEqual resolve 2 h

theorem neighbourCompose_familyUnequal_chiralityValue_aligned_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityValueDescribes
      resolve
      (neighbourComposeTransform resolve h
        (familyUnequal resolve 2 h))
      .aligned := by
  unfold ChiralityValueDescribes
  have hAll := (familyUnequal_rawAllEqual_stabilises resolve h).2 1 (by decide)
  rw [iteratedNeighbourCompose_succ, iteratedNeighbourCompose_zero] at hAll
  exact hAll

def ChiralityTransition
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n)
    (fromValue toValue : ChiralityValue) : Prop :=
  ChiralityValueDescribes resolve p fromValue
  ∧
  ChiralityValueDescribes resolve (A p) toValue

theorem neighbourCompose_chiralityTransition_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityTransition
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      .separated
      .aligned := by
  constructor
  · exact familyUnequal_chiralityValue_separated_n2 resolve h
  · exact neighbourCompose_familyUnequal_chiralityValue_aligned_n2 resolve h

def FoldedTrivialChiralityTransition
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n)
    (fromValue toValue : ChiralityValue) : Prop :=
  ThreadFamilyKernel resolve (A p) p
  ∧
  ChiralityTransition resolve A p fromValue toValue

theorem neighbourCompose_foldedTrivial_chiralityTransition_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    FoldedTrivialChiralityTransition
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      .separated
      .aligned := by
  constructor
  · have hK := familyUnequal_iter_kernel_stable resolve h 1
    rw [iteratedNeighbourCompose_succ, iteratedNeighbourCompose_zero] at hK
    exact hK
  · exact neighbourCompose_chiralityTransition_n2 resolve h

def RelationalAggregateChiralityTransition
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (A : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n)
    (fromValue toValue : ChiralityValue) : Prop :=
  IsRelationallyAggregate resolve A
  ∧
  FoldedTrivialChiralityTransition
      resolve A p fromValue toValue

theorem neighbourCompose_relationalAggregate_chiralityTransition_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RelationalAggregateChiralityTransition
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      .separated
      .aligned := by
  constructor
  · exact neighbourComposeTransform_isRelationallyAggregate resolve 2 h
  · exact neighbourCompose_foldedTrivial_chiralityTransition_n2 resolve h

theorem separated_ne_aligned :
    ChiralityValue.separated
    ≠
    ChiralityValue.aligned := by
  decide

theorem chiralityValue_changes_at_same_folded_position_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∃ p q : ThreadFamily resolve 2,
      ThreadFamilyKernel resolve p q
      ∧
      ChiralityValueDescribes resolve p .separated
      ∧
      ChiralityValueDescribes resolve q .aligned := by
  refine ⟨
    familyUnequal resolve 2 h,
    neighbourComposeTransform resolve h (familyUnequal resolve 2 h),
    ?_,
    familyUnequal_chiralityValue_separated_n2 resolve h,
    neighbourCompose_familyUnequal_chiralityValue_aligned_n2 resolve h
  ⟩
  have hK := familyUnequal_iter_kernel_stable resolve h 1
  rw [iteratedNeighbourCompose_succ, iteratedNeighbourCompose_zero] at hK
  exact ThreadFamilyKernel_symm resolve hK

def ChiralityValueAlongOrbit
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (step : AggregateFamilyTransform resolve n)
    (p : ThreadFamily resolve n)
    (k : Nat)
    (value : ChiralityValue) : Prop :=
  ChiralityValueDescribes
    resolve
    (RawOrbit (asAggregateFun resolve step) p k)
    value

theorem familyUnequal_chiralityValue_orbit_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityValueAlongOrbit
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      0
      .separated
    ∧
    ∀ k,
      0 < k →
      ChiralityValueAlongOrbit
        resolve
        (neighbourComposeTransform resolve h)
        (familyUnequal resolve 2 h)
        k
        .aligned := by
  constructor
  · unfold ChiralityValueAlongOrbit ChiralityValueDescribes
    rw [RawOrbit_eq_iteratedNeighbourCompose, iteratedNeighbourCompose_zero]
    exact familyUnequal_notAllEqual resolve 2 h
  · intro k hk
    unfold ChiralityValueAlongOrbit ChiralityValueDescribes
    rw [RawOrbit_eq_iteratedNeighbourCompose]
    exact (familyUnequal_rawAllEqual_stabilises resolve h).2 k hk

theorem familyUnequal_chiralityValue_stable_after_first_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∀ k : Nat,
      0 < k →
      ChiralityValueAlongOrbit
        resolve
        (neighbourComposeTransform resolve h)
        (familyUnequal resolve 2 h)
        k
        .aligned := by
  intro k hk
  exact
    (familyUnequal_chiralityValue_orbit_n2 resolve h).2
      k hk

theorem relationalAggregateSpecification_has_concrete_value_transition_n2
    (resolve : KernelExpr → Store → Location) :
    RelationalAggregateChiralitySpecificationExists resolve 2
    ∧
    ∃ h : 1 < 2,
      RelationalAggregateChiralityTransition
        resolve
        (neighbourComposeTransform resolve h)
        (familyUnequal resolve 2 h)
        .separated
        .aligned := by
  refine ⟨
    RelationalAggregateChiralitySpecificationExists_n2 resolve (by decide),
    ⟨by decide, neighbourCompose_relationalAggregate_chiralityTransition_n2 resolve (by decide)⟩
  ⟩

/-! Constructive computation firewall:
    ChiralityValue has decidable equality (via deriving DecidableEq).
    No total constructive function ThreadFamily → ChiralityValue is added,
    because RawAllEqual is not constructively decidable.
    Classical.choice and Classical.decEq are not used. -/

#check ChiralityValue
#check ChiralityValueDescribes
#check chiralityValueDescribes_exclusive
#check familyUnequal_chiralityValue_separated_n2
#check neighbourCompose_familyUnequal_chiralityValue_aligned_n2
#check neighbourCompose_chiralityTransition_n2
#check neighbourCompose_foldedTrivial_chiralityTransition_n2
#check neighbourCompose_relationalAggregate_chiralityTransition_n2
#check separated_ne_aligned
#check chiralityValue_changes_at_same_folded_position_n2
#check familyUnequal_chiralityValue_orbit_n2
#check relationalAggregateSpecification_has_concrete_value_transition_n2

#print axioms chiralityValueDescribes_exclusive
#print axioms familyUnequal_chiralityValue_separated_n2
#print axioms neighbourCompose_familyUnequal_chiralityValue_aligned_n2
#print axioms neighbourCompose_chiralityTransition_n2
#print axioms neighbourCompose_foldedTrivial_chiralityTransition_n2
#print axioms neighbourCompose_relationalAggregate_chiralityTransition_n2
#print axioms separated_ne_aligned
#print axioms chiralityValue_changes_at_same_folded_position_n2
#print axioms familyUnequal_chiralityValue_orbit_n2
#print axioms relationalAggregateSpecification_has_concrete_value_transition_n2

/-! ============================================================
    Induced Trajectory Map — Reversibility Descent
============================================================ -/

def inducedTrajectoryMap
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext)
    (hrespect :
      ∀ xs ys,
        FoldKernel resolve xs ys →
        FoldKernel resolve (rotation xs) (rotation ys)) :
    TrajectoryBoundary resolve → TrajectoryBoundary resolve :=
  Quotient.lift
    (s := trajectorySetoid resolve)
    (fun xs => trajectoryProjection resolve (rotation xs))
    (by
      intro xs ys hEq
      have hFK : FoldKernel resolve xs ys := Quotient.sound hEq
      exact hrespect xs ys hFK)

theorem inducedTrajectoryMap_projection
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext)
    (hrespect :
      ∀ xs ys,
        FoldKernel resolve xs ys →
        FoldKernel resolve (rotation xs) (rotation ys))
    (xs : List KernelExprContext) :
    inducedTrajectoryMap resolve rotation hrespect
      (trajectoryProjection resolve xs)
    =
    trajectoryProjection resolve (rotation xs) := by
  rfl

theorem inducedTrajectoryMap_id
    (resolve : KernelExpr → Store → Location) :
    inducedTrajectoryMap resolve
      (fun xs => xs)
      (by
        intro xs ys h
        exact h)
    =
    id := by
  funext q
  refine Quotient.inductionOn q ?_
  intro xs
  rfl

theorem inducedTrajectoryMap_comp
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : List KernelExprContext → List KernelExprContext)
    (h₁ : ∀ xs ys, FoldKernel resolve xs ys → FoldKernel resolve (r₁ xs) (r₁ ys))
    (h₂ : ∀ xs ys, FoldKernel resolve xs ys → FoldKernel resolve (r₂ xs) (r₂ ys)) :
    inducedTrajectoryMap resolve
      (fun xs => r₂ (r₁ xs))
      (by
        intro xs ys hxy
        exact h₂ (r₁ xs) (r₁ ys) (h₁ xs ys hxy))
    =
    inducedTrajectoryMap resolve r₂ h₂
      ∘
    inducedTrajectoryMap resolve r₁ h₁ := by
  funext q
  refine Quotient.inductionOn q ?_
  intro xs
  rfl

/-! Reversibility descent -/

theorem inducedTrajectoryMap_left_inverse
    (resolve : KernelExpr → Store → Location)
    (r rinv : List KernelExprContext → List KernelExprContext)
    (hr :
      ∀ xs ys,
        FoldKernel resolve xs ys →
        FoldKernel resolve (r xs) (r ys))
    (hrinv :
      ∀ xs ys,
        FoldKernel resolve xs ys →
        FoldKernel resolve (rinv xs) (rinv ys))
    (hleft : ∀ xs, rinv (r xs) = xs) :
    inducedTrajectoryMap resolve rinv hrinv
      ∘
    inducedTrajectoryMap resolve r hr
    =
    id := by
  funext q
  refine Quotient.inductionOn q ?_
  intro xs
  show inducedTrajectoryMap resolve rinv hrinv
        (inducedTrajectoryMap resolve r hr (trajectoryProjection resolve xs))
      = trajectoryProjection resolve xs
  rw [inducedTrajectoryMap_projection]
  rw [inducedTrajectoryMap_projection]
  rw [hleft]

theorem inducedTrajectoryMap_right_inverse
    (resolve : KernelExpr → Store → Location)
    (r rinv : List KernelExprContext → List KernelExprContext)
    (hr :
      ∀ xs ys,
        FoldKernel resolve xs ys →
        FoldKernel resolve (r xs) (r ys))
    (hrinv :
      ∀ xs ys,
        FoldKernel resolve xs ys →
        FoldKernel resolve (rinv xs) (rinv ys))
    (hright : ∀ xs, r (rinv xs) = xs) :
    inducedTrajectoryMap resolve r hr
      ∘
    inducedTrajectoryMap resolve rinv hrinv
    =
    id := by
  funext q
  refine Quotient.inductionOn q ?_
  intro xs
  show inducedTrajectoryMap resolve r hr
        (inducedTrajectoryMap resolve rinv hrinv (trajectoryProjection resolve xs))
      = trajectoryProjection resolve xs
  rw [inducedTrajectoryMap_projection]
  rw [inducedTrajectoryMap_projection]
  rw [hright]

/-! ============================================================
    ThreadPermutation → projected family action
    (carrier is Fin n → TrajectoryBoundary, not single List)
============================================================ -/

def ThreadPermutation.projectedAction
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (f : Fin n → TrajectoryBoundary resolve) :
    Fin n → TrajectoryBoundary resolve :=
  fun i => f (π.toFun i)

def ThreadPermutation.projectedAction_inverse
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (f : Fin n → TrajectoryBoundary resolve) :
    Fin n → TrajectoryBoundary resolve :=
  fun i => f (π.invFun i)

theorem ThreadPermutation.projectedAction_left_inverse
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (f : Fin n → TrajectoryBoundary resolve) :
    π.projectedAction_inverse resolve (π.projectedAction resolve f) = f := by
  funext i
  unfold projectedAction projectedAction_inverse
  exact congrArg f (π.right_inv i)

theorem ThreadPermutation.projectedAction_right_inverse
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (f : Fin n → TrajectoryBoundary resolve) :
    π.projectedAction resolve (π.projectedAction_inverse resolve f) = f := by
  funext i
  unfold projectedAction projectedAction_inverse
  exact congrArg f (π.left_inv i)

theorem ThreadPermutation.projectedAction_projection
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p : ThreadFamily resolve n)
    (i : Fin n) :
    π.projectedAction resolve (projectThreadFamily resolve p) i
    =
    projectThreadFamily resolve (permuteThreadFamily resolve π p) i := by
  unfold projectedAction projectThreadFamily permuteThreadFamily reindexThreadFamily
  rfl

/-! ============================================================

-/
