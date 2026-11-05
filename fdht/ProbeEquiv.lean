import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

#check identityContext
#check TrajectoryEquivalent resolve [] [identityContext]
#check evolvePersistent resolve [] 
#check evolvePersistent resolve [identityContext]
