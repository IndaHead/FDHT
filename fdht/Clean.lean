import FDHT_Audit_ArbitraryCollision

open KernelExprContext

variable
    {Store : Sort u}
    {Location : Sort v}

example
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    (trajectoryQuotientHom resolve).toFun xs =
      (trajectoryQuotientHom resolve).toFun ys
    ↔
    FoldKernel resolve xs ys :=
  trajectoryQuotientHom_kernel_iff resolve xs ys
