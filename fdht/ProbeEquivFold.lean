import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

#check TrajectoryEquivalent resolve
#check FoldKernel resolve
#check trajectoryProjection_first_isomorphism resolve
