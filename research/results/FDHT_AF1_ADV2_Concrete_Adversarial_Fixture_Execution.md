# FDHT AF₁-ADV2: Concrete Adversarial Fixture Execution

## Classification

A — CONCRETE ADVERSARIAL RESULT REPLICATES

## Prior claim reduction

PRIOR AF₁-ADV CLAIM REDUCED:
LABELLED MATRIX EXECUTED;
CONCRETE ADVERSARIAL ROBUSTNESS NOT ESTABLISHED.

## Summary

Concrete adversarial fixtures replicate the baseline result. A1 consumer outcome matches independent oracle across all geometries, attacks, and shadows. Zero false ADMIT. Zero live requests were issued.

## Concrete matrix

| Dimension | Values |
|---|---|
| Source sizes | 64, 256 |
| Requirement sizes | 2, 4, 8 |
| Geometries | G0–G4 |
| Attacks | M0, M1, M50 |
| Shadows | DS0, DS1, DS3, DS4 |
| Treatments | A0, A1 |

## Results

| Metric | Value |
|---|---|
| Cells executed | 720 |
| A1 consumer match | YES |
| False ADMIT | 0 |
| Incorrect STOP | 0 |

## Oracle independence

Oracle uses only source and requirement. Does not use geometry, attack, or shadow labels.

## Treatment label-blindness

Treatments receive only source and requirement. Do not receive fixture metadata.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Evidence-supported claim

Within the tested concrete source sizes, requirement sizes, geometries, attacks and duplicate-shadow constructions, the frozen A1 treatment produced the measured results without label/oracle dependence. Zero false ADMIT. Zero near-match discharge. Zero duplicate substitution.

## Claims explicitly NOT established

- Generic requirement scaling
- Asymptotic scaling
- Complexity
- Compute reduction
- Runtime advantage
- Memory advantage
- Universal duplicate robustness
- Universal geometry invariance
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
