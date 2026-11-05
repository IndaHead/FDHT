import FDHTProjectedRotation
open KernelExprContext

/-! ============================================================
    Explicit three-thread cyclic rotation
============================================================ -/

/-! Three-cycle on Fin 3. -/

def threeThreadCycleFun : Fin 3 → Fin 3
  | ⟨0, _⟩ => ⟨1, by omega⟩
  | ⟨1, _⟩ => ⟨2, by omega⟩
  | ⟨2, _⟩ => ⟨0, by omega⟩

def threeThreadCycleInvFun : Fin 3 → Fin 3
  | ⟨0, _⟩ => ⟨2, by omega⟩
  | ⟨1, _⟩ => ⟨0, by omega⟩
  | ⟨2, _⟩ => ⟨1, by omega⟩

def threeThreadCycle : ThreadPermutation 3 where
  toFun := threeThreadCycleFun
  invFun := threeThreadCycleInvFun
  left_inv := fun i => by
    cases i using Fin.cases with
    | zero => rfl
    | succ j =>
      cases j using Fin.cases with
      | zero => rfl
      | succ k =>
        cases k using Fin.cases with
        | zero => rfl
        | succ m => exact absurd m.isLt (by omega)
  right_inv := fun i => by
    cases i using Fin.cases with
    | zero => rfl
    | succ j =>
      cases j using Fin.cases with
      | zero => rfl
      | succ k =>
        cases k using Fin.cases with
        | zero => rfl
        | succ m => exact absurd m.isLt (by omega)

/-! Index action. -/

theorem threeThreadCycle_apply_0 : threeThreadCycle.toFun 0 = 1 := rfl
theorem threeThreadCycle_apply_1 : threeThreadCycle.toFun 1 = 2 := rfl
theorem threeThreadCycle_apply_2 : threeThreadCycle.toFun 2 = 0 := rfl

theorem threeThreadCycle_inv_0 : threeThreadCycle.invFun 0 = 2 := rfl
theorem threeThreadCycle_inv_1 : threeThreadCycle.invFun 1 = 0 := rfl
theorem threeThreadCycle_inv_2 : threeThreadCycle.invFun 2 = 1 := rfl

/-! Three-step index return. -/

theorem threeThreadCycle_three_step :
    ∀ i : Fin 3,
      threeThreadCycle.toFun
        (threeThreadCycle.toFun
          (threeThreadCycle.toFun i))
      =
      i := by
  intro i
  cases i using Fin.cases with
  | zero => rfl
  | succ j =>
    cases j using Fin.cases with
    | zero => rfl
    | succ k =>
      cases k using Fin.cases with
      | zero => rfl
      | succ m => exact absurd m.isLt (by omega)

/-! Not order two. -/

theorem threeThreadCycle_not_two_step :
    threeThreadCycle.toFun (threeThreadCycle.toFun (0 : Fin 3)) ≠ 0 := by
  native_decide

/-! Raw transform. -/

def threeThreadCycleTransform
    (resolve : KernelExpr → Store → Location) :
    ThreadFamily resolve 3 → ThreadFamily resolve 3 :=
  permuteThreadFamily resolve threeThreadCycle

theorem threeThreadCycleTransform_apply
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 3)
    (i : Fin 3) :
    threeThreadCycleTransform resolve p i = p (threeThreadCycle.toFun i) := rfl

/-! Raw three-step return. -/

theorem threeThreadCycleTransform_three_step
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 3) :
    threeThreadCycleTransform resolve
      (threeThreadCycleTransform resolve
        (threeThreadCycleTransform resolve p))
    =
    p := by
  funext i
  unfold threeThreadCycleTransform permuteThreadFamily reindexThreadFamily
  congr 1
  exact threeThreadCycle_three_step i

/-! Raw nonidentity. -/

