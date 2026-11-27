# FDHT SCF-03B: Typed Carrier and Transformation Graph

## Classification

TWO_COMPONENTS — NO_CROSS_CARRIER_ADAPTER

## Summary

The typed carrier graph recovers 5 carriers, 3 transformations, and 5 consumers from frozen repository artefacts. Two connected components exist: the A2 SourceState domain and the permanent FDHT RawHistory domain. No cross-carrier adapter connects them. Zero live requests were issued.

## Graph inventory

| Type | Count |
|---|---|
| Carriers | 5 |
| Transformations | 3 |
| Consumers | 5 |
| Connected components | 2 |

## Connected components

| Component | Carriers |
|---|---|
| A2 SourceState | SourceState, ExactIndex, CandidateRepresentation |
| Permanent FDHT | RawHistory, TrajectoryBoundary |

## Carriers

| ID | Type | Authority |
|---|---|---|
| RawHistory | List KernelExprContext | PERMANENT |
| TrajectoryBoundary | TrajectoryBoundary resolve | PERMANENT |
| SourceState | List SourceRecord | RESEARCH |
| ExactIndex | Identity → List Position | RESEARCH |
| CandidateRepresentation | List Position | RESEARCH |

## Transformations

| ID | Source | Target | Authority |
|---|---|---|---|
| trajectoryProjection | RawHistory | TrajectoryBoundary | PERMANENT |
| buildExactIndex | SourceState | ExactIndex | RESEARCH |
| candidateT | SourceState | CandidateRepresentation | RESEARCH |

## Consumers

| ID | Carrier | Codomain | Authority |
|---|---|---|---|
| rawIdentityConsumer | RawHistory | RawHistory | RESEARCH |
| identityMembershipConsumer | SourceState | Bool | RESEARCH |
| identityMultiplicityConsumer | SourceState | Nat | RESEARCH |
| completeRecordConsumer | SourceState | Option SourceRecord | RESEARCH |
| provenanceConsumer | SourceState | Option Lineage | RESEARCH |

## Fate cells

| Transformation | Consumer | Status |
|---|---|---|
| candidateT | identityMembershipConsumer | SUFFICIENT |
| candidateT | identityMultiplicityConsumer | SUFFICIENT |
| candidateT | completeRecordConsumer | OBSERVABLE_LOSS |
| candidateT | provenanceConsumer | OBSERVABLE_LOSS |

## Cross-carrier status

No SourceState ↔ RawHistory adapter exists. SCF-03A confirmed this. The two domains remain separate.

## Claims explicitly NOT established

- Cross-carrier adapter
- SourceState identity from RawHistory
- RawHistory identity from SourceState
- Permanent Address mathematics
- Permanent FDHT pressure
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
