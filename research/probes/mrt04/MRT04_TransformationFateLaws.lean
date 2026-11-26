/-
MRT-04: Generic Transformation Fate Laws

Research probe only.
Does not modify fdht/.
Does not promote mathematics.
Uses only Lean standard library.
-/

universe u

variable {X Y Z W R R₁ R₂ S : Type u}

/-! ## Core definitions -/

def SufficientFor (T : X → Y) (C : X → R) : Prop :=
  ∀ x₁ x₂, T x₁ = T x₂ → C x₁ = C x₂

def ObservableLoss (T : X → Y) (C : X → R) : Prop :=
  ∃ x₁ x₂, T x₁ = T x₂ ∧ C x₁ ≠ C x₂

def KernelIncluded (T : X → Y) (C : X → R) : Prop :=
  ∀ x₁ x₂, T x₁ = T x₂ → C x₁ = C x₂

/-! ## TL1: Sufficiency excludes observable loss (constructive) -/

theorem sufficientFor_not_observableLoss
    (T : X → Y) (C : X → R) :
    SufficientFor T C → ¬ ObservableLoss T C := by
  intro hSuff ⟨x₁, x₂, hT, hC⟩
  exact hC (hSuff x₁ x₂ hT)

/-! ## TL2: No loss implies sufficiency (classical) -/

-- This direction requires classical reasoning.
-- The constructive direction (TL1) is already proved.
-- The reverse uses excluded middle.

open Classical in
theorem not_observableLoss_implies_sufficientFor
    (T : X → Y) (C : X → R) :
    ¬ ObservableLoss T C → SufficientFor T C := by
  intro hNoLoss x₁ x₂ hT
  by_cases hC : C x₁ = C x₂
  · exact hC
  · exact False.elim (hNoLoss ⟨x₁, x₂, hT, hC⟩)

theorem sufficientFor_iff_not_observableLoss
    (T : X → Y) (C : X → R) :
    SufficientFor T C ↔ ¬ ObservableLoss T C := by
  constructor
  · exact sufficientFor_not_observableLoss T C
  · exact not_observableLoss_implies_sufficientFor T C

/-! ## TL3: Kernel-inclusion equivalence (definitional) -/

theorem sufficientFor_iff_kernelIncluded
    (T : X → Y) (C : X → R) :
    SufficientFor T C ↔ KernelIncluded T C := by
  rfl

/-! ## TL4: Downstream sufficiency implies upstream (constructive) -/

theorem sufficientFor_comp_implies_upstream
    (T : X → Y) (U : Y → Z) (C : X → R) :
    SufficientFor (U ∘ T) C → SufficientFor T C := by
  intro h x₁ x₂ hT
  exact h x₁ x₂ (congrArg U hT)

/-! ## TL5: Observable loss persists under post-processing (constructive) -/

theorem observableLoss_persists_under_postprocessing
    (T : X → Y) (U : Y → Z) (C : X → R) :
    ObservableLoss T C → ObservableLoss (U ∘ T) C := by
  intro ⟨x₁, x₂, hT, hC⟩
  exact ⟨x₁, x₂, congrArg U hT, hC⟩

/-! ## TL6: Identity-consumer sufficiency iff injectivity (constructive) -/

def Injective (T : X → Y) : Prop :=
  ∀ x₁ x₂, T x₁ = T x₂ → x₁ = x₂

theorem sufficientFor_identity_iff_injective
    (T : X → Y) :
    SufficientFor T id ↔ Injective T := by
  rfl

/-! ## TL7: Identity transformation is sufficient (constructive) -/

theorem sufficientFor_identity_transform
    (C : X → R) :
    SufficientFor id C := by
  intro x₁ x₂ h
  exact congrArg C h

/-! ## TL8: Consumer post-processing weakens requirements (constructive) -/

theorem sufficientFor_consumer_postprocess
    (T : X → Y) (C : X → R) (D : R → S) :
    SufficientFor T C → SufficientFor T (D ∘ C) := by
  intro h x₁ x₂ hT
  exact congrArg D (h x₁ x₂ hT)

/-! ## TL9: Domain precomposition preserves sufficiency (constructive) -/

theorem sufficientFor_domain_precompose
    (V : W → X) (T : X → Y) (C : X → R) :
    SufficientFor T C → SufficientFor (T ∘ V) (C ∘ V) := by
  intro h w₁ w₂ hTV
  exact h (V w₁) (V w₂) hTV

def Surjective (V : W → X) : Prop :=
  ∀ x, ∃ w, V w = x

