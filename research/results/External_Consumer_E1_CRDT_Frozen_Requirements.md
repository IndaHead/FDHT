# External Consumer E1 — State-Based G-Counter CRDT Convergence

**Status:** FROZEN EXTERNAL REQUIREMENTS  
**Authority:** EXTERNAL SPECIFICATION  
**External Source Family:** State-based CRDT literature  
**Frozen Before:** Any FDHT adapter implementation

## External Source Family

State-based Conflict-free Replicated Data Types (CRDTs), specifically the grow-only counter (G-counter).

## External Consumer Question

"After independently accepting updates, do replicas that have incorporated the same logical updates expose equivalent state under the frozen G-counter semantics?"

## Exact G-Counter State

| Field | Description |
|-------|-------------|
| components | Map from ReplicaId to non-negative integer |
| incorporated_updates | Set of UpdateId |

## Exact Local-Update Operation

A local increment at replica r:

- increases only component r by 1
- generates one unique UpdateId
- adds that UpdateId to incorporated_updates
- preserves all other components
- never reduces any component

Formally: increment_r(state)[r] = state[r] + 1; for all q ≠ r, increment_r(state)[q] = state[q].

## Exact Merge Operation

merge(x, y)[r] = max(x[r], y[r])

The merged incorporated_updates is the set union of both update sets.

The merge function must not use addition, timestamps, arrival order, last writer, global sequence order, coordination, or consensus.

## Exact Observable-Value Projection

value(state) = sum of all replica components

Observable value ≠ complete component state.

## Exact Partial Order

x ≤ y iff for every replica component r: x[r] ≤ y[r]

## Exact Convergence Precondition

Convergence is required only when incorporated_updates(x) = incorporated_updates(y).

## Exact Consumer Result States

| State | Definition |
|-------|------------|
| CONVERGED | Both replicas have incorporated the same logical updates and expose equivalent complete G-counter state. |
| DIVERGED | Both replicas have incorporated the same logical updates but expose different complete G-counter states. |
| PRECONDITION_NOT_MET | The replicas have not incorporated the same logical updates. Convergence is therefore not currently required. |

Temporary replica inequality during a partition is not DIVERGED unless the same-update-set precondition holds.

## Exact Algebraic Obligations

| Obligation | Statement |
|------------|-----------|
| Commutativity | merge(x, y) = merge(y, x) |
| Associativity | merge(merge(x, y), z) = merge(x, merge(y, z)) |
| Idempotence | merge(x, x) = x |
| Inflation | x ≤ increment_r(x); x ≤ merge(x, y) |
| Strong convergence | If incorporated_updates(x) = incorporated_updates(y) then complete_state(x) = complete_state(y) for valid executions. |

## Exact Fixtures

| ID | Description | Expected |
|----|-------------|----------|
| C1 | Same updates, different delivery order | CONVERGED, state {A:2, B:3}, value 5 |
| C2 | Duplicate state delivery | CONVERGED, state {A:2, B:1}, value 3 |
| C3 | Commutative merge | States equal |
| C4 | Associative merge | States equal |
| C5 | Idempotent merge | merge(X,X) = X |
| C6 | Partition before reconciliation | PRECONDITION_NOT_MET |
| C7 | Reconciliation after partition | CONVERGED, state {A:2, B:3}, value 5 |
| C8 | Broken additive merge | Invariant failure |
| C9 | Lost component | DIVERGED |
| C10 | Same value, different complete state | Value equal, state unequal, PRECONDITION_NOT_MET if update sets differ |
| C11 | Same updates, different full state | DIVERGED |
| C12 | History difference with valid convergence | CONVERGED, histories may differ |
| C13 | Inflation failure | Invariant failure |

## Exact Expected Outcomes

Frozen before adapter implementation. See external_crdt_expected_results.json after E1-C.

## Explicit Out-of-Scope Claims

This fixture does NOT claim:
- implementation of all CRDT variants
- operation-based CRDTs
- delta-state CRDTs
- sets, removals, tombstones
- registers, last-writer-wins
- vector clocks
- graphs
- consensus
- leader election

## Terminology Firewall

This document does not use:
- FDHT
- A0
- consumer edge
- trajectory boundary
- FoldKernel
- provenance plane
- ESTABLISHED
- REFUTED
- UNRESOLVED
- ADMIT
- REJECT
- STOP

Those terms belong only to the later adapter stage.
