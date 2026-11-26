# FDHT AF₀-DN: Duplicate-Noise Robustness Control

## Classification

A — DUPLICATE NOISE INERT TO ACTIVE FRONTIER AND CONSUMER OUTCOME

## Summary

Duplicate consumer-irrelevant information does not change the frozen consumer outcome or the measured A1 active frontier. A1 active_occurrences remains exactly 1 across all tested families, densities and placements. Inspection trajectory remains position-sensitive. Zero live requests were issued.

## AF₀ baseline reproduction

PASS. A0 and A1 both produce the frozen consumer outcome. A1 active count = 1.

## Duplicate families

| ID | Name | Result |
|---|---|---|
| D0 | UNIQUE_NOISE_BASELINE | STABLE |
| D1 | EXACT_DUPLICATE_OCCURRENCES | STABLE |
| D2 | SAME_PAYLOAD_DISTINCT_IDENTITIES | STABLE |
| D3 | SAME_PAYLOAD_SHARED_LINEAGE | STABLE |
| D4 | MIXED_DUPLICATE_NOISE | STABLE |

## Density response

INERT. Changing density from 0.00 to 0.90 does not alter consumer result or A1 active count.

## Placement response

POSITION_SENSITIVE for inspection count. Active frontier remains stable under position matching.

## Expanded metrics

| Metric | A1 value |
|---|---|
| active_occurrences | 1 |
| active_unique_ids | 1 |
| active_unique_payloads | 1 |
| active_unique_lineages | 1 |
| consumer_match | true |
| false_discharge | 0 |
| semantic_inflation | 0 |
| gate_inflation | 0 |
| authority_inflation | 0 |

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS
- Cells executed: 1400

## Evidence-supported claim

Within the tested R1 identity consumer, source sizes, duplicate families, densities and placements, duplicate consumer-irrelevant information did not change the frozen consumer outcome or measured A1 active frontier. Inspection trajectory remains position-sensitive. Available ≠ Inspected ≠ Active.

## Claims explicitly NOT established

- Generic duplicate robustness
- Generic deduplication correctness
- Generic evidence independence
- Runtime improvement
- Memory improvement
- Compute reduction
- Asymptotic scaling
- Optimal retrieval
- Fractal scaling
- Permanent FDHT pressure
- New mathematics

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
