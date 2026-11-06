# FDHT Consumer Probe C₅ — Evidence-Gated Narrowing

**Status:** PROBE VERIFIED  
**Authority:** RESEARCH RESULT ONLY  
**Branch:** `research/consumer-layer`  
**HEAD:** `73ab78d4e6f52b19970b98586c7f635fe53c19d4`  
**Promotion:** NOT PROMOTED

## Summary

C₅ verified evidence-gated, non-destructive constraint refinement over the
C₄ branching fixture.

Both Branch B and Branch C remain ESTABLISHED for their own claims, but a
later requirement for `RelationalAggregateChiralityTransition` is satisfied
by Branch C evidence and not by Branch B's
`FoldedTrivialChiralityTransition` evidence.

## Verified distinctions

- same status ≠ same downstream capability;
- requirement satisfaction ≠ ranking;
- narrowing ≠ selection;
- narrowing ≠ destructive pruning;
- non-admission to a later request ≠ refutation;
- non-admission ≠ invalidation;
- narrowing ≠ action.

Both original branches and proof payloads remain preserved.

## Not required

No `INADMISSIBLE`, explicit Applicability, `MULTIPLE`, merge semantics,
action layer, generic narrowing API, new mathematics, or foundational
abstraction was required.

## Probe Artefact

`research/probes/consumer_layer/c5_evidence_gated_narrowing_consumer.lean`

## Trust

| Gate | Result |
|------|--------|
| lake build | EXIT 0 (49 jobs) |
| strict axiom audit | PASS (77 source files) |
| sorryAx | ABSENT |
| Classical.choice | ABSENT |
| permanent/main diff | EMPTY |

## Disposition

**PROBE-LOCAL ONLY. EXISTING SUBSTRATE SUFFICIENT.**

Retain FDHT v3.1 scope. No permanent promotion justified.
