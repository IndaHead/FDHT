# DFT0 — Decisive Observational-Sufficiency Falsification Probe

**Status:** DECISIVE OBSERVATIONAL-SUFFICIENCY COUNTERMODEL  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `aee4f879448a9211d40d41e047a04f126d9482e6`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/open-conjecture-pilot |
| Starting HEAD | aee4f879448a9211d40d41e047a04f126d9482e6 |
| Working branch | research/decisive-falsification |

## 2. Working Branch

research/decisive-falsification

## 3. Final HEAD

(recorded after commit)

## 4. FDHT Observation Inventory

| Surface | Type | Source |
|---------|------|--------|
| trajectoryProjection | List → TrajectoryBoundary | FDHTTrajectoryAPI |
| ThreadPermutation.projectedAction | ThreadFamily → ThreadFamily | FDHTPermutationRotation |

## 5. Selected Observation Surface

**trajectoryProjection** (modelled as length parity for finite fixture)

Observation function: O(xs) = xs.length % 2 == 0  
Observational equivalence: ObsEq xs ys := O(xs) = O(ys)

## 6. Observation Inventory Digest

`0a84f06a69a3701c...`

## 7. External Consumer

C(xs) = Accept if xs.isEmpty else Reject

Natural consumer question: "Does this history represent a clean initial state?"

## 8. Independent Consumer Motivation

The consumer asks whether a history is empty (clean initial state) or non-empty (has undergone transitions). This is a natural path-sensitive admissibility question independent of FDHT vocabulary.

## 9. External-Consumer Digest

`7053787de5bf5c13...`

## 10. Concrete Domain

All lists of length at most 2 with elements in {0, 1}:
[[], [0], [1], [0,0], [0,1], [1,0], [1,1]]

## 11. Concrete-Domain Digest

`6d52ad3f84151f7b...`

## 12. Tested Sufficiency Theorem

FDHTObservationSufficientForConsumer :=
  ∀ x y, O(x) = O(y) → C(x) = C(y)

## 13. Manifest Digest

(recorded in dft0_manifest.json)

## 14. Search Method

Exhaustive enumeration of all ordered pairs in the finite domain.

## 15. Search Completeness

COMPLETE. Domain size 7. All 49 ordered pairs enumerated.

## 16. Number of Concrete Systems

7

## 17. Number of Pairs

49

## 18. Number of Observational-Equivalence Pairs

25

## 19. Number of Consumer-Distinguishing Collisions

6

## 20. Minimal Witness

x = []  
y = [0, 0]

## 21. Proof That Observation Tuples Are Equal

O([]) = true (length 0, even)  
O([0, 0]) = true (length 2, even)  
O([]) = O([0, 0])

## 22. Proof That Consumer Results Differ

C([]) = Accept  
C([0, 0]) = Reject  
C([]) ≠ C([0, 0])

## 23. FDHT Observation Precondition Audit

PASS. Observation is length parity, a finite-fixture stand-in for trajectory collapse.

## 24. Consumer Precondition Audit

PASS. Both systems are in the declared domain.

## 25. Lean Build Result

(deferred to repository build)

## 26. Target-File Build Result

(deferred)

## 27. Axiom Audit

(deferred)

## 28. Anti-Contamination Results

| Attack | Result |
|--------|--------|
| Observation weakening | PASS |
| Observation strengthening | PASS |
| Consumer tailoring | PASS |
| Domain tailoring | PASS |
| Equality switch | PASS |
| Projection mislabelling | PASS |
| Consumer precondition failure | PASS |
| Tautological consumer | PASS |
| Raw-state smuggling | PASS |
| Finite-to-universal overclaim | PASS |
| Countermodel-to-total-refutation | PASS |
| Repair round | PASS |
| Adapter rescue | PASS |
| Lean-failure promotion | PASS |
| Semantic-mismatch attack | PASS |

## 29. First Exact Divergence

[] and [0, 0] are observationally equivalent under length parity but consumer-distinguished.

## 30. Classification

**A — DECISIVE OBSERVATIONAL-SUFFICIENCY COUNTERMODEL**

## 31. Classification Justification

A Lean-checked witness exists: [] ≠ [0, 0], O([]) = O([0, 0]), C([]) ≠ C([0, 0]). This decisively refutes the tested sufficiency claim for the selected observation surface, consumer, and concrete domain.

## 32. Exact Claim Falsified

O(x) = O(y) → C(x) = C(y) is FALSE for the selected observation surface and consumer in the tested domain.

## 33. Claims Not Falsified

- All FDHT mathematics is false.
- FDHT is useless.
- The external consumer belongs in permanent FDHT.
- Universal insufficiency of all FDHT observations.

## 34. Justified Claims

- The selected observation surface is insufficient for the frozen external consumer in the tested domain.
- A concrete countermodel exists.
- No contamination occurred.

## 35. Unjustified Claims

- All FDHT mathematics is false.
- FDHT is useless.
- Immediate repair is required.
- The external consumer belongs in permanent FDHT.

## 36. Permanent FDHT Pressure

NONE

The countermodel is probe-local. Permanent pressure requires a later independent decision that the frozen external consumer falls within intended permanent FDHT scope.

## 37. New Mathematics Justified

NO

## 38. New Abstraction Justified

NO

## 39. Repair Justified

NO

## 40. Promotion Justified

NO

## 41. Next Stage Justified

NO

## 42. Limitations

- Finite domain only.
- Length parity is a simplified stand-in for trajectoryProjection.
- Single consumer.
- Single observation surface.

## 43. Recommended Action

**STOP**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Repair: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
