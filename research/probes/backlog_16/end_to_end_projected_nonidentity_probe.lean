import AggregateFamilyTransform
import FDHTPermutationRotation

open KernelExprContext

namespace KernelExprContext

universe u v

variable {Store : Type u}
variable {Location : Type v}

/--
Constructive search for moved coordinate.
Returns either a witness or a proof that all coordinates are fixed.
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
theorem ThreadPermutation.ne_identity_implies_projectedAction_moved
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (π : ThreadPermutation n)
    (hπ : π ≠ identityThreadPermutation n)
    (hT : ∃ a b : TrajectoryBoundary resolve, a ≠ b) :
    ∃ f : Fin n → TrajectoryBoundary resolve,
      π.projectedAction resolve f ≠ f := by
  obtain ⟨i, hi⟩ := π.ne_identity_implies_moved_coordinate hπ
  obtain ⟨a, b, hab⟩ := hT
  exact π.projectedAction_moved hi hab

/--
Function-nonidentity packaging.
-/
theorem ThreadPermutation.ne_identity_implies_projectedAction_ne_identity
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (π : ThreadPermutation n)
    (hπ : π ≠ identityThreadPermutation n)
    (hT : ∃ a b : TrajectoryBoundary resolve, a ≠ b) :
    π.projectedAction resolve ≠ id := by
  obtain ⟨f, hf⟩ := π.ne_identity_implies_projectedAction_moved hπ hT
  intro h_id
  have h_eq : π.projectedAction resolve f = f := by
    rw [h_id]
    rfl
  exact hf h_eq

#print axioms ThreadPermutation.ne_identity_implies_moved_coordinate
#print axioms ThreadPermutation.projectedAction_moved
#print axioms ThreadPermutation.ne_identity_implies_projectedAction_moved
#print axioms ThreadPermutation.ne_identity_implies_projectedAction_ne_identity

end KernelExprContext
