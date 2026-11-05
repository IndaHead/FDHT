import FDHTThreeThreadCycle
open KernelExprContext

/-! ============================================================
    Generic ThreadPermutation → ThreadFamilyRotation admission
============================================================ -/

/-! Pointwise action. -/

theorem permuteThreadFamily_apply
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p : ThreadFamily resolve n)
    (i : Fin n) :
    permuteThreadFamily resolve π p i = p (π.toFun i) := rfl

/-! Inverse permutation. -/

def ThreadPermutation.inverse {n : Nat} (π : ThreadPermutation n) : ThreadPermutation n where
  toFun := π.invFun
  invFun := π.toFun
  left_inv := π.right_inv
  right_inv := π.left_inv

/-! Generic reversibility. -/

theorem permuteThreadFamily_inverse_rotate
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p : ThreadFamily resolve n) :
    permuteThreadFamily resolve π.inverse
      (permuteThreadFamily resolve π p) = p := by
  funext i
  unfold permuteThreadFamily reindexThreadFamily
  congr 1
  exact π.right_inv i

theorem permuteThreadFamily_rotate_inverse
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p : ThreadFamily resolve n) :
    permuteThreadFamily resolve π
      (permuteThreadFamily resolve π.inverse p) = p := by
  funext i
  unfold permuteThreadFamily reindexThreadFamily
  congr 1
  exact π.left_inv i

/-! Generic kernel automorphism. -/

theorem permuteThreadFamily_kernel_iff
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p q : ThreadFamily resolve n) :
    ThreadFamilyKernel resolve
      (permuteThreadFamily resolve π p)
      (permuteThreadFamily resolve π q)
    ↔
    ThreadFamilyKernel resolve p q := by
  constructor
  · intro h
    have hinv := permuteThreadFamily_respects_kernel resolve π.inverse h
    rw [permuteThreadFamily_inverse_rotate resolve π p,
        permuteThreadFamily_inverse_rotate resolve π q] at hinv
    exact hinv
  · intro h
    exact permuteThreadFamily_respects_kernel resolve π h

/-! Nontriviality predicate. -/

def ThreadPermutation.Nontrivial {n : Nat} (π : ThreadPermutation n) : Prop :=
  ∃ i : Fin n, π.toFun i ≠ i

/-! Finite period hypothesis. -/

def ThreadPermutation.HasFinitePeriod {n : Nat} (π : ThreadPermutation n) (k : Nat) : Prop :=
  1 < k ∧ ∀ i : Fin n, Nat.repeat π.toFun k i = i

/-! Helper: iteration tracks index. -/

theorem Nat_repeat_commute
    {n : Nat}
    (π : ThreadPermutation n)
    (m : Nat)
    (j : Fin n) :
    Nat.repeat π.toFun m (π.toFun j) = π.toFun (Nat.repeat π.toFun m j) := by
  induction m with
  | zero => rfl
  | succ m ih =>
    simp only [Nat.repeat.eq_2]
    congr 1

theorem permuteThreadFamily_iterate_apply
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (m : Nat)
    (p : ThreadFamily resolve n)
    (j : Fin n) :
    (Nat.repeat (permuteThreadFamily resolve π) m p) j
    =
    p (Nat.repeat π.toFun m j) := by
  induction m generalizing j with
  | zero => rfl
  | succ m ih =>
    show permuteThreadFamily resolve π
        (Nat.repeat (permuteThreadFamily resolve π) m p) j
      =
      p (π.toFun (Nat.repeat π.toFun m j))
    rw [permuteThreadFamily_apply]
    rw [←Nat_repeat_commute π m j]
    exact ih (π.toFun j)

/-! Index period → family period. -/

theorem permuteThreadFamily_repeat
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (k : Nat)
    (hperiod : ∀ i : Fin n, Nat.repeat π.toFun k i = i)
    (p : ThreadFamily resolve n) :
    Nat.repeat (permuteThreadFamily resolve π) k p = p := by
  funext i
  rw [permuteThreadFamily_iterate_apply]
  rw [hperiod i]

/-! Nontrivial index → nontrivial family action. -/

