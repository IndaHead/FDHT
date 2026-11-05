import FDHTThreadFamilyFirstIso
open KernelExprContext

/-! ============================================================
    Projected Rotation via First-Isomorphism Conjugation
============================================================ -/

namespace ThreadFamilyRotation

variable {resolve : KernelExpr → Store → Location} {n : Nat}
variable (R : ThreadFamilyRotation resolve n)

/-! Projected rotation by conjugation. -/

noncomputable def projectedRotate :
    (Fin n → TrajectoryBoundary resolve) →
      (Fin n → TrajectoryBoundary resolve) :=
  fun f =>
    (threadFamilyQuotientEquivProjected resolve n).toFun
      (R.quotientRotate
        ((threadFamilyQuotientEquivProjected resolve n).invFun f))

/-! Naturality. -/

theorem projectedRotate_projectThreadFamily
    (p : ThreadFamily resolve n) :
    R.projectedRotate (projectThreadFamily resolve p)
    =
    projectThreadFamily resolve (R.rotate p) := by
  show (threadFamilyQuotientEquivProjected resolve n).toFun
      (R.quotientRotate
        ((threadFamilyQuotientEquivProjected resolve n).invFun
          (projectThreadFamily resolve p)))
    =
    projectThreadFamily resolve (R.rotate p)
  have h1 : (threadFamilyQuotientEquivProjected resolve n).invFun
      (projectThreadFamily resolve p)
    =
    Quotient.mk _ p := by
    apply Quotient.sound
    have hspec := Classical.choose_spec
      (projectThreadFamily_surjective resolve n (projectThreadFamily resolve p))
    exact hspec
  rw [h1]
  rw [quotientRotate_mk]
  exact threadFamilyQuotientEquivProjected_mk resolve n (R.rotate p)

/-! ============================================================
    Generic finite-order transport
============================================================ -/

/-! Raw → quotient iteration commutation. -/

theorem quotient_repeat_mk
    (k : Nat)
    (p : ThreadFamily resolve n) :
    Nat.repeat R.quotientRotate k
      (Quotient.mk _ p)
    =
    Quotient.mk _
      (Nat.repeat R.rotate k p) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    simp only [Nat.repeat.eq_2, ih, R.quotientRotate_mk]

/-! Generic quotient finite order. -/

theorem quotient_finiteOrder :
    ∃ k : Nat,
      1 < k ∧
      ∀ x : ThreadFamilyQuotient resolve n,
        Nat.repeat R.quotientRotate k x = x := by
  rcases R.finiteOrder with ⟨k, hk, hperiod⟩
  refine ⟨k, hk, ?_⟩
  intro x
  refine Quotient.inductionOn x ?_
  intro p
  rw [R.quotient_repeat_mk]
  rw [hperiod p]

/-! Projected iteration conjugation. -/

theorem projected_repeat
    (k : Nat)
    (f : Fin n → TrajectoryBoundary resolve) :
    Nat.repeat R.projectedRotate k f
    =
    (threadFamilyQuotientEquivProjected resolve n).toFun
      (Nat.repeat R.quotientRotate k
        ((threadFamilyQuotientEquivProjected resolve n).invFun f)) := by
  induction k with
  | zero =>
    simp only [Nat.repeat.eq_1]
    exact Eq.symm ((threadFamilyQuotientEquivProjected resolve n).right_inv f)
  | succ k ih =>
    show R.projectedRotate (Nat.repeat R.projectedRotate k f)
      =
      (threadFamilyQuotientEquivProjected resolve n).toFun
        (R.quotientRotate
          (Nat.repeat R.quotientRotate k
            ((threadFamilyQuotientEquivProjected resolve n).invFun f)))
    rw [ih]
    unfold projectedRotate
    have hinv : (threadFamilyQuotientEquivProjected resolve n).invFun
        ((threadFamilyQuotientEquivProjected resolve n).toFun
          (Nat.repeat R.quotientRotate k
            ((threadFamilyQuotientEquivProjected resolve n).invFun f)))
      =
      Nat.repeat R.quotientRotate k
        ((threadFamilyQuotientEquivProjected resolve n).invFun f) :=
      (threadFamilyQuotientEquivProjected resolve n).left_inv _
    rw [hinv]

/-! Generic projected finite order. -/

theorem projected_finiteOrder :
    ∃ k : Nat,
      1 < k ∧
      ∀ f : Fin n → TrajectoryBoundary resolve,
        Nat.repeat R.projectedRotate k f = f := by
  rcases R.quotient_finiteOrder with ⟨k, hk, hperiod⟩
  refine ⟨k, hk, ?_⟩
  intro f
  rw [R.projected_repeat]
  rw [hperiod]
  exact (threadFamilyQuotientEquivProjected resolve n).right_inv f

