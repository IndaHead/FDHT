# External Consumer E1 — State-Based G-Counter CRDT Convergence

**Status:** REPRESENTATION WITH ADAPTER-LOCAL CRDT ALGEBRA  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `a7369ed0628b953fc5667ddc31258ba829a3976d`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/external-consumer-slsa |
| Starting HEAD | a7369ed0628b953fc5667ddc31258ba829a3976d |
| Working branch | research/external-consumer-crdt |

## 2. Working Branch

research/external-consumer-crdt

## 3. Final HEAD

(recorded after commit)

## 4. External Source Family

State-based CRDT literature. Grow-only counter (G-counter).

## 5. Frozen External Requirement

"After independently accepting updates, do replicas that have incorporated the same logical updates expose equivalent state under the frozen G-counter semantics?"

## 6. Frozen Requirement Digest

`829e7558cb8a323c5f81780d57bc0dd6f0ef20828646cd4b447ded90294ab1a1`

## 7. External Consumer Question

After independently accepting updates, do replicas that have incorporated the same logical updates expose equivalent state under the frozen G-counter semantics?

## 8. Exact External State

GCounterState with components (Map[ReplicaId, non-negative integer]) and incorporated_updates (Set[UpdateId]).

## 9. Exact External Operations

| Operation | Definition |
|-----------|------------|
| Increment | increment_r(state)[r] = state[r] + 1; other components unchanged |
| Merge | merge(x, y)[r] = max(x[r], y[r]); update sets unioned |
| Value | sum of all components |
| Partial order | x ≤ y iff for every r: x[r] ≤ y[r] |

## 10. Exact External Result States

| State | Definition |
|-------|------------|
| CONVERGED | Same updates and equivalent complete state |
| DIVERGED | Same updates but different complete state |
| PRECONDITION_NOT_MET | Update sets differ; convergence not required |

## 11. All External Fixtures

| ID | Expected |
|----|----------|
| C1 | CONVERGED, state {A:2, B:3}, value 5 |
| C2 | CONVERGED, state {A:2, B:1}, value 3 |
| C3 | Commutative |
| C4 | Associative |
| C5 | Idempotent |
| C6 | PRECONDITION_NOT_MET |
| C7 | CONVERGED |
| C8 | Invariant failure |
| C9 | DIVERGED |
| C10 | Value equal, state unequal, PRECONDITION_NOT_MET |
| C11 | DIVERGED |
| C12 | CONVERGED (histories may differ) |
| C13 | Invariant failure |

## 12. External Test Results

All 13 fixtures pass. All expected outcomes match.

## 13. Frozen Expected-Results Digest

`f3050bf3372c213db055cfe0c7177bf6b4f9ed59b1a59373f09de02f4e7f70a8`

## 14. Stage-Order Audit

| Stage | Status |
|-------|--------|
| E1-A: Freeze requirements | COMPLETE (before adapter) |
| E1-B: Implement external consumer | COMPLETE (no FDHT imports) |
| E1-C: Freeze expected results | COMPLETE |
| E1-D: Implement FDHT adapter | COMPLETE |
| E1-E: Compare results | COMPLETE |

## 15. Import-Separation Audit

external_gcounter.py does not import FDHT, A0, locality, SLSA, or adapter modules. It imports only from frozen_crdt_requirements.

## 16. FDHT Adapter Design

The adapter preserves the complete external convergence result, including same_logical_updates, full_state_equal, observable_value_equal, and the external result state. An optional status projection (CONVERGED→ESTABLISHED, DIVERGED→REFUTED, PRECONDITION_NOT_MET→UNRESOLVED) is recorded as LOSSY and is not the primary representation.

## 17. Candidate External-to-FDHT Mapping

The primary representation preserves the external result intact. The optional A0 projection is examined only as a lossy status projection after the full external state relation has been preserved.

## 18. Translation Loss Ledger Summary

| Status | Count |
|--------|-------|
| EXACT | 8 |
| TRANSFORMED_LOSSLESS | 7 |
| LOSSY | 0 (primary representation) |
| UNREPRESENTABLE | 0 |
| ADDED_BY_FDHT | 0 |

The optional A0 projection is recorded as LOSSY but is not the primary representation.

## 19. Fixture-by-Fixture Outcome Comparison

All fixtures: external result equals adapted external_result. No outcome changes.

## 20. Key Distinctions Preserved

| Distinction | Preserved |
|-------------|-----------|
| Full-state equality ≠ observable-value equality | YES |
| Update-set equality ≠ delivery-history equality | YES |
| Temporary divergence ≠ DIVERGED | YES |
| Convergence ≠ history identity | YES |
| Partial order ≠ total order | YES |

## 21. Anti-Contamination Attacks

| Attack | Result |
|--------|--------|
| A0 coercion | PASS (full result preserved) |
| Temporary-divergence collapse | PASS |
| Arrival-order authority | PASS (not used) |
| Duplicate-effect attack | PASS |
| Projection-equality collapse | PASS |
| Full-state/history collapse | PASS |
| History-overconstraint | PASS |
| History-deletion attack | PASS |
| Coordination injection | PASS (none added) |
| Merge-law deletion | PASS (none deleted) |
| Update-set/history collapse | PASS |
| Update-set/state collapse | PASS |
| Precondition-to-unresolved collapse | PASS (reason preserved) |
| External-fixture mutation | PASS (none) |
| FDHT-added requirement | PASS (none) |
| External-condition deletion | PASS (none) |
| Passing-test promotion | PASS (not claimed) |

## 22. First Semantic Divergence

None. All external outcomes preserved.

## 23. Lossy Translations

0 in primary representation. Optional A0 projection is LOSSY but not primary.

## 24. Unrepresentable Distinctions

0

## 25. FDHT-Added Conditions

0

## 26. Deleted External Conditions

0

## 27. Authority Escalations

0

## 28. Classification

**B — REPRESENTATION WITH ADAPTER-LOCAL CRDT ALGEBRA**

## 29. Justification for Classification

All external behaviour is preserved. CRDT-specific state and merge laws (commutativity, associativity, idempotence, inflation, pointwise-max merge) remain adapter-local. No permanent FDHT gap is exposed. No external semantics are changed. Temporary divergence is not treated as failure. Observable-value equality is not collapsed into full-state equality. Convergence does not require history identity.

Classification is not A because the adapter introduces operational content (the optional status projection and the research-local types) that is not part of the external specification, even though it does not change outcomes.

## 30. Justified Claims

- All frozen CRDT distinctions are represented.
- All external fixture outcomes are preserved.
- No semantic loss occurs in the primary representation.
- No external requirement is deleted.
- No FDHT-only requirement is added that changes outcomes.
- Temporary divergence is preserved without being classified as failure.
- Observable-value equality is distinguished from full-state equality.
- Convergence does not require history identity.

## 31. Unjustified Claims

- FDHT universality.
- FDHT completeness.
- Generic CRDT absorption.
- Distributed-state convergence as a permanent FDHT property.
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
Generic CRDT API: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
