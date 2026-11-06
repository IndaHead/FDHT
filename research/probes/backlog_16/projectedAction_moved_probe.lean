import AggregateFamilyTransform

open KernelExprContext

namespace KernelExprContext

universe u v

variable {Store : Type u}
variable {Location : Type v}

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

#print axioms ThreadPermutation.projectedAction_moved

end KernelExprContext
