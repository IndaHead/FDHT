import ClassifierFactorisation
import FDHTTrajectoryAPI
import FDHTThreadFamilyFirstIso

/-!
SA0: Permanent-substrate absorption audit for consumer-relative sufficiency.

Probe-local only. Do not promote.
-/

namespace FDHT.Research.SA0

universe uX uQ uR

variable {X : Type uX}
variable {Q : Type uQ}
variable {R : Type uR}

/-- Probe-local generic sufficiency predicate. -/
def GenericSufficientFor (T : X → Q) (C : X → R) : Prop :=
  ∀ ⦃x y : X⦄, T x = T y → C x = C y

/-- Probe-local generic observable-loss predicate. -/
def GenericObservableLoss (T : X → Q) (C : X → R) : Prop :=
  ∃ x y, T x = T y ∧ C x ≠ C y

/-- T1: GenericSufficientFor T id ↔ Function.Injective T -/
theorem genericSufficientFor_id_iff_injective
    (T : X → Q) :
    GenericSufficientFor T id ↔ Function.Injective T := by
  constructor
  · intro h x y hEq
    exact h hEq
  · intro h x y hEq
    exact h hEq

/-- T2: GenericObservableLoss T₁ C → GenericObservableLoss (T₂ ∘ T₁) C -/
theorem genericObservableLoss_composition
    {Y : Type}
    (T₁ : X → Y)
    (T₂ : Y → Q)
    (C : X → R)
    (h : GenericObservableLoss T₁ C) :
    GenericObservableLoss (T₂ ∘ T₁) C := by
  obtain ⟨x, y, hT₁, hC⟩ := h
  refine ⟨x, y, ?_, hC⟩
  simp [Function.comp, hT₁]

/-- T3: GenericSufficientFor T C → Function.Injective P → GenericSufficientFor (P ∘ T) C -/
theorem genericSufficientFor_injective_composition
    {Y : Type}
    (T : X → Y)
    (P : Y → Q)
    (C : X → R)
    (hSuff : GenericSufficientFor T C)
    (hInj : Function.Injective P) :
    GenericSufficientFor (P ∘ T) C := by
  intro x y hEq
  have hT : T x = T y := hInj hEq
  exact hSuff hT

#print axioms genericSufficientFor_id_iff_injective
#print axioms genericObservableLoss_composition
#print axioms genericSufficientFor_injective_composition

end FDHT.Research.SA0
