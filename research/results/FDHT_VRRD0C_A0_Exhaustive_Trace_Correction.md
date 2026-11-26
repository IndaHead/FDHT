# FDHT VRRD₀-C: A0 Exhaustive-Trace Correction

## Classification

A — A0 EXHAUSTIVE TRACE CORRECTED; MICROSCOPIC RADIX QUERY-PRUNING CLAIM RETAINED

## Summary

The original A0 implementation had early-stop behaviour. Corrected A0 now exhausts all 64 source occurrences. A1 and VRRD independently reproduce. Query-pruning claim retained. Zero live requests were issued.

## A0 correction

| Metric | Original | Corrected |
|---|---|---|
| A0 inspections | 48 | 64 |
| Defect cause | A0_RUNNER_EARLY_STOP | — |

## Reproduction

| Treatment | Inspections | Outcome |
|---|---|---|
| A0 | 64 | ADMIT |
| A1 | 48 (K=48) | ADMIT |
| VRRD | 6 | ADMIT |
| Oracle | — | ADMIT |

## Accounting

| Metric | Value |
|---|---|
| VRRD build | 64 |
| VRRD full validation | 64 |
| VRRD query | 6 |
| VRRD build-plus-query | 70 |
| VRRD full-validation e2e | 134 |

## Claim dispositions

| Claim | Disposition |
|---|---|
| Original A0=48 | REFUTED |
| A1=48 | RETAIN |
| VRRD=6 | RETAIN |
| Microscopic query-pruning | RETAIN |
| Single-query e2e benefit | NOT_ESTABLISHED |

## Core result

Corrected A0 inspects all 64 source occurrences. A1 and VRRD independently reproduce. Query-pruning claim retained.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Single-query end-to-end benefit
- Repeated-query amortisation
- Radix scaling
- Runtime reduction
- Compute reduction
- Generic structural pruning
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
