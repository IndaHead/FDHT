# XC1-SLSA: Frozen External Requirement

## Source

- Authoritative source: SLSA Specification v1.0
- URL: https://slsa.dev/spec/v1.0/requirements
- Verification guidance: https://slsa.dev/spec/v1.0/verifying-artifacts
- Extraction date: 2026-11-26
- Source status: Published specification

## ExternalConsumerRequirement

| Field | Value |
|---|---|
| requirement_id | SLSA-VERIFY-L2 |
| source | SLSA Specification v1.0 |
| source_version | 1.0 |
| consumer | Package ecosystem or software consumer verifying artefact provenance |
| decision | ACCEPT / REJECT / REVIEW |
| subject | Software artefact with accompanying provenance attestation |
| required_information | Provenance attestation identifying output package by cryptographic digest; builder identity; buildType; externalParameters |
| admissible_alternatives | SLSA Provenance format or ecosystem-accepted equivalent |
| negative_information | Missing provenance; invalid signature; builder not in trusted set; buildType mismatch; externalParameters mismatch; digest mismatch |
| provenance_requirements | Provenance must be authentic (signature verifiable); builder identity must be identifiable |
| verification_requirements | Signature must verify against trusted key; digest must match artefact |
| trust_assumptions | Consumer maintains trusted builder set; signature verification key is trusted |
| success_condition | Provenance exists, signature verifies, builder is trusted, buildType matches expected, externalParameters match expected, digest matches artefact |
| failure_conditions | Missing provenance; invalid signature; untrusted builder; buildType mismatch; externalParameters mismatch; digest mismatch |
| unresolved_conditions | Provenance incomplete (external parameters not fully captured); builder trust not yet established |
| action_consequence | ACCEPT permits use; REJECT blocks use; REVIEW requires manual assessment |
| explicit_non_requirements | Completeness of resolved dependencies is best effort at L2; no requirement for hermetic build |

## Interpretation boundaries

- This freeze captures SLSA v1.0 Build L2 verification requirements only.
- L3/L4 requirements (unforgeable provenance, isolated builder) are out of scope.
- The consumer is the artefact verifier, not the builder.
- Signature verification is assumed to be available; the freeze does not specify cryptographic algorithms.

## Assumptions

- Consumer has access to a trusted builder set.
- Consumer has access to the signing key for signature verification.
- Artefact digest is computable.

## Unresolved terms

- "Trusted builder set" membership criteria are consumer-defined.
- "Expected buildType" and "expected externalParameters" are consumer-defined.

## Prohibited AH₀-added conditions

- No requirement that evidence be "inspected" before submission.
- No requirement that evidence carry a specific polarity.
- No requirement that evidence discharge an AH₀ obligation.
- No requirement that evidence produce an AH₀ status.

## SHA-256

Computed after freeze.
