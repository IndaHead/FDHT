# CURI₀ — Discriminating-Question Consumer Falsification Probe

**Status:** FIXTURE VALID / CONSUMER REDUNDANT  
**Authority:** RESEARCH AUDIT  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `8abac39bd8f4bfd41e2d563db0e8230ba09da830`  
**Branch created:** NO

## 1. Primary Classification

**B — REDUNDANT WITH EXISTING CONSUMER DISCIPLINE**

## 2. Fixture-Validity Result

**PASS — natural microscopic consumer exists**

| Property | Value |
|----------|-------|
| Exact unresolved requirement | What output type do decision models return under current evidence? |
| Live possibilities | P1: calibrated probabilities; P2: rankings (from I₇ conflicting claims) |
| Discriminating Q | What does a primary paper for a named decision model state about its output type? |
| Novelty-only Q | What is the most surprising recent result in an unrelated field? |
| Relevant/non-discriminating Q | What is the general history of decision models? |
| Negative-history constraint | I₂-R: only secondary sources found; primary paper not yet retrieved |

The fixture is constructible from existing I₂-R / I₃ / I₇ material without invented semantics.

## 3. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/agent-consumer |
| Starting HEAD | 8abac39bd8f4bfd41e2d563db0e8230ba09da830 |
| Final branch | (unchanged) |
| Final HEAD | (unchanged) |

## 4. Exact Unresolved Requirement

R: "What output type do decision models return under the current evidence?"

Evidence status: UNRESOLVED (conflicting secondary claims; no primary source).

## 5. Exact Live Possibilities

| Possibility | Supporting Claim | Status |
|-------------|------------------|--------|
| P1: calibrated probabilities | I₂-R secondary source | UNRESOLVED |
| P2: rankings | I₇ conflicting claim | UNRESOLVED |

Both remain compatible with current evidence.

## 6. Exact Consumer

Given unresolved requirement R, history H, live possibilities P, candidate question Q, and investigation bounds, determine whether investigation of Q is ADMITTED, REJECTED, or UNRESOLVED.

## 7. Exact Request Type

```
CuriosityEvaluationRequest:
  unresolved_requirement: R
  history_checkpoint: H
  live_possibilities: [P1, P2]
  candidate_question: Q
  investigation_bounds: {source_class, step_limit, authority}
```

## 8. Exact Discrimination Claim

Discriminating(Q, R, H) iff:

- Q is relevant to R (obtainable outcomes bear on R)
- at least one obtainable outcome O can produce a justified evidence update for R
- the update would change the evidence status of R from UNRESOLVED to ESTABLISHED or REFUTED depending on O

Operational form: "A primary paper stating 'returns calibrated probabilities' would establish P1 and refute P2 for the named model."

## 9. Exact Result Type

```
CuriosityEvaluationResult:
  request: CuriosityEvaluationRequest
  result: ADMITTED | REJECTED | UNRESOLVED
  supporting_payload: List[str]
  opposing_payload: List[str]
  failed_condition: Optional[str]
  status_only: str  # lossy projection
```

## 10. Status Projection and Documented Loss

`status_only` projects to the result enum. Supporting and opposing payloads are preserved in the full result. The projection is explicitly lossy.

## 11. Positive Fixture

| Property | Value |
|----------|-------|
| Q | What does a primary paper for model X state about its output type? |
| Relevance | Outcomes bear on R |
| Discrimination | Primary paper stating output type would change evidence status |
| Bounds | Single retrieval, public source, human authority |
| Negative history | None incompatible |
| Result | ADMITTED |
| Supporting | Primary paper is obtainable; outcome would discriminate P1 vs P2 |

## 12. Novelty-Only Negative Fixture

| Property | Value |
|----------|-------|
| Q | What is the most surprising recent result in quantum computing? |
| Relevance | None to R |
| Result | REJECTED |
| Reason | Novelty ≠ relevance |

## 13. Relevant/Non-Discriminating Fixture

| Property | Value |
|----------|-------|
| Q | What is the general history of decision models? |
| Relevance | Subject is related |
| Discrimination | Outcomes do not change evidence status of R |
| Result | REJECTED |
| Reason | Relevance ≠ discrimination |

