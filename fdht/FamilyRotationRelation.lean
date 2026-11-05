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
    Relation-action equivalence
============================================================ -/

def RotationRelationEquivalent
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (R : ThreadFamily resolve n → Prop) : Prop :=
  ∀ p : ThreadFamily resolve n,
    R (rotateThreadFamily resolve r₁ p)
    ↔
    R (rotateThreadFamily resolve r₂ p)

def RotationAllRelationsEquivalent
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  ∀ R : ThreadFamily resolve n → Prop,
    RotationRelationEquivalent resolve n r₁ r₂ R

def FamilyRawActionEqual
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve) : Prop :=
  ∀ p : ThreadFamily resolve n,
    rotateThreadFamily resolve r₁ p =
    rotateThreadFamily resolve r₂ p

theorem rawFamilyActionEqual_implies_allRelationsEquivalent
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (h : FamilyRawActionEqual resolve n r₁ r₂) :
    RotationAllRelationsEquivalent resolve n r₁ r₂ := by
  intro R p
  rw [h p]

theorem allRelationsEquivalent_implies_rawFamilyActionEqual
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (h : RotationAllRelationsEquivalent resolve n r₁ r₂) :
    FamilyRawActionEqual resolve n r₁ r₂ := by
  intro p
  let R : ThreadFamily resolve n → Prop :=
    fun x => x = rotateThreadFamily resolve r₁ p
  have hR := h R p
  have hLeft : R (rotateThreadFamily resolve r₁ p) := rfl
  have hRight := hR.mp hLeft
  exact hRight.symm

theorem allRelationsEquivalent_iff_rawFamilyActionEqual
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve) :
    RotationAllRelationsEquivalent resolve n r₁ r₂
    ↔
    FamilyRawActionEqual resolve n r₁ r₂ := by
  constructor
  · exact allRelationsEquivalent_implies_rawFamilyActionEqual resolve n r₁ r₂
  · exact rawFamilyActionEqual_implies_allRelationsEquivalent resolve n r₁ r₂

/-! ============================================================
    Relation-sensitive witness
============================================================ -/

def RelationSensitiveRotationCollision
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  ∃ (r₁ r₂ : FoldCompatibleRotation resolve)
    (R : ThreadFamily resolve n → Prop)
    (p : ThreadFamily resolve n),
      FamilyRotationKernel resolve n r₁ r₂ ∧
      (R (rotateThreadFamily resolve r₁ p)
       ≠
       R (rotateThreadFamily resolve r₂ p))

theorem relationSensitiveWitness_refutes_allRelationsEquivalent
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (r₁ r₂ : FoldCompatibleRotation resolve)
    (R : ThreadFamily resolve n → Prop)
    (p : ThreadFamily resolve n)
    (hRel :
      R (rotateThreadFamily resolve r₁ p)
      ≠
      R (rotateThreadFamily resolve r₂ p)) :
    ¬ RotationAllRelationsEquivalent resolve n r₁ r₂ := by
  intro hAll
  exact hRel (propext (hAll R p))

/-! ============================================================
    Rotation orbit
============================================================ -/

def SameRotationOrbit
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p q : ThreadFamily resolve n) : Prop :=
  ∃ (r : FoldCompatibleRotation resolve),
    rotateThreadFamily resolve r p = q

theorem SameRotationOrbit_refl
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) :
    SameRotationOrbit resolve p p := by
  exact ⟨foldCompatibleRotationIdentity resolve, by funext i; rfl⟩

theorem SameRotationOrbit_trans
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {p q s : ThreadFamily resolve n}
    (hpq : SameRotationOrbit resolve p q)
    (hqs : SameRotationOrbit resolve q s) :
    SameRotationOrbit resolve p s := by
  rcases hpq with ⟨r₁, hr₁⟩
  rcases hqs with ⟨r₂, hr₂⟩
  exact ⟨foldCompatibleRotationCompose resolve r₂ r₁,
         by rw [← hr₂, ← hr₁]; funext i; rfl⟩

/-! ============================================================
    Relation variation along orbit
============================================================ -/

def RelationVariesAlongRotation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : ThreadFamily resolve n → Prop) : Prop :=
  ∃ p q,
    SameRotationOrbit resolve p q ∧
    R p ≠ R q

def FoldedTrivialRotationStep
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p q : ThreadFamily resolve n) : Prop :=
  SameRotationOrbit resolve p q ∧
  ThreadFamilyKernel resolve p q

def RelationChangesAcrossFoldedTrivialRotation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : ThreadFamily resolve n → Prop) : Prop :=
  ∃ p q,
    FoldedTrivialRotationStep resolve p q ∧
    R p ≠ R q

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check rawFamilyActionEqual_implies_allRelationsEquivalent
#check allRelationsEquivalent_implies_rawFamilyActionEqual
#check allRelationsEquivalent_iff_rawFamilyActionEqual
#check relationSensitiveWitness_refutes_allRelationsEquivalent
#check SameRotationOrbit_refl
#check SameRotationOrbit_trans

#print axioms rawFamilyActionEqual_implies_allRelationsEquivalent
#print axioms allRelationsEquivalent_implies_rawFamilyActionEqual
#print axioms allRelationsEquivalent_iff_rawFamilyActionEqual
#print axioms relationSensitiveWitness_refutes_allRelationsEquivalent
#print axioms SameRotationOrbit_refl
#print axioms SameRotationOrbit_trans
