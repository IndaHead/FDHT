# FDHT Interface I₂ — Read-Only Data Acquisition Boundary

**Status:** AUDIT COMPLETE  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `71821e87bb7159b13ce75646374a23bbfcee4155`

## Question

How does a read-only FDHT interface acquire formal mathematical state for
presentation without:

- mutating formal state;
- injecting proofs;
- fabricating evidence;
- collapsing provenance planes;
- treating research artefacts as mathematical authority;
- requiring new mathematics?

## Verified Inputs

| Layer | Capability | Status |
|-------|------------|--------|
| I₀ | Read-only presentation boundary | AUDITED |
| I₁ | Workbench information architecture | AUDITED |

## Acquisition Sources

### Source A: Permanent Mathematical Substrate

**Location:** `fdht/*.lean`

**Content:**

- Theorems
- Definitions
- Proofs
- Type signatures

**Acquisition method:**

- Compile-time inspection
- `#print axioms`
- `#check`
- Direct theorem reference

**Authority:** MATHEMATICAL

### Source B: Research Probe Artefacts

**Location:** `research/probes/*.lean`

**Content:**

- Probe-local theorems
- Fixture constructions
- Trust footprints

**Acquisition method:**

- Probe compilation
- `#print axioms`
- Result document reference

**Authority:** RESEARCH RESULT ONLY

### Source C: Research Result Documents

**Location:** `research/results/*.md`

**Content:**

- Audit findings
- Classification
- Trust footprints
- Provenance records

**Acquisition method:**

- Document reading
- Structured extraction

**Authority:** RESEARCH RESULT ONLY

### Source D: Programme Specifications

**Location:** `research/results/*_Programme_Specification.md`

**Content:**

- Programme progression
- Milestone status
- Disposition

**Acquisition method:**

- Document reading

**Authority:** RESEARCH RESULT ONLY

## Acquisition Invariants

### Invariant A1: No Mutation

Acquisition does not modify:

- formal theorems
- proof objects
- history
- verification state

### Invariant A2: No Injection

Acquisition does not:

- inject proofs
- fabricate evidence
- construct new mathematical objects

### Invariant A3: Authority Preservation

| Source | Authority |
|--------|-----------|
| Permanent substrate | MATHEMATICAL |
| Research probe | RESEARCH RESULT ONLY |
| Research document | RESEARCH RESULT ONLY |
| Programme specification | RESEARCH RESULT ONLY |

### Invariant A4: Provenance Plane Separation

Acquisition must preserve:

- Mathematical applicability
- Trust provenance
- Research provenance

as separate planes.

## Acquisition Routes

### Route R1: Theorem Reference

**Source:** Permanent substrate  
**Method:** Direct theorem name reference  
**Output:** Theorem identity, type, trust footprint  
**Authority:** MATHEMATICAL

### Route R2: Probe Compilation

**Source:** Research probe  
**Method:** Lean compilation + `#print axioms`  
**Output:** Probe-local theorem, trust footprint  
**Authority:** RESEARCH RESULT ONLY

### Route R3: Document Extraction

**Source:** Research result document  
**Method:** Structured reading  
**Output:** Classification, findings, provenance  
**Authority:** RESEARCH RESULT ONLY

### Route R4: Programme Status

**Source:** Programme specification  
**Method:** Document reading  
**Output:** Milestone status, disposition  
**Authority:** RESEARCH RESULT ONLY

## Field Acquisition Map

| I₀ Field | Acquisition Route | Source |
|----------|-------------------|--------|
| request_scope | R1 / R2 | Theorem type signature |
| result_class | R1 / R2 / R3 | Theorem existence / classification |
| evidence_ref | R1 / R2 | Theorem name |
| obstruction_ref | R1 / R2 | Theorem name |
| non_admission_reason | R3 | Result document |
| historical_lineage | R3 | Result document |
| trust_footprint | R1 / R2 | `#print axioms` |
| research_provenance | R3 / R4 | Result document / programme spec |

## Acquisition Boundaries

### Boundary B1: No Runtime Evaluation

I₂ does not require:

- runtime Lean evaluation
- proof term extraction
- computational witness extraction

### Boundary B2: No Serialisation

I₂ does not define:

- JSON schema
- REST payloads
- database schema

### Boundary B3: No Caching Authority

Cached acquisition results do not become:

- mathematical authority
- trust authority
- research authority

### Boundary B4: No Aggregation

I₂ does not aggregate:

- multiple trust footprints into a score
- multiple research results into a ranking
- multiple evidence references into a confidence

## Specimen Acquisition

### Specimen S1: V₀-R applicable_verified

| Field | Value | Route |
|-------|-------|-------|
| request_scope | Fin 8, k=8 | R2 |
| result_class | ESTABLISHED | R2 |
| evidence_ref | n8_index_first_return | R1 |
| trust_footprint | [propext, Quot.sound] | R2 |
| research_provenance | V₀-R, RESEARCH RESULT ONLY | R3 |

### Specimen S2: V₀-R baseline_unresolved

| Field | Value | Route |
|-------|-------|-------|
| request_scope | Fin 8, k=8 | R2 |
| result_class | UNRESOLVED | R2 |
| non_admission_reason | NO APPLICABLE HISTORICAL EVIDENCE | R3 |
| trust_footprint | [propext, Quot.sound] | R2 |
| research_provenance | V₀-R, RESEARCH RESULT ONLY | R3 |

## Adversarial Acquisition Tests

### Test A1: Authority Drift

**Attempt:** Treat research probe theorem as mathematical authority.  
**Result:** REJECTED. Research probe remains RESEARCH RESULT ONLY.

### Test A2: Trust Fabrication

**Attempt:** Acquire trust footprint without `#print axioms`.  
**Result:** REJECTED. Trust footprint requires compile-time inspection.

### Test A3: Evidence Injection

**Attempt:** Acquire evidence_ref for UNRESOLVED result.  
**Result:** REJECTED. UNRESOLVED has no evidence_ref.

### Test A4: Provenance Collapse

**Attempt:** Combine trust and research into single authority.  
**Result:** REJECTED. Planes remain separate.

## Acquisition Firewall

I₂ does not:

- mutate formal state
- inject proofs
- fabricate evidence
- collapse provenance planes
- treat research artefacts as mathematical authority
- require new mathematics
- define serialisation
- define transport
- define GUI

## Classification

**I₂ READ-ONLY DATA ACQUISITION BOUNDARY AUDITED.**

Acquisition sources identified.  
Acquisition routes defined.  
Field acquisition map established.  
Adversarial tests passed.  
No new mathematics.  
No substrate modification.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean probe: **NONE** (documentation-only)  
FDHT v3.1 scope: **UNCHANGED**
