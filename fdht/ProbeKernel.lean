import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

#check trajectoryQuotientHom_kernel_iff
#check FoldKernelQuotient_monoidEquiv_TrajectoryBoundary
