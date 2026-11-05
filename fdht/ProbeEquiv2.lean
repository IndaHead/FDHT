import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

theorem empty_identity_equivalent :
    TrajectoryEquivalent resolve [] [identityContext] := by
  intro q
  simp [evolvePersistent, identityContext, plugPersistent]
  rfl

#check empty_identity_equivalent
