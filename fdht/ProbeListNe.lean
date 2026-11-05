import FDHT_Audit_ArbitraryCollision
open KernelExprContext

theorem empty_ne_identity :
    ([] : List KernelExprContext) ≠ [identityContext] := by
  intro h
  injection h with hHead hTail
  cases hHead

#check empty_ne_identity
