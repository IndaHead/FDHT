import FDHT_Audit_ArbitraryCollision
import ThreadFamilyWitness
import ClassifierReconciliation
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Verified layers
============================================================ -/

def RotationRespectsFoldKernel
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext) : Prop :=
  ∀ xs ys,
    FoldKernel resolve xs ys →
    FoldKernel resolve (rotation xs) (rotation ys)

structure FoldCompatibleRotation
    (resolve : KernelExpr → Store → Location) where
  rotate : List KernelExprContext → List KernelExprContext
  compatible : RotationRespectsFoldKernel resolve rotate

def identityRotation : List KernelExprContext → List KernelExprContext :=
  id

theorem identityRotation_respectsFoldKernel
    (resolve : KernelExpr → Store → Location) :
    RotationRespectsFoldKernel resolve identityRotation := by
  intro xs ys h
  exact h

def foldCompatibleRotationIdentity
    (resolve : KernelExpr → Store → Location) :
    FoldCompatibleRotation resolve where
  rotate := identityRotation
  compatible := identityRotation_respectsFoldKernel resolve

def rotateThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r : FoldCompatibleRotation resolve)
    (p : ThreadFamily resolve n) :
    ThreadFamily resolve n :=
  fun i => r.rotate (p i)

def FamilyRotationKernel
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  ∀ p : ThreadFamily resolve n,
    projectThreadFamily resolve (rotateThreadFamily resolve r₁ p) =
    projectThreadFamily resolve (rotateThreadFamily resolve r₂ p)

def RotationBoundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  ∀ q : TrajectoryBoundary resolve,
    Quotient.lift
      (s := trajectorySetoid resolve)
      (fun xs => trajectoryProjection resolve (r₁.rotate xs))
      (by
        intro xs ys hEq
        have hKernel : FoldKernel resolve xs ys :=
          (by
            unfold FoldKernel trajectoryProjection toTrajectoryBoundary
            exact Quotient.sound hEq)
        exact r₁.compatible xs ys hKernel)
      q
    =
    Quotient.lift
      (s := trajectorySetoid resolve)
      (fun xs => trajectoryProjection resolve (r₂.rotate xs))
      (by
        intro xs ys hEq
        have hKernel : FoldKernel resolve xs ys :=
          (by
            unfold FoldKernel trajectoryProjection toTrajectoryBoundary
            exact Quotient.sound hEq)
        exact r₂.compatible xs ys hKernel)
      q

/-! ============================================================
    Rotation classifier
============================================================ -/

def RotationClassifierInvariant
    (resolve : KernelExpr → Store → Location)
    (C : RelationalClassifier (FoldCompatibleRotation resolve)) : Prop :=
  ClassifierInvariant C (RotationBoundaryEquivalent resolve)

def RotationClassifierFaithful
    (resolve : KernelExpr → Store → Location)
    (C : RelationalClassifier (FoldCompatibleRotation resolve)) : Prop :=
  ∀ r₁ r₂,
    C.classify r₁ = C.classify r₂ →
    RotationBoundaryEquivalent resolve r₁ r₂

/-! ============================================================
    Rotation-sensitive classifier
============================================================ -/

def RotationSensitiveClassifierWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ∃ (r : FoldCompatibleRotation resolve)
    (p : ThreadFamily resolve n),
      C.classify (rotateThreadFamily resolve r p)
      ≠
      C.classify p

theorem identityRotation_not_sensitive_for_classifier
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (p : ThreadFamily resolve n) :
    C.classify
      (rotateThreadFamily resolve
        (foldCompatibleRotationIdentity resolve) p)
    =
    C.classify p := by
  rfl

/-! ============================================================
    Folded-trivial rotation classifier
============================================================ -/

def FoldedTrivialRotationClassifierWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ∃ (r : FoldCompatibleRotation resolve)
    (p : ThreadFamily resolve n),
      ThreadFamilyKernel resolve
        (rotateThreadFamily resolve r p) p
      ∧
      C.classify (rotateThreadFamily resolve r p)
      ≠
      C.classify p

/-! ============================================================
    Chirality specification
============================================================ -/

structure ChiralitySpecification
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier :
    RelationalClassifier (ThreadFamily resolve n)
  rotationSensitive :
    RotationSensitiveClassifierWitness resolve classifier
  foldedTrivialSensitive :
    FoldedTrivialRotationClassifierWitness resolve classifier

def ChiralitySpecificationExists
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  Nonempty (ChiralitySpecification resolve n)

/-! ============================================================
    Rotation-kernel classifier specification
============================================================ -/

def ChiralityClassifiesRotationKernel
    (resolve : KernelExpr → Store → Location)
    (C : RelationalClassifier (FoldCompatibleRotation resolve)) : Prop :=
  ∀ r₁ r₂,
    C.classify r₁ = C.classify r₂
    ↔
    RotationBoundaryEquivalent resolve r₁ r₂

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check RelationalClassifier
#check ClassifierInvariant
#check FamilyClassifierIndependentWitness
#check FoldedTrivialRotationClassifierWitness
#check ChiralitySpecification
#check ChiralitySpecificationExists

#print axioms identityRotation_not_sensitive_for_classifier
