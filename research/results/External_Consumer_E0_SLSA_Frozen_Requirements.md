# External Consumer E0 — SLSA-Derived Software-Artifact Acceptance

**Status:** FROZEN EXTERNAL REQUIREMENTS  
**Authority:** EXTERNAL SPECIFICATION  
**External Source:** SLSA v1.2  
**Frozen Before:** Any FDHT adapter implementation

## External Source

| Property | Value |
|----------|-------|
| Name | SLSA |
| Version | v1.2 |
| Surfaces | Build Provenance, Verifying Artifacts, Distributing Provenance, Guiding Principles |

## External Consumer

Software-artifact acceptance verifier.

## Consumer Question

"May software artifact A enter an approved release path under frozen provenance expectations E?"

## Exact Required Inputs

| Input | Description |
|-------|-------------|
| artifact_id | Identifier of the software artifact |
| artifact_digest | Cryptographic digest of the artifact |
| provenance_envelope | Structured provenance record |
| expected_subject_digest | Digest the consumer expects |
| accepted_builder_identities | Set of builder IDs the consumer accepts |
| required_build_type | Build type the consumer requires |
| permitted_external_parameters | Map of parameter names to permitted values |
| available_trust_material | Fixture-local material for signature verification |

## Exact Checks

### CHECK 1 — ARTIFACT SUBJECT BINDING

Require:
- provenance subject artifact ID matches requested artifact ID
- provenance subject digest matches expected artifact digest

Mismatch: FAIL  
Missing or unreadable subject evidence: UNVERIFIABLE

### CHECK 2 — PROVENANCE SIGNATURE

Deterministic fixture-local signature verification. Distinguishes valid, invalid, and unverifiable. Not real public-key signature verification.

Valid: PASS  
Invalid: FAIL  
Unverifiable (missing trust material): UNVERIFIABLE

### CHECK 3 — BUILDER IDENTITY

Require: provenance builder_id belongs to accepted_builder_identities.

Unknown or explicitly unaccepted builder: FAIL  
Missing builder identity: UNVERIFIABLE

### CHECK 4 — BUILD TYPE

Require: provenance build_type equals required_build_type.

Mismatch: FAIL  
Missing build_type: UNVERIFIABLE

### CHECK 5 — EXTERNAL PARAMETERS

Require: every external parameter is recognised and every value is permitted.

Unrecognised parameter: FAIL  
Recognised but forbidden value: FAIL  
Missing mandatory parameter information: UNVERIFIABLE

## Exact Result States

| State | Definition |
|-------|------------|
| ACCEPT | Every mandatory check passes. |
| REJECT | At least one mandatory check definitively contradicts frozen acceptance expectations. |
| REVIEW | No definitive contradiction is established, but at least one mandatory check cannot be completed because required evidence is missing, malformed, unsupported or unverifiable. |

These are fixture-local consumer states. This document does not claim SLSA mandates this exact enumeration.

## Exact Positive Fixture

### E1 — POSITIVE

- subject artifact ID matches
- subject digest matches
- fixture signature verifies
- builder accepted
- build_type matches
- all external parameters recognised and permitted

Expected: ACCEPT

## Exact Negative Fixtures

| ID | Condition | Expected |
|----|-----------|----------|
| E2 | Wrong artifact digest | REJECT |
| E3 | Wrong artifact ID | REJECT |
| E4 | Invalid signature | REJECT |
| E6 | Unaccepted builder | REJECT |
| E8 | Wrong build type | REJECT |
| E10 | Unrecognised external parameter | REJECT |
| E11 | Forbidden parameter value | REJECT |
| E13 | Multiple failures (digest, builder, build type) | REJECT |

## Exact Incomplete-Evidence Fixtures

| ID | Condition | Expected |
|----|-----------|----------|
| E5 | Unverifiable signature (missing trust material) | REVIEW |
| E7 | Missing builder | REVIEW |
| E9 | Missing build type | REVIEW |
| E12 | Missing provenance | REVIEW |

## Explicit Out-of-Scope Claims

This fixture does NOT claim:
- complete SLSA specification implementation
- any SLSA Build level
- real SLSA compliance
- production provenance
- production signature security
- external builder authenticity
- real supply-chain security

## Terminology Firewall

This document does not use:
- FDHT
- A0
- trajectory
- consumer edge
- provenance planes
- admissibility
- ESTABLISHED
- REFUTED
- UNRESOLVED
- ADMIT
- REJECT
- STOP

Those terms belong only to the later adapter stage.