theorem permuteThreadFamily_nonidentity_of_nontrivial
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hnon : π.Nontrivial) :
    ∃ p : ThreadFamily resolve n,
      permuteThreadFamily resolve π p ≠ p := by
  rcases hnon with ⟨i, hi⟩
  let p : ThreadFamily resolve n := fun j => if j = i then [] else [identityContext]
  refine ⟨p, ?_⟩
  intro heq
  have happly := congrFun heq i
  rw [permuteThreadFamily_apply] at happly
  have hpi : p i = [] := by simp [p]
  have hpπi : p (π.toFun i) = [identityContext] := by
    simp [p, hi]
  rw [hpi, hpπi] at happly
  exact List.cons_ne_nil _ _ happly

/-! Generic admission theorem. -/

def ThreadPermutation.toThreadFamilyRotation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hnon : π.Nontrivial)
    (k : Nat)
    (hperiod : π.HasFinitePeriod k) :
    ThreadFamilyRotation resolve n where
  rotate := permuteThreadFamily resolve π
  inverse := permuteThreadFamily resolve π.inverse
  inverse_rotate := permuteThreadFamily_inverse_rotate resolve π
  rotate_inverse := permuteThreadFamily_rotate_inverse resolve π
  kernel_iff := permuteThreadFamily_kernel_iff resolve π
  nonidentity := permuteThreadFamily_nonidentity_of_nontrivial resolve π hnon
  finiteOrder := ⟨k, hperiod.1, fun p => permuteThreadFamily_repeat resolve π k hperiod.2 p⟩

/-! Generic projected action. -/

theorem permutationRotation_projected_apply
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hnon : π.Nontrivial)
    (k : Nat)
    (hperiod : π.HasFinitePeriod k)
    (f : Fin n → TrajectoryBoundary resolve)
    (i : Fin n) :
    (π.toThreadFamilyRotation resolve hnon k hperiod).projectedRotate f i
    =
    f (π.toFun i) := by
  have ⟨p, hp⟩ := projectThreadFamily_surjective resolve n f
  have hnat := (π.toThreadFamilyRotation resolve hnon k hperiod).projectedRotate_projectThreadFamily p
  rw [hp] at hnat
  have hnat_i : (π.toThreadFamilyRotation resolve hnon k hperiod).projectedRotate f i
    =
    projectThreadFamily resolve ((π.toThreadFamilyRotation resolve hnon k hperiod).rotate p) i :=
    congrFun hnat i
  have hperm : projectThreadFamily resolve ((π.toThreadFamilyRotation resolve hnon k hperiod).rotate p) i
    =
    projectThreadFamily resolve p (π.toFun i) := by
    show trajectoryProjection resolve (permuteThreadFamily resolve π p i)
      =
      trajectoryProjection resolve (p (π.toFun i))
    rw [permuteThreadFamily_apply]
  rw [hnat_i, hperm]
  rw [hp]

/-! Generic projected fixed-point condition. -/

theorem permutationRotation_projected_fixed_iff
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hnon : π.Nontrivial)
    (k : Nat)
    (hperiod : π.HasFinitePeriod k)
    (f : Fin n → TrajectoryBoundary resolve) :
    (π.toThreadFamilyRotation resolve hnon k hperiod).projectedRotate f = f
    ↔
    ∀ i, f (π.toFun i) = f i := by
  constructor
  · intro hfix i
    have hi := congrFun hfix i
    rw [permutationRotation_projected_apply] at hi
    exact hi
  · intro hinv
    funext i
    rw [permutationRotation_projected_apply]
    exact hinv i

/-! n = 2 regression. -/

theorem twoThreadSwap_nontrivial : twoThreadSwap.Nontrivial := by
  refine ⟨0, ?_⟩
  intro heq
  have : twoThreadSwap.toFun 0 = 1 := rfl
  rw [this] at heq
  exact Fin.zero_ne_one heq.symm

theorem twoThreadSwap_hasFinitePeriod : twoThreadSwap.HasFinitePeriod 2 := by
  refine ⟨by omega, ?_⟩
  intro i
  cases i using Fin.cases with
  | zero => rfl
  | succ j =>
    cases j using Fin.cases with
    | zero => rfl
    | succ k => exact absurd k.isLt (by omega)

