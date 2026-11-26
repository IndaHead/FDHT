# AH₀-XC1: Natural External Consumer Search

## Classification

A — UNIQUE NATURAL EXTERNAL CONSUMER SELECTED AND FROZEN

## Summary

SLSA Provenance Verification (v1.0 Build L2) was selected as the unique natural external consumer. The requirement was frozen before AH₀ mapping. An independent evaluator passes all frozen fixtures. AH₀-blindness passes. Zero AH₀ live-model requests were issued.

## Candidate inventory

| Candidate | Source | N1–N10 | Result |
|---|---|---|---|
| SLSA Provenance Verification | SLSA v1.0 | ALL PASS | SELECTED |
| NIST SSDF | NIST SP 800-218 | N3 FAIL (high-level practices, no specific decision) | REJECTED |
| in-toto Attestation | in-toto v1.2 | N2 FAIL (framework, not a specific consumer decision) | REJECTED |

## Frozen artefacts

| Artefact | SHA-256 |
|---|---|
| FROZEN_EXTERNAL_REQUIREMENT.md | c8c9dee0f29268e9edebba0d6278d7864b59b5e8c260fb169a4c0760ec991615 |
| FROZEN_FIXTURE.json | a7eb141426821d832103383d5876912424c4706591a7ccbc01938fddb687391f |
| FROZEN_EXPECTED_RESULTS.json | c3f3e6e725cfbca4ba1a3161e09553f02ebf14962d2f632470eec6343eb33bf5 |

## External evaluator

7/7 fixtures PASS. Outcomes: ACCEPT, REJECT. No AH₀ imports.

## AH₀-blindness

PASS. Evaluator uses neutral field names (provenance_exists, signature_valid, builder_trusted, build_type_matches, external_params_match, digest_matches). No AH₀ terminology.

## Translation ledger

| External concept | AH₀ representation | Classification |
|---|---|---|
| Provenance exists | MemoryRecord presence | TRANSFORMED_LOSSLESS |
| Signature valid | verification_status | LOSSY (status is string, not signature verification) |
| Builder trusted | NOT REPRESENTABLE | UNREPRESENTABLE |
| BuildType matches | NOT REPRESENTABLE | UNREPRESENTABLE |
| ExternalParameters match | NOT REPRESENTABLE | UNREPRESENTABLE |
| Digest matches | NOT REPRESENTABLE | UNREPRESENTABLE |

Mandatory UNREPRESENTABLE fields: builder trust, buildType match, externalParameters match, digest match.

## H_XC1

The frozen external information requirement CANNOT be fully represented through existing AH₀ distinctions. Builder trust, buildType, externalParameters, and digest verification are UNREPRESENTABLE.

## Integrity

- AH₀ implementation performed: NO
- AH₀ live-model requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Evidence-supported claim

SLSA Provenance Verification (v1.0 Build L2) is a natural external consumer with explicit information requirements. The requirement was frozen before AH₀ mapping. An independent evaluator passes all frozen fixtures. Translation reveals mandatory UNREPRESENTABLE fields.

## Claims explicitly NOT established

- That AH₀ can represent SLSA verification requirements
- That SLSA verification produces ESTABLISHED
- Permanent FDHT pressure
- Promotion of any mathematics

## Permanent FDHT pressure

CANDIDATE (external consumer frozen; translation pressure established)

## Promotion justified

NO

## Next transition

XC2 ADAPTATION PROBE ELIGIBLE
