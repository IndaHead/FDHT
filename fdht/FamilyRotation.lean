import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Single-thread rotation layer
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

/-! ============================================================
    ThreadFamily layer
============================================================ -/

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

/-! ============================================================
    Componentwise family rotation
============================================================ -/

def rotateThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r : FoldCompatibleRotation resolve)
    (p : ThreadFamily resolve n) :
    ThreadFamily resolve n :=
  fun i => r.rotate (p i)

theorem rotateThreadFamily_apply
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r : FoldCompatibleRotation resolve)
    (p : ThreadFamily resolve n)
    (i : Fin n) :
    rotateThreadFamily resolve r p i =
    r.rotate (p i) := by
  rfl

/-! ============================================================
    Kernel compatibility
============================================================ -/

theorem rotateThreadFamily_respects_kernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r : FoldCompatibleRotation resolve)
    {p q : ThreadFamily resolve n}
    (h : ThreadFamilyKernel resolve p q) :
    ThreadFamilyKernel resolve
      (rotateThreadFamily resolve r p)
      (rotateThreadFamily resolve r q) := by
  unfold ThreadFamilyKernel projectThreadFamily rotateThreadFamily at *
  funext i
  have hProj : trajectoryProjection resolve (p i) = trajectoryProjection resolve (q i) :=
    congrFun h i
  exact r.compatible (p i) (q i) hProj

/-! ============================================================
    Identity family rotation
============================================================ -/

theorem identityFamilyRotation_is_id
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) :
    rotateThreadFamily resolve (foldCompatibleRotationIdentity resolve) p
    =
    p := by
  funext i
  rfl

/-! ============================================================
    Family rotation composition
============================================================ -/

def foldCompatibleRotationCompose
    (resolve : KernelExpr → Store → Location)
    (r₁ r₂ : FoldCompatibleRotation resolve) :
    FoldCompatibleRotation resolve where
  rotate := fun xs => r₁.rotate (r₂.rotate xs)
  compatible := by
    intro xs ys h
    exact r₁.compatible (r₂.rotate xs) (r₂.rotate ys)
      (r₂.compatible xs ys h)

theorem familyRotation_compose
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (p : ThreadFamily resolve n) :
    rotateThreadFamily resolve
      (foldCompatibleRotationCompose resolve r₁ r₂) p
    =
    rotateThreadFamily resolve r₁
      (rotateThreadFamily resolve r₂ p) := by
  funext i
  rfl

/-! ============================================================
    Family rotation boundary equivalence
============================================================ -/

def FamilyRotationBoundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  ∀ p : ThreadFamily resolve n,
    projectThreadFamily resolve (rotateThreadFamily resolve r₁ p) =
    projectThreadFamily resolve (rotateThreadFamily resolve r₂ p)

theorem rawFamilyRotationEquality_implies_boundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (h : r₁.rotate = r₂.rotate) :
    FamilyRotationBoundaryEquivalent resolve n r₁ r₂ := by
  intro p
  funext i
  show trajectoryProjection resolve (r₁.rotate (p i)) =
       trajectoryProjection resolve (r₂.rotate (p i))
  rw [h]

/-! ============================================================
    Family rotation kernel
============================================================ -/

def FamilyRotationKernel
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  FamilyRotationBoundaryEquivalent resolve n r₁ r₂

theorem FamilyRotationKernel_refl
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r : FoldCompatibleRotation resolve) :
    FamilyRotationKernel resolve n r r := by
  intro p
  rfl

theorem FamilyRotationKernel_symm
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    {r₁ r₂ : FoldCompatibleRotation resolve}
    (h : FamilyRotationKernel resolve n r₁ r₂) :
    FamilyRotationKernel resolve n r₂ r₁ := by
  intro p
  exact (h p).symm

theorem FamilyRotationKernel_trans
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    {r₁ r₂ r₃ : FoldCompatibleRotation resolve}
    (h12 : FamilyRotationKernel resolve n r₁ r₂)
    (h23 : FamilyRotationKernel resolve n r₂ r₃) :
    FamilyRotationKernel resolve n r₁ r₃ := by
  intro p
  exact (h12 p).trans (h23 p)

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check rotateThreadFamily
#check rotateThreadFamily_apply
#check rotateThreadFamily_respects_kernel
#check identityFamilyRotation_is_id
#check familyRotation_compose
#check FamilyRotationKernel_refl
#check FamilyRotationKernel_symm
#check FamilyRotationKernel_trans

#print axioms rotateThreadFamily_respects_kernel
#print axioms identityFamilyRotation_is_id
#print axioms familyRotation_compose
#print axioms FamilyRotationKernel_refl
#print axioms FamilyRotationKernel_symm
#print axioms FamilyRotationKernel_trans
