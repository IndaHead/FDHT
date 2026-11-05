import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

theorem identity_plug_is_id
    (q : PersistentBoundary resolve) :
    plugPersistent resolve identityContext q = q := by
  induction q using Quotient.ind with
  | _ e =>
    simp [plugPersistent, identityContext, toPersistentBoundary]
    rfl

theorem empty_identity_equivalent :
    TrajectoryEquivalent resolve [] [identityContext] := by
  intro q
  simp [evolvePersistent]
  exact identity_plug_is_id resolve q

#check empty_identity_equivalent
