import FDHTPermutationRotation
import FDHTThreeThreadCycle

open KernelExprContext

/-! Probe-local n=6 cycle: 0→1→2→3→4→5→0 -/

def sixThreadCycleFun : Fin 6 → Fin 6
  | ⟨0, _⟩ => ⟨1, by omega⟩
  | ⟨1, _⟩ => ⟨2, by omega⟩
  | ⟨2, _⟩ => ⟨3, by omega⟩
  | ⟨3, _⟩ => ⟨4, by omega⟩
  | ⟨4, _⟩ => ⟨5, by omega⟩
  | ⟨5, _⟩ => ⟨0, by omega⟩

def sixThreadCycleInvFun : Fin 6 → Fin 6
  | ⟨0, _⟩ => ⟨5, by omega⟩
  | ⟨1, _⟩ => ⟨0, by omega⟩
  | ⟨2, _⟩ => ⟨1, by omega⟩
  | ⟨3, _⟩ => ⟨2, by omega⟩
  | ⟨4, _⟩ => ⟨3, by omega⟩
  | ⟨5, _⟩ => ⟨4, by omega⟩

def sixThreadCycle : ThreadPermutation 6 where
  toFun := sixThreadCycleFun
  invFun := sixThreadCycleInvFun
  left_inv := fun i => by
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl
  right_inv := fun i => by
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl

abbrev sixThreadCycleCube : ThreadPermutation 6 :=
  composeThreadPermutation
    (composeThreadPermutation sixThreadCycle sixThreadCycle)
    sixThreadCycle

/-! Period 6 -/

theorem sixThreadCycle_k6 :
    ∀ i : Fin 6,
      sixThreadCycle.toFun
        (sixThreadCycle.toFun
          (sixThreadCycle.toFun
            (sixThreadCycle.toFun
              (sixThreadCycle.toFun
                (sixThreadCycle.toFun i))))) = i := by
  intro i
  match i with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl
  | ⟨2, _⟩ => rfl
  | ⟨3, _⟩ => rfl
  | ⟨4, _⟩ => rfl
  | ⟨5, _⟩ => rfl

theorem sixThreadCycle_hasFinitePeriod :
    sixThreadCycle.HasFinitePeriod 6 := by
  constructor
  · omega
  · intro i
    exact sixThreadCycle_k6 i

/-! π³ explicit mapping -/

theorem sixThreadCycleCube_apply :
    sixThreadCycleCube.toFun 0 = 3 ∧
    sixThreadCycleCube.toFun 1 = 4 ∧
    sixThreadCycleCube.toFun 2 = 5 ∧
    sixThreadCycleCube.toFun 3 = 0 ∧
    sixThreadCycleCube.toFun 4 = 1 ∧
    sixThreadCycleCube.toFun 5 = 2 := by
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

theorem sixThreadCycleCube_ne_identity :
    sixThreadCycleCube ≠ identityThreadPermutation 6 := by
  intro h
  have h0 := congrFun (congrArg ThreadPermutation.toFun h) (0 : Fin 6)
  have hleft : sixThreadCycleCube.toFun 0 = 3 := rfl
  rw [hleft] at h0
  cases h0

/-! Involutive -/

theorem sixThreadCycleCube_involutive :
    composeThreadPermutation sixThreadCycleCube sixThreadCycleCube
      = identityThreadPermutation 6 := by
  unfold composeThreadPermutation identityThreadPermutation sixThreadCycleCube
  congr 1
  · funext i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl
  · funext i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl
  · funext i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl
  · funext i
    match i with
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
    | ⟨2, _⟩ => rfl
    | ⟨3, _⟩ => rfl
    | ⟨4, _⟩ => rfl
    | ⟨5, _⟩ => rfl

/-! Fixed-point-free (explicit) -/

theorem sixThreadCycleCube_fixed_point_free :
    sixThreadCycleCube.toFun 0 ≠ 0 ∧
    sixThreadCycleCube.toFun 1 ≠ 1 ∧
    sixThreadCycleCube.toFun 2 ≠ 2 ∧
    sixThreadCycleCube.toFun 3 ≠ 3 ∧
    sixThreadCycleCube.toFun 4 ≠ 4 ∧
    sixThreadCycleCube.toFun 5 ≠ 5 := by
  constructor
  · have : sixThreadCycleCube.toFun 0 = 3 := rfl
    rw [this]
    decide
  constructor
  · have : sixThreadCycleCube.toFun 1 = 4 := rfl
    rw [this]
    decide
  constructor
  · have : sixThreadCycleCube.toFun 2 = 5 := rfl
    rw [this]
    decide
  constructor
  · have : sixThreadCycleCube.toFun 3 = 0 := rfl
    rw [this]
    decide
  constructor
  · have : sixThreadCycleCube.toFun 4 = 1 := rfl
    rw [this]
    decide
  · have : sixThreadCycleCube.toFun 5 = 2 := rfl
    rw [this]
    decide

/-! Projected involution -/

theorem sixThreadCycleCube_projected_involutive
    (resolve : KernelExpr → Store → Location)
    (f : Fin 6 → TrajectoryBoundary resolve) :
    sixThreadCycleCube.projectedAction resolve
      (sixThreadCycleCube.projectedAction resolve f)
    = f := by
  funext i
  show f (sixThreadCycleCube.toFun (sixThreadCycleCube.toFun i)) = f i
  have h : sixThreadCycleCube.toFun (sixThreadCycleCube.toFun i) = i := by
    have hinv := sixThreadCycleCube_involutive
    have hto : (composeThreadPermutation sixThreadCycleCube sixThreadCycleCube).toFun i = i := by
      rw [hinv]; rfl
    exact hto
  rw [h]

#print axioms sixThreadCycle_hasFinitePeriod
#print axioms sixThreadCycleCube_apply
#print axioms sixThreadCycleCube_ne_identity
#print axioms sixThreadCycleCube_involutive
#print axioms sixThreadCycleCube_fixed_point_free
#print axioms sixThreadCycleCube_projected_involutive
