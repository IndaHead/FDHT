import AggregateFamilyTransform
import FDHTPermutationRotation
import FDHTReturnStabilizerBoundaryAPI
import FDHTEvenCycleRegression4
import FDHTEvenCycleRegression6
import FDHTEvenCycleRegression8

open KernelExprContext

namespace KernelExprContext

universe u v

variable {Store : Type u}
variable {Location : Type v}

/--
Constructive search for moved coordinate.
-/
def findMovedOrAllFixed
    {n : Nat}
    (π : ThreadPermutation n)
    (k : Nat)
    (hk : k ≤ n) :
    (∃ i : Fin n, π.toFun i ≠ i) ∨ (∀ i : Fin n, i.val < k → π.toFun i = i) := by
  match k with
  | 0 =>
    exact Or.inr fun i hi => by omega
  | k' + 1 =>
    have h_prev := findMovedOrAllFixed π k' (Nat.le_of_succ_le hk)
    match h_prev with
    | Or.inl h_found => exact Or.inl h_found
    | Or.inr h_all =>
      if h_eq : π.toFun ⟨k', Nat.lt_of_le_of_lt (Nat.le_refl _) hk⟩ = ⟨k', Nat.lt_of_le_of_lt (Nat.le_refl _) hk⟩ then
        exact Or.inr fun i hi => by
          if h_lt : i.val < k' then
            exact h_all i h_lt
          else
            have h_val : i.val = k' := by omega
            have h_i : i = ⟨k', Nat.lt_of_le_of_lt (Nat.le_refl _) hk⟩ := Fin.eq_of_val_eq h_val
            rw [h_i]
            exact h_eq
      else
        exact Or.inl ⟨⟨k', Nat.lt_of_le_of_lt (Nat.le_refl _) hk⟩, h_eq⟩

/--
Permutation nonidentity yields a moved coordinate.
-/
theorem ThreadPermutation.ne_identity_implies_moved_coordinate
    {n : Nat}
    (π : ThreadPermutation n)
    (h : π ≠ identityThreadPermutation n) :
    ∃ i : Fin n, π.toFun i ≠ i := by
  have h_search := findMovedOrAllFixed π n (Nat.le_refl n)
  match h_search with
  | Or.inl h_found => exact h_found
  | Or.inr h_all =>
    have h_all' : ∀ i : Fin n, π.toFun i = i := fun i => h_all i i.isLt
    have h_eq : π = identityThreadPermutation n := by
      match π with
      | ⟨toFun, invFun, left_inv, right_inv⟩ =>
        have h_toFun : toFun = fun i => i := by
          funext i
          exact h_all' i
        have h_invFun : invFun = fun i => i := by
          funext i
          have h1 : toFun (invFun i) = i := right_inv i
          rw [h_toFun] at h1
          exact h1
        congr
    exact False.elim (h h_eq)

/--
Moved coordinate plus carrier nontriviality yields projected nonidentity.
-/
theorem ThreadPermutation.projectedAction_moved
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (π : ThreadPermutation n)
    {i : Fin n}
    (hi : π.toFun i ≠ i)
    {a b : TrajectoryBoundary resolve}
    (hab : a ≠ b) :
    ∃ f : Fin n → TrajectoryBoundary resolve,
      π.projectedAction resolve f ≠ f := by
  let f : Fin n → TrajectoryBoundary resolve := fun j => if j = i then a else b
  refine ⟨f, ?_⟩
  intro h
  have h_at_i : f (π.toFun i) = f i := congrFun h i
  have h_left : f (π.toFun i) = b := by
    simp [f, hi]
  have h_right : f i = a := by
    simp [f]
  rw [h_left, h_right] at h_at_i
  exact hab h_at_i.symm

/--
End-to-end: permutation nonidentity plus carrier nontriviality yields projected nonidentity.
-/
theorem ThreadPermutation.ne_identity_implies_projectedAction_ne_identity
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (π : ThreadPermutation n)
    (hπ : π ≠ identityThreadPermutation n)
    (hT : ∃ a b : TrajectoryBoundary resolve, a ≠ b) :
    π.projectedAction resolve ≠ id := by
  obtain ⟨i, hi⟩ := π.ne_identity_implies_moved_coordinate hπ
  obtain ⟨a, b, hab⟩ := hT
  obtain ⟨f, hf⟩ := π.projectedAction_moved hi hab
  intro h_id
  have h_eq : π.projectedAction resolve f = f := by
    rw [h_id]
    rfl
  exact hf h_eq

/--
Shared carrier witness from existing resolver-level distinction.
-/
theorem resolverSeparationWitness_trajectoryBoundary_nontrivial :
    ∃ a b : TrajectoryBoundary resolverSeparationWitness, a ≠ b := by
  obtain ⟨xs, hxs⟩ := resolverSeparationWitness_nonidentity
  exact ⟨trajectoryProjection resolverSeparationWitness xs, emptyTrajectory resolverSeparationWitness, hxs⟩

/--
n=4 half-power raw nonidentity.
-/
theorem fourThreadCycleSquare_ne_identity :
    composeThreadPermutation fourThreadCycle fourThreadCycle ≠ identityThreadPermutation 4 := by
  intro h
  have h0 : (composeThreadPermutation fourThreadCycle fourThreadCycle).toFun 0 = 0 := by
    rw [h]
    rfl
  have h2 : (composeThreadPermutation fourThreadCycle fourThreadCycle).toFun 0 = 2 := by
    have hk2 := fourThreadCycle_k2
    exact hk2.1
  rw [h2] at h0
  exact Fin.ne_of_val_ne (by omega : (2 : Nat) ≠ 0) h0

/--
n=4 projected nonidentity.
-/
theorem fourThreadCycleSquare_projected_ne_identity :
    ThreadPermutation.projectedAction resolverSeparationWitness
      (composeThreadPermutation fourThreadCycle fourThreadCycle) ≠ id := by
  exact ThreadPermutation.ne_identity_implies_projectedAction_ne_identity
    (composeThreadPermutation fourThreadCycle fourThreadCycle)
    fourThreadCycleSquare_ne_identity
    resolverSeparationWitness_trajectoryBoundary_nontrivial

/--
n=6 projected nonidentity.
-/
theorem sixThreadCycleCube_projected_ne_identity :
    ThreadPermutation.projectedAction resolverSeparationWitness sixThreadCycleCube ≠ id := by
  exact ThreadPermutation.ne_identity_implies_projectedAction_ne_identity
    sixThreadCycleCube
    sixThreadCycleCube_ne_identity
    resolverSeparationWitness_trajectoryBoundary_nontrivial

/--
n=8 projected nonidentity.
-/
theorem eightThreadCycleFourth_projected_ne_identity :
    ThreadPermutation.projectedAction resolverSeparationWitness eightThreadCycleFourth ≠ id := by
  exact ThreadPermutation.ne_identity_implies_projectedAction_ne_identity
    eightThreadCycleFourth
    eightThreadCycleFourth_ne_identity
    resolverSeparationWitness_trajectoryBoundary_nontrivial

#print axioms resolverSeparationWitness_trajectoryBoundary_nontrivial
#print axioms ThreadPermutation.ne_identity_implies_projectedAction_ne_identity
#print axioms fourThreadCycleSquare_projected_ne_identity
#print axioms sixThreadCycleCube_projected_ne_identity
#print axioms eightThreadCycleFourth_projected_ne_identity

end KernelExprContext
