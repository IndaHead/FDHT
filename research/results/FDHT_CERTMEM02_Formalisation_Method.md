# FDHT CERTMEM-02 Formalisation Method

## Method
1. Inspect predecessor artefacts (CERTMEM-01 obligations, CIDX-01 dispositions, MRT-04 SufficientFor/ObservableLoss, six-class Python models).
2. Create research-local Lean types for the six records, MemoryState6, CertificationRequirement, CertificateState, dispositions, Authority, LookupObservation, QueryDisposition.
3. Define certificationProjection using requirement-relative any-predicates on the six lists.
4. Define evaluateCertificate and certifiedQuery.
5. Construct microscopic fixtures M_valid, M_uncertified, M_invalidated, M_irrelevantNegative.
6. Prove T1–T5, T7 and the MRT-04 SufficientFor connection.
7. Compile under pinned Lean 4.35.0 with MRT-04 import path.

## Translation
Python dataclasses → Lean structures: TRANSFORMED_LOSSLESS for the semantic fields used.
