# FDHT A2₀-C: Address-Structure Accounting Correction

## Classification

C — SELECTIVE AMORTISED INSPECTION PRUNING

## Summary

A2 query inspection equals |R|, not universally 1. LATE placement reaches strict break-even for repeated queries. EARLY placement does not reach break-even. Zero live requests were issued.

## Prior claim dispositions

| Claim | Disposition |
|---|---|
| A2 query inspection is constant (1) | REDUCED to R=1 only |
| Single-query A2 equals A1 | RETAINED |
| A2 amortises over repeated queries | SELECTIVE (LATE only) |
| Break-even q>1 for late placement | RETAINED with exact q |

## Corrected findings

| R | A2_query | A2_build |
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

## Core result

A2 query inspection equals |R|. LATE placement amortises over repeated queries. EARLY placement does not.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Universal amortisation
- Runtime scaling
- Compute scaling
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