/-! n = 3 regression. -/

theorem threeThreadCycle_nontrivial : threeThreadCycle.Nontrivial := by
  refine ⟨0, ?_⟩
  intro heq
  have : threeThreadCycle.toFun 0 = 1 := threeThreadCycle_apply_0
  rw [this] at heq
  exact Fin.zero_ne_one heq.symm

theorem threeThreadCycle_hasFinitePeriod : threeThreadCycle.HasFinitePeriod 3 := by
  refine ⟨by omega, ?_⟩
  intro i
  exact threeThreadCycle_three_step i

#print axioms permuteThreadFamily_kernel_iff
#print axioms permuteThreadFamily_repeat
#print axioms permuteThreadFamily_nonidentity_of_nontrivial
#print axioms permutationRotation_projected_apply
#print axioms permutationRotation_projected_fixed_iff
#print axioms twoThreadSwap_nontrivial
#print axioms threeThreadCycle_nontrivial

/-! ============================================================
    Projected action alignment
============================================================ -/

theorem ThreadPermutation.projectedAction_rotation_eq_pointwise
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hnon : π.Nontrivial)
    (k : Nat)
    (hperiod : π.HasFinitePeriod k)
    (f : Fin n → TrajectoryBoundary resolve)
    (i : Fin n) :
    π.projectedAction resolve f i
    =
    (π.toThreadFamilyRotation resolve hnon k hperiod).projectedRotate f i := by
  show f (π.toFun i)
    =
    (π.toThreadFamilyRotation resolve hnon k hperiod).projectedRotate f i
  exact (permutationRotation_projected_apply resolve π hnon k hperiod f i).symm

theorem ThreadPermutation.projectedAction_period_independent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hnon : π.Nontrivial)
    (k₁ k₂ : Nat)
    (hk₁ : π.HasFinitePeriod k₁)
    (hk₂ : π.HasFinitePeriod k₂)
    (f : Fin n → TrajectoryBoundary resolve)
    (i : Fin n) :
    (π.toThreadFamilyRotation resolve hnon k₁ hk₁).projectedRotate f i
    =
    (π.toThreadFamilyRotation resolve hnon k₂ hk₂).projectedRotate f i := by
  rw [← projectedAction_rotation_eq_pointwise resolve π hnon k₁ hk₁ f i]
  rw [← projectedAction_rotation_eq_pointwise resolve π hnon k₂ hk₂ f i]

/-! ============================================================
    Direct projected finite-period transport
============================================================ -/

theorem Nat.repeat_apply_commute
    {α : Type u}
    (g : α → α)
    (m : Nat)
    (a : α) :
    Nat.repeat g m (g a) = g (Nat.repeat g m a) := by
  induction m generalizing a with
  | zero => rfl
  | succ m ih =>
    have hstep : Nat.repeat g (m + 1) (g a) = g (Nat.repeat g m (g a)) := rfl
    rw [hstep]
    exact congrArg g (ih a)

theorem ThreadPermutation.projectedAction_repeat_apply
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (m : Nat)
    (f : Fin n → TrajectoryBoundary resolve)
    (i : Fin n) :
    Nat.repeat (π.projectedAction resolve) m f i
    =
    f (Nat.repeat π.toFun m i) := by
  induction m generalizing f i with
  | zero => rfl
  | succ m ih =>
    have hstep : Nat.repeat (π.projectedAction resolve) (m + 1) f i
      = π.projectedAction resolve (Nat.repeat (π.projectedAction resolve) m f) i := rfl
    rw [hstep]
    have hdef : π.projectedAction resolve (Nat.repeat (π.projectedAction resolve) m f) i
      = Nat.repeat (π.projectedAction resolve) m f (π.toFun i) := rfl
    rw [hdef]
    have hih := ih f (π.toFun i)
    rw [hih]
    exact congrArg f (Nat.repeat_apply_commute π.toFun m i)

