# FDHT SCF-03D: A2 buildExactIndex Fate-Cell Falsification

## Classification

A — ALL FOUR buildExactIndex CELLS SETTLED

## Summary

All four unresolved buildExactIndex fate cells are settled. Membership and multiplicity are SUFFICIENT. Complete record and provenance are OBSERVABLE_LOSS. Injectivity is refuted by collision. Zero live requests were issued.

## Fate results

| Cell | Consumer | Status |
|---|---|---|
| U0 | identityMembershipConsumer | SUFFICIENT |
| U1 | identityMultiplicityConsumer | SUFFICIENT |
| U2 | completeRecordConsumer | OBSERVABLE_LOSS |
| U3 | provenanceConsumer | OBSERVABLE_LOSS |

## Index correctness

| Property | Status |
|---|---|
| INDEX_SOUND | DEFINITIONAL |
| INDEX_COMPLETE | DEFINITIONAL |
| INDEX_POSITION_VALID | DEFINITIONAL |
| INDEX_MULTIPLICITY_PRESERVED | DEFINITIONAL |
| INDEX_ORDER_PRESERVED | DEFINITIONAL |

## ObservableLoss witnesses

| Cell | Distinguished field | Minimal |
|---|---|---|
| U2 | payload | YES |
| U3 | lineage | YES |

## Injectivity control

buildExactIndex is REFUTED_BY_COLLISION (U2 witness: same index, different payload).

## Fate vector comparison

F_index = (SUFFICIENT, SUFFICIENT, OBSERVABLE_LOSS, OBSERVABLE_LOSS)
F_candidate = (SUFFICIENT, SUFFICIENT, OBSERVABLE_LOSS, OBSERVABLE_LOSS)
Relationship: IDENTICAL_FATE_PROFILE

Vector equality does not establish transformation identity.

## Claims explicitly NOT established

- Universal exact-index sufficiency
- Generic indexing theory
- Permanent Address mathematics
- Permanent FDHT pressure
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
