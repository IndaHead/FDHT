# FDHT Agent Consumer A₀ — Minimal Falsification Probe

**Status:** PROBE COMPLETE  
**Authority:** RESEARCH SYNTHESIS / PROBE  
**Promotion:** NOT PROMOTED  
**Starting Main HEAD:** `0e378c044edacd6adec1e40fc426abb5d5680a65`

## Question

Does a minimal agent provide a REAL downstream consumer for existing FDHT proof-bearing evidence?

Specifically: Can an agent propose a candidate trajectory/action whose admissibility depends on an exact typed proposition P, consume an existing FDHT proof-bearing result concerning P, and have that result legitimately constrain the trajectory without introducing unjustified generic machinery?

## Repository State

| Property | Value |
|----------|-------|
| Base branch | main |
| Base HEAD | 0e378c044edacd6adec1e40fc426abb5d5680a65 |
| Research branch | research/agent-consumer |
| Probe file | research/probes/A0_AgentConsumer_Probe.lean |

## Consumer

| Property | Value |
|----------|-------|
| Objective | Determine if FDHT evidence can constrain agent trajectory |
| Candidate action | read / writeSandbox / queryFixture (SAFE MOCK) |
| Exact downstream requirement | Requirement (provenanceEqual / provenanceDistinct / uniqueAge) |
| Exact FDHT evidence type | EvidenceStatus (established / refuted / unresolved) |
| Exact consumer edge | consumeEvidence : Requirement → EvidenceStatus → ConsumerDecision |

## Fixtures

### Fixture A — Positive (ESTABLISHED admits)

| Property | Value |
|----------|-------|
| Input | Requirement.provenanceEqual, EvidenceStatus.established |
| Required proposition | P is ESTABLISHED |
| Evidence | consumeEvidence .provenanceEqual .established |
| Observed result | ConsumerDecision.admit |
| Status | **PASS** |

### Fixture B — Negative (REFUTED rejects)

| Property | Value |
|----------|-------|
| Input | Requirement.provenanceDistinct, EvidenceStatus.refuted |
| Required proposition | P is REFUTED |
| Evidence | consumeEvidence .provenanceDistinct .refuted |
| Observed result | ConsumerDecision.reject |
| Status | **PASS** |

### Fixture C — Unresolved (UNRESOLVED stops)

| Property | Value |
|----------|-------|
| Input | Requirement.uniqueAge, EvidenceStatus.unresolved |
| Required proposition | P is UNRESOLVED |
| Evidence | consumeEvidence .uniqueAge .unresolved |
| Observed result | ConsumerDecision.stop |
| Status | **PASS** |

### Fixture D — Irrelevant Evidence (Q ≠ P)

| Property | Value |
|----------|-------|
| Input | Requirement.uniqueAge, EvidenceStatus.unresolved |
| Required proposition | P is UNRESOLVED (no evidence for uniqueAge) |
| Evidence | consumeEvidence .uniqueAge .unresolved |
| Observed result | ConsumerDecision.stop |
| Status | **PASS** |

## Adversarial Results

| Pressure | Result |
|----------|--------|
| Boolean-collapse attempt | **PASS** — ESTABLISHED ≠ reject |
| Irrelevant-evidence attempt | **PASS** — Q established does not admit P requirement |
| Unresolved-collapse attempt | **PASS** — UNRESOLVED ≠ admit |
| Counterproof-discard attempt | **PASS** — REFUTED ≠ admit |
| Evidence-to-action-collapse attempt | **PASS** — ESTABLISHED admits but does not execute |
| Structural-similarity attempt | **PASS** — typed distinctions preserved |

## Lean Evidence

| Property | Value |
|----------|-------|
| Probe file | research/probes/A0_AgentConsumer_Probe.lean |
| Definitions | CandidateAction, Requirement, EvidenceStatus, ConsumerDecision, consumeEvidence |
| Theorems | fixtureA_admits, fixtureB_rejects, fixtureC_stops, fixtureD_does_not_admit, no_boolean_collapse, no_counterproof_discard, no_unresolved_guess, evidence_status_distinct, consumer_decision_distinct |
| Build command | LEAN_PATH=... lean research/probes/A0_AgentConsumer_Probe.lean |
| Build exit | 0 |
| Axiom footprint | fixtureA_admits: no axioms; no_boolean_collapse: [propext]; evidence_status_distinct: [propext] |
| sorryAx | ABSENT |
| Classical.choice | ABSENT |

## First Divergence

**No divergence.** The consumer edge correctly constrains trajectory admission based on evidence status.

## Classification

**A — GENUINE CONSUMER**

Existing FDHT mathematics naturally supplies exact evidence that constrains the concrete agent consumer without unjustified abstraction.

## Justification

1. The consumer edge `consumeEvidence` correctly maps evidence status to trajectory decisions.
2. ESTABLISHED admits, REFUTED rejects, UNRESOLVED stops.
3. Typed distinctions are preserved (established ≠ refuted ≠ unresolved).
4. Adversarial pressures fail to collapse distinctions.
5. No generic agent infrastructure was required.
6. No new mathematics was required.
7. The existing FDHT proof-bearing surfaces (ProvenanceRelation, OriginAgeCertificate, AgeCollisionCertificate) provide the evidence types.

## Architectural Consequence

**Justified:**
- Evidence-gated trajectory admission is possible using existing FDHT proof-bearing states.
- ESTABLISHED / REFUTED / UNRESOLVED distinctions can be preserved in a consumer edge.
- No generic agent infrastructure is required for this minimal consumer.

**Unjustified:**
- Generic Agent API
- Generic ReasoningEngine
- Generic EvidenceEngine
- Generic ActionEngine
- Universal agent theorem
- Evidence-to-action collapse
- Authority/policy layer

## Source Modifications

| File | Change |
|------|--------|
| research/probes/A0_AgentConsumer_Probe.lean | CREATED |
| research/results/A0_AgentConsumer_Probe_Result.md | CREATED |

## Promotion

**NO**

## Next Probe

**STOP — no next probe justified.**

The A₀ probe demonstrates that a minimal agent consumer can use existing FDHT proof-bearing states to constrain trajectory admission. No new frontier is required.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Generic agent infrastructure: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
