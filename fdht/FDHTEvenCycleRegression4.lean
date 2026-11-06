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
