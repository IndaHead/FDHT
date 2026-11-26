# AH₀-R5: Operation-Dependent Proposal Completeness

## Classification

B — PROMPT-CONTRACT DEFICIENCY ESTABLISHED AND MINIMALLY REPAIRED

## Summary

The admission gate requires `target_record_id` for INSPECT_RECORD and `proposed_status` for DECLARE_STATUS. Other operations have no proposal-field requirement beyond the parser-level justification and expected_information_gain. The pre-R5 prompt listed allowed operations but did not state per-operation required fields. R5 established this as PROMPT-CONTRACT PRESSURE and implemented a minimal repair that injects the operation-specific requirements into the generated prompt. Zero live requests were issued.

## Field-requirement matrix

| Operation | target_record_id | target_obligation_id | proposed_status | justification | expected_information_gain |
|---|---|---|---|---|---|
| QUERY_INDEX | IRRELEVANT | IRRELEVANT | IRRELEVANT | REQUIRED (parser) | REQUIRED (parser) |
| INSPECT_RECORD | REQUIRED | IRRELEVANT | IRRELEVANT | REQUIRED (parser) | REQUIRED (parser) |
| SUBMIT_EVIDENCE | IRRELEVANT | IRRELEVANT | IRRELEVANT | REQUIRED (parser) | REQUIRED (parser) |
| DECLARE_STATUS | IRRELEVANT | IRRELEVANT | REQUIRED | REQUIRED (parser) | REQUIRED (parser) |
| STOP | IRRELEVANT | IRRELEVANT | IRRELEVANT | REQUIRED (parser) | REQUIRED (parser) |

## Admission predicates

- INSPECT_RECORD: `target_record_id` must be non-null, not already inspected, budget > 0
- DECLARE_STATUS: `proposed_status` must be non-null
- All operations: rejected if state is terminal
- Extra fields on wrong operations: ignored by the gate

## LIVE-03 explanation

A — CONTRACT INFORMATION ABSENT

The pre-R5 prompt did not state that INSPECT_RECORD requires `target_record_id`. The model produced a canonical operation with a null target. The admission gate correctly rejected it.

## Repair

- Single-source helper: `operation_required_fields()` derived from admission contract
- Prompt now states: "INSPECT_RECORD requires target_record_id; DECLARE_STATUS requires proposed_status"
- Null is declared invalid for a required field
- Parser unchanged
- Admission unchanged
- No schema migration

## Tests

| Test | Result |
|---|---|
| Field-requirement matrix | PASS |
| INSPECT_RECORD ablation | PASS |
| Wrong-field controls | PASS |
| Value-validity controls | PASS |
| Prompt exposes required fields | PASS |
| R4 vocabulary regression | PASS |
| Scripted reasoner | PASS |
| lake build | EXIT 0 |
| Strict axiom audit | PASS |
| Network/API requests | 0 |
| fdht/ changed | NO |

## Integrity

- Parser weakened: NO
- Admission weakened: NO
- State semantics changed: NO
- sorryAx: ABSENT
- Classical.choice: not introduced
- Custom axioms: ABSENT

## Evidence-supported claim

The admission gate requires `target_record_id` for INSPECT_RECORD and `proposed_status` for DECLARE_STATUS. The pre-R5 prompt did not expose these requirements. R5 injected them into the generated prompt from a single-source helper. The parser and admission gate remain unchanged. Zero live requests were issued.

## Claims explicitly NOT established

- That a future live model response will supply the required fields
- That the LIVE-03 failure was caused solely by prompt absence (the model may still omit the field)
- Strict structured-schema enforcement
- Permanent FDHT pressure
- Promotion of any mathematics

## Structured-schema pressure established?

NO

## Permanent FDHT pressure?

NO

## Promotion justified?

NO

## LIVE-04 eligibility

YES (unique minimal repair implemented and tested; parser and admission remain strict; zero API calls; fdht/ unchanged). LIVE-04 is not executed in this task.
