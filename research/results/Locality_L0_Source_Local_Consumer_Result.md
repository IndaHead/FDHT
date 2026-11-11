# Locality L0 — Source-Local Consumer Relation POC

**Status:** SOURCE-LOCAL CONSUMER RELATION OBSERVED IN FIXTURE  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `11bb4e8cc8c25a30dabedaf402030e38fb324c2e`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/agent-consumer |
| Starting HEAD | 11bb4e8cc8c25a30dabedaf402030e38fb324c2e |
| Working branch | research/locality-poc |

## 2. Files Created/Changed

| File | Change |
|------|--------|
| research/agents/IndaAgent001/locality/locality_poc.py | CREATED |
| research/agents/IndaAgent001/locality/test_locality_poc.py | CREATED |
| research/results/Locality_L0_Source_Local_Consumer_Result.md | CREATED |

## 3. Exact Hypothesis

For at least one microscopic fixture, a source-local evaluation route can preserve the exact consumer decision and required provenance while moving strictly less source information than a control route that first transports the complete source relation.

## 4. Exact Fixture

One frozen source relation:

```
N1 --supports--> N2
source_id: src_001
provenance: fixture-local-inert
```

No graph. No neighbouring nodes. No inferred edges.

## 5. Synthetic/Real Status of Fixture

**Synthetic / fixture-local inert.**

This fixture cannot establish anything about biological connectomes or external real-world information transport. No genuine externally sourced relation was available as a frozen local artefact with provenance.

## 6. Control Information Flow

```
SourceRelation (complete)
  -> ConsumerLocalCopy (5 fields: source_id, source_node, relation, target_node, provenance)
  -> ConsumerEvaluator
  -> EvaluationResult
  -> A0 decision
```

## 7. Source-Local Information Flow

```
ConsumerRequirement
  -> SourceLocalEvaluator (at source)
  -> EvaluationResult (evidence + provenance only)
  -> A0 decision
```

Complete SourceRelation does not cross the boundary.

## 8. Per-Field Information Movement

| Field | Control | Source-Local |
|-------|---------|--------------|
| source_id | YES | NO |
| source_node | YES | NO |
| relation | YES | NO |
| target_node | YES | NO |
| provenance | YES | YES (as evidence) |
| evidence payload | — | YES |

## 9. Six-Memory-Class Audit

| Class | Required to Cross | Required to Return | Justified to Persist |
|-------|-------------------|--------------------|----------------------|
| ObservationRecord | NO | NO | NO |
| ClaimRecord | NO | NO | NO |
| EvidenceRecord | NO | NO | NO |
| NegativeRecord | NO | NO | NO |
| ObjectiveRecord | NO | NO | NO |
| CheckpointRecord | NO | NO | NO |

None of the six memory classes are required to cross the source boundary for this fixture. Evidence is returned as a payload, not as a class instance.

## 10. Positive Result

| Route | Status | Decision | Fields Moved |
|-------|--------|----------|--------------|
| Control | ESTABLISHED | ADMIT | 5 |
| Source-local | ESTABLISHED | ADMIT | 2 |

Decisions equal. Provenance sufficient. Source-local does not copy complete SourceRelation.

## 11. Refuted Result

| Route | Status | Decision | Fields Moved |
|-------|--------|----------|--------------|
| Control | REFUTED | REJECT | 5 |
| Source-local | REFUTED | REJECT | 2 |

Decisions equal. Same locality discriminator.

## 12. Unresolved Result

| Route | Status | Decision | Fields Moved |
|-------|--------|----------|--------------|
| Control | UNRESOLVED | STOP | 5 |
| Source-local | UNRESOLVED | STOP | 2 |

Decisions equal. No guessing. No source expansion.

## 13. Adversarial Results

| Attack | Result |
|--------|--------|
| Retrieval collapse | PASS |
| Possession collapse | PASS |
| Authority collapse | PASS |
| Persistence collapse | PASS |
| Objective replacement | PASS |
| Scope expansion | PASS |
| Information-volume attack | PASS |
| Status-only collapse | PASS |

## 14. Provenance Assessment

Provenance preserved in both routes. Source-local returns provenance as part of the evidence payload without returning the complete source relation.

## 15. Authority Escalations

0

## 16. Objective Replacements

0

## 17. Persistence Differences

None. No memory classes are auto-persisted in either route.

## 18. Exact First Divergence

Information volume: control moves 5 source fields; source-local moves 2 evidence fields. Decision and status are identical.

## 19. Classification

**A — SOURCE-LOCAL CONSUMER RELATION OBSERVED IN FIXTURE**

## 20. Justified Claims

- Source-local evaluation can preserve the exact consumer decision.
- Source-local evaluation can preserve required provenance.
- Source-local evaluation moves strictly less source information than control.
- A0 discipline is preserved in both routes.
- Adversarial collapses are rejected.

## 21. Unjustified Claims

- Universal superiority of source-local evaluation.
- Applicability to biological connectomes.
- Applicability to external real-world information transport.
- General locality abstraction.
- Any permanent FDHT mathematics.

## 22. FDHT Pressure

NONE

## 23. New Mathematics Justified

NO

## 24. Promotion Justified

NO

## 25. Recommended Action

**STOP**

A later L1 may be considered only if L0 exposes a concrete, natural, untested requirement not absorbed by existing consumer discipline.

This fixture does not expose such a requirement.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Generic locality infrastructure: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
