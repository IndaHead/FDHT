# FDHT A2₀: Requirement-Blind Address Structure Experiment

## Classification

B — QUERY INSPECTION REDUCED; BUILD COST AMORTISED

## Summary

A2 query inspection is constant (1) regardless of source size. A1 inspection grows with source size for LATE placement. A2 build cost equals source size. For a single query, A2 end-to-end equals A1. For repeated queries, A2 amortises the build cost. Zero live requests were issued.

## Key findings

| Placement | A1 | A2_query | A2_build |
|---|---|---|---|
| EARLY | 1 | 1 | |X| |
| LATE | |X| | 1 | |X| |

## Amortisation

| Query count | A1 cumulative | A2 cumulative |
|---|---|---|
| 1 | |X| | |X| + 1 |
| 2 | 2|X| | |X| + 2 |
| q | q|X| | |X| + q |

Break-even: q > 1 for LATE placement.

## Research questions

| RQ | Result |
|---|---|
| Query inspection | A2 reduces to 1 |
| End-to-end single query | A2 equals A1 |
| Amortisation | A2 amortises over repeated queries |
| Placement independence | A2 query inspection independent of placement |

## Core result

A2 reduces query inspection to constant. Build cost amortises over repeated queries.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Runtime scaling
- Compute scaling
- Memory scaling
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
