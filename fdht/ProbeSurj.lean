import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

#check trajectoryProjection_surjective
#check trajectoryQuotientHom_surjective
