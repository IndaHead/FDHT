import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

structure FoldCompatibleRotation (resolve : KernelExpr → Store → Location) where
  rotate : List KernelExprContext → List KernelExprContext
  compatible : ∀ xs ys, FoldKernel resolve xs ys → FoldKernel resolve (rotate xs) (rotate ys)

def descendedRotation (r : FoldCompatibleRotation resolve) :
    TrajectoryBoundary resolve → TrajectoryBoundary resolve :=
  Quotient.lift
    (s := trajectorySetoid resolve)
    (fun xs => trajectoryProjection resolve (r.rotate xs))
    (by
      intro xs ys hEq
      have hKernel : FoldKernel resolve xs ys :=
        (by
          unfold FoldKernel trajectoryProjection toTrajectoryBoundary
          exact Quotient.sound hEq)
      exact r.compatible xs ys hKernel)

example (r₁ r₂ : FoldCompatibleRotation resolve) (h : r₁.rotate = r₂.rotate) :
    ∀ q, descendedRotation resolve r₁ q = descendedRotation resolve r₂ q := by
  intro q
  induction q using Quotient.ind with
  | _ xs =>
    show trajectoryProjection resolve (r₁.rotate xs) = trajectoryProjection resolve (r₂.rotate xs)
    rw [h]
