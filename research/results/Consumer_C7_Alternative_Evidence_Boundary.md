# FDHT Consumer C₇ — Alternative Evidence Admission Boundary

**Status:** BOUNDARY VERIFIED / FIXTURE-KILL  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `41b6ec32eb5be6c761affc52e94dc77016bc3ec8`

## Exact research question

Can one exact downstream request type be admitted through either of two
genuinely distinct and independently sufficient proof routes while preserving
route identity and proof payloads?

## Fixture requirements

A valid C₇ fixture requires:

- P : Prop — mathematically meaningful
- Q : Prop — mathematically meaningful
- R : downstream request type
- P and Q genuinely distinct (neither subsumes the other)
- Evidence hP : P exists naturally
- Evidence hQ : Q exists naturally
- P alone can construct R
- Q alone can construct the SAME R type
- Neither route requires the other proof
- Neither route is a renamed wrapper around the other

## Candidate audit

| Candidate | P | Q | Result |
|-----------|---|---|--------|
| 1 | ChiralityTransition | FoldedTrivialChiralityTransition | **REJECTED** — Q derives P by definition |
| 2 | FoldedTrivialChiralityTransition | RelationalAggregateChiralityTransition | **REJECTED** — Q derives P by definition |
| 3 | ChiralityTransition | RelationalAggregateChiralityTransition | **REJECTED** — Q derives P through nested definitions |
| 4 | ChiralityValueDescribes .separated | ChiralityValueDescribes .aligned | **REJECTED** — distinct propositions, not same request |

## Nesting structure

```
RelationalAggregateChiralityTransition
= IsRelationallyAggregate ∧ FoldedTrivialChiralityTransition

FoldedTrivialChiralityTransition
= ThreadFamilyKernel ∧ ChiralityTransition

ChiralityTransition
= ChiralityValueDescribes fromValue ∧ ChiralityValueDescribes toValue
```

Each stronger theorem derives the weaker one by definition.

## Fixture-kill result

C₇ did not produce a Lean consumer implementation because the required natural
fixture failed before implementation: the audited chirality-transition
candidates are nested/subsuming, while the separated/aligned description
candidates concern different propositions rather than alternative sufficient
routes to one common downstream request.

**NO NATURAL ALTERNATIVE SUFFICIENT ROUTES FOUND.**

## Classification

**F — FALSE REQUIREMENT / COUNTERMODEL**

## Boundary interpretation

The result constrains the CURRENT AUDITED CONSUMER SURFACE.

It does not prove that no future FDHT domain can contain genuine alternative
sufficient evidence routes.

## Explicit non-claims

This result is NOT:

- a compiler-verified C₇ Lean implementation
- a proof that no future FDHT domain can ever contain alternative sufficient routes
- a universal impossibility theorem
- new mathematics
- a foundational theorem
- justification for an AlternativeEvidence API

## Distinctions preserved

- fixture kill ≠ theorem refutation
- no natural fixture found ≠ universal impossibility
- nested evidence ≠ alternative evidence
- stronger theorem deriving weaker theorem ≠ independent admission route
- distinct propositions ≠ same downstream request
- research boundary ≠ permanent mathematics
- negative result ≠ failed research
- no implementation required ≠ missing work

## Architectural commentary

THE ARCHITECTURE STOPPED WHERE THE MATHEMATICS STOPPED.

## Disposition

**DO NOT INTRODUCE ALTERNATIVE-EVIDENCE MACHINERY WITHOUT A CONCRETE FUTURE
CONSUMER THAT SUPPLIES A VALID NON-SUBSUMING FIXTURE.**

Retain FDHT v3.1 scope. No permanent promotion justified.