theorem threeThreadCycleTransform_nonidentity
    (resolve : KernelExpr → Store → Location) :
    ∃ p : ThreadFamily resolve 3,
      threeThreadCycleTransform resolve p ≠ p := by
  refine ⟨fun (i : Fin 3) => if i.val = 0 then [] else [identityContext], ?_⟩
  intro heq
  have h0 := congrFun heq 0
  unfold threeThreadCycleTransform permuteThreadFamily reindexThreadFamily at h0
  -- h0 : p (threeThreadCycle.toFun 0) = p 0
  have happly : threeThreadCycle.toFun 0 = 1 := threeThreadCycle_apply_0
  rw [happly] at h0
  -- now h0 : [identityContext] = []
  exact List.cons_ne_nil _ _ h0

/-! Kernel automorphism. -/

theorem threeThreadCycleTransform_preserves_kernel
    (resolve : KernelExpr → Store → Location)
    {p q : ThreadFamily resolve 3}
    (h : ThreadFamilyKernel resolve p q) :
    ThreadFamilyKernel resolve
      (threeThreadCycleTransform resolve p)
      (threeThreadCycleTransform resolve q) :=
  permuteThreadFamily_respects_kernel resolve threeThreadCycle h

theorem threeThreadCycleTransform_reflects_kernel
    (resolve : KernelExpr → Store → Location)
    {p q : ThreadFamily resolve 3}
    (h : ThreadFamilyKernel resolve
      (threeThreadCycleTransform resolve p)
      (threeThreadCycleTransform resolve q)) :
    ThreadFamilyKernel resolve p q := by
  -- apply the inverse permutation
  let invPerm : ThreadPermutation 3 :=
    { toFun := threeThreadCycle.invFun
      invFun := threeThreadCycle.toFun
      left_inv := threeThreadCycle.right_inv
      right_inv := threeThreadCycle.left_inv }
  have hinv := permuteThreadFamily_respects_kernel resolve invPerm h
  have hrec : permuteThreadFamily resolve invPerm
      (threeThreadCycleTransform resolve p) = p := by
    funext i
    unfold threeThreadCycleTransform permuteThreadFamily reindexThreadFamily
    congr 1
    show threeThreadCycle.toFun (threeThreadCycle.invFun i) = i
    exact threeThreadCycle.right_inv i
  have hrecq : permuteThreadFamily resolve invPerm
      (threeThreadCycleTransform resolve q) = q := by
    funext i
    unfold threeThreadCycleTransform permuteThreadFamily reindexThreadFamily
    congr 1
    show threeThreadCycle.toFun (threeThreadCycle.invFun i) = i
    exact threeThreadCycle.right_inv i
  rw [hrec, hrecq] at hinv
  exact hinv

theorem threeThreadCycleTransform_kernel_iff
    (resolve : KernelExpr → Store → Location)
    (p q : ThreadFamily resolve 3) :
    ThreadFamilyKernel resolve
      (threeThreadCycleTransform resolve p)
      (threeThreadCycleTransform resolve q)
    ↔
    ThreadFamilyKernel resolve p q :=
  ⟨threeThreadCycleTransform_reflects_kernel resolve,
   threeThreadCycleTransform_preserves_kernel resolve⟩

/-! Finite order. -/

theorem threeThreadCycle_finiteOrder
    (resolve : KernelExpr → Store → Location) :
    ∃ k : Nat,
      1 < k ∧
      ∀ p : ThreadFamily resolve 3,
        Nat.repeat (threeThreadCycleTransform resolve) k p = p := by
  refine ⟨3, by omega, ?_⟩
  intro p
  show threeThreadCycleTransform resolve
        (threeThreadCycleTransform resolve
          (threeThreadCycleTransform resolve p)) = p
  exact threeThreadCycleTransform_three_step resolve p

/-! Inverse transform. -/

def threeThreadCycleInverseTransform
    (resolve : KernelExpr → Store → Location) :
    ThreadFamily resolve 3 → ThreadFamily resolve 3 :=
  fun p => permuteThreadFamily resolve
    { toFun := threeThreadCycle.invFun
      invFun := threeThreadCycle.toFun
      left_inv := threeThreadCycle.right_inv
      right_inv := threeThreadCycle.left_inv } p

