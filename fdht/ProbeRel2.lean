import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

example (xs ys : List KernelExprContext) (h : FoldKernel resolve xs ys) :
    TrajectoryEquivalent resolve xs ys := by
  intro q
  unfold FoldKernel trajectoryProjection toTrajectoryBoundary at h
  -- h is equality of quotients
  exact h

#print FoldKernel
