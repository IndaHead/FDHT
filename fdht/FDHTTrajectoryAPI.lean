import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Compatibility layer for the canonical first-isomorphism API.
    Derived only from the current compiled surface.
============================================================ -/

/-- The free monoid on raw kernel-expression histories. -/
def rawHistoryLocalMonoid : LocalMonoid (List KernelExprContext) where
  one := []
  mul := List.append
  one_mul := List.nil_append
  mul_one := List.append_nil
  mul_assoc := List.append_assoc

/-- Homomorphism of local monoids. -/
structure LocalMonoidHom
    (A B : Type)
    (MA : LocalMonoid A)
    (MB : LocalMonoid B) where

  toFun : A → B

  map_one :
    toFun MA.one = MB.one

  map_mul :
    ∀ x y,
      toFun (MA.mul x y)
      =
      MB.mul (toFun x) (toFun y)

/-- The quotient homomorphism induced by trajectory projection. -/
def trajectoryQuotientHom
    (resolve : KernelExpr → Store → Location) :
    LocalMonoidHom
      (List KernelExprContext)
      (TrajectoryBoundary resolve)
      rawHistoryLocalMonoid
      (trajectoryLocalMonoid resolve) where
  toFun := trajectoryProjection resolve
  map_one := trajectoryProjection_nil resolve
  map_mul := trajectoryProjection_append resolve

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
structure TrajectoryProjectionFirstIso
    (resolve : KernelExpr → Store → Location) where

  projection :
    LocalMonoidHom
      (List KernelExprContext)
      (TrajectoryBoundary resolve)
      rawHistoryLocalMonoid
      (trajectoryLocalMonoid resolve)

  surjective :
    Function.Surjective projection.toFun

  kernel_exact :
    ∀ xs ys,
      projection.toFun xs = projection.toFun ys
      ↔
      FoldKernel resolve xs ys

  quotientEquiv :
    LocalMonoidEquiv
      (FoldKernelQuotient resolve)
      (TrajectoryBoundary resolve)
      (foldKernelQuotientMonoid resolve)
      (trajectoryLocalMonoid resolve)

  representative_recovery :
    ∀ xs,
      quotientEquiv.equiv.toFun
        (Quotient.mk (FoldKernelSetoid resolve) xs)
      =
      projection.toFun xs

theorem foldKernelMonoidEquiv_recovers_projection
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    (FoldKernelQuotient_monoidEquiv_TrajectoryBoundary resolve).equiv.toFun
      (Quotient.mk (FoldKernelSetoid resolve) xs)
    =
    trajectoryProjection resolve xs := by
  unfold FoldKernelQuotient_monoidEquiv_TrajectoryBoundary
  unfold FoldKernelQuotient_equiv_TrajectoryBoundary
  unfold foldKernelToTrajectory
  rfl

def trajectoryProjectionFirstIso
    (resolve : KernelExpr → Store → Location) :
    TrajectoryProjectionFirstIso resolve where
  projection := trajectoryQuotientHom resolve
  surjective := trajectoryQuotientHom_surjective resolve
  kernel_exact := trajectoryQuotientHom_kernel_iff resolve
  quotientEquiv := FoldKernelQuotient_monoidEquiv_TrajectoryBoundary resolve
  representative_recovery := by
    intro xs
    exact foldKernelMonoidEquiv_recovers_projection resolve xs

theorem trajectoryProjection_first_isomorphism
    (resolve : KernelExpr → Store → Location) :
    let F := trajectoryProjectionFirstIso resolve
    Function.Surjective F.projection.toFun
    ∧
    (∀ xs ys : List KernelExprContext,
      F.projection.toFun xs =
        F.projection.toFun ys
      ↔
      FoldKernel resolve xs ys)
    ∧
    (∀ xs : List KernelExprContext,
      F.quotientEquiv.equiv.toFun
        (Quotient.mk (FoldKernelSetoid resolve) xs)
      =
      F.projection.toFun xs) := by
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