theorem threeThreadCycle_inverse_rotate
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 3) :
    threeThreadCycleInverseTransform resolve
      (threeThreadCycleTransform resolve p) = p := by
  funext i
  unfold threeThreadCycleInverseTransform threeThreadCycleTransform
    permuteThreadFamily reindexThreadFamily
  congr 1
  show threeThreadCycle.toFun (threeThreadCycle.invFun i) = i
  exact threeThreadCycle.right_inv i

theorem threeThreadCycle_rotate_inverse
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 3) :
    threeThreadCycleTransform resolve
      (threeThreadCycleInverseTransform resolve p) = p := by
  funext i
  unfold threeThreadCycleInverseTransform threeThreadCycleTransform
    permuteThreadFamily reindexThreadFamily
  congr 1
  show threeThreadCycle.invFun (threeThreadCycle.toFun i) = i
  exact threeThreadCycle.left_inv i

/-! ThreadFamilyRotation inhabitant. -/

def threeThreadCycleRotation
    (resolve : KernelExpr → Store → Location) :
    ThreadFamilyRotation resolve 3 where
  rotate := threeThreadCycleTransform resolve
  inverse := threeThreadCycleInverseTransform resolve
  inverse_rotate := threeThreadCycle_inverse_rotate resolve
  rotate_inverse := threeThreadCycle_rotate_inverse resolve
  kernel_iff := threeThreadCycleTransform_kernel_iff resolve
  nonidentity := threeThreadCycleTransform_nonidentity resolve
  finiteOrder := threeThreadCycle_finiteOrder resolve

/-! Projected coordinate action. -/

theorem threeThreadCycleRotation_projected_apply
    (resolve : KernelExpr → Store → Location)
    (f : Fin 3 → TrajectoryBoundary resolve)
    (i : Fin 3) :
    (threeThreadCycleRotation resolve).projectedRotate f i
    =
    f (threeThreadCycle.toFun i) := by
  have ⟨p, hp⟩ := projectThreadFamily_surjective resolve 3 f
  have hnat := (threeThreadCycleRotation resolve).projectedRotate_projectThreadFamily p
  rw [hp] at hnat
  have hnat_i : (threeThreadCycleRotation resolve).projectedRotate f i
    =
    projectThreadFamily resolve ((threeThreadCycleRotation resolve).rotate p) i :=
    congrFun hnat i
  have hcycle : projectThreadFamily resolve ((threeThreadCycleRotation resolve).rotate p) i
    =
    projectThreadFamily resolve p (threeThreadCycle.toFun i) := by
    show trajectoryProjection resolve (((threeThreadCycleRotation resolve).rotate p) i)
      =
      trajectoryProjection resolve (p (threeThreadCycle.toFun i))
    have hreindex : ((threeThreadCycleRotation resolve).rotate p) i = p (threeThreadCycle.toFun i) := by
      show reindexThreadFamily resolve threeThreadCycle.toFun p i = p (threeThreadCycle.toFun i)
      rfl
    rw [hreindex]
  rw [hnat_i, hcycle]
  rw [hp]

theorem threeThreadCycleRotation_projected_apply_0
    (resolve : KernelExpr → Store → Location)
    (f : Fin 3 → TrajectoryBoundary resolve) :
    (threeThreadCycleRotation resolve).projectedRotate f 0 = f 1 := by
  rw [threeThreadCycleRotation_projected_apply]
  rw [threeThreadCycle_apply_0]

theorem threeThreadCycleRotation_projected_apply_1
    (resolve : KernelExpr → Store → Location)
    (f : Fin 3 → TrajectoryBoundary resolve) :
    (threeThreadCycleRotation resolve).projectedRotate f 1 = f 2 := by
  rw [threeThreadCycleRotation_projected_apply]
  rw [threeThreadCycle_apply_1]

theorem threeThreadCycleRotation_projected_apply_2
    (resolve : KernelExpr → Store → Location)
    (f : Fin 3 → TrajectoryBoundary resolve) :
    (threeThreadCycleRotation resolve).projectedRotate f 2 = f 0 := by
  rw [threeThreadCycleRotation_projected_apply]
  rw [threeThreadCycle_apply_2]

/-! Projected three-step return via generic transport. -/

