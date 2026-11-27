# FDHT SCF-03C: Component-Local Transformation-Fate Matrices

## Classification

B — BOTH COMPONENT FATE MATRICES COMPLETE; SOME VALID CELLS REMAIN UNRESOLVED

## Summary

Component-local fate matrices are complete for both connected components. The permanent FDHT component has 1 valid cell (OBSERVABLE_LOSS). The A2 component has 8 valid cells (4 settled, 4 unresolved). No cross-component adapter exists. Zero live requests were issued.

## Permanent FDHT matrix

| Transformation | Consumer | Status |
|---|---|---|
| trajectoryProjection | rawIdentityConsumer | OBSERVABLE_LOSS |

Completeness: COMPLETE (1/1 settled)

## A2 matrix

| Transformation | Consumer | Status |
|---|---|---|
| candidateT | identityMembershipConsumer | SUFFICIENT |
| candidateT | identityMultiplicityConsumer | SUFFICIENT |
| candidateT | completeRecordConsumer | OBSERVABLE_LOSS |
| candidateT | provenanceConsumer | OBSERVABLE_LOSS |
| buildExactIndex | identityMembershipConsumer | UNRESOLVED |
| buildExactIndex | identityMultiplicityConsumer | UNRESOLVED |
| buildExactIndex | completeRecordConsumer | UNRESOLVED |
| buildExactIndex | provenanceConsumer | UNRESOLVED |

Completeness: COMPLETE (8/8 classified, 4 unresolved)

## Invalid-pair ledger

6 invalid-domain pairs recorded (cross-component mismatches).

## Injectivity controls

| Transformation | Injectivity |
|---|---|
| trajectoryProjection | REFUTED_BY_COLLISION |
| candidateT | UNRESOLVED |
| buildExactIndex | UNRESOLVED |

## Claims explicitly NOT established

- Cross-component adapter
- Global consumer axis
- Universal information preservation
- Universal information loss
- Permanent FDHT pressure
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
