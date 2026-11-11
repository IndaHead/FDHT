# External Consumer E0 — SLSA-Derived Software-Artifact Acceptance

**Status:** ABSORPTION WITH ADAPTER-LOCAL OPERATIONAL CONTENT  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `f9c07b3ca71a4680c1b3788d4efbf6c3b57c61ca`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/locality-attestation |
| Starting HEAD | f9c07b3ca71a4680c1b3788d4efbf6c3b57c61ca |
| Working branch | research/external-consumer-slsa |

## 2. Working Branch

research/external-consumer-slsa

## 3. Final HEAD

(recorded after commit)

## 4. External Source and Version

| Property | Value |
|----------|-------|
| Name | SLSA |
| Version | v1.2 |
| Surfaces | Build Provenance, Verifying Artifacts, Distributing Provenance, Guiding Principles |

## 5. Frozen External Requirement

Software-artifact acceptance verifier.

## 6. Frozen Requirement Digest

`ad670b1c36841764597bb300718506ef587dfb57634d6e30f450b64613edaf6c`

## 7. External Consumer Question

"May software artifact A enter an approved release path under frozen provenance expectations E?"

## 8. Exact External Request

ArtifactAcceptanceRequest with fields: artifact_id, artifact_digest, provenance_envelope, expected_subject_digest, accepted_builder_identities, required_build_type, permitted_external_parameters, available_trust_material.

## 9. Exact External Checks

| Check | Pass Condition | Fail | Unverifiable |
|-------|----------------|------|--------------|
| Subject binding | ID and digest match | Mismatch | Missing/unreadable |
| Signature | Fixture HMAC verifies | Invalid | Missing trust material |
| Builder | In accepted set | Not accepted | Missing |
| Build type | Equals required | Mismatch | Missing |
| External parameters | All recognised and permitted | Unrecognised or forbidden | Missing |

## 10. Exact External Result States

| State | Meaning |
|-------|---------|
| ACCEPT | Every mandatory check passes |
| REJECT | At least one mandatory check definitively fails |
| REVIEW | No definitive failure, but at least one check unverifiable |

## 11. All External Fixtures

| ID | Condition | Expected |
|----|-----------|----------|
| E1 | All checks pass | ACCEPT |
| E2 | Wrong digest | REJECT |
| E3 | Wrong ID | REJECT |
| E4 | Invalid signature | REJECT |
| E5 | Unverifiable signature | REVIEW |
| E6 | Unaccepted builder | REJECT |
| E7 | Missing builder | REVIEW |
| E8 | Wrong build type | REJECT |
| E9 | Missing build type | REVIEW |
| E10 | Unrecognised parameter | REJECT |
| E11 | Forbidden parameter value | REJECT |
| E12 | Missing provenance | REVIEW |
| E13 | Multiple failures | REJECT |

## 12. External Test Results

All 13 fixtures pass. All expected outcomes match.

## 13. Frozen Expected-Results Digest

`351271026e5a28835865a96480090d1c7c77272aa1e24de84a350a98b03e2663`

## 14. Stage-Order Audit

| Stage | Status |
|-------|--------|
| E0-A: Freeze requirements | COMPLETE (before adapter) |
| E0-B: Implement external consumer | COMPLETE (no FDHT imports) |
| E0-C: Freeze expected results | COMPLETE |
| E0-D: Implement FDHT adapter | COMPLETE |
| E0-E: Compare results | COMPLETE |

## 15. Import-Separation Audit

external_slsa_consumer.py does not import FDHT, A0, locality, or adapter modules. It imports only from frozen_slsa_requirements.

## 16. FDHT Adapter Design

The adapter consumes frozen external verification results and translates them into research-local EvidenceStatus and ConsumerDecision while preserving the original external result and all check-level outcomes.

## 17. Candidate External-to-FDHT Mapping

| External | EvidenceStatus | ConsumerDecision |
|----------|----------------|------------------|
| ACCEPT | ESTABLISHED | ADMIT |
| REJECT | REFUTED | REJECT |
| REVIEW | UNRESOLVED | STOP |

This mapping is a hypothesis. The original external result remains attached.

## 18. Translation Loss Ledger Summary

| Status | Count |
|--------|-------|
| EXACT | 10 |
| TRANSFORMED_LOSSLESS | 3 |
| LOSSY | 0 |
| UNREPRESENTABLE | 0 |
| ADDED_BY_FDHT | 0 |

## 19. Fixture-by-Fixture Outcome Comparison

All 13 fixtures: external result equals adapted external_result. No outcome changes.

## 20. Check-by-Check Comparison

All check results preserved. Failed checks and unverifiable checks carried through.

## 21. Anti-Contamination Attacks

| Attack | Result |
|--------|--------|
| Authority-applicability collapse | PASS |
| Signature-truth collapse | PASS |
| Provenance-decision collapse | PASS |
| Subject-release collapse | PASS (not triggered) |
| Unknown-parameter suppression | PASS (not triggered) |
| Review-to-reject collapse | PASS |
| Review-to-accept collapse | PASS |
| Multiple-failure loss | PASS |
| FDHT-added condition | PASS (none added) |
| External-condition deletion | PASS (none deleted) |
| Result-name substitution | PASS |
| External-fixture mutation | PASS (none) |
| Provenance-authority collapse | PASS |
| Passing-test promotion | PASS (not claimed) |

## 22. First Semantic Divergence

None. All external outcomes preserved.

## 23. Lossy Translations

0

## 24. Unrepresentable Distinctions

0

## 25. FDHT-Added Conditions

0

## 26. Deleted External Conditions

0

## 27. Authority Escalations

0

## 28. Classification

**B — ABSORPTION WITH ADAPTER-LOCAL OPERATIONAL CONTENT**

## 29. Justification for Classification

All external behaviour is preserved. Domain-specific verification checks (subject binding, signature, builder, build type, parameters) remain adapter-local. No permanent FDHT gap is exposed. No external semantics are changed. The candidate mapping ACCEPT→ESTABLISHED→ADMIT, REJECT→REFUTED→REJECT, REVIEW→UNRESOLVED→STOP is operationally lossless for the tested fixtures.

Classification is not A because the adapter introduces operational content (the mapping and the research-local types) that is not part of the external specification, even though it does not change outcomes.

## 30. Justified Claims

- All frozen external distinctions are represented.
- All external fixture outcomes are preserved.
- No semantic loss occurs.
- No external requirement is deleted.
- No FDHT-only condition is added that changes outcomes.
- The candidate mapping is operationally lossless for the tested fixtures.

## 31. Unjustified Claims

- Real SLSA compliance.
- Production signature security.
- Supply-chain security.
- FDHT universality.
- Permanent architectural sufficiency.
- Any permanent FDHT mathematics.

## 32. FDHT Pressure

NONE

## 33. New Permanent Mathematics Justified

NO

## 34. New Abstraction Justified

NO

## 35. Promotion Justified

NO

## 36. Next Stage Justified

NO

This fixture does not expose a concrete, natural, untested requirement not absorbed by existing research-local structures.

## 37. Recommended Action

**STOP**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Generic ExternalConsumer API: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
