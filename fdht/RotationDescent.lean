import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Abstract rotation system
============================================================ -/

structure RotationSystem (X : Type) where
  Rotation : Type
  identity : Rotation
  compose : Rotation → Rotation → Rotation
  act : Rotation → X → X
  identity_act : ∀ x, act identity x = x
  compose_act : ∀ r₁ r₂ x, act (compose r₁ r₂) x = act r₁ (act r₂ x)

/-! ============================================================
    Fold-kernel compatibility criterion
============================================================ -/

def RotationRespectsFoldKernel
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext) : Prop :=
  ∀ xs ys,
    FoldKernel resolve xs ys →
    FoldKernel resolve (rotation xs) (rotation ys)

/-! ============================================================
    Descent criterion
============================================================ -/

def RotationDescendsToBoundary
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext) : Prop :=
  ∃ rotateBoundary : TrajectoryBoundary resolve → TrajectoryBoundary resolve,
    ∀ xs,
      rotateBoundary (trajectoryProjection resolve xs) =
      trajectoryProjection resolve (rotation xs)

theorem foldKernel_iff_trajectoryEquivalent
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    FoldKernel resolve xs ys ↔ TrajectoryEquivalent resolve xs ys := by
  constructor
  · intro h
    unfold FoldKernel trajectoryProjection toTrajectoryBoundary at h
    exact Quotient.exact h
  · intro h
    unfold FoldKernel trajectoryProjection toTrajectoryBoundary
    exact Quotient.sound h

theorem rotation_descends_iff_kernel_compatible
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext) :
    RotationDescendsToBoundary resolve rotation
    ↔
    RotationRespectsFoldKernel resolve rotation := by
  constructor
  · intro ⟨rotateBoundary, hDesc⟩ xs ys hKernel
    unfold FoldKernel at *
    rw [← hDesc xs, ← hDesc ys, hKernel]
  · intro hRespect
    refine ⟨fun q =>
      Quotient.lift
        (s := trajectorySetoid resolve)
        (fun xs => trajectoryProjection resolve (rotation xs))
        (by
          intro xs ys hEq
          have hKernel : FoldKernel resolve xs ys :=
            (foldKernel_iff_trajectoryEquivalent resolve xs ys).mpr hEq
          exact hRespect xs ys hKernel)
        q, ?_⟩
    intro xs
    rfl

/-! ============================================================
    Canonical descended rotation
============================================================ -/

def rotateTrajectoryBoundary
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext)
    (h : RotationRespectsFoldKernel resolve rotation) :
    TrajectoryBoundary resolve → TrajectoryBoundary resolve :=
  Quotient.lift
    (s := trajectorySetoid resolve)
    (fun xs => trajectoryProjection resolve (rotation xs))
    (by
      intro xs ys hEq
      have hKernel : FoldKernel resolve xs ys :=
        (foldKernel_iff_trajectoryEquivalent resolve xs ys).mpr hEq
      exact h xs ys hKernel)

theorem rotateTrajectoryBoundary_mk
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext)
    (h : RotationRespectsFoldKernel resolve rotation)
    (xs : List KernelExprContext) :
    rotateTrajectoryBoundary resolve rotation h
      (trajectoryProjection resolve xs)
    =
    trajectoryProjection resolve (rotation xs) := by
  rfl

/-! ============================================================
    Identity rotation
============================================================ -/

def identityRotation : List KernelExprContext → List KernelExprContext :=
  id

theorem identityRotation_respectsFoldKernel
    (resolve : KernelExpr → Store → Location) :
    RotationRespectsFoldKernel resolve identityRotation := by
  intro xs ys h
  exact h

theorem identityRotation_boundary
    (resolve : KernelExpr → Store → Location) :
    rotateTrajectoryBoundary resolve identityRotation
      (identityRotation_respectsFoldKernel resolve)
    =
    id := by
  funext q
  induction q using Quotient.ind with
  | _ xs =>
    rfl

/-! ============================================================
    Composition of rotations
============================================================ -/

theorem composeRotation_respectsFoldKernel
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : List KernelExprContext → List KernelExprContext)
    (h₁ : RotationRespectsFoldKernel resolve r₁)
    (h₂ : RotationRespectsFoldKernel resolve r₂) :
    RotationRespectsFoldKernel resolve (fun xs => r₁ (r₂ xs)) := by
  intro xs ys h
  exact h₁ (r₂ xs) (r₂ ys) (h₂ xs ys h)

theorem composeRotation_boundary
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : List KernelExprContext → List KernelExprContext)
    (h₁ : RotationRespectsFoldKernel resolve r₁)
    (h₂ : RotationRespectsFoldKernel resolve r₂) :
    rotateTrajectoryBoundary resolve (fun xs => r₁ (r₂ xs))
      (composeRotation_respectsFoldKernel resolve r₁ r₂ h₁ h₂)
    =
    fun q =>
      rotateTrajectoryBoundary resolve r₁ h₁
        (rotateTrajectoryBoundary resolve r₂ h₂ q) := by
  funext q
  induction q using Quotient.ind with
  | _ xs =>
    rfl

/-! ============================================================
    Fold-compatible rotation monoid
============================================================ -/

structure FoldCompatibleRotation
    (resolve : KernelExpr → Store → Location) where
  rotate : List KernelExprContext → List KernelExprContext
  compatible : RotationRespectsFoldKernel resolve rotate

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
  compatible := composeRotation_respectsFoldKernel resolve
    r₁.rotate r₂.rotate r₁.compatible r₂.compatible

