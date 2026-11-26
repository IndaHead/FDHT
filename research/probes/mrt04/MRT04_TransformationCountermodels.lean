/-
import MRT04_TransformationFateLaws
MRT-04: Transformation Fate Countermodels

Explicit finite countermodels for false converses.
Uses only Lean standard library.
-/

/-! ## CM1: Noninjective post-processing destroys sufficiency -/

def cm1_T : Nat → Nat := fun x => x
def cm1_U : Nat → Nat := fun _ => 0
def cm1_C : Nat → Nat := fun x => x

theorem cm1_sufficientFor_T :
    SufficientFor cm1_T cm1_C := by
  intro x₁ x₂ h
  exact h

theorem cm1_observableLoss_UT :
    ObservableLoss (cm1_U ∘ cm1_T) cm1_C := by
  refine ⟨0, 1, ?_, ?_⟩
  · rfl
  · decide

/-! ## CM2: Consumer post-processing converse fails -/

def cm2_T : Nat → Nat := fun _ => 0
def cm2_C : Nat → Nat := fun x => x
def cm2_D : Nat → Nat := fun _ => 0

theorem cm2_sufficientFor_DC :
    SufficientFor cm2_T (cm2_D ∘ cm2_C) := by
  intro x₁ x₂ _
  rfl

theorem cm2_observableLoss_C :
    ObservableLoss cm2_T cm2_C := by
  refine ⟨0, 1, ?_, ?_⟩
  · rfl
  · decide

/-! ## CM3: Same T sufficient for one consumer, insufficient for another -/

def cm3_T : Nat → Nat := fun _ => 0
def cm3_C1 : Nat → Nat := fun _ => 0
def cm3_C2 : Nat → Nat := fun x => x

theorem cm3_sufficientFor_C1 :
    SufficientFor cm3_T cm3_C1 := by
  intro x₁ x₂ _
  rfl

theorem cm3_observableLoss_C2 :
    ObservableLoss cm3_T cm3_C2 := by
  refine ⟨0, 1, ?_, ?_⟩
  · rfl
  · decide

/-! ## CM4: Constant consumer survives maximal collapse -/

def cm4_T : Nat → Nat := fun _ => 0
def cm4_C : Nat → Nat := fun _ => 0

theorem cm4_sufficientFor :
    SufficientFor cm4_T cm4_C := by
  intro x₁ x₂ _
  rfl

/-! ## CM5: Identity consumer detects every noninjective collapse -/

def cm5_T : Nat → Nat := fun _ => 0

theorem cm5_observableLoss :
    ObservableLoss cm5_T id := by
  refine ⟨0, 1, ?_, ?_⟩
  · rfl
  · decide

/-! ## CM6: Domain restriction can hide global insufficiency -/

def cm6_V : Nat → Nat := fun _ => 0
def cm6_T : Nat → Nat := fun _ => 0
def cm6_C : Nat → Nat := fun x => x

theorem cm6_sufficientFor_restricted :
    SufficientFor (cm6_T ∘ cm6_V) (cm6_C ∘ cm6_V) := by
  intro w₁ w₂ _
  rfl

theorem cm6_observableLoss_global :
    ObservableLoss cm6_T cm6_C := by
  refine ⟨0, 1, ?_, ?_⟩
  · rfl
  · decide

/-! ## CM7: Surjective domain precomposition restores converse -/

def cm7_V : Nat → Nat := fun x => x
def cm7_T : Nat → Nat := fun x => x
def cm7_C : Nat → Nat := fun x => x

theorem cm7_surjective :
    Surjective cm7_V := by
  intro x
  exact ⟨x, rfl⟩

theorem cm7_sufficientFor_restricted :
    SufficientFor (cm7_T ∘ cm7_V) (cm7_C ∘ cm7_V) := by
  intro w₁ w₂ h
  exact h

theorem cm7_sufficientFor_global :
    SufficientFor cm7_T cm7_C :=
  sufficientFor_domain_precompose_converse_of_surjective
    cm7_V cm7_T cm7_C cm7_surjective cm7_sufficientFor_restricted
