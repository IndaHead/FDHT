# BSN0 — Blind Structural Necessity Probe

**Status:** FDHT-SPECIFIC UTILITY NOT ESTABLISHED  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `97c20918c671e99a1795bee07eee0b945ad7aa01`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/external-consumer-crdt |
| Starting HEAD | 97c20918c671e99a1795bee07eee0b945ad7aa01 |
| Working branch | research/blind-structural-necessity |

## 2. Working Branch

research/blind-structural-necessity

## 3. Final HEAD

(recorded after commit)

## 4. Complete Oracle Digest

`841add4b0eae917cfc91f4fd00a8ed7c38e2332a1e69053e3076e8449ae2854a`

## 5. Visible Specification Digest

`c98cb65eeb91b73c2da06ecee6fcece4afa47cd4d5d5b99296f61b38f41adb2b`

## 6. Visible Fixture Digest

`068b1c3647aea54c12ec3507f7d3ead11c28df0bb475bcd3657ad25b355fe111`

## 7. Hidden Fixture Digest

`f116b3b2b4fd0ea98fc182e41a22830b422b9181ef78f7fec1a95e546848d3bf`

## 8. Hidden Expected-Output Digest

(included in oracle digest)

## 9. Exact External System

Versioned Accumulator with Path-Sensitive Audit.

State: (accumulator_value, path_tag, merge_count)  
Projection: accumulator_value only  
Merge: max(value), concatenate path_tags, increment merge_count  
Audit: path-sensitive operation not visible in public specification

## 10. Exact External Consumer

Consumer observes only the projected integer value. Hidden audit operation may reject states based on path_tag content.

## 11. Visible Information Supplied

- Public types (value, path_tag present in data)
- Public transitions (increment, merge)
- Public projection (integer value)
- Visible examples (increment, merge, partition, equal projection)

## 12. Hidden Information Withheld

- Hidden invariant names
- Hidden fixture expected outcomes
- Audit function semantics
- Forbidden path_tag patterns
- Merge-count threshold

## 13. FDHT Treatment Specification

Uses existing FDHT concepts: history, trajectory, state, projection, equivalence, provenance, scope, transformation, consumer dependency. Does not import oracle or read hidden fixtures.

## 14. Generic-Control Specification

Uses conventional structures: TypedRecord, Event, State, Relation, History, Provenance, Projection, Result. Does not import FDHT, A0, FoldKernel, TrajectoryBoundary, locality, or adapters. Does not import oracle or read hidden fixtures.

## 15. Model/Prompt Parity Audit

No language model used. Both arms use deterministic fixture logic with identical visible inputs.

## 16. FDHT Prediction Digest

`fef2d8808c892c6d99f9400065e8eb9c437e1f11cb5cbaa978c6cc2b94d3cf8e`

## 17. Generic Prediction Digest

`b61d54f267a1696423b840d2d7cfb68f797020cf0de2c09251a6eaa5499d6351`

## 18. Complete Frozen FDHT Prediction Set

| ID | Relation | Distinction |
|----|----------|-------------|
| FDHT_P1 | MUST_REMAIN_DISTINCT | value vs path_tag |
| FDHT_P2 | MUST_REMAIN_DISTINCT | temporary vs failure |
| FDHT_P3 | MAY_COLLAPSE_FOR_CONSUMER | merge order |
| FDHT_P4 | UNKNOWN | merge_count |
| FDHT_P5 | MAY_COLLAPSE_FOR_CONSUMER | history vs state |

## 19. Complete Frozen Generic Prediction Set

| ID | Relation | Distinction |
|----|----------|-------------|
| GEN_P1 | MUST_REMAIN_DISTINCT | value vs path_tag |
| GEN_P2 | MUST_REMAIN_DISTINCT | temporary vs failure |
| GEN_P3 | MAY_COLLAPSE_FOR_CONSUMER | merge order |
| GEN_P4 | UNKNOWN | merge_count |
| GEN_P5 | MAY_COLLAPSE_FOR_CONSUMER | history vs state |

## 20. Hidden Fixtures Revealed

