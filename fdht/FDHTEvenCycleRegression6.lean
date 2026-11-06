import FDHTPermutationRotation
import FDHTThreeThreadCycle

open KernelExprContext

/-!
# FDHT n=6 Even-Cycle Regression Fixture

Original historical probe:
/tmp/n6_halfpower_probe.lean

Original SHA256:
3fd04cecab5a3391037fdc3d976b6e0af46f4f15171e99baf176e9a9db997d72

Promotion audit: #14G / #14H

Compatibility delta:
one redundant historical proof bullet removed from
sixThreadCycleCube_involutive because current `congr 1` closes that goal.

Classification: MATHEMATICALLY IDENTICAL

Purpose: permanent regression fixture only
-/


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

/-! ============================================================
    n=6 no-early-return (30-cell coordinate table)
============================================================ -/

theorem sixThreadCycle_k1_ne :
    ∀ i : Fin 6, Nat.repeat sixThreadCycle.toFun 1 i ≠ i := by
  intro i
  match i with
  | ⟨0, _⟩ => change sixThreadCycleFun 0 ≠ 0; simp [sixThreadCycleFun]
  | ⟨1, _⟩ => change sixThreadCycleFun 1 ≠ 1; simp [sixThreadCycleFun]
  | ⟨2, _⟩ => change sixThreadCycleFun 2 ≠ 2; simp [sixThreadCycleFun]
  | ⟨3, _⟩ => change sixThreadCycleFun 3 ≠ 3; simp [sixThreadCycleFun]
  | ⟨4, _⟩ => change sixThreadCycleFun 4 ≠ 4; simp [sixThreadCycleFun]
  | ⟨5, _⟩ => change sixThreadCycleFun 5 ≠ 5; simp [sixThreadCycleFun]

theorem sixThreadCycle_k2_ne :
    ∀ i : Fin 6, Nat.repeat sixThreadCycle.toFun 2 i ≠ i := by
  intro i
  match i with
  | ⟨0, _⟩ => change sixThreadCycleFun (sixThreadCycleFun 0) ≠ 0; simp [sixThreadCycleFun]
  | ⟨1, _⟩ => change sixThreadCycleFun (sixThreadCycleFun 1) ≠ 1; simp [sixThreadCycleFun]
  | ⟨2, _⟩ => change sixThreadCycleFun (sixThreadCycleFun 2) ≠ 2; simp [sixThreadCycleFun]
  | ⟨3, _⟩ => change sixThreadCycleFun (sixThreadCycleFun 3) ≠ 3; simp [sixThreadCycleFun]
  | ⟨4, _⟩ => change sixThreadCycleFun (sixThreadCycleFun 4) ≠ 4; simp [sixThreadCycleFun]
  | ⟨5, _⟩ => change sixThreadCycleFun (sixThreadCycleFun 5) ≠ 5; simp [sixThreadCycleFun]

theorem sixThreadCycle_k3_ne :
    ∀ i : Fin 6, Nat.repeat sixThreadCycle.toFun 3 i ≠ i := by
  intro i
  match i with
  | ⟨0, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 0)) ≠ 0; simp [sixThreadCycleFun]
  | ⟨1, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 1)) ≠ 1; simp [sixThreadCycleFun]
  | ⟨2, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 2)) ≠ 2; simp [sixThreadCycleFun]
  | ⟨3, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 3)) ≠ 3; simp [sixThreadCycleFun]
  | ⟨4, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 4)) ≠ 4; simp [sixThreadCycleFun]
  | ⟨5, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 5)) ≠ 5; simp [sixThreadCycleFun]

theorem sixThreadCycle_k4_ne :
    ∀ i : Fin 6, Nat.repeat sixThreadCycle.toFun 4 i ≠ i := by
  intro i
  match i with
  | ⟨0, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 0))) ≠ 0; simp [sixThreadCycleFun]
  | ⟨1, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 1))) ≠ 1; simp [sixThreadCycleFun]
  | ⟨2, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 2))) ≠ 2; simp [sixThreadCycleFun]
  | ⟨3, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 3))) ≠ 3; simp [sixThreadCycleFun]
  | ⟨4, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 4))) ≠ 4; simp [sixThreadCycleFun]
  | ⟨5, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 5))) ≠ 5; simp [sixThreadCycleFun]

theorem sixThreadCycle_k5_ne :
    ∀ i : Fin 6, Nat.repeat sixThreadCycle.toFun 5 i ≠ i := by
  intro i
  match i with
  | ⟨0, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 0)))) ≠ 0; simp [sixThreadCycleFun]
  | ⟨1, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 1)))) ≠ 1; simp [sixThreadCycleFun]
  | ⟨2, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 2)))) ≠ 2; simp [sixThreadCycleFun]
  | ⟨3, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 3)))) ≠ 3; simp [sixThreadCycleFun]
  | ⟨4, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 4)))) ≠ 4; simp [sixThreadCycleFun]
  | ⟨5, _⟩ => change sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun (sixThreadCycleFun 5)))) ≠ 5; simp [sixThreadCycleFun]

theorem sixThreadCycle_noEarlyReturn :
    ∀ i : Fin 6,
      ∀ k : Nat,
        0 < k →
        k < 6 →
        Nat.repeat sixThreadCycle.toFun k i ≠ i := by
  intro i k hkPos hkLt
  have hk : k = 1 ∨ k = 2 ∨ k = 3 ∨ k = 4 ∨ k = 5 := by omega
  rcases hk with rfl | rfl | rfl | rfl | rfl
  · exact sixThreadCycle_k1_ne i
  · exact sixThreadCycle_k2_ne i
  · exact sixThreadCycle_k3_ne i
  · exact sixThreadCycle_k4_ne i
  · exact sixThreadCycle_k5_ne i
