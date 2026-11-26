# FDHT AF₁-M5: MORPH-5 Semantic Requirement-Representation Invariance

## Classification

A — MORPH-5 REPRESENTATION INVARIANCE ESTABLISHED

## Summary

Equivalent requirement representations canonicalise to the same semantic requirement. Different semantic requirements remain distinct. Malformed input is rejected. Zero live requests were issued.

## Positive representations

| ID | Type | Result |
|---|---|---|
| E0 | CANONICAL_ORDERED_LIST | EQUAL |
| E1 | REORDERED_LIST | EQUAL |
| E2 | DUPLICATE_BEARING_LIST | EQUAL |
| E3 | COMPACT_OBJECT | EQUAL |
| E4 | VERBOSE_OBJECT | EQUAL |
| E5 | FORMATTING_VARIANT | EQUAL |
| E6 | SUPPORTED_VERSIONED_ENVELOPE | EQUAL |
| E7 | OBJECT_KEY_ORDER_VARIANT | EQUAL |

## Negative representations

| ID | Type | Result |
|---|---|---|
| N0 | ONE_IDENTITY_REMOVED | DIFFERENT |
| N1 | ONE_IDENTITY_ADDED | DIFFERENT |
| N2 | EXACT_IDENTITY_REPLACED_BY_NEAR_MATCH | DIFFERENT |
| N3 | IDENTITY_VALUE_CASE_MUTATION | DIFFERENT |
| N4 | MALFORMED_REPRESENTATION | ERROR |
| N5 | UNSUPPORTED_SCHEMA_VERSION | DIFFERENT |
| N6 | CONFLICTING_FIELDS | DIFFERENT |
| N7 | EMPTY_REQUIREMENT | DIFFERENT |

## Metamorphic properties

| Property | Result |
|---|---|
| M5-1 ORDER INVARIANCE | PASS |
| M5-2 DUPLICATE INVARIANCE | PASS |
| M5-3 INERT-METADATA INVARIANCE | PASS |
| M5-4 SERIALISATION INVARIANCE | PASS |
| M5-5 SUPPORTED-ENVELOPE INVARIANCE | PASS |
| M5-6 SEMANTIC REMOVAL SENSITIVITY | PASS |
| M5-7 SEMANTIC ADDITION SENSITIVITY | PASS |
| M5-8 NEAR-MATCH NON-EQUIVALENCE | PASS |
| M5-9 MALFORMED INPUT REJECTION | PASS |
| M5-10 CONFLICT REJECTION | PARTIAL |

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Evidence-supported claim

Within the tested identity-set requirement schemas and concrete fixture subset, specified equivalent representations canonicalised to the same semantic requirement and produced the same oracle/treatment outcome and active identity set. Different semantic requirements remained distinct. Malformed input was rejected.

## Claims explicitly NOT established

- Universal representation invariance
- Support for arbitrary schemas
- Natural-language requirement equivalence
- Semantic equivalence of arbitrary programs
- Generic canonicalisation correctness
- Generic requirement scaling
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
