# FDHT Stage 6 Boundary Specification
## Information-Addition Boundary

### Status

STAGE 6 INFORMATION-ADDITION SEMANTICS NOT YET MATHEMATICALLY DEFINED

The existing substrate distinguishes dependency sources without defining
genuine information addition.

---

## 1. Dependency lattice

```text
Derived structure                 ESTABLISHED
External-parameter dependence     ESTABLISHED
Selected-witness dependence       PARTIAL
Non-derivability                  ESTABLISHED
Genuine information addition      NOT DEFINED
Spontaneous information creation  NOT PROVED
```

## 2. Supporting theorems

```text
trajectoryProjection resolve xs
  : TrajectoryBoundary resolve
  dependency: resolve, xs

trajectoryProjection_first_isomorphism
  : projection determines FoldKernel class

raw_history_not_recoverable
  : ¬RawHistoryRecoverable resolve

collapsed_pair_blocks_common_reconstruction
  : xs ≠ ys → π(xs) = π(ys) →
    ¬∃ recover, recover(π(xs)) = xs ∧ recover(π(ys)) = ys

familyClassifier_factors_iff_invariant
  : FamilyClassifierFactorsThroughProjections C
    ↔ FamilyClassifierInvariant C

distinguishingResolve
  : KernelExpr → Unit → KernelExpr
```

## 3. Distinctions preserved

- new structure ≠ new information
- external dependence ≠ spontaneous creation
- selection ≠ reconstruction
- selected witness ≠ source information
- non-derivability ≠ information destruction
- non-derivability ≠ spontaneous information creation
- NOT DEFINED ≠ FALSE
- UNPROVED ≠ REFUTED

## 4. Trust surface

```text
raw_history_not_recoverable
  depends on axioms: [propext, Quot.sound]

collapsed_pair_blocks_common_reconstruction
  depends on axioms: [Quot.sound]

trajectoryProjection_first_isomorphism
  depends on axioms: [propext, Quot.sound]

familyClassifier_factors_iff_invariant
  depends on axioms: [Classical.choice, Quot.sound]
```

## 5. Governing rule

FDHT currently has sufficient mathematics to distinguish dependency
sources without requiring an ontology of "added information".

New claims about information addition require new mathematics that
defines the concept.

Trust the maths.
