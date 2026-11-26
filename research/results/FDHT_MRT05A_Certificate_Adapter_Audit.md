# FDHT MRT-05A: Certificate Adapter Audit

## Classification

TRANSFORMATION_RELATION_ONLY for collapse and distinction certificates.

## Summary

Existing certificates supply transformation relations (projected equality or inequality) but do not directly supply SufficientFor or ObservableLoss evidence without additional consumer specification.

## Certificate classifications

| Certificate | Classification | Reason |
|---|---|---|
| CollapseCertificate | TRANSFORMATION_RELATION_ONLY | Supplies raw distinctness and projected equality |
| ProjectedDistinctionCertificate | TRANSFORMATION_RELATION_ONLY | Supplies projected inequality |
| ObservableFactorisationCertificate | SUFFICIENCY_EVIDENCE | Supplies factorisation through projection |
| DistinguishingResolveCertificate | NOT_APPLICABLE | Resolver-specific algebraic result |

## Adapter requirement

Each certificate requires an explicit consumer to instantiate SufficientFor or ObservableLoss. No certificate directly supplies a generic consumer-relative classification.

## Permanent FDHT pressure

NO

## Next transition

STOP