theorem foldCompatibleRotation_leftIdentity
    (resolve : KernelExpr → Store → Location)
    (r : FoldCompatibleRotation resolve) :
    foldCompatibleRotationCompose resolve
      (foldCompatibleRotationIdentity resolve) r
    =
    r := by
  cases r
  rfl

theorem foldCompatibleRotation_rightIdentity
    (resolve : KernelExpr → Store → Location)
    (r : FoldCompatibleRotation resolve) :
    foldCompatibleRotationCompose resolve
      r (foldCompatibleRotationIdentity resolve)
    =
    r := by
  cases r
  rfl

theorem foldCompatibleRotation_assoc
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ r₃ : FoldCompatibleRotation resolve) :
    foldCompatibleRotationCompose resolve
      (foldCompatibleRotationCompose resolve r₁ r₂) r₃
    =
    foldCompatibleRotationCompose resolve
      r₁ (foldCompatibleRotationCompose resolve r₂ r₃) := by
  cases r₁; cases r₂; cases r₃
  rfl

/-! ============================================================
    Descent homomorphism
============================================================ -/

def descendedRotation
    (resolve : KernelExpr → Store → Location)
    (r : FoldCompatibleRotation resolve) :
    TrajectoryBoundary resolve → TrajectoryBoundary resolve :=
  rotateTrajectoryBoundary resolve r.rotate r.compatible

theorem descendedRotation_identity
    (resolve : KernelExpr → Store → Location) :
    descendedRotation resolve (foldCompatibleRotationIdentity resolve)
    =
    id := by
  exact identityRotation_boundary resolve

theorem descendedRotation_compose
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : FoldCompatibleRotation resolve) :
    descendedRotation resolve
      (foldCompatibleRotationCompose resolve r₁ r₂)
    =
    fun q =>
      descendedRotation resolve r₁
        (descendedRotation resolve r₂ q) := by
  exact composeRotation_boundary resolve
    r₁.rotate r₂.rotate r₁.compatible r₂.compatible

/-! ============================================================
    Rotation boundary equivalence
============================================================ -/

def RotationBoundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  ∀ q : TrajectoryBoundary resolve,
    descendedRotation resolve r₁ q =
    descendedRotation resolve r₂ q

theorem rawRotationEquality_implies_boundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (h : r₁.rotate = r₂.rotate) :
    RotationBoundaryEquivalent resolve r₁ r₂ := by
  intro q
  induction q using Quotient.ind with
  | _ xs =>
    show trajectoryProjection resolve (r₁.rotate xs) =
         trajectoryProjection resolve (r₂.rotate xs)
    rw [h]

/-! ============================================================
    Rotation kernel
============================================================ -/

def RotationKernel
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  RotationBoundaryEquivalent resolve r₁ r₂

theorem RotationKernel_refl
    (resolve : KernelExpr → Store → Location)
    (r : FoldCompatibleRotation resolve) :
    RotationKernel resolve r r := by
  intro q
  rfl

theorem RotationKernel_symm
    (resolve : KernelExpr → Store → Location)
    {r₁ r₂ : FoldCompatibleRotation resolve}
    (h : RotationKernel resolve r₁ r₂) :
    RotationKernel resolve r₂ r₁ := by
  intro q
  exact (h q).symm

theorem RotationKernel_trans
    (resolve : KernelExpr → Store → Location)
    {r₁ r₂ r₃ : FoldCompatibleRotation resolve}
    (h12 : RotationKernel resolve r₁ r₂)
    (h23 : RotationKernel resolve r₂ r₃) :
    RotationKernel resolve r₁ r₃ := by
  intro q
  exact (h12 q).trans (h23 q)

/-! ============================================================
    Countermodel criterion
============================================================ -/

def RotationFoldCollision
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext) : Prop :=
  ∃ xs ys,
    FoldKernel resolve xs ys ∧
    ¬ FoldKernel resolve (rotation xs) (rotation ys)

theorem rotationFoldCollision_refutes_respects
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext)
    (h : RotationFoldCollision resolve rotation) :
    ¬ RotationRespectsFoldKernel resolve rotation := by
  intro hRespect
  rcases h with ⟨xs, ys, hKernel, hNot⟩
  exact hNot (hRespect xs ys hKernel)

theorem rotationFoldCollision_refutes_descent
    (resolve : KernelExpr → Store → Location)
    (rotation : List KernelExprContext → List KernelExprContext)
    (h : RotationFoldCollision resolve rotation) :
    ¬ RotationDescendsToBoundary resolve rotation := by
  intro hDesc
  exact rotationFoldCollision_refutes_respects resolve rotation h
    ((rotation_descends_iff_kernel_compatible resolve rotation).mp hDesc)

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check rotation_descends_iff_kernel_compatible
#check rotateTrajectoryBoundary_mk
#check identityRotation_respectsFoldKernel
#check composeRotation_respectsFoldKernel
#check foldCompatibleRotation_assoc
#check descendedRotation_compose
#check RotationKernel_refl
#check rotationFoldCollision_refutes_descent

#print axioms rotation_descends_iff_kernel_compatible
#print axioms rotateTrajectoryBoundary_mk
#print axioms identityRotation_respectsFoldKernel
#print axioms composeRotation_respectsFoldKernel
#print axioms foldCompatibleRotation_assoc
#print axioms descendedRotation_compose
#print axioms RotationKernel_refl
#print axioms rotationFoldCollision_refutes_descent
