# MRT/CRT Consumer Transformation Closure

## Classification

EXISTING SUFFICIENCY DISCIPLINE ABSORBS MRT/CRT

## Programme

MRT-01 → MRT-02 → MRT-03 → CRT-01

## Provenance

External Lean probes imported as research evidence.

### MRT-01 provenance caveat

| Item | Status |
|------|--------|
| Source status | RECONSTRUCTED FROM CONVERSATION HISTORY |
| Original artefact | UNAVAILABLE |
| Original SHA-256 | UNVERIFIABLE |
| Reconstructed SHA-256 | `2cafe8ac0ce14e32b3aa98882c3daa49308722f81885368b338cf7b2d6fc1364` |
| Lean compile | EXIT 0 |
| sorry | ABSENT |
| Mathematical content | Reproduces reported MRT-01 results |
| Byte-identical to original | NOT ESTABLISHED |

MRT-02, MRT-03, and CRT-01 source files were copied from their original probe locations.

## Source SHA-256

| Probe | SHA-256 |
|-------|---------|
| MRT01_probe.lean | `2cafe8ac0ce14e32b3aa98882c3daa49308722f81885368b338cf7b2d6fc1364` |
| MRT02_probe.lean | `59347220a467b114b423a31fabaf117defe59a79fd9dbb8938db2996fad578ee` |
| MRT03_probe.lean | `603edbab9fc9435a89e634564bc61e08ad1b519ab7760fda637eaf97400fc87c` |
| CRT01_probe.lean | `3514d6761edfe1bf9674a86dae0a71e904568e43736c88678edaf114a53687ee` |

## Results

### MRT-01

Three behaviours (Persist change, Recall requirement-sensitivity, Recall store-sensitivity) are distinguishable. Three primitive operations are not necessary. Arbitrary Persist admits trivial Memorise/Retain factorisation. Tagged encoding is possible.

### MRT-02

Persist/Recall are useful consumer-relative operational boundaries but not primitive necessities. Arbitrary Persist admits trivial Memorise/Retain factorisation. Tagged encoding is possible.

### MRT-03

Existing SufficientFor is load-bearing. Memory-specific structures disappear from the generic theorem surface. Consumer-distinction preservation is verified. Sufficiency is consumer-relative.

### CRT-01

Composition laws verified. Downstream sufficiency implies upstream sufficiency. Explicit ObservableLoss persists under common deterministic post-processing. SufficientFor T id ↔ Function.Injective T. Augmentation with additional source-derived information can restore distinctions unavailable from T alone. Recursively reusable law shape. Not a fractal theorem.

## Strong generic theorems

| Theorem | Status | Axioms |
|---------|--------|--------|
| downstream_sufficient_implies_upstream | VERIFIED | none |
| observableLoss_postprocess | VERIFIED | none |
| sufficient_identity_iff_injective | VERIFIED | none |

## Augmentation boundary

Pure post-processing cannot re-separate an explicit T-collision. Additional source-derived information changes the representation and may restore a required distinction.

## Authority classification

VERIFIED RESEARCH ONLY

## Permanent mathematics

UNCHANGED

## New abstraction

NONE

## Promotion

NOT JUSTIFIED

## Final classification

EXISTING SUFFICIENCY DISCIPLINE ABSORBS MRT/CRT

## STOP

No further MRT/CRT probe is justified absent new concrete consumer pressure or contradiction.

---

## CRT Factorisation Boundary

### Classification

FACTORISATION PERSISTENCE / RESTORATION BOUNDARY VERIFIED

### Provenance

| Item | Status |
|------|--------|
| Source status | FROZEN FROM VERIFIED PROBE |
| Probe path | `research/probes/crt/CRT_Factorisation_Persistence.lean` |
| SHA-256 | `58c42f56039d42f0c94ce44f17bd58ec87b3204ff81121ab752a0fa51629ac44` |
| Lean compile | EXIT 0 |
| sorry | ABSENT |
| sorryAx | ABSENT |
| Classical.choice | ABSENT |

### Results

#### Generic persistence under factorisation

**VERIFIED**

```lean
theorem observableLoss_of_factorsThrough
    (hFactor : FactorsThrough T U)
    (hLoss : ObservableLoss T C) :
    ObservableLoss U C
```

Axioms: none

#### Dual restoration/non-factorisation

**VERIFIED**

```lean
theorem restoration_implies_not_factorsThrough
    (hLoss : ObservableLoss T C)
    (hSuff : SufficientFor U C) :
    ¬ FactorsThrough T U
```

Axioms: none

#### Direct proof control

**VERIFIED**

```lean
theorem restoration_direct
    (hLoss : ObservableLoss T C)
    (hSuff : SufficientFor U C) :
    ¬ FactorsThrough T U
```

Axioms: none

Both derived and direct proofs are constructive and axiom-free.

### Minimal two-state boundary fixture

- `MicroX = {a, b}`
- `microT : MicroX → Unit` (maximal collapse)
- `microC` distinguishes a, b
- `microU` retains the distinction

Verified:
- `ObservableLoss microT microC`
- `SufficientFor microU microC`
- `¬ FactorsThrough microT microU`

### Factor-through control

- `microUfactor : MicroX → Unit` factors through `microT`
- Verified: `FactorsThrough microT microUfactor`, `ObservableLoss microUfactor microC`

### Stronger-claim attacks

| Claim | Result |
|-------|--------|
| A: ¬ FactorsThrough → SufficientFor | REFUTED |
| B: SufficientFor → ¬ FactorsThrough (without loss) | REFUTED |
| C: ObservableLoss → ¬ FactorsThrough (without sufficiency) | REFUTED |
| D: ¬ FactorsThrough → Injective | REFUTED |

Both hypotheses of the dual restoration theorem are load-bearing.

### Exact interpretation

If T collapses a distinction required by C, every U determined solely from T's output inherits that explicit consumer-relative loss.

If U is instead sufficient for the same C, U cannot be determined solely by T's output.

Mathematically:

```text
restoration of consumer sufficiency
    →
non-factorisation through the collapsed representation
```

### Claims explicitly NOT established

- Absolute information destruction
- Physical irreversibility
- Reconstruction of X
- Injectivity of U
- Universal information theory
- Existence of a particular side channel
- Existence of a particular augmentation architecture
- Fractal theorem

### Permanent status

| Item | Status |
|------|--------|
| Permanent FactorsThrough abstraction | NOT JUSTIFIED |
| Permanent augmentation abstraction | NOT JUSTIFIED |
| Permanent FDHT pressure | NONE |
| Promotion | NOT PERFORMED |

### STOP

This boundary is frozen as research evidence only.
