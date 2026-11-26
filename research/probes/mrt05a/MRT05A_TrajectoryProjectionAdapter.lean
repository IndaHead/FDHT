/-
MRT-05A: Trajectory-Projection Domain Adapter

Research probe only.
Does not modify fdht/.
Does not promote MRT-04 definitions.
-/

import FDHT_Audit_ArbitraryCollision
import MRT04_TransformationFateLaws

open KernelExprContext

/-! ## Frozen adapter -/

abbrev RawHistory := List KernelExprContext

/-- Transparent wrapper. Definitionally equal to trajectoryProjection. -/
abbrev trajectoryT
    (resolve : KernelExpr → Store → Location) :
    RawHistory → TrajectoryBoundary resolve :=
  trajectoryProjection resolve

/-! ## C0: Projected-state control (positive) -/

def projectedConsumer
    (resolve : KernelExpr → Store → Location) :
    RawHistory → TrajectoryBoundary resolve :=
  trajectoryProjection resolve

theorem c0_projected_sufficientFor
    (resolve : KernelExpr → Store → Location) :
    SufficientFor (trajectoryT resolve) (projectedConsumer resolve) := by
  intro x₁ x₂ h
  exact h

/-! ## C1: Factorised boundary consumer (positive) -/

def factorisedBoundaryConsumer
    {R : Type}
    (resolve : KernelExpr → Store → Location)
    (D : TrajectoryBoundary resolve → R) :
    RawHistory → R :=
  D ∘ trajectoryT resolve

theorem c1_factorised_sufficientFor
    {R : Type}
    (resolve : KernelExpr → Store → Location)
    (D : TrajectoryBoundary resolve → R) :
    SufficientFor (trajectoryT resolve) (factorisedBoundaryConsumer resolve D) := by
  intro x₁ x₂ h
  exact congrArg D h

/-! ## C2: Raw-identity consumer (negative) -/

def rawIdentityConsumer : RawHistory → RawHistory := id

theorem c2_rawDistinct :
    ([] : RawHistory) ≠ [identityContext] := by
  intro h
  cases h

theorem c2_projectedEqual
    (resolve : KernelExpr → Store → Location) :
    trajectoryProjection resolve ([] : RawHistory) =
    trajectoryProjection resolve [identityContext] := by
  rw [trajectoryProjection_nil]
  exact (identity_singleton_equals_empty_trajectory resolve).symm

theorem c2_observableLoss_identity
    (resolve : KernelExpr → Store → Location) :
    ObservableLoss (trajectoryT resolve) rawIdentityConsumer := by
  refine ⟨[], [identityContext], ?_, ?_⟩
  · exact c2_projectedEqual resolve
  · exact c2_rawDistinct

theorem c2_not_sufficientFor_identity
    (resolve : KernelExpr → Store → Location) :
    ¬ SufficientFor (trajectoryT resolve) rawIdentityConsumer := by
  intro hSuff
  exact c2_rawDistinct (hSuff [] [identityContext] (c2_projectedEqual resolve))

theorem c2_not_injective
    (resolve : KernelExpr → Store → Location) :
    ¬ Injective (trajectoryT resolve) := by
  intro hInj
  exact c2_rawDistinct (hInj [] [identityContext] (c2_projectedEqual resolve))

/-! ## C4: Pair consumer -/

theorem c4_pair_decomposition
    {R₁ R₂ : Type}
    (resolve : KernelExpr → Store → Location)
    (C₁ : RawHistory → R₁)
    (C₂ : RawHistory → R₂) :
    SufficientFor (trajectoryT resolve) (fun x => (C₁ x, C₂ x)) ↔
    SufficientFor (trajectoryT resolve) C₁ ∧
    SufficientFor (trajectoryT resolve) C₂ :=
  sufficientFor_pair_iff _ _ _

theorem c4_pair_insufficient
    (resolve : KernelExpr → Store → Location) :
    ¬ SufficientFor (trajectoryT resolve)
      (fun x => (projectedConsumer resolve x, rawIdentityConsumer x)) := by
  intro h
  have ⟨_, hId⟩ := (c4_pair_decomposition resolve _ _).mp h
  exact c2_not_sufficientFor_identity resolve hId

/-! ## Kernel adapter -/

theorem foldKernel_iff_trajectoryT
    (resolve : KernelExpr → Store → Location)
    (xs ys : RawHistory) :
    FoldKernel resolve xs ys ↔ trajectoryT resolve xs = trajectoryT resolve ys := by
  rfl

/-! ## Axiom audit -/

#print axioms c0_projected_sufficientFor
#print axioms c1_factorised_sufficientFor
#print axioms c2_observableLoss_identity
#print axioms c2_not_sufficientFor_identity
#print axioms c2_not_injective
#print axioms c4_pair_decomposition
#print axioms foldKernel_iff_trajectoryT