end ThreadFamilyRotation

/-! Two-thread projected action is coordinate swap. -/

theorem twoThreadSwapRotation_projected_apply
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (f : Fin 2 → TrajectoryBoundary resolve)
    (i : Fin 2) :
    (twoThreadSwapRotation resolve h).projectedRotate f i
    =
    f (twoThreadSwapFun i) := by
  have ⟨p, hp⟩ := projectThreadFamily_surjective resolve 2 f
  have hnat := (twoThreadSwapRotation resolve h).projectedRotate_projectThreadFamily p
  rw [hp] at hnat
  have hnat_i : (twoThreadSwapRotation resolve h).projectedRotate f i
    =
    projectThreadFamily resolve ((twoThreadSwapRotation resolve h).rotate p) i :=
    congrFun hnat i
  have hswap : projectThreadFamily resolve ((twoThreadSwapRotation resolve h).rotate p) i
    =
    projectThreadFamily resolve p (twoThreadSwapFun i) := by
    show trajectoryProjection resolve (((twoThreadSwapRotation resolve h).rotate p) i)
      =
      trajectoryProjection resolve (p (twoThreadSwapFun i))
    have hreindex : ((twoThreadSwapRotation resolve h).rotate p) i = p (twoThreadSwapFun i) := by
      show reindexThreadFamily resolve twoThreadSwapFun p i = p (twoThreadSwapFun i)
      rfl
    rw [hreindex]
  rw [hnat_i, hswap]
  rw [hp]

theorem twoThreadSwapRotation_projected_eq_reindex
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    (twoThreadSwapRotation resolve h).projectedRotate
    =
    fun f i => f (twoThreadSwapFun i) := by
  funext f i
  exact twoThreadSwapRotation_projected_apply resolve h f i

/-! Two-thread projected period. -/

theorem twoThreadSwapRotation_projected_finiteOrder
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∀ f,
      Nat.repeat
        (twoThreadSwapRotation resolve h).projectedRotate
        2 f
      =
      f := by
  intro f
  have hquot : Nat.repeat (twoThreadSwapRotation resolve h).quotientRotate 2
      ((threadFamilyQuotientEquivProjected resolve 2).invFun f)
    =
    (threadFamilyQuotientEquivProjected resolve 2).invFun f := by
    have ⟨p, hp⟩ := Quotient.exists_rep ((threadFamilyQuotientEquivProjected resolve 2).invFun f)
    rw [←hp]
    rw [(twoThreadSwapRotation resolve h).quotient_repeat_mk]
    apply Quotient.sound
    -- equality implies kernel
    have heq : Nat.repeat (twoThreadSwapRotation resolve h).rotate 2 p = p := by
      simp only [Nat.repeat.eq_2, Nat.repeat.eq_1]
      exact twoThreadSwapTransform_involutive resolve p
    rw [heq]
    exact ThreadFamilyKernel_refl resolve p
  rw [(twoThreadSwapRotation resolve h).projected_repeat]
  rw [hquot]
  exact (threadFamilyQuotientEquivProjected resolve 2).right_inv f

#print axioms ThreadFamilyRotation.quotient_repeat_mk
#print axioms ThreadFamilyRotation.quotient_finiteOrder
#print axioms ThreadFamilyRotation.projected_repeat
#print axioms ThreadFamilyRotation.projected_finiteOrder
#print axioms twoThreadSwapRotation_projected_finiteOrder


/-! ============================================================
    Projected nontriviality
============================================================ -/

namespace ThreadFamilyRotation

variable {resolve : KernelExpr → Store → Location} {n : Nat}
variable (R : ThreadFamilyRotation resolve n)

def ProjectedNontrivial : Prop :=
  ∃ f : Fin n → TrajectoryBoundary resolve,
    R.projectedRotate f ≠ f

theorem quotientNontrivial_implies_projectedNontrivial :
    R.QuotientNontrivial →
      R.ProjectedNontrivial := by
  intro ⟨x, hx⟩
  refine ⟨(threadFamilyQuotientEquivProjected resolve n).toFun x, ?_⟩
  intro heq
  -- projectedRotate (φ x) = φ (quotientRotate x)
  have hnat : R.projectedRotate
      ((threadFamilyQuotientEquivProjected resolve n).toFun x)
    =
    (threadFamilyQuotientEquivProjected resolve n).toFun
      (R.quotientRotate x) := by
    unfold projectedRotate
    congr 1
    rw [(threadFamilyQuotientEquivProjected resolve n).left_inv x]
  rw [hnat] at heq
  -- injectivity via left inverse
  have hleft_x := (threadFamilyQuotientEquivProjected resolve n).left_inv x
  have hleft_rot := (threadFamilyQuotientEquivProjected resolve n).left_inv (R.quotientRotate x)
  have heq' : (threadFamilyQuotientEquivProjected resolve n).invFun
      ((threadFamilyQuotientEquivProjected resolve n).toFun (R.quotientRotate x))
    =
    (threadFamilyQuotientEquivProjected resolve n).invFun
      ((threadFamilyQuotientEquivProjected resolve n).toFun x) :=
    congrArg (threadFamilyQuotientEquivProjected resolve n).invFun heq
  rw [hleft_rot, hleft_x] at heq'
  exact hx heq'

