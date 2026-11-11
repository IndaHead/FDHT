/-
Frozen FDHT observation surface for DFT0.

Imports permanent FDHT read-only.
Does not add external consumer semantics.
-/

import FDHTTrajectoryAPI

namespace DFT0Observation

variable {Store : Sort u} {Location : Sort v}

/-- Frozen resolver for the probe. -/
def frozenResolve : KernelExpr → Store → Location :=
  fun _ _ => Classical.choice ⟨fun _ => Classical.choice ⟨⟩⟩

/-- Observation function: trajectory projection. -/
def O (xs : List KernelExprContext) : TrajectoryBoundary frozenResolve :=
  trajectoryProjection frozenResolve xs

/-- Observational equivalence. -/
def ObsEq (xs ys : List KernelExprContext) : Prop :=
  O xs = O ys

end DFT0Observation