/-!
A valid index-level period transports to the direct projected action.
The theorem establishes a valid projected period, not minimal or exact
projected order.
-/
theorem ThreadPermutation.projectedAction_hasFinitePeriod
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (k : Nat)
    (hperiod : π.HasFinitePeriod k)
    (f : Fin n → TrajectoryBoundary resolve) :
    Nat.repeat (π.projectedAction resolve) k f = f := by
  funext i
  rw [projectedAction_repeat_apply]
  exact congrArg f (hperiod.2 i)


/-! Rotation-side period transport via alignment -/

theorem ThreadPermutation.projectedAction_rotation_eq
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hnon : π.Nontrivial)
    (k : Nat)
    (hperiod : π.HasFinitePeriod k) :
    π.projectedAction resolve
    =
    (π.toThreadFamilyRotation resolve hnon k hperiod).projectedRotate := by
  funext f i
  exact π.projectedAction_rotation_eq_pointwise resolve hnon k hperiod f i

theorem ThreadPermutation.rotation_projected_hasFinitePeriod
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hnon : π.Nontrivial)
    (k : Nat)
    (hperiod : π.HasFinitePeriod k)
    (f : Fin n → TrajectoryBoundary resolve) :
    Nat.repeat
      (π.toThreadFamilyRotation resolve hnon k hperiod).projectedRotate
      k
      f
    =
    f := by
  rw [← projectedAction_rotation_eq]
  exact π.projectedAction_hasFinitePeriod resolve k hperiod f

/-! ============================================================
/-!
# Frozen ThreadPermutation projected-action calculus

`ThreadPermutation.projectedAction` acts on projected thread families by
coordinate precomposition:

    π.projectedAction resolve f i = f (π.toFun i)

The direct projected API preserves the permutation calculus in pullback
orientation:

* identity maps to identity;
* composition reverses at the projected-action level:
    projectedAction (π₁ ∘ π₂)
      = projectedAction π₂ ∘ projectedAction π₁;
* the inverse permutation induces a two-sided inverse projected action;
* iteration satisfies:
    π̄^m(f)(i) = f(π^m(i));
* every valid `HasFinitePeriod k` certificate transports to a valid
  period `k` of the projected action.

This layer is independent of ThreadFamilyRotation admission and does not
require `Nontrivial`.

A transported period is not asserted to be minimal or exact.

This API is frozen. Extend it only when a downstream verified boundary
requires additional structure.
-/

    Direct projected identity and composition
============================================================ -/

def identityThreadPermutation (n : Nat) : ThreadPermutation n where
  toFun := fun i => i
  invFun := fun i => i
  left_inv := fun _ => rfl
  right_inv := fun _ => rfl

def composeThreadPermutation
    {n : Nat}
    (π₁ π₂ : ThreadPermutation n) :
    ThreadPermutation n where
  toFun := fun i => π₁.toFun (π₂.toFun i)
  invFun := fun i => π₂.invFun (π₁.invFun i)
  left_inv := fun i => by rw [π₁.left_inv, π₂.left_inv]
  right_inv := fun i => by rw [π₂.right_inv, π₁.right_inv]

theorem ThreadPermutation.projectedAction_eq_id_of_toFun_eq
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hπ : ∀ i : Fin n, π.toFun i = i) :
    π.projectedAction resolve = id := by
  funext f i
  simp [ThreadPermutation.projectedAction, hπ i]

theorem ThreadPermutation.projectedAction_id
    (resolve : KernelExpr → Store → Location)
    {n : Nat} :
    (identityThreadPermutation n).projectedAction resolve = id := by
  funext f i
  rfl

/-!
`projectedAction` acts by coordinate precomposition. Consequently,
ThreadPermutation composition is represented contravariantly:
projectedAction (π₁ ∘ π₂) = projectedAction π₂ ∘ projectedAction π₁.
This is the expected pullback orientation, not an inversion bug.
-/
theorem ThreadPermutation.projectedAction_comp
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π₁ π₂ : ThreadPermutation n) :
    (composeThreadPermutation π₁ π₂).projectedAction resolve
    =
    π₂.projectedAction resolve ∘ π₁.projectedAction resolve := by
  funext f i
  rfl
