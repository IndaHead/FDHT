# FDHT MRT-05B-PD3: Lean 4.35.0 vs 4.36.0 Identical-Proof Comparison

## Classification

B — IDENTICAL FROZEN PROOF FAILS IDENTICALLY ON BOTH TOOLCHAINS

## Summary

The frozen MRT-05B proof artefact fails direct compilation under both Lean 4.35.0 and Lean 4.36.0 with identical errors. The 4.35-specific blocker hypothesis is weakened. Zero live requests were issued.

## Source identity

| Check | Result |
|---|---|
| SHA before | 6fbae4e85af92cc301be8f47a56a865caf12a265b10b27cc33b28678bf5ab174 |
| SHA after 4.35 | 6fbae4e85af92cc301be8f47a56a865caf12a265b10b27cc33b28678bf5ab174 |
| SHA after 4.36 | 6fbae4e85af92cc301be8f47a56a865caf12a265b10b27cc33b28678bf5ab174 |
| Identity preserved | YES |

## Compilation results

| Toolchain | Exit | Error count | First error |
|---|---|---|---|
| 4.35.0 | 1 | 12 | unsolved goals at 57:15 |
| 4.36.0 | 1 | 12 | unsolved goals at 57:15 |

## Theorem comparison

| Theorem | 4.35 | 4.36 |
|---|---|---|
| c0_membership_structural | FAILED | FAILED |
| c1_multiplicity_structural | FAILED | FAILED |
| c4_verified_structural | FAILED | FAILED |
| c5_verified_completeRecord_structural | FAILED | FAILED |
| c2_observableLoss_completeRecord | COMPILED | COMPILED |
| c3_observableLoss_provenance | COMPILED | COMPILED |

## Differential classification

D2 — NO_TOOLCHAIN_RELIEF_IDENTICAL_FAILURE

The frozen proof failure reproduces under both Lean 4.35.0 and Lean 4.36.0.

## Claims explicitly NOT established

- 4.35-specific blocker
- Toolchain migration justified
- Permanent FDHT pressure
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

PROOF CONSTRUCTION REPAIR REQUIRED
