import FDHT_Audit_ArbitraryCollision
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
    Constant family
============================================================ -/

def constantThreadFamily
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (xs : List KernelExprContext) :
    ThreadFamily resolve n :=
  fun _ => xs

theorem constantThreadFamily_apply
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (xs : List KernelExprContext)
    (i : Fin n) :
    constantThreadFamily resolve n xs i = xs := by
  rfl

theorem rotate_constantThreadFamily
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r : FoldCompatibleRotation resolve)
    (xs : List KernelExprContext) :
    rotateThreadFamily resolve r
      (constantThreadFamily resolve n xs)
    =
    constantThreadFamily resolve n (r.rotate xs) := by
  funext i
  rfl

theorem project_constantThreadFamily
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (xs : List KernelExprContext) :
    projectThreadFamily resolve
      (constantThreadFamily resolve n xs)
    =
    fun _ => trajectoryProjection resolve xs := by
  funext i
  rfl

/-! ============================================================
    Positive-arity converse
============================================================ -/

theorem positiveFamilyKernel_implies_singleBoundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (hn : 0 < n)
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (hFamily : FamilyRotationKernel resolve n r₁ r₂) :
    RotationBoundaryEquivalent resolve r₁ r₂ := by
  intro q
  rcases KernelExprContext.trajectoryProjection_surjective resolve q with ⟨xs, hxs⟩
  let i₀ : Fin n := ⟨0, hn⟩
  have hFam := hFamily (constantThreadFamily resolve n xs)
  have hAt := congrFun hFam i₀
  unfold projectThreadFamily rotateThreadFamily constantThreadFamily at hAt
  rw [← hxs]
  exact hAt

/-! ============================================================
    Positive-arity iff
============================================================ -/

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
  exact h (trajectoryProjection resolve (p i))

theorem positiveFamilyKernel_iff_singleBoundaryEquivalent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (hn : 0 < n)
    (r₁ r₂ : FoldCompatibleRotation resolve) :
    FamilyRotationKernel resolve n r₁ r₂
    ↔
    RotationBoundaryEquivalent resolve r₁ r₂ := by
  constructor
  · exact positiveFamilyKernel_implies_singleBoundaryEquivalent resolve hn r₁ r₂
  · exact singleBoundaryEquivalent_implies_familyKernel resolve n r₁ r₂

/-! ============================================================
    Positive-arity kernel independence
============================================================ -/

theorem positive_arity_rotation_kernel_equivalence
    (resolve : KernelExpr → Store → Location)
    {m n : Nat}
    (hm : 0 < m)
    (hn : 0 < n)
    (r₁ r₂ : FoldCompatibleRotation resolve) :
    FamilyRotationKernel resolve m r₁ r₂
    ↔
    FamilyRotationKernel resolve n r₁ r₂ := by
  constructor
  · intro h
    have hSingle :=
      positiveFamilyKernel_implies_singleBoundaryEquivalent resolve hm r₁ r₂ h
    exact singleBoundaryEquivalent_implies_familyKernel resolve n r₁ r₂ hSingle
  · intro h
    have hSingle :=
      positiveFamilyKernel_implies_singleBoundaryEquivalent resolve hn r₁ r₂ h
    exact singleBoundaryEquivalent_implies_familyKernel resolve m r₁ r₂ hSingle

/-! ============================================================
    Faithfulness reduction
============================================================ -/

def RotationBoundaryFaithful
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ r₁ r₂ : FoldCompatibleRotation resolve,
    RotationBoundaryEquivalent resolve r₁ r₂ →
    r₁.rotate = r₂.rotate

def FamilyRotationFaithful
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  ∀ r₁ r₂ : FoldCompatibleRotation resolve,
    FamilyRotationKernel resolve n r₁ r₂ →
    r₁.rotate = r₂.rotate

theorem positiveFamilyFaithful_iff_boundaryFaithful
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (hn : 0 < n) :
    FamilyRotationFaithful resolve n
    ↔
    RotationBoundaryFaithful resolve := by
  constructor
  · intro hFaithful r₁ r₂ hBound
    have hFam :=
      singleBoundaryEquivalent_implies_familyKernel resolve n r₁ r₂ hBound
    exact hFaithful r₁ r₂ hFam
  · intro hFaithful r₁ r₂ hFam
    have hBound :=
      positiveFamilyKernel_implies_singleBoundaryEquivalent resolve hn r₁ r₂ hFam
    exact hFaithful r₁ r₂ hBound

/-! ============================================================
    Collision correspondence
============================================================ -/

def FamilyRotationCollision
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  ∃ r₁ r₂ : FoldCompatibleRotation resolve,
    r₁.rotate ≠ r₂.rotate ∧
    FamilyRotationKernel resolve n r₁ r₂

def RotationBoundaryCollision
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ r₁ r₂ : FoldCompatibleRotation resolve,
    r₁.rotate ≠ r₂.rotate ∧
    RotationBoundaryEquivalent resolve r₁ r₂

theorem familyRotationCollision_iff_boundaryCollision
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (hn : 0 < n) :
    FamilyRotationCollision resolve n
    ↔
    RotationBoundaryCollision resolve := by
  constructor
  · intro ⟨r₁, r₂, hNe, hFam⟩
    exact ⟨r₁, r₂, hNe,
           positiveFamilyKernel_implies_singleBoundaryEquivalent
             resolve hn r₁ r₂ hFam⟩
  · intro ⟨r₁, r₂, hNe, hBound⟩
    exact ⟨r₁, r₂, hNe,
           singleBoundaryEquivalent_implies_familyKernel
             resolve n r₁ r₂ hBound⟩

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check constantThreadFamily_apply
#check rotate_constantThreadFamily
#check project_constantThreadFamily
#check positiveFamilyKernel_implies_singleBoundaryEquivalent
#check positiveFamilyKernel_iff_singleBoundaryEquivalent
#check positive_arity_rotation_kernel_equivalence
#check positiveFamilyFaithful_iff_boundaryFaithful
#check familyRotationCollision_iff_boundaryCollision

#print axioms constantThreadFamily_apply
#print axioms rotate_constantThreadFamily
#print axioms project_constantThreadFamily
#print axioms positiveFamilyKernel_implies_singleBoundaryEquivalent
#print axioms positiveFamilyKernel_iff_singleBoundaryEquivalent
#print axioms positive_arity_rotation_kernel_equivalence
#print axioms positiveFamilyFaithful_iff_boundaryFaithful
#print axioms familyRotationCollision_iff_boundaryCollision
