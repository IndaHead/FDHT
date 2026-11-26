# AH₀-R9: Evidence → Obligation Discharge Semantics

## Classification

C — OBLIGATION DISCHARGE SEMANTICS UNDERDETERMINED; NO IMPLEMENTATION

## Summary

The source contains a build_obligation_profiles function that marks an obligation DISCHARGED if evidence has a matching claim and verification_result=True. However, no fixture constructs an EvidenceObligation for obl1, and MemoryRecord uses verification_status (string) rather than verification_result (bool). Multiple non-equivalent discharge rules fit the available source. No unique discharge predicate is established. Zero live requests were issued.

## Obligation structure

ObligationDischargeStatus: DISCHARGED, FAILED, UNVERIFIABLE, NOT_APPLICABLE

EvidenceObligation fields: obligation_id, requirement_id, candidate_status, proposition, required_scope, provenance_requirement, verifier_requirement, mandatory, dependency_ids

obl1 construction: NOT PRESENT in fixtures or tests. Tests use obligation_profiles={"obl1": UNVERIFIABLE} as a dict without an EvidenceObligation object.

## Identifiability

C — UNDER-SPECIFIED; MULTIPLE NON-EQUIVALENT DISCHARGE RULES FIT SOURCE

## Candidate discharge rules

| Rule | Source evidence | Result |
|---|---|---|
| D1: any submitted evidence | NONE | UNDERDETERMINED |
| D2: positive evidence only | NONE | UNDERDETERMINED |
| D3: negative evidence only | NONE | UNDERDETERMINED |
| D4: both required | NONE | UNDERDETERMINED |
| D5: specific record identity | NONE | UNDERDETERMINED |
| D6: verified provenance | PARTIAL (function checks verification_result) | UNDERDETERMINED |
| D7: alternative routes | NONE | UNDERDETERMINED |

No candidate uniquely survives.

## Field mismatch

build_obligation_profiles checks:
- item.claim == omega.proposition
- item.verification_result == True

MemoryRecord has:
- claim: str
- verification_status: str (not verification_result: bool)

The function and the record type do not align.

## Implementation

NO

A unique discharge rule is not established. Implementing one would invent semantics not uniquely determined by source.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS
- Parser changed: NO
- Admission changed: NO
- State machine changed: NO
- Evaluator changed: NO

## Evidence-supported claim

No EvidenceObligation is constructed for obl1. The build_obligation_profiles function expects verification_result (bool) but MemoryRecord provides verification_status (str). Multiple non-equivalent discharge rules fit the available source. No unique discharge predicate is established.

## Claims explicitly NOT established

- That obl1 is discharged by any specific evidence combination
- That positive evidence satisfies obl1
- That negative evidence satisfies or blocks obl1
- Permanent FDHT pressure
- Promotion of any mathematics

## Structured-schema pressure

NO

## Permanent FDHT pressure

NO

## Promotion justified

NO

## LIVE-05 eligibility

NO (obligation discharge semantics underdetermined)

## Next transition

STOP