| ID | Distinction Required |
|----|---------------------|
| H1 | YES (unsafe collapse) |
| H2 | NO (safe collapse) |
| H3 | NO (temporary difference) |
| H4 | YES (path-dependent) |
| H5 | NO (history-irrelevant) |
| H6 | NO (projection trap, but audit same) |
| H7 | NO (redundant detail) |
| H8 | YES (missing distinction) |

## 21. Hidden Oracle Outcomes

All hidden fixtures executed. Audit function returns INVALID for forbidden path_tag patterns, AUDIT_REQUIRED for merge_count > 5, VALID otherwise.

## 22. Prediction-to-Hidden Comparison

Both arms predict MUST_REMAIN_DISTINCT for value vs path_tag, covering H1, H4, H8. Both predict MUST_REMAIN_DISTINCT for temporary vs failure, covering H3. Both predict MAY_COLLAPSE for merge order, covering H5. Both predict UNKNOWN for merge_count, covering H7 correctly.

## 23. Correct Necessary Distinctions Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 2 |
| Generic | 2 |

## 24. Missed Necessary Distinctions Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 0 |
| Generic | 0 |

## 25. Correct Safe Collapses Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 2 |
| Generic | 2 |

## 26. False Overconstraints Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 0 |
| Generic | 0 |

## 27. False Equivalences Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 0 |
| Generic | 0 |

## 28. UNKNOWN Results Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 1 |
| Generic | 1 |

## 29. Unjustified-Certainty Results Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 0 |
| Generic | 0 |

## 30. Decision-Level Sufficiency Per Hidden Fixture

| Fixture | FDHT Sufficient | Generic Sufficient |
|---------|-----------------|-------------------|
| H1 | YES | YES |
| H3 | YES | YES |
| H5 | YES | YES |
| H7 | YES (UNKNOWN correct) | YES (UNKNOWN correct) |
| H8 | YES | YES |

## 31. First FDHT Advantage

None observed.

## 32. First Generic Advantage

None observed.

## 33. First FDHT Overconstraint

None observed.

## 34. Anti-Contamination Audit

| Attack | Result |
|--------|--------|
| Hidden-fixture leak | PASS (no access before freeze) |
| Prompt asymmetry | PASS (no model used) |
| Control sabotage | PASS (competent generic) |
| FDHT answer-key attack | PASS (no hidden hints) |
| Post-hoc prediction | PASS (frozen before reveal) |
| Prediction rewording | PASS (frozen) |
| Safe-collapse punishment | PASS (counted correctly) |
| UNKNOWN punishment | PASS (not scored as failure) |
| Universality promotion | PASS (not claimed) |
| One-fixture overclaim | PASS (not claimed) |

## 35. Null-Hypothesis Result

Primary null: FDHT provides no material structural-necessity advantage over a competent generic typed history/state/provenance representation.

**NOT REJECTED.** Both arms perform equivalently.

## 36. Classification

**B — FDHT-SPECIFIC UTILITY NOT ESTABLISHED**

## 37. Classification Justification

Both arms produce identical predictions on all tested distinctions. Both correctly identify necessary distinctions (value vs path_tag, temporary vs failure). Both correctly identify safe collapses (merge order, history vs state). Both correctly return UNKNOWN for underdetermined cases (merge_count). No FDHT-specific advantage is observed. No generic advantage is observed. No overconstraint is observed.

## 38. Justified Claims

- Both arms correctly predict necessary distinctions from visible information.
- Both arms correctly identify safe collapses.
- Both arms correctly return UNKNOWN when visible information is insufficient.
- No hidden information leaked.
- No contamination occurred.

## 39. Unjustified Claims

- FDHT structural necessity.
- FDHT predictive superiority.
- FDHT universality.
- Generic-model inferiority.
- Permanent FDHT mathematics.

## 40. Permanent FDHT Pressure

NONE

## 41. New Mathematics Justified

NO

## 42. New Abstraction Justified

NO

## 43. Promotion Justified

NO

## 44. Next Stage Justified

NO

This fixture does not expose a concrete, natural, untested requirement that FDHT satisfies and a competent generic representation does not.

## 45. Limitations

- Microscopic external system.
- Deterministic prediction logic (no model variability).
- Single fixture family.
- Visible specification may have been sufficient for both arms to reason correctly.

## 46. Recommended Action

**STOP**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
FDHT-specific utility: **NOT ESTABLISHED**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
