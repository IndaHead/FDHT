# FDHT Interface I₁ — Read-Only Workbench Information Architecture

**Status:** AUDIT COMPLETE  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `d5be18aa5f0b33220c69b352f3bd89cb93dfaf35`

## Question

How should a human navigate the I₀ presentation information without duplicating
semantic authority, losing exact request scope, collapsing result states,
confusing evidence with provenance, confusing trust with mathematical
applicability, or changing formal state through interface navigation?

## Verified I₀ Inputs

Required presentation fields:

- request_scope
- result_class
- evidence_ref
- obstruction_ref
- non_admission_reason
- historical_lineage
- trust_footprint
- research_provenance

Required result distinctions:

- ESTABLISHED ≠ REFUTED ≠ UNRESOLVED
- UNRESOLVED ≠ FALSE
- NO APPLICABLE EVIDENCE ≠ REFUTATION

## IA Principles

1. Objects live in primary views.
2. Relationships are exposed through references and inspection.
3. Inspector does not own semantic truth.
4. Navigation changes focus.
5. Navigation does not change FDHT state.

## Primary Views

| View | Owns | Does Not Own |
|------|------|--------------|
| REQUESTS | Current mathematical request/result interpretation | Trust, research authority |
| HISTORY | Temporal/historical lineage presentation | Result classification |
| EVIDENCE | Proof-bearing support inspection | Research authority, trust acceptance |
| VERIFICATION | Evidence-admission / verification-state inspection | Certification |
| RESEARCH | Research authority and research provenance | Mathematical truth |
| INSPECTOR | NOTHING | Everything (renders context only) |

## Field Ownership

| Field | Primary Owner | Required Views | Reference-Only Views |
|-------|---------------|----------------|----------------------|
| request_scope | REQUESTS | REQUESTS, HISTORY, EVIDENCE, VERIFICATION | INSPECTOR |
| result_class | REQUESTS | REQUESTS, HISTORY, VERIFICATION | INSPECTOR |
| evidence_ref | EVIDENCE | EVIDENCE, REQUESTS (conditional) | HISTORY, INSPECTOR |
| obstruction_ref | EVIDENCE | EVIDENCE, REQUESTS (conditional) | INSPECTOR |
| non_admission_reason | REQUESTS | REQUESTS, VERIFICATION | INSPECTOR |
| historical_lineage | HISTORY | HISTORY | REQUESTS, EVIDENCE, INSPECTOR |
| trust_footprint | EVIDENCE | EVIDENCE | INSPECTOR |
| research_provenance | RESEARCH | RESEARCH | EVIDENCE, INSPECTOR |

## Field Cardinality

| Field | Cardinality |
|-------|-------------|
| request_scope | Exactly one per represented request/result |
| result_class | Exactly one of ESTABLISHED / REFUTED / UNRESOLVED |
| evidence_ref | Zero or one primary presentation reference |
| obstruction_ref | Zero or one |
| non_admission_reason | Zero or one |
| historical_lineage | Zero or one presentation summary |
| trust_footprint | Zero or one presentation record |
| research_provenance | Zero or one presentation record |

## Requests View

**Human questions:**

- What request am I looking at?
- What exact mathematical scope does it have?
- What is its current result class?
- What is the basis for that result?

**Required:**

- request_scope
- result_class

**Conditional basis:**

- ESTABLISHED → evidence_ref
- REFUTED → obstruction_ref
- UNRESOLVED → non_admission_reason

**Invariant:**

UNRESOLVED + non_admission_reason ≠ REFUTED.

## History View

**Human questions:**

- What episodes/events are represented?
- What request/scope did an episode concern?
- What result was represented?
- Which historical episode supplied current evidence?

**Required:**

- historical_lineage
- request_scope
- result_class

**Invariant:**

Selecting an episode changes INTERFACE FOCUS. It does NOT mutate history,
select new mathematical authority, rewrite current result, or change
verification state.

## Evidence View

**Human questions:**

- What exact evidence supports this result?
- What exact scope does the evidence support?
- Where did the evidence originate?
- What does its proof depend upon?
- Where does this research evidence come from?

**Required:**

- evidence_ref
- request_scope
- trust_footprint
- research_provenance

**Invariant:**

evidence_ref without request_scope = INVALID PRESENTATION STATE.

## Verification View

**Human questions:**

- What verification case is being inspected?
- Was prerequisite evidence admitted?
- What verification result follows?
- Why was evidence not admitted where unavailable?

**Required:**

- request_scope
- result_class

**Invariants:**

- EVIDENCE NOT AVAILABLE ≠ REFUTED
- VERIFIED ≠ CERTIFIED

## Research View

**Human questions:**

- What research result/probe/artefact am I inspecting?
- What authority does it possess?
- Is it promoted?
- Where did it originate?

