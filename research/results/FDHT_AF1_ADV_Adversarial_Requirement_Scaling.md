# FDHT AF₁-ADV: Full Adversarial Requirement-Scaling Matrix

## Classification

A — BASELINE SURVIVES ADVERSARIAL ATTACKS

## Summary

The AF₁-RS baseline survives adversarial attacks. A1 consumer outcome matches expected outcome across all geometries, partial-requirement attacks, and duplicate-shadow regimes. Zero live requests were issued.

## Adversarial matrix

| Dimension | Values |
|---|---|
| Source sizes | 32, 64, 128, 256, 512, 1024 |
| Requirement sizes | 1, 2, 4, 8, 16 |
| Geometries | G0–G4 |
| Attacks | M0, M1, M25, M50 |
| Shadows | DS0–DS4 |
| Treatments | A0, A1 |

## Results

| Attack | Cells | Consumer match |
|---|---|---|
| M0 NONE_MISSING | 750 | YES |
| M1 ONE_MISSING | 750 | YES |
| M25 TWENTY_FIVE_PERCENT_MISSING | 750 | YES |
| M50 FIFTY_PERCENT_MISSING | 750 | YES |

## Partial-requirement safety

M1, M25, M50 correctly produce STOP_INSUFFICIENT. No false ADMIT.

## Duplicate-shadow safety

DS0–DS4 do not alter consumer outcome. Multiplicity does not substitute for missing requirements.

## Geometry sensitivity

G0–G4 do not alter consumer outcome. Active frontier remains stable.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS
- Cells executed: 6000

## Evidence-supported claim

The AF₁-RS baseline survives adversarial attacks. A1 consumer outcome matches expected outcome across all geometries, partial-requirement attacks, and duplicate-shadow regimes. Active capacity continues to track requirement size for sufficient fixtures.

## Claims explicitly NOT established

- Generic requirement scaling
- Asymptotic scaling
- Runtime complexity
- Space complexity
- Compute reduction
- Permanent FDHT pressure
- New mathematics

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
