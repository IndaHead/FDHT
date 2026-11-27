# FDHT CERTMEM-02 Lean Formalisation of Six-Class Memory Certification

## Classification
A — LOAD-BEARING LAWS FORMALISED AND COMPILE UNDER LEAN 4.35.0

## Summary
Research-local Lean model of:

MemoryState6 → certificationProjection → CertificateState → evaluateCertificate → CertificationDisposition

Faithful translation of the six classes (TRANSFORMED_LOSSLESS from Python dataclasses). Concrete String types used for the probe.

Theorems proved (compile under Lean 4.35.0):

- T1 valid_history_certifies_absence
- T2 uncertified_history_stops
- T3 history_changes_admissible_disposition
- T4 applicable_negative_blocks_certification
- T5 irrelevant_negative_preserves_certification
- T7 certification_never_produces_external_authority / certification_authority_range
- SufficientFor (certificationProjection req) (semanticCertificationConsumer req)

Authority theorems and SufficientFor are pure (propext only). Fixture equalities use native_decide on finite concrete data (research-probe acceptable, analogous to prior MRT-05B negative fixtures).

No seventh class. No fdht/ modification. No promotion. Semantic conclusions of CIDX-01 / CERTMEM-01 preserved.

## Claim boundary
Bounded research formalisation of the frozen certification workload. Does not claim universal memory completeness or permanent mathematics.
