# FDHT SCF-01: Blind Stage/Channel Factorisation

## Classification

PARTIAL_ALIGNMENT — NO_COUNT_ALIGNMENT

## Summary

Blind extraction discovered 5 stages and 5 channels (4 independent). The sealed hypothesis specified 8 layers and 3 channels. No count alignment. Partial structural alignment exists. The second dimension represents consumer distinctions, not transition operators. Zero live requests were issued.

## Blind extraction

| Dimension | Discovered | Candidate |
|---|---|---|
| Stages/Layers | 5 | 8 |
| Channels | 5 (4 independent) | 3 |
| Product | 25 | 24 |

## Stage inventory

| ID | Input | Output | Transformation |
|---|---|---|---|
| S0 | SourceState | ExactIndex | buildExactIndex |
| S1 | ExactIndex × Identity | List Position | lookup |
| S2 | SourceState × List Position | List SourceRecord | dereference |
| S3 | List SourceRecord × Identity | VerifiedResult | exact verification |
| S4 | RawHistory | TrajectoryBoundary | trajectoryProjection |

## Channel inventory

| ID | Consumer | Codomain | Independence |
|---|---|---|---|
| C0 | identityMembership | Bool | weaker than C1 |
| C1 | identityMultiplicity | Nat | independent |
| C2 | completeRecord | Option SourceRecord | independent |
| C3 | provenance | Option Lineage | independent |
| C4 | rawIdentity | RawHistory | not comparable |

## Alignment classification

- Count alignment: NO_COUNT_ALIGNMENT
- Structural alignment: PARTIAL_ALIGNMENT
- Second dimension: CONSUMER_DISTINCTIONS
- Orbit: LINEAR_PIPELINE

## A2 profile preserved

- Candidate addressing sufficient for membership
- Candidate addressing sufficient for multiplicity
- Candidate addressing insufficient for complete record
- Candidate addressing insufficient for provenance
- Verified composite sufficient for identity outcome

## Trajectory profile preserved

- Factorised consumers projection-safe
- Raw identity projection-unsafe
- FoldKernel aligns with projection equality

## Claims explicitly NOT established

- 8×3 geometry
- Cyclic closure
- Transition operators
- Permanent 8×3 API
- Architectural necessity
- Permanent FDHT pressure
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
