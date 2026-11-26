# FDHT VRRD₀: Microscopic Verified Radix Range Source-Inspection Probe

## Classification

A — MICROSCOPIC RADIX RANGE PRUNING OBSERVED

## Summary

Within one frozen 64-occurrence identity-set fixture using fixed depth-2 Radix prefix policy, deterministic candidate-range routing reduced concrete query source inspection relative to sequential A1 while preserving exact source verification. Zero live requests were issued.

## Primary metrics

| Metric | Value |
|---|---|
| Source count | 64 |
| Requirement | ac05 |
| Prefix | ac |
| Candidate count | 8 |
| Sigma | 0.125 |
| Range amplification | 8 |

## Inspection comparison

| Treatment | Source inspections |
|---|---|
| A0 | 48 |
| A1 | 48 (K=48) |
| VRRD | 6 |

## Semantic safety

| Treatment | Outcome | Active |
|---|---|---|
| A0 | ADMIT | ac05 |
| A1 | ADMIT | ac05 |
| VRRD | ADMIT | ac05 |
| Oracle | ADMIT | ac05 |

## Core result

VRRD query-source inspection (6) < A1 query-source inspection (48). Candidate range remains 8. Exact source verification occurs. Anti-exact-address firewall survives.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Repeated-query amortisation
- Build-cost benefit
- Full-validation benefit
- Runtime reduction
- Compute reduction
- Source-size scaling
- Requirement-size scaling
- Generic Radix benefit
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
