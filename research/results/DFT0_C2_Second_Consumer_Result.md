# DFT0-C2 — Second Consumer Observational-Sufficiency Probe

**Status:** SECOND CONSUMER SUFFICIENCY COUNTERMODEL  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `1375d3894974d7e23bc59ba021726d3b568f03ed`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/decisive-falsification |
| Starting HEAD | 1375d3894974d7e23bc59ba021726d3b568f03ed |
| Working branch | research/decisive-falsification-consumer2 |

## 2. Working Branch

research/decisive-falsification-consumer2

## 3. Final HEAD

(recorded after commit)

## 4. Unchanged Observation Surface

O(xs) = xs.length % 2 == 0

(Length parity, unchanged from DFT0)

## 5. Unchanged Concrete Domain

All lists of length ≤ 2 over {0, 1}:
[[], [0], [1], [0,0], [0,1], [1,0], [1,1]]

## 6. External Consumer 2

C2(xs) = terminal-event disposition

## 7. Independent Consumer Motivation

A downstream component requiring the disposition of the most recent recorded event. Does not ask whether the history is empty, whether length is even, or for complete history identity.

## 8. Exact Consumer 2 Semantics

| History | Result |
|---------|--------|
| [] | NO_EVENT |
| non-empty ending in 0 | BLOCK |
| non-empty ending in 1 | ALLOW |

## 9. Tested Sufficiency Theorem

C2Sufficient :=
  ∀ x y in FrozenDomain, O(x) = O(y) → C2(x) = C2(y)

## 10. Search Completeness

COMPLETE. Domain size 7. All 49 ordered pairs enumerated.

## 11. Domain Size

7

## 12. Pair Count

49

## 13. Observational-Equivalence Pair Count

25

## 14. Collision Count

12

## 15. Minimal Witness

x = [0]  
y = [1]

## 16. Lean Countermodel Theorem

isC2Collision:
  [0] ≠ [1] ∧ O([0]) = O([1]) ∧ C2([0]) ≠ C2([1]) ∧ [0] ∈ domain ∧ [1] ∈ domain

## 17. Axiom Footprint

(deferred to repository build)

## 18. Consumer 1 Lost Distinction

Empty vs non-empty information (C1: Accept vs Reject)

## 19. Consumer 2 Lost Distinction

Terminal-event content (C2: BLOCK vs ALLOW)

## 20. Same/Different Loss Classification

**STRUCTURALLY DIFFERENT LOST DISTINCTIONS**

C1 distinguishes empty from non-empty. C2 distinguishes terminal event content (BLOCK vs ALLOW). The witness pairs differ: C1 uses [] vs [0,0]; C2 uses [0] vs [1].

## 21. Anti-Contamination Audit

| Attack | Result |
|--------|--------|
| Observation refinement | PASS |
| Domain change | PASS |
| Consumer tailoring | PASS |
| C1 reuse | PASS |
| Predicted-witness shortcut | PASS |
| Content/parity collapse | PASS |
| No-event/BLOCK collapse | PASS |
| Last-event/full-history collapse | PASS |
| Countermodel overclaim | PASS |
| Refinement promotion | PASS |

## 22. Classification

**A — SECOND CONSUMER SUFFICIENCY COUNTERMODEL**

## 23. Justified Claims

- The same frozen observation loses at least two different kinds of consumer-relevant information in the tested domain.
- C2 requires terminal-event disposition, not empty/non-empty.
- No contamination occurred.

## 24. Unjustified Claims

- All FDHT observations fail.
- FDHT is false.
- FDHT requires repair.
- Universal insufficiency.

## 25. Permanent FDHT Pressure

NONE

## 26. Refinement Justified

NO

## 27. New Mathematics Justified

NO

## 28. Promotion Justified

NO

## 29. Next Stage Justified

NO

## 30. Recommended Action

**STOP**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Refinement: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
