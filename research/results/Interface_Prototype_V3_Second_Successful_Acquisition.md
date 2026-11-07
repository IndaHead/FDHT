# FDHT Interface Prototype V₃ — Second Successful Acquisition Frontier

**Status:** PROTOTYPE COMPLETE  
**Authority:** RESEARCH TOOLING / PROTOTYPE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `1d819bc159a9caae1ec39a1ebf87e76d61e15e58`

## Question

Does the existing repository contain a SECOND concrete real acquisition
specimen that is STRUCTURALLY DIFFERENT from V₁ and can be acquired
non-circularly?

## Answer

**YES.**

## Starting State

| Property | Value |
|----------|-------|
| Branch | research/interface-consumer |
| HEAD | 1d819bc159a9caae1ec39a1ebf87e76d61e15e58 |
| Remote | 1d819bc159a9caae1ec39a1ebf87e76d61e15e58 |

## V₁ Successful Baseline

- Specimen: n8_index_first_return
- Domain: Permutation/cycle
- Type shape: FirstPositiveReturnAt
- Scope shape: Fin n, k, step
- Result: ESTABLISHED → evidence_ref

## V₂ Fixture-Kill Boundary

- Target: AgeCollisionCertificate → REFUTED
- Result: NO EXISTING CONCRETE FIXTURE
- Architecture: NOT FALSIFIED

## Audit Domains

| Domain | Inspected | Concrete Specimens |
|--------|-----------|-------------------|
| OriginAgeCertificate | YES | Generic only |
| ThreadPermutation | YES | Concrete |
| projectedAction | YES | Concrete |
| distinguishingResolve | YES | Concrete |
| ProvenanceAudit | YES | Regression only |

## Candidate Inventory

| ID | Domain | Source | Concrete | Type Shape | Difference from V₁ | Classification |
|----|--------|--------|----------|------------|-------------------|----------------|
| C1 | Trajectory | distinguishingResolve_exposing_idempotent_nonidentity | YES | Conjunction | Different family, type, scope | SURVIVES |
| C2 | Permutation | fourThreadCycle_noEarlyReturn | YES | ∀ i k | Same family, similar scope | K2 V₁ DUPLICATE |
| C3 | Trajectory | distinguishingResolve_cancellation_frontier | YES | 6-conjunction | Different family, type, scope | SURVIVES |

## Candidate Kill Table

| ID | Kill Reason |
|----|-------------|
| C2 | K2 V₁ ACQUISITION DUPLICATE |

## Structural-Diversity Comparison

| Dimension | V₁ | V₃ (C1) |
|-----------|-----|---------|
| Theorem family | Permutation/cycle | Trajectory/stabilisation |
| Type shape | FirstPositiveReturnAt | Conjunction (q ≠ empty ∧ q*q = q) |
| Scope shape | Fin n, k, step | TrajectoryBoundary, resolver, context |
| Evidence shape | Theorem reference | Theorem reference |
| Extraction rule | Parameter pattern | Conjunction pattern |

## Selected Specimen

**distinguishingResolve_exposing_idempotent_nonidentity**

### Selection Rationale

- Structurally different from V₁ (different family, type shape, scope shape)
- Concrete fixture exists
- Trust acquirable
- Minimal implementation
- No new mathematics required
- No generic infrastructure required

## Exact Source Artefacts

| Artefact | Location |
|----------|----------|
| Theorem | `fdht/FDHTReturnStabilizerBoundaryAPI.lean` |
| Declaration | `distinguishingResolve_exposing_idempotent_nonidentity` |

## Acquisition Implementation

**Location:** `research/interface/workbench/acquire_distinguishing.py`

**Method:** Executable read-only acquisition from actual Lean source.

## Field Lineage

| Field | Source | Extraction | Direct/Derived |
|-------|--------|------------|----------------|
| request_scope | Theorem type signature | Parsed conjunction pattern | DIRECT |
| result_class | Theorem existence + consumer context | Derived | DERIVED |
| evidence_ref | Theorem declaration | Extracted | DIRECT |
| trust_footprint | Lean `#print axioms` | Acquired via `lake env lean` | DIRECT |
| source_snapshot | Git | Acquired via `git rev-parse` | DIRECT |

## Non-Circularity

| Requirement | Satisfied |
|-------------|-----------|
| No hard-coded result_class | YES |
| No hard-coded trust footprint | YES |
| No hard-coded request scope | YES |
| No fixture-specific lookup table | YES |
| Source change → output change | YES |

## Trust Acquisition

**Acquired:** [propext, Quot.sound]

## Snapshot Acquisition

**Acquired:** `1d819bc159a9caae1ec39a1ebf87e76d61e15e58`

## Research Provenance

**Acquired:** RESEARCH RESULT ONLY, interface-consumer, V₃

## Generated Record

**Location:** `research/interface/workbench/generated/acquired_distinguishing.json`

## i3.0 Validation

**PASS** — Generated record passes I₃ i3.0 validation

## Workbench Integration

**PASS** — Generated record can be loaded into existing V₀ Workbench

## Differential V₁/V₃ Analysis

### Common Acquisition Properties

- Trust acquisition via `#print axioms`
- Snapshot acquisition via `git rev-parse`
- Evidence reference extraction from theorem declaration
- Result class derivation from theorem existence

### Different Acquisition Properties

| Property | V₁ | V₃ |
|----------|-----|-----|
| Theorem family | Permutation/cycle | Trajectory/stabilisation |
| Type shape | FirstPositiveReturnAt | Conjunction |
| Scope shape | Fin n, k, step | TrajectoryBoundary, resolver, context |
| Extraction rule | Parameter pattern | Conjunction pattern |

## Discovery-Readiness Audit

**Classification:** DISCOVERY NOT YET JUSTIFIED

Two successful specimens do not justify automated discovery.

## Gap Register

| ID | Classification | Description | Disposition |
|----|----------------|-------------|-------------|
| G1 | IMPLEMENTATION-ONLY | Trust acquisition requires `lake env` | ACCEPTABLE |

## Classification

**PROTOTYPE V₃ SECOND SUCCESSFUL ACQUISITION IMPLEMENTED.**

Structurally different from V₁.  
Non-circular acquisition.  
I₃ validation passed.  
Workbench integration verified.  
No new mathematics.  
No substrate modification.  
No generic acquisition engine.  
No automated discovery.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Generic acquirer: **NO**  
Automated discovery: **NO**  
FDHT v3.1 scope: **UNCHANGED**
