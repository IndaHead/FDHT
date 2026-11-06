# FDHT Consumer C₁₆ — Mixed-Polarity Conjunctive Admission Audit

**Status:** FIXTURE-KILL  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `6b3cde62d161adeda21123773229c1fd80ec1f16`

## Question

Can one downstream typed consumer request require simultaneously positive
evidence hA : A and negative evidence notB : ¬B, where neither alone admits
the request?

## Primary fixture

A:

```lean
FamilyClassifierIndependentWitness resolve C
```

B:

```lean
FamilyClassifierFactorsThroughProjections resolve C
```

¬B:

```lean
¬ FamilyClassifierFactorsThroughProjections resolve C
```

Existing theorem:

```lean
familyClassifierIndependentWitness_blocks_factorisation
```

establishes:

```text
A → ¬B
```

## Fixture audit

The preferred fixture fails the non-redundancy requirement.

Positive evidence A already derives the proposed negative evidence ¬B.

Therefore a consumer requiring both A and ¬B would not establish independent
mixed-polarity conjunctive admission.

Two stored proof fields would not imply two independently necessary evidence
requirements.

Alternative fixture families audited:

- AggregateFoldedTrivialClassifierWitness
- ChiralityValueDescribes
- ThreadFamilyKernel

No natural non-redundant mixed-polarity conjunctive consumer was found.

## Classification

**F — FALSE REQUIREMENT / COUNTERMODEL**

## Boundary

Within the audited current FDHT consumer substrate:

**NO NATURAL NON-REDUNDANT MIXED-POLARITY CONJUNCTIVE CONSUMER WAS FOUND.**

This does NOT establish that such a consumer is mathematically impossible or
cannot appear in future FDHT mathematics.

## Architectural consequence

Do not introduce:

- MixedEvidence
- EvidencePolarity
- EvidenceBundle
- generic conjunction machinery
- generic Evidence API
- generic Consumer API
- action semantics

without a concrete future consumer supplying genuinely independent mixed-
polarity prerequisites.

## Non-claims

C₁₆ does NOT establish:

- mixed-polarity evidence is impossible;
- positive and negative evidence cannot coexist;
- conjunction is impossible;
- negative evidence is a veto;
- positive evidence has priority;
- A and ¬B are independent;
- failure to find another fixture is a universal theorem.

## Research significance

C₆ verified genuine conjunctive evidence admission where two independent
positive proof payloads were required.

C₁₆ demonstrates that merely changing one prerequisite to negative polarity
does not automatically produce a new conjunctive consumer shape.

The proposed fixture is redundant because A already entails ¬B.

Therefore:

**INDEPENDENCE MUST BE MATHEMATICAL, NOT STRUCTURAL OR REPRESENTATIONAL.**

## Repository disposition

C₁₆ Lean probe: **NONE**

New mathematics: **NO**

New foundational abstraction: **NO**

Substrate modification: **NO**

lake build: **NOT RUN** — no source changes

strict axiom audit: **NOT RUN** — no source changes

Permanent/main diff: **EMPTY**

Recommended action: **STOP**

Retain FDHT v3.1 scope.
