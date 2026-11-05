import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

example (xs ys : List KernelExprContext) :
    FoldKernel resolve xs ys → TrajectoryEquivalent resolve xs ys := by
  intro h
  unfold FoldKernel TrajectoryEquivalent trajectoryProjection toTrajectoryBoundary
  exact h

#check (·)
