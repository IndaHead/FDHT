import FDHT_Audit_ArbitraryCollision

open KernelExprContext

variable
    {Store : Sort u}
    {Location : Sort v}

structure ThreadPair
    (resolve : KernelExpr → Store → Location) where
  left  : List KernelExprContext
  right : List KernelExprContext

def projectThreadPair
    (resolve : KernelExpr → Store → Location) :
    ThreadPair resolve →
    TrajectoryBoundary resolve ×
      TrajectoryBoundary resolve
  | p =>
      (trajectoryProjection resolve p.left,
       trajectoryProjection resolve p.right)

/-- R relates the projected left and right trajectories. -/
def ProjectedRelated
    (R : TrajectoryBoundary resolve →
         TrajectoryBoundary resolve → Prop)
    (p : ThreadPair resolve) : Prop :=
  R (trajectoryProjection resolve p.left)
    (trajectoryProjection resolve p.right)

#check ProjectedRelated
