# FDHT A2₁: Independent Replication of Addressed Inspection Pruning

## Classification

A — INDEPENDENT A2 REPLICATION PASSES

## Summary

An independently written implementation reproduces the corrected A2₀-C accounting and A2₀-S safety controls. A2 query inspection equals |R|. LATE placement reaches break-even. EARLY placement does not. Zero live requests were issued.

## Key findings

| R | A2_query | Build |
|---|---|---|
| 1 | 1 | |X| |
| 2 | 2 | |X| |
| 4 | 4 | |X| |
| 8 | 8 | |X| |
| 16 | 16 | |X| |

## Break-even

| Placement | Break-even rows |
|---|---|
| LATE | 149 |
| EARLY | 0 |

## Safety

| Attack | Result |
|---|---|
| MISSING_BUCKET | STOP_INDEX_INVALID (60) |

## Independence

- Sorted-tuple index (not defaultdict)
- Independent source generator
- Independent oracle
- Independent A1
- Independent validator
- No predecessor imports

## Core result

Independent replication confirms selective amortisation and fail-closed safety.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Generic structural pruning
- Runtime reduction
- Compute reduction
- Asymptotic complexity
- Permanent index promotion
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