theorem sufficientFor_domain_precompose_converse_of_surjective
    (V : W → X) (T : X → Y) (C : X → R)
    (hSurj : Surjective V) :
    SufficientFor (T ∘ V) (C ∘ V) → SufficientFor T C := by
  intro h x₁ x₂ hT
  obtain ⟨w₁, hw₁⟩ := hSurj x₁
  obtain ⟨w₂, hw₂⟩ := hSurj x₂
  have hTV : T (V w₁) = T (V w₂) := by
    rw [hw₁, hw₂]; exact hT
  have hCV := h w₁ w₂ hTV
  rw [← hw₁, ← hw₂]; exact hCV

/-! ## TL10: Pair-consumer decomposition (constructive) -/

theorem sufficientFor_pair_iff
    (T : X → Y) (C₁ : X → R₁) (C₂ : X → R₂) :
    SufficientFor T (fun x => (C₁ x, C₂ x)) ↔
    SufficientFor T C₁ ∧ SufficientFor T C₂ := by
  constructor
  · intro h
    constructor
    · intro x₁ x₂ hT
      exact congrArg Prod.fst (h x₁ x₂ hT)
    · intro x₁ x₂ hT
      exact congrArg Prod.snd (h x₁ x₂ hT)
  · intro ⟨h₁, h₂⟩ x₁ x₂ hT
    exact Prod.ext (h₁ x₁ x₂ hT) (h₂ x₁ x₂ hT)

/-! ## TL11: Constant consumer (constructive) -/

theorem sufficientFor_constant_consumer
    (T : X → Y) (r₀ : R) :
    SufficientFor T (fun _ => r₀) := by
  intro x₁ x₂ _
  rfl

/-! ## TL12: Constant transformation characterisation (constructive) -/

theorem sufficientFor_constant_transform_iff
    (y₀ : Y) (C : X → R) :
    SufficientFor (fun _ => y₀) C ↔ ∀ x₁ x₂, C x₁ = C x₂ := by
  constructor
  · intro h x₁ x₂
    exact h x₁ x₂ rfl
  · intro h x₁ x₂ _
    exact h x₁ x₂

/-! ## TL13: Injective post-processing preserves sufficiency (constructive) -/

theorem sufficientFor_injective_postprocess_iff
    (T : X → Y) (U : Y → Z) (C : X → R)
    (hU : Injective U) :
    SufficientFor (U ∘ T) C ↔ SufficientFor T C := by
  constructor
  · exact sufficientFor_comp_implies_upstream T U C
  · intro h x₁ x₂ hUT
    exact h x₁ x₂ (hU _ _ hUT)

/-! ## TL15: Collision propagation chain (constructive) -/

theorem observableLoss_chain
    (T : X → Y) (U : Y → Z) (V : Z → W) (C : X → R) :
    ObservableLoss T C → ObservableLoss (V ∘ U ∘ T) C := by
  intro h
  exact observableLoss_persists_under_postprocessing (U ∘ T) V C
    (observableLoss_persists_under_postprocessing T U C h)

theorem sufficientFor_chain_implies_upstream
    (T : X → Y) (U : Y → Z) (V : Z → W) (C : X → R) :
    SufficientFor (V ∘ U ∘ T) C → SufficientFor T C := by
  intro h
  exact sufficientFor_comp_implies_upstream T (V ∘ U) C h

/-! ## TL16: Factorisation implies sufficiency (constructive) -/

theorem factorisation_implies_sufficientFor
    (T : X → Y) (C : X → R) (Ĉ : Y → R)
    (hFactor : C = Ĉ ∘ T) :
    SufficientFor T C := by
  rw [hFactor]
  intro x₁ x₂ hT
  exact congrArg Ĉ hT

/-! ## Axiom audit -/

#print axioms sufficientFor_not_observableLoss
#print axioms not_observableLoss_implies_sufficientFor
#print axioms sufficientFor_iff_kernelIncluded
#print axioms sufficientFor_comp_implies_upstream
#print axioms observableLoss_persists_under_postprocessing
#print axioms sufficientFor_identity_iff_injective
#print axioms sufficientFor_identity_transform
#print axioms sufficientFor_consumer_postprocess
#print axioms sufficientFor_domain_precompose
#print axioms sufficientFor_pair_iff
#print axioms sufficientFor_constant_consumer
#print axioms sufficientFor_constant_transform_iff
#print axioms sufficientFor_injective_postprocess_iff
#print axioms factorisation_implies_sufficientFor

/-! ## Countermodels -/

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
