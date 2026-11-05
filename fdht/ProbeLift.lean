import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

example (rotation : List KernelExprContext → List KernelExprContext)
    (h : ∀ xs ys, FoldKernel resolve xs ys → FoldKernel resolve (rotation xs) (rotation ys)) :
    TrajectoryBoundary resolve → TrajectoryBoundary resolve :=
  Quotient.lift
    (s := trajectorySetoid resolve)
    (fun xs => trajectoryProjection resolve (rotation xs))
    (by
      intro xs ys hEq
      -- hEq : TrajectoryEquivalent resolve xs ys
      -- need FoldKernel resolve (rotation xs) (rotation ys)
      -- FoldKernel is trajectoryProjection equality
      -- trajectoryProjection is Quotient.mk, so TrajectoryEquivalent ↔ FoldKernel
      have hFK : FoldKernel resolve xs ys := Quotient.sound hEq
      exact h xs ys hFK)

#print TrajectoryEquivalent
