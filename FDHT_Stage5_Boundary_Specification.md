# FDHT Stage 5 Boundary Specification
## Reconstruction Semantics

### Status

STAGE 5 RECONSTRUCTION SEMANTICS VERIFIED FROM EXISTING SUBSTRATE

No new mathematical definitions or theorems were required.

---

## 1. Reconstruction lattice

The current FDHT substrate supports the following reconstruction boundary:

```text
Projected trajectory state
        │
        ├── Equivalence class
        │      PROVED
        │
        ├── Invariant observable
        │      PARTIALLY SUPPORTED
        │
        ├── Raw representative existence
        │      PROVED
        │
        ├── Selected representative
        │      NOT ENCODED
        │
        ├── Canonical representative
        │      NOT DEFINED
        │
        └── Exact original raw history
               GENERICALLY NON-RECOVERABLE
```

## 2. Supporting theorems

```text
raw_history_not_recoverable
collapsed_pair_blocks_common_reconstruction
trajectoryProjection_first_isomorphism
trajectoryProjection_surjective
familyClassifier_factors_iff_invariant
```

## 3. Distinctions preserved

- representative ≠ original history
- existence ≠ selection
- selected representative ≠ canonical representative
- quotient recovery ≠ raw recovery
- observable recovery ≠ full reconstruction
- non-recoverability ≠ deletion
- non-recoverability ≠ non-existence
- restricted-domain reconstruction ≠ global reconstruction
- external evidence ≠ information already present in projection

## 4. Trust surface

```text
raw_history_not_recoverable
  depends on axioms: [propext, Quot.sound]

collapsed_pair_blocks_common_reconstruction
  depends on axioms: [Quot.sound]

trajectoryProjection_first_isomorphism
  depends on axioms: [propext, Quot.sound]

trajectoryProjection_surjective
  depends on axioms: [Quot.sound]

familyClassifier_factors_iff_invariant
  depends on axioms: [Classical.choice, Quot.sound]
```

## 5. Governing rule

The reconstruction lattice is supported by the existing substrate. New reconstruction claims require new mathematics that identifies a concrete missing boundary.

Trust the maths.
