# FDHT AF₀: Active-Frontier Scaling Baseline

## Classification

B — BOUNDED ACTIVE-FRONTIER REDUCTION OBSERVED

## Summary

A1 (requirement-conditioned) preserves consumer outcome while activating a smaller fraction of total available information as source size grows. A0 (exhaustive) activates all records. A2 (structure-aware) is NOT JUSTIFIED. Zero live requests were issued.

## Frozen consumer

| Field | Value |
|---|---|
| ID | R1 |
| Name | MISSING_IDENTITY |
| Provenance | SP1-R frozen consumer |
| SHA-256 | f2ebb76ec4c3bddb466d8be3cf1abacdee60fcbb4774c7c49c2fe171a56760dd |

## Frozen requirement

| Field | Value |
|---|---|
| Required | entity_identity |
| Expected | ADMIT |
| SHA-256 | 77764b75679545ca331b2eee6c7487264ffda63c32ad6e1bedee58e439765587 |

## Scaling staircase

|X₁| = 16, |X₂| = 32, |X₃| = 64, |X₄| = 128, |X₅| = 256, |X₆| = 512, |X₇| = 1024

## Treatment definitions

| ID | Name | Description |
|---|---|---|
| A0 | EXHAUSTIVE | Inspect every record |
| A1 | REQUIREMENT_CONDITIONED | Stop when requirement satisfied |
| A2 | STRUCTURE_AWARE | NOT JUSTIFIED |

## Results

| Treatment | Consumer match | Active count | α_C trend |
|---|---|---|---|
| A0 | YES | = source size | STABLE (1.0) |
| A1 | YES | = 1 | DECREASING |
| A2 | N/A | N/A | NOT JUSTIFIED |

## A1 α_C measurements

| Source size | α_C |
|---|---|
| 16 | 0.0625 |
| 32 | 0.0313 |
| 64 | 0.0156 |
| 128 | 0.0078 |
| 256 | 0.0039 |
| 512 | 0.0020 |
| 1024 | 0.0010 |

## Absolute active count

A1 active count = 1 (constant across all tested sizes)

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS
- Cells executed: 42

## Evidence-supported claim

A1 preserves consumer outcome while activating a smaller fraction of total available information as source size grows. Absolute active count remains constant. A2 is NOT JUSTIFIED. This is bounded measurement, not a theorem.

## Claims explicitly NOT established

- Asymptotic complexity
- Compute reduction
- Optimal retrieval
- Fractal scaling
- Permanent FDHT mathematics
- Promotion of any mathematics

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
