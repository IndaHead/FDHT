# AH₀-R6: Target-Reference Validity and Ownership

## Classification

C — REFERENCE-VALIDITY DEFECT ESTABLISHED; OWNERSHIP OR REPAIR UNDERDETERMINED

## Summary

The admission gate admits INSPECT_RECORD proposals with unknown non-null target_record_id. The catalogue layer can distinguish known from unknown via inspect_record returning None. The state machine does not call the catalogue and does not mutate inspected_record_ids or budget on INSPECT_RECORD. No layer in the executable path currently owns reference validity. A unique minimal repair is not established because the state machine lacks an inspection-transition path that uses the catalogue. Zero live requests were issued.

## Source ownership

| Layer | Checks presence | Checks existence | Mutates inspection state |
|---|---|---|---|
| Parser | YES (type) | NO | NO |
| Admission gate | YES (non-null) | NO | NO |
| State machine | NO | NO | NO (for INSPECT_RECORD) |
| Catalogue | N/A | YES (returns None) | NO |

First dereference layer: catalogue.inspect_record (not called by state machine)  
First layer capable of known/unknown distinction: catalogue (unused in executable path)

## Target classes

| Class | Specimen | Admission | Lookup | State mutation |
|---|---|---|---|---|
| VALID_VISIBLE_CURRENT | pos1 | ADMITTED | FOUND | NONE |
| VALID_VISIBLE_NEGATIVE | neg1 | ADMITTED | FOUND | NONE |
| UNKNOWN_NONEMPTY | missing_record_r6 | ADMITTED | NOT FOUND | NONE |
| EMPTY_STRING | "" | REJECTED (Missing target_record_id) | NOT FOUND | NONE |
| NULL | None | REJECTED (Missing target_record_id) | NOT FOUND | NONE |
| ALREADY_INSPECTED | pos1 (pre-inspected) | REJECTED | N/A | NONE |

STALE_OR_SUPERSEDED, NOT_VISIBLE, IRRELEVANT_TO_CURRENT_REQUIREMENT: NO EXISTING TEST SPECIMEN

## Unknown-target fate

D — ADMITTED, THEN SILENT NO-OP

The proposal is admitted. The state machine does not dereference the target. No exception is raised. No state is mutated. The event records ADMITTED with no indication that the record does not exist.

## Safety invariants

| Invariant | Result |
|---|---|
| I1: Unknown does not enter inspected_record_ids | PASS (never mutates) |
| I2: Unknown does not consume budget | PASS (never mutates) |
| I3: Unknown does not satisfy obligation | PASS (never mutates) |
| I4: Unknown does not mutate evidence | PASS (never mutates) |
| I5: Unknown does not alter objective/authority | PASS |
| I6: Unknown does not produce false successful inspection event | UNDERDETERMINED (event records ADMITTED; no success flag) |
| I7: Unknown distinguishable from successful inspection | FAIL (both produce ADMITTED with no state change) |
| I8: Empty string not treated as valid identifier | PASS (rejected as missing) |
| I9: Null distinguishable from unknown nonempty | PASS (null rejected; unknown admitted) |

## Ownership classification

Current: NO_LAYER_CURRENTLY_OWNS_REFERENCE_VALIDITY  
Desired: STATE_TRANSITION_OWNS_REFERENCE_VALIDITY (using catalogue as authority)

Desired ownership is not uniquely implementable as a minimal repair because the state machine currently lacks an inspection-transition path that dereferences the catalogue.

## Repair pressure

MULTI-LAYER PRESSURE

Admission does not check existence. State transition does not dereference. Catalogue can distinguish but is unused.

## Repair implemented

NO

A unique minimal repair is not established. Adding catalogue dereference and state mutation for inspection would be a new state-transition path, not a minimal repair of an existing path.

## Integrity

- Parser changed: NO
- Admission changed: NO
- State-machine changed: NO
- Catalogue changed: NO
- EventLog changed: NO
- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Evidence-supported claim

The admission gate admits unknown non-null targets. The catalogue can distinguish known from unknown but is not called by the state machine. The state machine does not mutate inspection state for INSPECT_RECORD. No layer in the executable path currently owns reference validity. A unique minimal repair is not established.

## Claims explicitly NOT established

- That unknown targets are currently rejected
- That inspection state is currently mutated for valid targets
- That a unique minimal repair exists
- Permanent FDHT pressure
- Promotion of any mathematics

## Structured-schema pressure

NO

## Permanent FDHT pressure

NO

## Promotion justified

NO

## LIVE-04 eligibility

NO (reference-validity ownership underdetermined; no unique minimal repair established)

## Next transition

STOP
