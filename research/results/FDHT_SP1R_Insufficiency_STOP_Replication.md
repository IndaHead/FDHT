# FDHT SP₁-R: Insufficiency → STOP Replication

## Classification

A — CROSS-STRUCTURE STOP EFFECT REPLICATED

## Summary

Insufficiency-triggered STOP prevents false completion across all 6 structurally distinct consumer families. NO-STOP treatment produces false completions on all insufficient fixtures. Zero over-STOP on sufficient controls. Zero live requests were issued.

## Original W5 reproduction

| Treatment | Gate | Sufficiency |
|---|---|---|
| T1 | STOP | INSUFFICIENT |
| T3 | ADMIT | INSUFFICIENT |

## Treatment definitions

| ID | Name | Stop on insufficient |
|---|---|---|
| R-T0 | STOP_AUTHORITY | YES |
| R-T1 | NO_STOP_AUTHORITY | NO |

## Treatment SHA-256

e0aa86ae7bd58878546ee7b24610e102f354db48922396c5edda9a2f9814246b

## Consumer families

| ID | Name | Independence |
|---|---|---|
| R1 | MISSING_IDENTITY | STRUCTURALLY_DISTINCT |
| R2 | MISSING_NEGATIVE_HISTORY | STRUCTURALLY_DISTINCT |
| R3 | MISSING_PROVENANCE | STRUCTURALLY_DISTINCT |
| R4 | MISSING_TEMPORAL_DISTINCTION | STRUCTURALLY_DISTINCT |
| R5 | MISSING_RELATIONAL_DISTINCTION | STRUCTURALLY_DISTINCT |
| R6 | PARTIAL_REQUIREMENT_WITH_DISTRACTOR | STRUCTURALLY_DISTINCT |

## Consumer SHA-256

37f77de0851efa4d8403605bf704e5f3f61d3701e6829b6b0b7cdf5119db2c4a

## Results

| Metric | Count |
|---|---|
| Correct STOP | 6 |
| NO-STOP false completions | 6 |
| Over-STOP | 0 |
| Missed STOP | 0 |
| False sufficiency | 0 |

## Per-family replication

| Family | Classification |
|---|---|
| R1 | REPLICATED |
| R2 | REPLICATED |
| R3 | REPLICATED |
| R4 | REPLICATED |
| R5 | REPLICATED |
| R6 | REPLICATED |

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS
- Cells executed: 24

## Evidence-supported claim

Insufficiency-triggered STOP prevents false completion across all 6 structurally distinct consumer families. NO-STOP treatment produces false completions on all insufficient fixtures. Zero over-STOP on sufficient controls.

## Claims explicitly NOT established

- Universal STOP necessity
- Permanent FDHT pressure
- General AI safety
- Compute efficiency
- Promotion of SP₀ or AH₀

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