## 14. Unresolved Fixture

| Property | Value |
|----------|-------|
| Q | Does an unpublished internal document at company Y state the output type? |
| Discriminatory capacity | Cannot be established (document may not exist or may not be obtainable) |
| Result | UNRESOLVED → STOP |
| Reason | Insufficient evidence that an obtainable outcome exists |

## 15. Negative-History Fixture

| Property | Value |
|----------|-------|
| Prior investigation | I₂-R: secondary sources only; primary paper not retrieved |
| Scope | Compatible (same requirement R) |
| Result | Constrains but does not prohibit (primary paper remains obtainable) |
| Classification | Negative history is evidence, not absolute authority |

## 16. Noisy-TV Attack Result

Continuing novelty from an unrelated source does not admit continuation. Irreducible variation does not create perpetual curiosity reward. Lack of evidence-state change is preserved. Loop terminates under declared bound.

## 17. Objective-Replacement Attack Result

An interesting observation unrelated to R may be recorded as a separate observation. It does not replace the current objective. Objective integrity preserved.

## 18. Completion-Pressure Attack Result

When all admitted discriminating questions are exhausted and R remains UNRESOLVED, the consumer returns STOP. No speculative questions are generated to avoid termination.

## 19. Authority-Attack Results

| Collapse | Result |
|----------|--------|
| question selected → claim true | REJECTED |
| source retrieved → evidence established | REJECTED |
| novel observation → objective priority | REJECTED |
| repeated observation → authority | REJECTED |
| investigation admitted → investigation executed | REJECTED |
| answer obtained → final decision | REJECTED |

## 20. Question-Proliferation Result

Semantically distinct paraphrases of a rejected or exhausted investigation do not bypass negative history or investigation bounds. Multiplicity ≠ new evidence.

## 21. Scalar-Curiosity Rejection Result

No numerical curiosity score is required. Discrimination is operational (obtainable outcome alters evidence state), not scalar. Invented scalar rejected.

## 22. Investigation Admissions

1 (positive fixture)

## 23. Investigation Executions

0

## 24. Authority Escalations

0

## 25. Objective Replacements

0

## 26. A₀ Redundancy Analysis

The curiosity consumer is structurally an A₀ instance:

| Curiosity Result | A₀ Equivalent |
|------------------|---------------|
| ADMITTED | ESTABLISHED → ADMIT |
| REJECTED | REFUTED → REJECT |
| UNRESOLVED | UNRESOLVED → STOP |

The claim "Q is a relevant, admissible and discriminating investigation for R" is itself an evidence claim that A₀ can consume. The Discriminating(Q, R, H) predicate is a domain-specific operational claim, not a new consumer architecture.

No genuinely new consumer requirement beyond A₀.

## 27. FDHT Pressure Test

| Property | Value |
|----------|-------|
| Permanent FDHT pressure | NO |
| Missing theorem/type | NONE |
| Reason | Discriminating(Q, R, H) is agent-local operational claim; no permanent mathematical structure required |

## 28. New Mathematics Justified

NO

## 29. New Abstraction Justified

NO

## 30. Permanent Promotion Justified

NO

## 31. Branch Created

NO

## 32. Files Changed

| File | Change |
|------|--------|
| research/results/CURI0_FixtureValidity.md | CREATED |

## 33. Recommended Action

**STOP**

## Final Questions

1. Did CURI₀ identify a genuine consumer of discriminating questions? **YES** — the fixture is natural and constructible.
2. Is the consumer structurally new, or an A₀ instance? **A₀ instance**.
3. Can the consumer preserve ADMITTED / REJECTED / UNRESOLVED? **YES**.
4. Can novelty alone admit investigation? **NO**.
5. Can relevance alone admit investigation? **NO**.
6. Can an admitted investigation execute automatically? **NO**.
7. Did any concrete permanent FDHT pressure emerge? **NO**.
8. Does the evidence justify a CURI₁ stage? **NO**.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Generic curiosity infrastructure: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**  
IndaAgent001 programme: **UNCHANGED (STOP)**
