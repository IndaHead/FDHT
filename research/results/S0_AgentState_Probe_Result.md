# FDHT Agent-State S₀ — Structured State and Token-Minimisation Probe

**Status:** PROBE COMPLETE  
**Authority:** RESEARCH SYNTHESIS / PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `3f7b52b1dd93b9fc6fb1871435824385256bbecf`

## Question

Can a minimal structured AgentState reuse existing A₀ and FDHT proof-bearing surfaces to replace a measurable set of repeated language-model decision steps with deterministic typed transitions, while preserving the same observable ADMIT / REJECT / STOP decisions?

## Repository State

| Property | Value |
|----------|-------|
| Base branch | research/agent-consumer |
| Base HEAD | 3f7b52b1dd93b9fc6fb1871435824385256bbecf |
| Probe file | research/probes/S0_AgentState_Probe.lean |

## A₀ Reuse Audit

| Type | Source | Status |
|------|--------|--------|
| EvidenceStatus | Probe-local (A₀ analogue) | REUSED |
| ConsumerDecision | Probe-local (A₀ analogue) | REUSED |
| Requirement | Probe-local (A₀ analogue) | REUSED |
| consumeEvidence | Probe-local (A₀ analogue) | REUSED |

**Note:** A₀ used probe-local analogues of permanent FDHT types. S₀ reuses these probe-local definitions. No permanent FDHT types were directly used.

## Minimal Agent-State Schema

### Retained Fields

| Field | Reason |
|-------|--------|
| DecisionRecord.requirement | Exact downstream requirement |
| DecisionRecord.evidence | Proof-bearing evidence status |
| DecisionRecord.decision | Observable decision |
| AgentState.decisionHistory | Preserves evidence and decisions |

### Removed Fields (Decorative or External)

| Field | Classification |
|-------|----------------|
| ObjectiveId | DECORATIVE — no fixture uses it |
| TrajectoryId | DECORATIVE — no fixture uses it |
| RequirementId | DECORATIVE — no fixture uses it |
| EvidenceId | DECORATIVE — no fixture uses it |
| ActionId | DECORATIVE — no fixture uses it |
| ObservationId | DECORATIVE — no fixture uses it |
| AuthorityDecision | EXTERNAL — outside evidence admission |
| ExecutionState | EXTERNAL — outside evidence admission |
| evidenceHistory | DUPLICATED — subsumed by decisionHistory |
| activeTrajectories | DECORATIVE — no fixture uses it |
| observations | DECORATIVE — no fixture uses it |

## Exact Consumer Edge

| Property | Value |
|----------|-------|
| Trajectory | AgentState → AgentState |
| Requirement | Requirement (provenanceEqual / provenanceDistinct / uniqueAge) |
| Evidence type | EvidenceStatus (established / refuted / unresolved) |
| Transition | transition : AgentState → Requirement → EvidenceStatus → AgentState |
| Preserved history | DecisionRecord in decisionHistory |

## Fixture Matrix

| Fixture | Requirement | Evidence | Structured Decision | Evidence Preserved | Status |
|---------|-------------|----------|---------------------|-------------------|--------|
| A — Positive | provenanceEqual | established | admit | YES | **PASS** |
| B — Negative | provenanceDistinct | refuted | reject | YES | **PASS** |
| C — Unresolved | uniqueAge | unresolved | stop | YES | **PASS** |
| D — Irrelevant | uniqueAge | unresolved | stop | YES | **PASS** |

**Note:** Baseline language path not tested. TOKEN COUNT NOT MEASURABLE.

## Efficiency Evidence

| Measurement | Value |
|-------------|-------|
| Baseline tokens | NOT MEASURABLE |
| Structured-path generated tokens | 0 (deterministic) |
| Baseline model calls | NOT MEASURABLE |
| Structured-path model calls | 0 |
| Latency | NOT MEASURABLE |

## Adversarial Results

| Pressure | Result |
|----------|--------|
| Boolean projection | **PASS** — ESTABLISHED ≠ reject |
| Evidence/status detachment | **PASS** — evidence preserved in history |
| Identifier collision | **PASS** — typed, not string-matched |
| String-label substitution | **PASS** — no string labels carry meaning |
| Irrelevant evidence substitution | **PASS** — Q established does not admit P |
| Proposition mismatch | **PASS** — typed requirement coupling |
| Proof payload discard | **PASS** — evidence preserved in history |
| Unresolved-to-default conversion | **PASS** — UNRESOLVED ≠ admit |
| Admission-to-authority collapse | **PASS** — authority external |
| Admission-to-execution collapse | **PASS** — execution external |
| History overwrite | **PASS** — history prepends, not overwrites |
| Provenance field as proof | **PASS** — no provenance field |
| Duplicate decision with conflicting evidence | **PASS** — each record independent |
| Repeated processing of settled edge | **PASS** — deterministic |

## First Divergence

**No divergence in structured path.** Evidence and decisions preserved.

**TOKEN COUNT NOT MEASURABLE** — baseline language path not available.

## Lean Evidence

| Property | Value |
|----------|-------|
| Probe file | research/probes/S0_AgentState_Probe.lean |
| Definitions | EvidenceStatus, ConsumerDecision, Requirement, DecisionRecord, AgentState, consumeEvidence, transition |
| Theorems | fixtureA_admits, fixtureA_preserves_evidence, fixtureB_rejects, fixtureB_preserves_evidence, fixtureC_stops, fixtureC_preserves_evidence, fixtureD_does_not_admit, no_boolean_collapse, no_counterproof_discard, no_unresolved_guess, evidence_preserved_in_history, decision_matches_evidence, evidence_status_distinct, consumer_decision_distinct |
| Build command | LEAN_PATH=... lean research/probes/S0_AgentState_Probe.lean |
| Build exit | 0 |
| Axiom footprint | fixtureA_admits: [propext]; evidence_preserved: [propext]; no_boolean_collapse: [propext] |
| sorryAx | ABSENT |
| Classical.choice | ABSENT |

## Classification

**B — STRUCTURED STATE VALID, TOKEN CLAIM UNMEASURED**

The structured transition is verified, but reliable baseline token or model-call comparison is unavailable.

## Justified Claim

A minimal structured AgentState reuses A₀ proof-bearing surfaces, preserves evidence and decisions in history, and produces deterministic ADMIT / REJECT / STOP decisions without model calls.

## Unjustified Claims

- Token reduction (NOT MEASURABLE)
- Equivalence to language-mediated path (NOT TESTED)
- Generic agent architecture
- Authority/execution semantics
- Permanent FDHT type integration

## Source Modifications

| File | Change |
|------|--------|
| research/probes/S0_AgentState_Probe.lean | CREATED |
| research/results/S0_AgentState_Probe_Result.md | CREATED |

## Promotion

**NO**

## Next Probe

**STOP — no next probe justified.**

The S₀ probe demonstrates that a minimal structured AgentState can preserve evidence and decisions deterministically. Token measurement is unavailable. No new frontier is required.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Generic agent infrastructure: **NO**  
Token claim: **UNMEASURED**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