**Required:**

- research_provenance

**Invariant:**

Research metadata remains non-mathematical. Do not use research authority as
mathematical truth status.

## Inspector

**Sections:**

- MATHEMATICAL: request_scope, result_class, applicable basis
- TRUST: trust_footprint
- RESEARCH: research_provenance
- HISTORY: historical_lineage

**Invariant:**

Inspector has NO independent source-of-truth role. It renders context from the
selected presentation object.

## Provenance Planes

Inspector does NOT collapse MATHEMATICAL / TRUST / RESEARCH into a single:

- confidence
- quality
- authority
- health
- reliability

score.

No scalar combination. No traffic-light aggregate.

## Cross-View Navigation Graph

| Source | Destination | Reference Followed |
|--------|-------------|-------------------|
| REQUEST | EVIDENCE | evidence_ref |
| REQUEST | HISTORY | historical_lineage |
| REQUEST | VERIFICATION | request_scope |
| REQUEST | RESEARCH | research_provenance |
| HISTORY | REQUEST | request_scope |
| HISTORY | EVIDENCE | evidence_ref |
| HISTORY | RESEARCH | research_provenance |
| EVIDENCE | REQUEST | request_scope |
| EVIDENCE | HISTORY | historical_lineage |
| EVIDENCE | RESEARCH | research_provenance |
| VERIFICATION | REQUEST | request_scope |
| VERIFICATION | EVIDENCE | evidence_ref |
| RESEARCH | REQUEST/EVIDENCE/HISTORY | referenced objects |

## Navigation-Context Preservation

| Transition | Scope Preserved | Result Identity Preserved | Trust Context Preserved |
|------------|-----------------|---------------------------|-------------------------|
| REQUEST → EVIDENCE | YES | YES | YES |
| REQUEST → HISTORY | YES | YES | YES |
| EVIDENCE → REQUEST | YES | YES | YES |
| HISTORY → REQUEST | YES | YES | YES |

## End-to-End Specimen Walk

Using V₀-R applicable verification case:

1. REQUEST: state i, k=8, ESTABLISHED, evidence_ref → n8_index_first_return
2. EVIDENCE: n8_index_first_return, scope i/k=8, trust [propext, Quot.sound]
3. HISTORY: episode with evidence_ref, lineage DIRECT
4. TRUST: [propext, Quot.sound]
5. RESEARCH: V₀-R probe, RESEARCH RESULT ONLY
6. REQUEST: same scope, same basis

**Result:** No scope drift. No provenance-plane collapse. No result-status
reinterpretation.

## Adversarial Navigation Tests

### Scope-Drift Adversary

Two requests differing in state. Navigation through shared-looking evidence
surfaces must preserve selected request_scope.

**Result:** IA requires scope preservation. PASS.

### Trust-Drift Adversary

Clean and dirty research specimens. Following evidence/research references
must not cause dirty trust footprint to appear clean.

**Result:** IA requires trust context to change only because selected object
changed. PASS.

### Research-Authority Drift

Navigate between research result, formal source, historical evidence.
Research authority of one object does not transfer automatically to another.

**Result:** IA requires authority isolation. PASS.

## Empty/Absent Semantics

| State | Meaning |
|-------|---------|
| NOT APPLICABLE | Field does not apply to this object type |
| NOT REPRESENTED | Field exists but has no value in this instance |
| NOT AVAILABLE | Field value is not available through this route |
| UNKNOWN | Field status is not determined |
| UNRESOLVED | Result class is unresolved |

Do not automatically use null/blank/"-" as semantic meaning.

## Filtering/Search Boundary

| Operation | Status |
|-----------|--------|
| Navigating known references | ALLOWED |
| Filtering presentation records | FUTURE REQUIREMENT |
| Searching for applicable evidence | NOT INTRODUCED |

I₁ defines navigation. I₁ does not introduce semantic evidence search.

## Rejected Architecture Patterns

| Pattern | Reason |
|---------|--------|
| Bool success/failure | Collapses three-way status |
| Colour/icon only | Not semantic |
| Trust score | Scalar combination |
| Confidence % | Not represented |
| System health % | Not represented |
| Green/red global status | Collapses distinctions |

## Implementation-Stack Firewall

Do not select:

- React
- Vue
- Svelte
- Blazor
- Tauri
- Electron
- database
- server
- CLI framework

I₁ defines information architecture only.

## Final Classification

**I₁ READ-ONLY WORKBENCH INFORMATION ARCHITECTURE AUDITED.**

Primary views identified.  
Field ownership assigned.  
Navigation graph defined.  
Semantic invariants preserved.  
No new mathematics.  
No substrate modification.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean probe: **NONE** (documentation-only)  
FDHT v3.1 scope: **UNCHANGED**
