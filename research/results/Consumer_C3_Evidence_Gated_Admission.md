# FDHT Consumer Probe C₃ — Evidence-Gated Downstream Admission

**Status:** VERIFIED  
**Authority:** Research evidence  
**Branch:** `research/consumer-layer`  
**Substrate modification:** None

## Question

Can an established consumer result provide the typed evidence required to
construct a downstream request, while refuted and unresolved results remain
unable to admit that request?

## Result

Yes.

C₃ verified the trajectory:

```text
upstream request
    ↓
ESTABLISHED h
    ↓
recover h : P
    ↓
downstream request requires P
    ↓
request becomes constructible
    ↓
downstream claim established
    ↓
complete transition reconstructed
```

## Verified distinctions

| Distinction | Status |
|-------------|--------|
| ESTABLISHED unlocks downstream request | VERIFIED |
| REFUTED blocks admission | VERIFIED |
| UNRESOLVED blocks admission | VERIFIED |
| status alone is insufficient | VERIFIED |
| proof payload drives progression | VERIFIED |
| composition ≠ dependency | VERIFIED |
| wrong-value cross-wiring rejected | VERIFIED |
| wrong-family cross-wiring rejected | VERIFIED |
| kernel equivalence does not transfer raw description | VERIFIED |

## Not required

| Candidate | Classification |
|-----------|----------------|
| CONDITIONAL | F — FALSE REQUIREMENT |
| INADMISSIBLE | F — FALSE REQUIREMENT |
| explicit Applicability | F — FALSE REQUIREMENT |
| action layer | F — FALSE REQUIREMENT |
| generic Consumer API | F — FALSE REQUIREMENT |

## Trajectory certificate

`FoldedTransitionTrajectory` was found probe-local useful for retaining staged
lineage. Permanent promotion is NOT justified.

## Trust

| Gate | Result |
|------|--------|
| lake build | EXIT 0 (49 jobs) |
| strict axiom audit | PASS (77 source files) |
| sorryAx | ABSENT |
| Classical.choice | ABSENT |
| main/foundational diff | EMPTY |

## Axiom footprints

```text
downstream_claim_established       : [propext, Quot.sound]
complete_transition_reconstructed  : [propext, Quot.sound]
original_not_aligned               : [propext]
```

## Classification

**EVIDENCE-GATED ADMISSION VERIFIED; EXISTING SUBSTRATE SUFFICIENT**

## Disposition

PROBE-LOCAL ONLY. Not promoted. Not a permanent API.

## Research file

`research/probes/consumer_layer/c3_evidence_gated_transition_consumer.lean`