theorem threeThreadCycleRotation_projected_three_step
    (resolve : KernelExpr → Store → Location)
    (f : Fin 3 → TrajectoryBoundary resolve) :
    (threeThreadCycleRotation resolve).projectedRotate
      ((threeThreadCycleRotation resolve).projectedRotate
        ((threeThreadCycleRotation resolve).projectedRotate f))
    =
    f := by
  -- use the generic projected finite order and extract k = 3
  have hper := (threeThreadCycleRotation resolve).projected_finiteOrder
  rcases hper with ⟨k, hk, hperiod⟩
  -- the raw finite order uses k = 3
  have hraw := (threeThreadCycleRotation resolve).finiteOrder
  rcases hraw with ⟨k', hk', hper'⟩
  -- both use the same witness construction, so k = k' = 3
  -- for now, use direct coordinate proof
  funext i
  rw [threeThreadCycleRotation_projected_apply]
  rw [threeThreadCycleRotation_projected_apply]
  rw [threeThreadCycleRotation_projected_apply]
  congr 1
  exact threeThreadCycle_three_step i

/-! Projected fixed-point classification. -/

theorem threeThreadCycleRotation_projected_fixes_iff_all_equal
    (resolve : KernelExpr → Store → Location)
    (f : Fin 3 → TrajectoryBoundary resolve) :
    (threeThreadCycleRotation resolve).projectedRotate f = f
    ↔
    f 0 = f 1 ∧ f 1 = f 2 := by
  constructor
  · intro hfix
    constructor
    · have h0 := congrFun hfix 0
      rw [threeThreadCycleRotation_projected_apply_0] at h0
      exact h0.symm
    · have h1 := congrFun hfix 1
      rw [threeThreadCycleRotation_projected_apply_1] at h1
      exact h1.symm
  · intro ⟨h01, h12⟩
    funext i
    rw [threeThreadCycleRotation_projected_apply]
    cases i using Fin.cases with
    | zero =>
      rw [show threeThreadCycle.toFun 0 = 1 from threeThreadCycle_apply_0]
      exact h01.symm
    | succ j =>
      cases j using Fin.cases with
      | zero =>
        rw [show threeThreadCycle.toFun (Fin.succ 0) = 2 from threeThreadCycle_apply_1]
        exact h12.symm
      | succ k =>
        have hk : k = 0 := by
          cases k using Fin.cases with
          | zero => rfl
          | succ m => exact absurd m.isLt (by omega)
        subst hk
        rw [show threeThreadCycle.toFun (Fin.succ (Fin.succ 0)) = 0 from threeThreadCycle_apply_2]
        exact h01.trans h12

/-! Projected nontriviality for resolverSeparationWitness. -/

theorem threeThreadCycleRotation_projected_nontrivial :
    ThreadFamilyRotation.ProjectedNontrivial
      (threeThreadCycleRotation resolverSeparationWitness) := by
  let f : Fin 3 → TrajectoryBoundary resolverSeparationWitness :=
    fun i => if i.val = 0 then emptyTrajectory resolverSeparationWitness
             else trajectoryProjection resolverSeparationWitness [exposingContext]
  refine ⟨f, ?_⟩
  intro heq
  have h0 := congrFun heq 0
  rw [threeThreadCycleRotation_projected_apply_0] at h0
  -- h0 : f 1 = f 0
  have hf0 : f 0 = emptyTrajectory resolverSeparationWitness := by
    show (if (0 : Fin 3).val = 0 then _ else _) = _
    simp
  have hf1 : f 1 = trajectoryProjection resolverSeparationWitness [exposingContext] := by
    show (if (1 : Fin 3).val = 0 then _ else _) = _
    simp
  rw [hf0, hf1] at h0
  exact exposingContext_nonidentity_witness h0

#print axioms threeThreadCycle_three_step
#print axioms threeThreadCycleTransform_three_step
#print axioms threeThreadCycleTransform_nonidentity
#print axioms threeThreadCycleTransform_kernel_iff
#print axioms threeThreadCycleRotation_projected_apply
#print axioms threeThreadCycleRotation_projected_three_step
#print axioms threeThreadCycleRotation_projected_fixes_iff_all_equal
#print axioms threeThreadCycleRotation_projected_nontrivial
