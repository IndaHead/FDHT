import FDHTPermutationRotation
import FDHTThreeThreadCycle

open KernelExprContext

/-! Probe-local n=8 cycle: 0→1→2→3→4→5→6→7→0 -/

def eightThreadCycleFun : Fin 8 → Fin 8
  | ⟨0, _⟩ => ⟨1, by omega⟩
  | ⟨1, _⟩ => ⟨2, by omega⟩
  | ⟨2, _⟩ => ⟨3, by omega⟩
  | ⟨3, _⟩ => ⟨4, by omega⟩
  | ⟨4, _⟩ => ⟨5, by omega⟩
  | ⟨5, _⟩ => ⟨6, by omega⟩
  | ⟨6, _⟩ => ⟨7, by omega⟩
  | ⟨7, _⟩ => ⟨0, by omega⟩

def eightThreadCycleInvFun : Fin 8 → Fin 8
  | ⟨0, _⟩ => ⟨7, by omega⟩
  | ⟨1, _⟩ => ⟨0, by omega⟩
  | ⟨2, _⟩ => ⟨1, by omega⟩
  | ⟨3, _⟩ => ⟨2, by omega⟩
  | ⟨4, _⟩ => ⟨3, by omega⟩
  | ⟨5, _⟩ => ⟨4, by omega⟩
  | ⟨6, _⟩ => ⟨5, by omega⟩
  | ⟨7, _⟩ => ⟨6, by omega⟩

def eightThreadCycle : ThreadPermutation 8 where
  toFun := eightThreadCycleFun
  invFun := eightThreadCycleInvFun
  left_inv := fun i => by
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl
    | ⟨6, _⟩ => rfl
    | ⟨7, _⟩ => rfl
  right_inv := fun i => by
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl
    | ⟨6, _⟩ => rfl
    | ⟨7, _⟩ => rfl

abbrev eightThreadCycleFourth : ThreadPermutation 8 :=
  composeThreadPermutation
    (composeThreadPermutation
      (composeThreadPermutation eightThreadCycle eightThreadCycle)
      eightThreadCycle)
    eightThreadCycle

/-! Period 8 -/

theorem eightThreadCycle_k8 :
    ∀ i : Fin 8,
      eightThreadCycle.toFun
        (eightThreadCycle.toFun
          (eightThreadCycle.toFun
            (eightThreadCycle.toFun
              (eightThreadCycle.toFun
                (eightThreadCycle.toFun
                  (eightThreadCycle.toFun
                    (eightThreadCycle.toFun i))))))) = i := by
  intro i
  match i with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl
  | ⟨2, _⟩ => rfl
  | ⟨3, _⟩ => rfl
  | ⟨4, _⟩ => rfl
  | ⟨5, _⟩ => rfl
  | ⟨6, _⟩ => rfl
  | ⟨7, _⟩ => rfl

theorem eightThreadCycle_hasFinitePeriod :
    eightThreadCycle.HasFinitePeriod 8 := by
  constructor
  · omega
  · intro i
    exact eightThreadCycle_k8 i

/-! π⁴ explicit mapping -/

theorem eightThreadCycleFourth_apply :
    eightThreadCycleFourth.toFun 0 = 4 ∧
    eightThreadCycleFourth.toFun 1 = 5 ∧
    eightThreadCycleFourth.toFun 2 = 6 ∧
    eightThreadCycleFourth.toFun 3 = 7 ∧
    eightThreadCycleFourth.toFun 4 = 0 ∧
    eightThreadCycleFourth.toFun 5 = 1 ∧
    eightThreadCycleFourth.toFun 6 = 2 ∧
    eightThreadCycleFourth.toFun 7 = 3 := by
  constructor
  · rfl
  constructor
  · rfl
  constructor
  · rfl
  constructor
  · rfl
  constructor
  · rfl
  constructor
  · rfl
  constructor
  · rfl
  · rfl

/-! Nonidentity -/

theorem eightThreadCycleFourth_ne_identity :
    eightThreadCycleFourth ≠ identityThreadPermutation 8 := by
  intro h
  have h0 := congrFun (congrArg ThreadPermutation.toFun h) (0 : Fin 8)
  have hleft : eightThreadCycleFourth.toFun 0 = 4 := rfl
  rw [hleft] at h0
  cases h0

/-! Involutive -/

theorem eightThreadCycleFourth_involutive :
    composeThreadPermutation eightThreadCycleFourth eightThreadCycleFourth
      = identityThreadPermutation 8 := by
  unfold composeThreadPermutation identityThreadPermutation eightThreadCycleFourth
  congr 1
  · funext i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl
    | ⟨6, _⟩ => rfl
    | ⟨7, _⟩ => rfl
  · funext i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl
    | ⟨6, _⟩ => rfl
    | ⟨7, _⟩ => rfl

/-! Fixed-point-free -/

theorem eightThreadCycleFourth_fixed_point_free :
    eightThreadCycleFourth.toFun 0 ≠ 0 ∧
    eightThreadCycleFourth.toFun 1 ≠ 1 ∧
    eightThreadCycleFourth.toFun 2 ≠ 2 ∧
    eightThreadCycleFourth.toFun 3 ≠ 3 ∧
    eightThreadCycleFourth.toFun 4 ≠ 4 ∧
    eightThreadCycleFourth.toFun 5 ≠ 5 ∧
    eightThreadCycleFourth.toFun 6 ≠ 6 ∧
    eightThreadCycleFourth.toFun 7 ≠ 7 := by
  constructor
  · have : eightThreadCycleFourth.toFun 0 = 4 := rfl
    rw [this]
    decide
  constructor
  · have : eightThreadCycleFourth.toFun 1 = 5 := rfl
    rw [this]
    decide
  constructor
  · have : eightThreadCycleFourth.toFun 2 = 6 := rfl
    rw [this]
    decide
  constructor
  · have : eightThreadCycleFourth.toFun 3 = 7 := rfl
    rw [this]
    decide
  constructor
  · have : eightThreadCycleFourth.toFun 4 = 0 := rfl
    rw [this]
    decide
  constructor
  · have : eightThreadCycleFourth.toFun 5 = 1 := rfl
    rw [this]
    decide
  constructor
  · have : eightThreadCycleFourth.toFun 6 = 2 := rfl
    rw [this]
    decide
  · have : eightThreadCycleFourth.toFun 7 = 3 := rfl
    rw [this]
    decide

/-! Projected involution -/

theorem eightThreadCycleFourth_projected_involutive
    (resolve : KernelExpr → Store → Location)
    (f : Fin 8 → TrajectoryBoundary resolve) :
    eightThreadCycleFourth.projectedAction resolve
      (eightThreadCycleFourth.projectedAction resolve f)
    = f := by
  funext i
  show f (eightThreadCycleFourth.toFun (eightThreadCycleFourth.toFun i)) = f i
  have h : eightThreadCycleFourth.toFun (eightThreadCycleFourth.toFun i) = i := by
    have hinv := eightThreadCycleFourth_involutive
    have hto : (composeThreadPermutation eightThreadCycleFourth eightThreadCycleFourth).toFun i = i := by
      rw [hinv]; rfl
    exact hto
  rw [h]

#print axioms eightThreadCycle_hasFinitePeriod
#print axioms eightThreadCycleFourth_apply
#print axioms eightThreadCycleFourth_ne_identity
#print axioms eightThreadCycleFourth_involutive
#print axioms eightThreadCycleFourth_fixed_point_free
#print axioms eightThreadCycleFourth_projected_involutive