theorem projectedNontrivial_implies_quotientNontrivial :
    R.ProjectedNontrivial →
      R.QuotientNontrivial := by
  intro ⟨f, hf⟩
  refine ⟨(threadFamilyQuotientEquivProjected resolve n).invFun f, ?_⟩
  intro heq
  -- projectedRotate f = φ (quotientRotate (φ⁻¹ f))
  have hnat : R.projectedRotate f
    =
    (threadFamilyQuotientEquivProjected resolve n).toFun
      (R.quotientRotate
        ((threadFamilyQuotientEquivProjected resolve n).invFun f)) := by
    unfold projectedRotate
    rfl
  rw [hnat] at hf
  -- if quotientRotate (φ⁻¹ f) = φ⁻¹ f then projectedRotate f = f
  have hright : (threadFamilyQuotientEquivProjected resolve n).toFun
      ((threadFamilyQuotientEquivProjected resolve n).invFun f)
    =
    f :=
    (threadFamilyQuotientEquivProjected resolve n).right_inv f
  rw [heq] at hf
  rw [hright] at hf
  exact hf rfl

theorem projectedNontrivial_iff_quotientNontrivial :
    R.ProjectedNontrivial ↔
      R.QuotientNontrivial :=
  ⟨projectedNontrivial_implies_quotientNontrivial R,
   quotientNontrivial_implies_projectedNontrivial R⟩

end ThreadFamilyRotation

/-! Concrete two-thread projected nontriviality. -/

theorem twoThreadSwapRotation_projected_nontrivial
    (h : 1 < 2) :
    ThreadFamilyRotation.ProjectedNontrivial
      (twoThreadSwapRotation resolverSeparationWitness h) :=
  ThreadFamilyRotation.quotientNontrivial_implies_projectedNontrivial
    (twoThreadSwapRotation resolverSeparationWitness h)
    (twoThreadSwapRotation_quotient_nontrivial h)

theorem twoThreadSwapRotation_projected_not_identity
    (h : 1 < 2) :
    (twoThreadSwapRotation resolverSeparationWitness h).projectedRotate
    ≠
    id := by
  intro hid
  have ⟨f, hf⟩ := twoThreadSwapRotation_projected_nontrivial h
  exact hf (congrFun hid f)

#print axioms ThreadFamilyRotation.quotientNontrivial_implies_projectedNontrivial
#print axioms ThreadFamilyRotation.projectedNontrivial_implies_quotientNontrivial
#print axioms ThreadFamilyRotation.projectedNontrivial_iff_quotientNontrivial
#print axioms twoThreadSwapRotation_projected_nontrivial
#print axioms twoThreadSwapRotation_projected_not_identity

/-! ============================================================
    Projected orbit / fixed-locus classification
============================================================ -/

/-! Generic fixed-point classification. -/

theorem twoThreadSwapRotation_projected_fixes_iff_equal_coords_generic
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (f : Fin 2 → TrajectoryBoundary resolve) :
    (twoThreadSwapRotation resolve h).projectedRotate f = f
    ↔
    f 0 = f 1 := by
  constructor
  · intro hfix
    have h0 : (twoThreadSwapRotation resolve h).projectedRotate f 0 = f 0 :=
      congrFun hfix 0
    rw [twoThreadSwapRotation_projected_apply] at h0
    have hswap0 : twoThreadSwapFun (0 : Fin 2) = 1 := by
      show (if (0 : Fin 2).val = 0 then 1 else 0) = 1
      simp
    rw [hswap0] at h0
    exact h0.symm
  · intro heq
    funext i
    rw [twoThreadSwapRotation_projected_apply]
    cases i using Fin.cases with
    | zero =>
      have hswap0 : twoThreadSwapFun (0 : Fin 2) = 1 := by simp [twoThreadSwapFun]
      rw [hswap0]
      exact heq.symm
    | succ j =>
      have hj : j = 0 := by
        cases j using Fin.cases with
        | zero => rfl
        | succ k => exact absurd k.isLt (by omega)
      subst hj
      have hswap1 : twoThreadSwapFun (Fin.succ 0) = 0 := by simp [twoThreadSwapFun]
      rw [hswap1]
      exact heq

/-! Specialised version. -/

