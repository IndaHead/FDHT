# FDHT AF₀-DN: Duplicate-Noise Control

## Classification

A — DUPLICATE NOISE INERT TO ACTIVE FRONTIER AND CONSUMER OUTCOME

## Summary

Duplicate irrelevant information does not change consumer outcome, active-frontier size, or requirement discharge. A1 active count remains exactly 1 across all duplicate regimes. Zero live requests were issued.

## AF₀ baseline reproduction

| Treatment | Consumer match | Active count |
|---|---|---|
| A0 | YES | = source size |
| A1 | YES | = 1 |

## Duplicate families

| ID | Name |
|---|---|
| D0 | UNIQUE_NOISE_BASELINE |
| D1 | EXACT_DUPLICATE_OCCURRENCES |
| D2 | SAME_PAYLOAD_DISTINCT_IDENTITIES |
| D3 | SAME_PAYLOAD_SHARED_LINEAGE |
| D4 | MIXED_DUPLICATE_NOISE |

## Duplicate densities

0.00, 0.25, 0.50, 0.75, 0.90

## Placement schedule

P0 DUPLICATES_BEFORE_RELEVANT; P1 DUPLICATES_AFTER_RELEVANT; P2 DUPLICATES_SPLIT_AROUND_RELEVANT; P3 DUPLICATES_INTERLEAVED

## Results

| Metric | Value |
|---|---|
| Cells executed | 1400 |
| A1 active count | 1 (all cells) |
| Consumer match | YES (all cells) |
| False discharge | 0 |
| Semantic inflation | 0 |
| Authority inflation | 0 |

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Evidence-supported claim

Duplicate irrelevant information does not change consumer outcome or active-frontier size. A1 active count remains exactly 1 across all duplicate regimes. Inspection trajectory may vary with placement, but active frontier remains stable.

## Claims explicitly NOT established

- Permanent FDHT mathematics
- Asymptotic scaling
- Compute reduction
- Runtime improvement
- Memory improvement
- Optimal retrieval
- Independence detection
- Generic deduplication correctness

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
