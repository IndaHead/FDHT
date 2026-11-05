# FDHT Stage 7 Boundary Specification
## Provenance Sufficiency

### Status

STAGE 7 PROVENANCE SUFFICIENCY PARTIALLY CHARACTERISED

No new mathematical definitions or theorems were required.

---

## 1. Provenance-sufficiency lattice

```text
Observable-level provenance sufficiency    PARTIAL
Explicit-parameter dependence              PROVED
Existential/selection dependence           PARTIAL
Provenance insufficiency                   PROVED
Exact raw-history recovery                 NO
InformationFate                            NOT REQUIRED
```

## 2. Supporting theorems

```text
trajectoryProjection resolve xs
  : TrajectoryBoundary resolve
  dependency: resolve, xs

FoldKernel resolve xs ys
  : Prop
  role: equivalence class

distinguishingResolve
  : KernelExpr → Unit → KernelExpr

trajectoryProjection_first_isomorphism
  : projection determines FoldKernel class

trajectoryProjection_surjective
  : ∀ t, ∃ xs, π(xs) = t

familyClassifier_factors_iff_invariant
  : FamilyClassifierFactorsThroughProjections C
    ↔ FamilyClassifierInvariant C

raw_history_not_recoverable
  : ¬RawHistoryRecoverable resolve

collapsed_pair_blocks_common_reconstruction
  : xs ≠ ys → π(xs) = π(ys) →
    ¬∃ recover, recover(π(xs)) = xs ∧ recover(π(ys)) = ys
```

## 3. Distinctions preserved

- provenance ≠ raw identity
- sufficiency ≠ exact reconstruction
- insufficiency ≠ deletion
- insufficiency ≠ non-existence
- external dependency ≠ information creation
- selection ≠ recovery
- collision ≠ destruction
- NOT REQUIRED ≠ FALSE
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

The substrate characterises observable-level provenance sufficiency through
factorisation and witnesses provenance insufficiency through collision.
Exact raw recovery is generically non-recoverable. No ontology of
information fate is required.

Trust the maths.
