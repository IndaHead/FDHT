# AH₀-R8: Evidence-Submission Transition Semantics

## Classification

B — EVIDENCE-SUBMISSION SEMANTICS ESTABLISHED AND IMPLEMENTED

## Summary

SUBMIT_EVIDENCE now resolves target_record_id through the catalogue, requires the record to have been inspected, and adds it to admitted_evidence_ids (positive) or opposing_evidence_ids (negative). Duplicate submission is rejected. Inspection does not auto-submit. Submission does not declare status. Zero live requests were issued.

## Evidence identity

E1 (target_record_id): SUPPORTED  
E2 (target_obligation_id): UNDERDETERMINED  
E3 (all inspected): REFUTED  
E4 (separate object): UNDERDETERMINED  

Established identity: target_record_id

## Inspection prerequisite

YES — record must be in inspected_record_ids before submission.

## Failure distinctions

| Condition | Result |
|---|---|
| target null | MISSING_EVIDENCE_TARGET |
| target unknown | UNKNOWN_EVIDENCE_RECORD |
| not inspected | EVIDENCE_NOT_INSPECTED |
| already submitted | ALREADY_SUBMITTED |
| known and inspected | EVIDENCE_SUBMISSION_SUCCESS |

## Implementation

- State machine handles SUBMIT_EVIDENCE after admission
- Resolves via catalogue.inspect_record
- Requires inspected_record_ids membership
- Positive polarity → admitted_evidence_ids
- Negative polarity → opposing_evidence_ids
- Duplicate → ALREADY_SUBMITTED
- Existing AH0State fields sufficient

## Tests

| Test | Result |
|---|---|
| Submit after inspect | PASS |
| Submit negative | PASS |
| Submit without inspect | PASS |
| Submit unknown | PASS |
| Submit null | PASS |
| Duplicate | PASS |
| Inspect does not submit | PASS |
| Submit does not declare | PASS |
| R7 regression | PASS |
| R5 regression | PASS |
| R4 regression | PASS |
| Scripted | PASS |
| lake build | EXIT 0 |
| Strict axiom audit | PASS |
| Network/API requests | 0 |
| fdht/ changed | NO |

## Integrity

- Parser changed: NO
- Admission changed: NO
- Catalogue changed: NO
- EventLog schema changed: NO
- Prompt changed: NO
- sorryAx: ABSENT
- Classical.choice: not introduced
- Custom axioms: ABSENT

## Evidence-supported claim

SUBMIT_EVIDENCE now requires inspection, resolves the target through the catalogue, and adds it to the appropriate evidence list. Positive and negative evidence are preserved separately. Duplicate submission is rejected. Inspection does not auto-submit. Submission does not declare status. Zero live requests were issued.

## Claims explicitly NOT established

- That obligation discharge is automatic on submission
- That the evaluator is invoked on submission
- Permanent FDHT pressure
- Promotion of any mathematics

## Structured-schema pressure

NO

## Permanent FDHT pressure

NO

## Promotion justified

NO

## LIVE-05 eligibility

YES (evidence-submission semantics established and tested; zero API calls; fdht/ unchanged). LIVE-05 is not executed in this task.
