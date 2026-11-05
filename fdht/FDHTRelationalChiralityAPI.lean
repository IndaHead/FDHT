import AggregateFamilyTransform

/-!
# FDHT Relational Aggregate Chirality API

Thin public facade. All mathematics is defined in AggregateFamilyTransform
and its imports. This module re-exports the relational chirality surface
and adds one headline conjunction theorem by reuse only.

Semantic firewall:
  ChiralityValue.separated means only ¬ RawAllEqual.
  ChiralityValue.aligned   means only RawAllEqual.
  These do not mean left/right, clockwise, spin, helicity, or physical handedness.

Constructive firewall:
  ChiralityValue has DecidableEq.
  No total ThreadFamily → ChiralityValue function is provided,
  because RawAllEqual is not constructively decidable.
-/

open KernelExprContext

-- Structural API
#check RelationalClassifier
#check RawAllEqual
#check rawAllEqualClassifier
#check AggregateFamilyTransform
#check AggregateTransformRespectsKernel
#check FoldCompatibleAggregateTransform
#check IsIndexedComponentwise
#check IsReindexedComponentwise
#check IsRelationallyAggregate
#check neighbourComposeTransform
#check neighbourComposeAggregate
#check neighbourComposeTransform_respects_kernel
#check neighbourComposeTransform_contextSensitive
#check neighbourComposeTransform_not_indexed
#check neighbourComposeTransform_isRelationallyAggregate

-- Folded-trivial witness API
#check NeighbourComposeFoldedTrivialAt
#check neighbourCompose_familyUnequal_foldedTrivial
#check neighbourCompose_familyUnequal_rawlyNontrivial
#check neighbourCompose_nontrivialFoldedTrivial_witness
#check RelationallyAggregateFoldedTrivialClassifierWitness
#check RelationalAggregateChiralitySpecification
#check RelationalAggregateChiralitySpecificationExists
#check RelationalAggregateChiralitySpecificationExists_n2

-- Concrete value API
#check ChiralityValue
#check ChiralityValueDescribes
#check ChiralityTransition
#check FoldedTrivialChiralityTransition
#check RelationalAggregateChiralityTransition
#check ChiralityValueAlongOrbit
#check separated_ne_aligned
#check chiralityValueDescribes_exclusive
#check familyUnequal_chiralityValue_separated_n2
#check neighbourCompose_familyUnequal_chiralityValue_aligned_n2
#check neighbourCompose_chiralityTransition_n2
#check neighbourCompose_foldedTrivial_chiralityTransition_n2
#check neighbourCompose_relationalAggregate_chiralityTransition_n2
#check chiralityValue_changes_at_same_folded_position_n2
#check familyUnequal_chiralityValue_orbit_n2
#check familyUnequal_chiralityValue_stable_after_first_n2
#check relationalAggregateSpecification_has_concrete_value_transition_n2

-- Hidden dynamic orbit compatibility
#check familyUnequal_hidden_dynamic_split_n2
#check HiddenDynamicOrbit

/-! Headline conjunction. Reuses existing theorems only. -/

theorem relational_chirality_transition_at_stationary_fold_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    IsRelationallyAggregate resolve
      (neighbourComposeTransform resolve h)
    ∧
    ThreadFamilyKernel resolve
      (neighbourComposeTransform resolve h
        (familyUnequal resolve 2 h))
      (familyUnequal resolve 2 h)
    ∧
    ChiralityValueDescribes resolve
      (familyUnequal resolve 2 h)
      .separated
    ∧
    ChiralityValueDescribes resolve
      (neighbourComposeTransform resolve h
        (familyUnequal resolve 2 h))
      .aligned := by
  refine ⟨
    neighbourComposeTransform_isRelationallyAggregate resolve 2 h,
    ?_,
    familyUnequal_chiralityValue_separated_n2 resolve h,
    neighbourCompose_familyUnequal_chiralityValue_aligned_n2 resolve h
  ⟩
  have hK := familyUnequal_iter_kernel_stable resolve h 1
  rw [iteratedNeighbourCompose_succ, iteratedNeighbourCompose_zero] at hK
  exact hK
