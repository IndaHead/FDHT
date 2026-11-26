# FDHT MRT-05A: Trajectory-Projection Domain Adapter

## Classification

C — POSITIVE AND NEGATIVE CONTROLS VERIFIED; NO GENERAL INVARIANCE ADAPTER ESTABLISHED

## Summary

trajectoryProjection instantiates the generic transformation T. Factorised consumers are projection-safe. Raw-identity consumer is projection-unsafe via existing certified collision. No general invariance adapter is established. Zero live requests were issued.

## Adapter results

| Cell | Result | Status |
|---|---|---|
| C0 projected-state | SufficientFor | CONSTRUCTIVE |
| C1 factorised consumer | SufficientFor | CONSTRUCTIVE |
| C2 raw-identity | ObservableLoss | CONSTRUCTIVE |
| C2 noninjectivity | ¬Injective | CONSTRUCTIVE |
| C4 pair consumer | insufficient | CONSTRUCTIVE |
| FoldKernel equivalence | definitional | CONSTRUCTIVE |

## Collision witness

- Raw histories: [] vs [identityContext]
- Raw inequality: c2_rawDistinct
- Projected equality: c2_projectedEqual
- Source: existing FDHT theorem identity_singleton_equals_empty_trajectory

## Trust footprint

- All theorems: Quot.sound
- sorryAx: ABSENT
- Classical.choice: ABSENT
- fdht/ changed: NO

## Invariance relationship

| Concept | Relationship |
|---|---|
| FoldKernel | DEFINITIONALLY_IDENTICAL |
| TrajectoryEquivalent | RELATED_BUT_DISTINCT |
| HistoryInvariant | NO_MATCHING_PERMANENT_CONCEPT |

## Certificate classification

| Certificate | Classification |
|---|---|
| CollapseCertificate | TRANSFORMATION_RELATION_ONLY |
| ProjectedDistinctionCertificate | TRANSFORMATION_RELATION_ONLY |
| ObservableFactorisationCertificate | SUFFICIENCY_EVIDENCE |
| DistinguishingResolveCertificate | NOT_APPLICABLE |

## Claims explicitly NOT established

- Absolute information loss
- Deletion
- Physical destruction
- Universal consumer insufficiency
- Total provenance classification
- Generic collapse-event existence
- Stage-4/indexed-orbit identity
- Retrieval semantics
- Memory semantics
- Permanent FDHT pressure
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
