# FDHT Stage 8 Boundary Specification
## Admissible Inference

### Status

STAGE 8 ADMISSIBLE-INFERENCE BOUNDARY PARTIALLY CHARACTERISED

No new mathematical definitions or theorems were required.

---

## 1. Inference lattice

```text
DERIVABLE FROM AVAILABLE STATE          PARTIAL
NOT DETERMINED BY AVAILABLE STATE       PROVED
UNDERDETERMINED                         PROVED
PARAMETER-DEPENDENT                     PROVED
REPRESENTATIVE-DEPENDENT                PARTIAL
CONTRADICTED / INCONSISTENT             NOT ENCODED
```

## 2. Supporting theorems

```text
familyClassifier_factors_iff_invariant
  : FamilyClassifierFactorsThroughProjections C
    ↔ FamilyClassifierInvariant C

raw_history_not_recoverable
  : ¬RawHistoryRecoverable resolve

collapsed_pair_blocks_common_reconstruction
  : xs ≠ ys → π(xs) = π(ys) →
    ¬∃ recover, recover(π(xs)) = xs ∧ recover(π(ys)) = ys

trajectoryProjection_first_isomorphism
  : projection determines FoldKernel class

distinguishingResolve
  : KernelExpr → Unit → KernelExpr
```

## 3. Distinctions preserved

- not derivable ≠ false
- unknown ≠ false
- underdetermined ≠ contradictory
- contradiction ≠ inequality
- parameter dependence ≠ arbitrariness
- representative selection ≠ recovery
- collision ≠ deletion
- insufficiency ≠ destruction
- NOT ENCODED ≠ FALSE
- UNPROVED ≠ REFUTED

## 4. Trust surface

```text
familyClassifier_factors_iff_invariant
  depends on axioms: [Classical.choice, Quot.sound]

raw_history_not_recoverable
  depends on axioms: [propext, Quot.sound]

collapsed_pair_blocks_common_reconstruction
  depends on axioms: [Quot.sound]

trajectoryProjection_first_isomorphism
  depends on axioms: [propext, Quot.sound]
```

## 5. Governing rule

The substrate partially characterises admissible inference through
factorisation, non-derivability, underdetermination, and parameter
dependence. No reasoning ontology is required.

Trust the maths.
