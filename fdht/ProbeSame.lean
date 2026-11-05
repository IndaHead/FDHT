import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

example (xs ys : List KernelExprContext) :
    TrajectoryEquivalent resolve xs ys ↔ FoldKernel resolve xs ys := by
  constructor
  · intro h
    unfold FoldKernel trajectoryProjection toTrajectoryBoundary
    exact Quotient.sound h
  · intro h
    unfold FoldKernel trajectoryProjection toTrajectoryBoundary at h
    exact Quotient.exact h

#check (·)
