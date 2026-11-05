import FDHT_Audit_ArbitraryCollision
open KernelExprContext

theorem empty_ne_identity :
    ([] : List KernelExprContext) ≠ [identityContext] := by
  intro h
  cases h

#check empty_ne_identity
