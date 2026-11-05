import FDHT_Audit_ArbitraryCollision
open KernelExprContext hiding
  trajectoryQuotientHom_surjective
  trajectoryQuotientHom_kernel_iff
  trajectoryProjection_first_isomorphism
  rawHistoryLocalMonoid
  trajectoryQuotientHom
  trajectoryProjectionFirstIso
  foldKernelMonoidEquiv_recovers_projection
  TrajectoryProjectionFirstIso
  LocalMonoidHom

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Compatibility layer for the canonical first-isomorphism API.
    Derived only from the current compiled surface.

    Authoritative implementations live in KernelExprContext
    (FDHT_Audit_ArbitraryCollision). This module provides
    root-level compatibility names that explicitly reference
    those implementations.
============================================================ -/

/-- The free monoid on raw kernel-expression histories. -/
abbrev rawHistoryLocalMonoid : LocalMonoid (List KernelExprContext) :=
  KernelExprContext.rawHistoryLocalMonoid

/-- Homomorphism of local monoids. -/
abbrev LocalMonoidHom := KernelExprContext.LocalMonoidHom

/-- The quotient homomorphism induced by trajectory projection. -/
abbrev trajectoryQuotientHom
    (resolve : KernelExpr → Store → Location) :=
  KernelExprContext.trajectoryQuotientHom resolve

theorem trajectoryQuotientHom_apply
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    (trajectoryQuotientHom resolve).toFun xs
    =
    trajectoryProjection resolve xs := rfl

theorem trajectoryQuotientHom_surjective
    (resolve : KernelExpr → Store → Location) :
    Function.Surjective
      (trajectoryQuotientHom resolve).toFun := by
  intro t
  exact trajectoryProjection_surjective resolve t

theorem trajectoryQuotientHom_kernel_iff
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    (trajectoryQuotientHom resolve).toFun xs
      =
    (trajectoryQuotientHom resolve).toFun ys
    ↔
    FoldKernel resolve xs ys := Iff.rfl

/-- Certificate packaging the first-isomorphism data. -/
abbrev TrajectoryProjectionFirstIso
    (resolve : KernelExpr → Store → Location) :=
  KernelExprContext.TrajectoryProjectionFirstIso resolve

abbrev trajectoryProjectionFirstIso
    (resolve : KernelExpr → Store → Location) :
    TrajectoryProjectionFirstIso resolve :=
  KernelExprContext.trajectoryProjectionFirstIso resolve

theorem foldKernelMonoidEquiv_recovers_projection
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    (FoldKernelQuotient_monoidEquiv_TrajectoryBoundary resolve).equiv.toFun
      (Quotient.mk (FoldKernelSetoid resolve) xs)
    =
    trajectoryProjection resolve xs := by
  exact KernelExprContext.foldKernelMonoidEquiv_recovers_projection resolve xs

theorem trajectoryProjection_first_isomorphism
    (resolve : KernelExpr → Store → Location) :
    let F := trajectoryProjectionFirstIso resolve
    Function.Surjective (KernelExprContext.TrajectoryProjectionFirstIso.projection F).toFun
    ∧
    (∀ xs ys : List KernelExprContext,
      (KernelExprContext.TrajectoryProjectionFirstIso.projection F).toFun xs =
        (KernelExprContext.TrajectoryProjectionFirstIso.projection F).toFun ys
      ↔
      FoldKernel resolve xs ys)
    ∧
    (∀ xs : List KernelExprContext,
      (KernelExprContext.TrajectoryProjectionFirstIso.quotientEquiv F).equiv.toFun
        (Quotient.mk (FoldKernelSetoid resolve) xs)
      =
      (KernelExprContext.TrajectoryProjectionFirstIso.projection F).toFun xs) := by
  dsimp only
  refine ⟨
    trajectoryQuotientHom_surjective resolve,
    ?_,
    ?_
  ⟩
  · intro xs ys
    exact trajectoryQuotientHom_kernel_iff resolve xs ys
  · intro xs
    exact foldKernelMonoidEquiv_recovers_projection resolve xs
