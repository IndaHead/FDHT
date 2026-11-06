import FDHTPermutationRotation
import FDHTThreeThreadCycle

open KernelExprContext

/-! Local n=4 cycle: 0→1→2→3→0 -/

def fourThreadCycleFun : Fin 4 → Fin 4
  | ⟨0, _⟩ => ⟨1, by omega⟩
  | ⟨1, _⟩ => ⟨2, by omega⟩
  | ⟨2, _⟩ => ⟨3, by omega⟩
  | ⟨3, _⟩ => ⟨0, by omega⟩

def fourThreadCycleInvFun : Fin 4 → Fin 4
  | ⟨0, _⟩ => ⟨3, by omega⟩
  | ⟨1, _⟩ => ⟨0, by omega⟩
  | ⟨2, _⟩ => ⟨1, by omega⟩
  | ⟨3, _⟩ => ⟨2, by omega⟩

def fourThreadCycle : ThreadPermutation 4 where
  toFun := fourThreadCycleFun
  invFun := fourThreadCycleInvFun
  left_inv := fun i => by
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
  right_inv := fun i => by
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl

theorem fourThreadCycle_k2 :
    fourThreadCycle.toFun (fourThreadCycle.toFun 0) = 2 ∧
    fourThreadCycle.toFun (fourThreadCycle.toFun 1) = 3 ∧
    fourThreadCycle.toFun (fourThreadCycle.toFun 2) = 0 ∧
    fourThreadCycle.toFun (fourThreadCycle.toFun 3) = 1 := by
  constructor
  · rfl
  constructor
  · rfl
  constructor
  · rfl
  · rfl

theorem fourThreadCycle_k4 :
    ∀ i : Fin 4,
      fourThreadCycle.toFun
        (fourThreadCycle.toFun
          (fourThreadCycle.toFun
            (fourThreadCycle.toFun i))) = i := by
  intro i
  match i with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl
  | ⟨2, _⟩ => rfl
  | ⟨3, _⟩ => rfl

theorem fourThreadCycle_hasFinitePeriod :
    fourThreadCycle.HasFinitePeriod 4 := by
  constructor
  · omega
  · intro i
    exact fourThreadCycle_k4 i

def fourThreadCycleTransform
    (resolve : KernelExpr → Store → Location) :
    ThreadFamily resolve 4 → ThreadFamily resolve 4 :=
  permuteThreadFamily resolve fourThreadCycle

theorem fourThreadCycleTransform_four_step
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 4) :
    fourThreadCycleTransform resolve
      (fourThreadCycleTransform resolve
        (fourThreadCycleTransform resolve
          (fourThreadCycleTransform resolve p))) = p := by
  funext i
  unfold fourThreadCycleTransform permuteThreadFamily reindexThreadFamily
  congr 1
  exact fourThreadCycle_k4 i

theorem fourThreadCycle_k2_is_reindexing
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 4) :
    (fourThreadCycleTransform resolve
      (fourThreadCycleTransform resolve p)) =
    fun i => p (fourThreadCycle.toFun (fourThreadCycle.toFun i)) := by
  funext i
  unfold fourThreadCycleTransform permuteThreadFamily reindexThreadFamily
  rfl

#print axioms fourThreadCycle_hasFinitePeriod
#print axioms fourThreadCycleTransform_four_step
#print axioms fourThreadCycle_k2
#print axioms fourThreadCycle_k2_is_reindexing

/-! ============================================================
    n=4 no-early-return (coordinate-table proof)
    Verified in /tmp/n4_coordinate_table_no_early_return.lean
============================================================ -/

/-! k=1 table: 0→1, 1→2, 2→3, 3→0 -/
theorem fourThreadCycle_k1_ne :
    ∀ i : Fin 4, Nat.repeat fourThreadCycle.toFun 1 i ≠ i := by
  intro i
  match i with
  | ⟨0, _⟩ =>
    change fourThreadCycleFun 0 ≠ 0
    simp [fourThreadCycleFun]
  | ⟨1, _⟩ =>
    change fourThreadCycleFun 1 ≠ 1
    simp [fourThreadCycleFun]
  | ⟨2, _⟩ =>
    change fourThreadCycleFun 2 ≠ 2
    simp [fourThreadCycleFun]
  | ⟨3, _⟩ =>
    change fourThreadCycleFun 3 ≠ 3
    simp [fourThreadCycleFun]

/-! k=2 table: 0→2, 1→3, 2→0, 3→1 -/
theorem fourThreadCycle_k2_ne :
    ∀ i : Fin 4, Nat.repeat fourThreadCycle.toFun 2 i ≠ i := by
  intro i
  match i with
  | ⟨0, _⟩ =>
    change fourThreadCycleFun (fourThreadCycleFun 0) ≠ 0
    simp [fourThreadCycleFun]
  | ⟨1, _⟩ =>
    change fourThreadCycleFun (fourThreadCycleFun 1) ≠ 1
    simp [fourThreadCycleFun]
  | ⟨2, _⟩ =>
    change fourThreadCycleFun (fourThreadCycleFun 2) ≠ 2
    simp [fourThreadCycleFun]
  | ⟨3, _⟩ =>
    change fourThreadCycleFun (fourThreadCycleFun 3) ≠ 3
    simp [fourThreadCycleFun]

/-! k=3 table: 0→3, 1→0, 2→1, 3→2 -/
theorem fourThreadCycle_k3_ne :
    ∀ i : Fin 4, Nat.repeat fourThreadCycle.toFun 3 i ≠ i := by
  intro i
  match i with
  | ⟨0, _⟩ =>
    change fourThreadCycleFun (fourThreadCycleFun (fourThreadCycleFun 0)) ≠ 0
    simp [fourThreadCycleFun]
  | ⟨1, _⟩ =>
    change fourThreadCycleFun (fourThreadCycleFun (fourThreadCycleFun 1)) ≠ 1
    simp [fourThreadCycleFun]
  | ⟨2, _⟩ =>
    change fourThreadCycleFun (fourThreadCycleFun (fourThreadCycleFun 2)) ≠ 2
    simp [fourThreadCycleFun]
  | ⟨3, _⟩ =>
    change fourThreadCycleFun (fourThreadCycleFun (fourThreadCycleFun 3)) ≠ 3
    simp [fourThreadCycleFun]

theorem fourThreadCycle_noEarlyReturn :
    ∀ i : Fin 4,
      ∀ k : Nat,
        0 < k →
        k < 4 →
        Nat.repeat fourThreadCycle.toFun k i ≠ i := by
  intro i k hkPos hkLt
  have hk : k = 1 ∨ k = 2 ∨ k = 3 := by omega
  rcases hk with rfl | rfl | rfl
  · exact fourThreadCycle_k1_ne i
  · exact fourThreadCycle_k2_ne i
  · exact fourThreadCycle_k3_ne i
