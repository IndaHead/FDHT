# FDHT AF₁-RS: Requirement-Scaling Cross-Pressure

## Classification

B — ACTIVE CAPACITY RESPONDS TO REQUIREMENT SIZE

## Summary

A1 active count responds to requirement size, not source size. A1 active count equals requirement size across all tested cells. Consumer outcome preserved. Runtime and memory measured. Zero live requests were issued.

## Two-axis matrix

|X| ∈ {32, 64, 128, 256, 512, 1024}
|R| ∈ {1, 2, 4, 8, 16}
R < X

## Results

| Treatment | Active count | Consumer match |
|---|---|---|
| A0 | = source size | YES |
| A1 | = requirement size | YES |

## A1 active capacity

|R| = 1 → active = 1
|R| = 2 → active = 2
|R| = 4 → active = 4
|R| = 8 → active = 8
|R| = 16 → active = 16

## Runtime sample (|X| = 256, |R| = 4)

| Treatment | Median runtime |
|---|---|
| A0 | 449 ns |
| A1 | 432 ns |
| Ratio A1/A0 | 0.962 |

## Memory sample (|X| = 256, |R| = 4)

| Treatment | Median peak |
|---|---|
| A0 | 576 bytes |
| A1 | 576 bytes |
| Ratio A1/A0 | 1.000 |

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS
- Cells executed: 300

## Evidence-supported claim

A1 active count responds to requirement size, not source size. A1 active count equals requirement size across all tested cells. Consumer outcome preserved. Runtime and memory measured but do not establish complexity claims.

## Claims explicitly NOT established

- Asymptotic scaling
- Time complexity
- Space complexity
- Compute reduction
- Generic requirement scaling
- Permanent FDHT pressure
- New mathematics

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