theorem twoThreadSwapRotation_projected_fixes_iff_equal_coords
    (h : 1 < 2)
    (f : Fin 2 → TrajectoryBoundary resolverSeparationWitness) :
    (twoThreadSwapRotation resolverSeparationWitness h).projectedRotate f = f
    ↔
    f 0 = f 1 :=
  twoThreadSwapRotation_projected_fixes_iff_equal_coords_generic
    resolverSeparationWitness h f

/-! Moved-point classification. -/

theorem twoThreadSwapRotation_projected_moves_iff_ne_coords
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (f : Fin 2 → TrajectoryBoundary resolve) :
    (twoThreadSwapRotation resolve h).projectedRotate f ≠ f
    ↔
    f 0 ≠ f 1 := by
  have hiff := twoThreadSwapRotation_projected_fixes_iff_equal_coords_generic resolve h f
  constructor
  · intro hne
    intro heq
    exact hne ((hiff).mpr heq)
  · intro hne
    intro heq
    exact hne ((hiff).mp heq)

/-! Two-step return. -/

theorem twoThreadSwapRotation_projected_two_step
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (f : Fin 2 → TrajectoryBoundary resolve) :
    (twoThreadSwapRotation resolve h).projectedRotate
      ((twoThreadSwapRotation resolve h).projectedRotate f)
    =
    f := by
  have hper := twoThreadSwapRotation_projected_finiteOrder resolve h f
  simp only [Nat.repeat.eq_2, Nat.repeat.eq_1] at hper
  exact hper

/-! Orbit dichotomy. -/

theorem twoThreadSwapRotation_projected_orbit_dichotomy
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (f : Fin 2 → TrajectoryBoundary resolve) :
    (f 0 = f 1 ∧
      (twoThreadSwapRotation resolve h).projectedRotate f = f) ∨
    (f 0 ≠ f 1 ∧
      (twoThreadSwapRotation resolve h).projectedRotate f ≠ f ∧
      (twoThreadSwapRotation resolve h).projectedRotate
        ((twoThreadSwapRotation resolve h).projectedRotate f) = f) := by
  by_cases hdiag : f 0 = f 1
  · left
    exact ⟨hdiag, (twoThreadSwapRotation_projected_fixes_iff_equal_coords_generic resolve h f).mpr hdiag⟩
  · right
    exact ⟨hdiag,
      (twoThreadSwapRotation_projected_moves_iff_ne_coords resolve h f).mpr hdiag,
      twoThreadSwapRotation_projected_two_step resolve h f⟩

/-! Fixed-point existence. -/

theorem twoThreadSwapRotation_projected_fixed_point_exists
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∃ f : Fin 2 → TrajectoryBoundary resolve,
      (twoThreadSwapRotation resolve h).projectedRotate f = f := by
  refine ⟨fun _ => emptyTrajectory resolve, ?_⟩
  apply (twoThreadSwapRotation_projected_fixes_iff_equal_coords_generic resolve h _).mpr
  rfl

/-! Concrete two-cycle for resolverSeparationWitness. -/

theorem twoThreadSwapRotation_projected_two_cycle_exists
    (h : 1 < 2) :
    ∃ f : Fin 2 → TrajectoryBoundary resolverSeparationWitness,
      f 0 ≠ f 1 ∧
      (twoThreadSwapRotation resolverSeparationWitness h).projectedRotate f ≠ f ∧
      (twoThreadSwapRotation resolverSeparationWitness h).projectedRotate
        ((twoThreadSwapRotation resolverSeparationWitness h).projectedRotate f) = f := by
  refine ⟨fun i => if i.val = 0 then emptyTrajectory resolverSeparationWitness
                   else trajectoryProjection resolverSeparationWitness [exposingContext], ?_⟩
  constructor
  · -- f 0 ≠ f 1
    show emptyTrajectory resolverSeparationWitness ≠
         trajectoryProjection resolverSeparationWitness [exposingContext]
    exact exposingContext_nonidentity_witness.symm
  constructor
  · -- T f ≠ f
    apply (twoThreadSwapRotation_projected_moves_iff_ne_coords resolverSeparationWitness h _).mpr
    show emptyTrajectory resolverSeparationWitness ≠
         trajectoryProjection resolverSeparationWitness [exposingContext]
    exact exposingContext_nonidentity_witness.symm
  · -- T (T f) = f
    exact twoThreadSwapRotation_projected_two_step resolverSeparationWitness h _

#print axioms twoThreadSwapRotation_projected_fixes_iff_equal_coords_generic
#print axioms twoThreadSwapRotation_projected_moves_iff_ne_coords
#print axioms twoThreadSwapRotation_projected_two_step
#print axioms twoThreadSwapRotation_projected_orbit_dichotomy
#print axioms twoThreadSwapRotation_projected_fixed_point_exists
#print axioms twoThreadSwapRotation_projected_two_cycle_exists
