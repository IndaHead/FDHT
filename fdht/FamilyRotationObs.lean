import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Verified single-thread and family layers
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

def foldCompatibleRotationCompose
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : FoldCompatibleRotation resolve) :
    FoldCompatibleRotation resolve where
  rotate := fun xs => r₁.rotate (r₂.rotate xs)
  compatible := by
    intro xs ys h
    exact r₁.compatible (r₂.rotate xs) (r₂.rotate ys)
      (r₂.compatible xs ys h)

def ThreadFamily
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :=
  Fin n → List KernelExprContext

def projectThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) :
    Fin n → TrajectoryBoundary resolve :=
  fun i => trajectoryProjection resolve (p i)

def ThreadFamilyKernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p q : ThreadFamily resolve n) : Prop :=
  projectThreadFamily resolve p =
  projectThreadFamily resolve q

def rotateThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r : FoldCompatibleRotation resolve)
    (p : ThreadFamily resolve n) :
    ThreadFamily resolve n :=
  fun i => r.rotate (p i)

def FamilyRotationBoundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  ∀ p : ThreadFamily resolve n,
    projectThreadFamily resolve (rotateThreadFamily resolve r₁ p) =
    projectThreadFamily resolve (rotateThreadFamily resolve r₂ p)

def FamilyRotationKernel
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  FamilyRotationBoundaryEquivalent resolve n r₁ r₂

/-! ============================================================
    Raw rotation equality
============================================================ -/

def RawRotationEqual
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  r₁.rotate = r₂.rotate

theorem rawRotationEqual_implies_familyKernel
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (h : RawRotationEqual resolve r₁ r₂) :
    FamilyRotationKernel resolve n r₁ r₂ := by
  intro p
  funext i
  show trajectoryProjection resolve (r₁.rotate (p i)) =
       trajectoryProjection resolve (r₂.rotate (p i))
  rw [h]

/-! ============================================================
    Family rotation faithfulness
============================================================ -/

def FamilyRotationFaithful
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  ∀ r₁ r₂ : FoldCompatibleRotation resolve,
    FamilyRotationKernel resolve n r₁ r₂ →
    r₁.rotate = r₂.rotate

/-! ============================================================
    Family rotation collision
============================================================ -/

def FamilyRotationCollision
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  ∃ r₁ r₂ : FoldCompatibleRotation resolve,
    r₁.rotate ≠ r₂.rotate ∧
    FamilyRotationKernel resolve n r₁ r₂

theorem familyRotationCollision_implies_not_faithful
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (h : FamilyRotationCollision resolve n) :
    ¬ FamilyRotationFaithful resolve n := by
  intro hFaithful
  rcases h with ⟨r₁, r₂, hNe, hKernel⟩
  exact hNe (hFaithful r₁ r₂ hKernel)

/-! ============================================================
    Single-thread versus family observation
============================================================ -/

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

theorem singleBoundaryEquivalent_implies_familyKernel
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (h : RotationBoundaryEquivalent resolve r₁ r₂) :
    FamilyRotationKernel resolve n r₁ r₂ := by
  intro p
  funext i
  show trajectoryProjection resolve (r₁.rotate (p i)) =
       trajectoryProjection resolve (r₂.rotate (p i))
  have hQ := h (trajectoryProjection resolve (p i))
  exact hQ

/-! ============================================================
    Zero-arity behaviour
============================================================ -/

theorem familyKernel_zero_vacuous
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : FoldCompatibleRotation resolve) :
    FamilyRotationKernel resolve 0 r₁ r₂ := by
  intro p
  funext i
  exact Fin.elim0 i

/-! ============================================================
    Relation transport
============================================================ -/

def RelationTransportedByRotation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r : FoldCompatibleRotation resolve)
    (R : ThreadFamily resolve n → Prop) :
    ThreadFamily resolve n → Prop :=
  fun p => R (rotateThreadFamily resolve r p)

theorem relationTransport_compose
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (R : ThreadFamily resolve n → Prop)
    (p : ThreadFamily resolve n) :
    RelationTransportedByRotation resolve
      (foldCompatibleRotationCompose resolve r₁ r₂) R p
    ↔
    RelationTransportedByRotation resolve r₂
      (RelationTransportedByRotation resolve r₁ R) p := by
  rfl

/-! ============================================================
    Countermodel witness predicates
============================================================ -/

def RawDistinctFoldedEqual
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  ∃ r₁ r₂ : FoldCompatibleRotation resolve,
    r₁.rotate ≠ r₂.rotate ∧
    FamilyRotationKernel resolve n r₁ r₂

def DifferentFoldedActions
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  ∃ r₁ r₂ : FoldCompatibleRotation resolve,
    ¬ FamilyRotationKernel resolve n r₁ r₂

def RelationTransformedDifferently
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  ∃ (R : ThreadFamily resolve n → Prop) (p : ThreadFamily resolve n),
    R (rotateThreadFamily resolve r₁ p)
    ≠
    R (rotateThreadFamily resolve r₂ p)

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check rawRotationEqual_implies_familyKernel
#check familyRotationCollision_implies_not_faithful
#check singleBoundaryEquivalent_implies_familyKernel
#check familyKernel_zero_vacuous
#check relationTransport_compose

#print axioms rawRotationEqual_implies_familyKernel
#print axioms familyRotationCollision_implies_not_faithful
#print axioms singleBoundaryEquivalent_implies_familyKernel
#print axioms familyKernel_zero_vacuous
#print axioms relationTransport_compose
