import AggregateFamilyTransform
import FDHTReturnStabilizerBoundaryAPI
open KernelExprContext

/-! ============================================================
    FDHT Thread-Family First Isomorphism
============================================================ -/

/-! Bijectivity. -/

def Function.Bijective {α β : Sort u} (f : α → β) : Prop :=
  Function.Injective f ∧ Function.Surjective f

/-! Equivalence structure. -/

structure Equiv (α β : Sort u) where
  toFun : α → β
  invFun : β → α
  left_inv : ∀ x, invFun (toFun x) = x
  right_inv : ∀ y, toFun (invFun y) = y

/-! Kernel exactness (definitional). -/

theorem threadFamilyKernel_iff_project_eq
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p q : ThreadFamily resolve n) :
    ThreadFamilyKernel resolve p q ↔
      projectThreadFamily resolve p = projectThreadFamily resolve q :=
  Iff.rfl

/-! Quotient projection induced by projectThreadFamily. -/

def threadFamilyQuotientProjection
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    ThreadFamilyQuotient resolve n →
      (Fin n → TrajectoryBoundary resolve) :=
  Quotient.lift
    (projectThreadFamily resolve)
    (by
      intro p q hpq
      exact hpq)

/-! Computation law. -/

@[simp]
theorem threadFamilyQuotientProjection_mk
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (p : ThreadFamily resolve n) :
    threadFamilyQuotientProjection resolve n
      (Quotient.mk _ p)
    =
    projectThreadFamily resolve p :=
  rfl

/-! Injectivity (constructive modulo quotient infrastructure). -/

theorem threadFamilyQuotientProjection_injective
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    Function.Injective
      (threadFamilyQuotientProjection resolve n) := by
  intro x y h
  rcases Quotient.exists_rep x with ⟨p, rfl⟩
  rcases Quotient.exists_rep y with ⟨q, rfl⟩
  apply Quotient.sound
  exact h

/-! Surjectivity (inherits Classical.choice from projectThreadFamily_surjective). -/

theorem threadFamilyQuotientProjection_surjective
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    Function.Surjective
      (threadFamilyQuotientProjection resolve n) := by
  intro f
  have ⟨p, hp⟩ := projectThreadFamily_surjective resolve n f
  exact ⟨Quotient.mk (ThreadFamilyKernelSetoid resolve n) p, hp⟩

/-! Bijectivity. -/

theorem threadFamilyQuotientProjection_bijective
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    Function.Bijective
      (threadFamilyQuotientProjection resolve n) :=
  ⟨threadFamilyQuotientProjection_injective resolve n,
   threadFamilyQuotientProjection_surjective resolve n⟩

/-! First-isomorphism equivalence. -/

noncomputable def threadFamilyQuotientEquivProjected
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    Equiv (ThreadFamilyQuotient resolve n) (Fin n → TrajectoryBoundary resolve) where
  toFun := threadFamilyQuotientProjection resolve n
  invFun := fun f =>
    Quotient.mk (ThreadFamilyKernelSetoid resolve n)
      (Classical.choose (projectThreadFamily_surjective resolve n f))
  left_inv := by
    intro x
    rcases Quotient.exists_rep x with ⟨p, rfl⟩
    apply Quotient.sound
    have hspec := Classical.choose_spec (projectThreadFamily_surjective resolve n (projectThreadFamily resolve p))
    exact hspec
  right_inv := by
    intro f
    exact Classical.choose_spec (projectThreadFamily_surjective resolve n f)

/-! Equivalence computation law. -/

@[simp]
theorem threadFamilyQuotientEquivProjected_mk
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (p : ThreadFamily resolve n) :
    (threadFamilyQuotientEquivProjected resolve n).toFun
      (Quotient.mk _ p)
    =
    projectThreadFamily resolve p :=
  rfl

/-! First-isomorphism headline. -/

theorem threadFamily_first_isomorphism
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    Nonempty
      (Equiv (ThreadFamilyQuotient resolve n) (Fin n → TrajectoryBoundary resolve)) :=
  ⟨threadFamilyQuotientEquivProjected resolve n⟩

/-! Axiom audit. -/

#print axioms threadFamilyKernel_iff_project_eq
#print axioms threadFamilyQuotientProjection_mk
#print axioms threadFamilyQuotientProjection_injective
#print axioms threadFamilyQuotientProjection_surjective
#print axioms threadFamilyQuotientProjection_bijective
#print axioms threadFamilyQuotientEquivProjected
#print axioms threadFamilyQuotientEquivProjected_mk
#print axioms threadFamily_first_isomorphism
