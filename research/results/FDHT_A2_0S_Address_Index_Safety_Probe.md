# FDHT A2₀-S: Address-Index Corruption and Freshness Safety Probe

## Classification

A — INDEX CORRUPTION AND FRESHNESS CONTROLS SURVIVED

## Summary

The fail-closed address index detects corruption and staleness. Missing bucket produces STOP_INDEX_INVALID. Source revision produces STOP_INDEX_STALE. Zero false ADMIT. Zero false source-absence claims. Zero live requests were issued.

## Key findings

| Attack | Result |
|---|---|
| S0_VALID | ADMIT (18) |
| C1_MISSING_BUCKET | STOP_INDEX_INVALID (18) |
| R1_SOURCE_REVISION | STOP_INDEX_STALE (18) |

## Safety invariants

| INV | Status |
|---|---|
| INV-1: ADMIT requires valid index | SURVIVED |
| INV-2: STOP_INSUFFICIENT requires valid index | SURVIVED |
| INV-3: Invalid index cannot produce ADMIT | SURVIVED |
| INV-4: Invalid index cannot produce STOP_INSUFFICIENT | SURVIVED |
| INV-5: Stale index cannot be reused | SURVIVED |

## Core result

The fail-closed address index distinguishes index invalidity from source insufficiency. Corruption and staleness are detected.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Cryptographic security
- Adversarial completeness
- Runtime improvement
- Permanent index promotion
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
