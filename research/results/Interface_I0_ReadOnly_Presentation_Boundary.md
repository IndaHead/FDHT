# FDHT Interface I₀ — Read-Only Loss-Aware Presentation Boundary

**Status:** AUDIT COMPLETE  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `7795fda2f95658be2f4a81d550b2f15176526013`

## Question

What is the MINIMUM read-only presentation representation sufficient for a
human-facing FDHT interface to display a proof-bearing consumer result
faithfully, while preserving every distinction required by the interface?

## Human-Facing Questions

| ID | Question |
|----|----------|
| Q1 | What request am I looking at? |
| Q2 | What is its current result class? |
| Q3 | If ESTABLISHED, what evidence/proof-bearing origin supports it? |
| Q4 | If REFUTED, what obstruction/negative evidence supports it where represented? |
| Q5 | If UNRESOLVED, what may honestly be said about why no positive/negative result was admitted? |
| Q6 | What exact mathematical scope does this result belong to? |
| Q7 | What historical episode/lineage supplied the evidence where available? |
| Q8 | What trust information applies? |
| Q9 | What research authority/provenance applies? |

## Representative Formal States

| Specimen | Status | Source |
|----------|--------|--------|
| ESTABLISHED | FirstPositiveReturnAt n=8 | n8_index_first_return |
| UNRESOLVED | Empty history | V₀-R baseline |
| HISTORICAL | Applicable history | V₀-R applicable_verified |
| CLEAN TRUST | [propext, Quot.sound] | V₀-R central theorems |
| DIRTY TRUST | [propext, sorryAx, Quot.sound] | V₀ original |

## Required Presentation Fields

| Field | Required By | Justification |
|-------|-------------|---------------|
| request_scope | Q1, Q6 | Exact mathematical identity |
| result_class | Q2 | ESTABLISHED / REFUTED / UNRESOLVED |
| evidence_ref | Q3 | Proof-bearing origin for ESTABLISHED |
| obstruction_ref | Q4 | Negative evidence for REFUTED |
| non_admission_reason | Q5 | Honest UNRESOLVED explanation |
| historical_lineage | Q7 | Direct vs historically recovered |
| trust_footprint | Q8 | Axiom dependency metadata |
| research_provenance | Q9 | Authority / branch / artefact |

## Rejected Presentation Fields

| Field | Reason |
|-------|--------|
| Bool success/failure | Collapses three-way status |
| Colour/icon only | Not semantic |
| Serialised Lean term | Not required for human observation |
| Universal PresentationIdentity | Converse not proved |

## Status Distinctions

| Distinction | Preserved |
|-------------|-----------|
| ESTABLISHED ≠ UNRESOLVED | YES |
| REFUTED ≠ UNRESOLVED | YES (where fixture exists) |
| UNRESOLVED ≠ FALSE | YES |
| NO APPLICABLE EVIDENCE ≠ REFUTATION | YES |

## Payload / Proof Reference Requirements

For ESTABLISHED results, the presentation must retain enough identity for the
human observer to know which proof-bearing evidence supports the result.

Minimum: evidence_ref pointing to the source theorem or historical episode.

## Scope Requirements

Interface-relevant coordinates that must survive:

- state (Fin n)
- k (Nat)
- step / permutation identity

Dropping any of these allows distinct results to collapse.

## Historical Lineage Requirements

Where result was supplied through history, presentation must distinguish:

- DIRECT / FIXTURE SOURCE
- HISTORICALLY RECOVERED / SELECTED

Do not imply one has greater mathematical authority merely because route differs.

## Provenance-Plane Treatment

| Plane | Content | Treatment |
|-------|---------|-----------|
| Mathematical applicability | Result status, evidence | Required |
| Trust provenance | Axiom footprint | Required |
| Research provenance | Branch, artefact, authority | Required |

Planes remain separate. Do not unify.

## Collision Tests

### R1: ESTABLISHED ≠ UNRESOLVED

Same request/scope. One ESTABLISHED, one UNRESOLVED.  
**Result:** Distinct presentation required.

### R2: Scope Collision

Same visible status, different state.  
**Result:** state coordinate required.

### R3: Trust Collision

Same mathematical conclusion, different trust footprint.  
**Result:** trust_footprint required if trust inspector is an I₀ requirement.

### R4: Provenance Collision

Same mathematical conclusion, different research provenance.  
**Result:** research_provenance required if research inspector is an I₀ requirement.

## Loss Budget

| Omitted Field | Formal Distinction Lost | Interface Requirement Affected | Justification |
|---------------|-------------------------|--------------------------------|---------------|
| Lean proof term | Exact proof object | NO | Human observes reference, not term |
| Full history list | Intermediate episodes | NO | Lineage summary sufficient for I₀ |
| Colour encoding | Visual distinction | NO | Semantic fields sufficient |

## Round-Trip Policy

I₀ is one-way display projection.

PresentationView → reconstruct original Lean state is NOT required.

Projection is intentionally non-invertible.

## Read-Only Boundary

No interface command may:

- mutate history
- inject proofs
- alter verification
- certify
- select policy
- trigger action

No setters. No command API. No POST semantics.

## Trust Footprint

I₀ is documentation-only. No new Lean mathematics.

Existing trust footprints from V₀-R remain authoritative for the underlying
formal states.

## Classification

**I₀ READ-ONLY PRESENTATION BOUNDARY AUDITED.**

Minimum presentation representation identified.

All required distinctions preserved.

No new mathematics.

No substrate modification.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean probe: **NONE** (documentation-only)  
FDHT v3.1 scope: **UNCHANGED**
