# FDHT Interface Prototype V₂ — Second Real Acquisition Specimen

**Status:** FIXTURE-KILL  
**Authority:** RESEARCH FIXTURE AUDIT  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `4261c76864d4d68dfb090aca2549be8713b5008e`

## Question

Does the existing repository contain an ACTUAL concrete AgeCollisionCertificate
specimen that can support a second non-circular read-only acquisition path:

```
REAL CONCRETE COLLISION CERTIFICATE
        ↓
ageCollision_refutes_uniqueAge
        ↓
¬ HasUniqueAgeFrom ...
        ↓
i3.0 result_class = REFUTED
        ↓
obstruction_ref
        ↓
existing Workbench?
```

## Answer

**NO.**

## Starting State

| Property | Value |
|----------|-------|
| Branch | research/interface-consumer |
| HEAD | 4261c76864d4d68dfb090aca2549be8713b5008e |
| Remote | 4261c76864d4d68dfb090aca2549be8713b5008e |

## V₁ Baseline

Prototype V₁ established one real executable positive acquisition path:

- Specimen: n8_index_first_return
- Polarity: ESTABLISHED → evidence_ref
- Non-circularity: SOURCE CHANGE → OUTPUT CHANGE OR ACQUISITION REJECTION

## Permanent Negative Surface

### Certificate Structure

```lean
structure AgeCollisionCertificate
    (step : X → X)
    (origin : X)
    (k m : Nat) : Prop where
  distinctAges : k ≠ m
  sameState : RawOrbit step origin k = RawOrbit step origin m
```

**Location:** `fdht/FDHTOriginAgeCertificateAPI.lean`

### Refutation Theorem

```lean
theorem ageCollision_refutes_uniqueAge
    (step : X → X)
    (origin : X)
    (k m : Nat)
    (hCert : AgeCollisionCertificate step origin k m) :
    ¬ HasUniqueAgeFrom
      step
      origin
      (RawOrbit step origin k)
```

**Location:** `fdht/FDHTOriginAgeCertificateAPI.lean`

### Semantic Restriction

Collision refutes unique age.  
Collision does NOT refute reachability.

## Fixture Gate

### Search Results

| Location | Content | Concrete? |
|----------|---------|-----------|
| `fdht/FDHTOriginAgeCertificateAPI.lean` | Structure definition | NO |
| `fdht/FDHTOriginAgeCertificateAPIRegression.lean` | Generic example with variables | NO |
| `fdht/FDHTOriginRelativeDepthAPI.lean` | `rawOrbit_collision_refutes_unique_age` | NO (parametric) |

### Concrete Fixture Search

Searched for:

- `AgeCollisionCertificate` with concrete k/m values
- `AgeCollisionCertificate` with concrete step/origin
- Concrete instances in research probes

**Result:** NONE FOUND

### Regression Analysis

The regression in `FDHTOriginAgeCertificateAPIRegression.lean` uses:

```lean
variable {X : Type u}
variable (step : X → X)
variable (origin : X)
variable (k m : Nat)
variable (hDistinct : k ≠ m)
variable (hCollision : RawOrbit step origin k = RawOrbit step origin m)

example :
    AgeCollisionCertificate step origin k m :=
  {
    distinctAges := hDistinct
    sameState := hCollision
  }
```

This is a **generic example**, not a concrete fixture.

## Fixture Survival Analysis

| Condition | Status |
|-----------|--------|
| A. Already exists | FAIL |
| B. Exact enough to identify step | FAIL |
| C. Exact enough to identify origin | FAIL |
| D. Identifies k | FAIL |
| E. Identifies m | FAIL |
| F. Provides certificate or exact constituent proofs | FAIL |
| G. ageCollision_refutes_uniqueAge applies directly | FAIL (no concrete instance) |
| H. No new theorem required | N/A |
| I. No new permanent fixture required | N/A |
| J. No scope weakening required | N/A |
| K. No polarity reinterpretation required | N/A |

**Result:** FIXTURE-KILL

## Concrete Fixture

**NONE FOUND**

| Property | Value |
|----------|-------|
| Exact step | NOT AVAILABLE |
| Exact origin | NOT AVAILABLE |
| Exact k | NOT AVAILABLE |
| Exact m | NOT AVAILABLE |

## Classification

**PROTOTYPE V₂ FIXTURE-KILL**

**NO EXISTING CONCRETE AGE-COLLISION ACQUISITION SPECIMEN.**

## What Exists

| Item | Status |
|------|--------|
| General permanent negative theorem | EXISTS |
| AgeCollisionCertificate structure | EXISTS |
| ageCollision_refutes_uniqueAge theorem | EXISTS |
| Generic regression example | EXISTS |

## What Does Not Exist

| Item | Status |
|------|--------|
| Concrete AgeCollisionCertificate specimen | ABSENT |
| Concrete step/origin/k/m values | ABSENT |
| REFUTED real acquisition path | NOT ESTABLISHED |

## Acquisition Architecture

**NOT FALSIFIED.**

The acquisition architecture established by V₁ is not falsified by this fixture-kill.

The required concrete specimen is simply absent.

## No Acquisition Code Created

Per fixture-kill protocol:

- No acquisition implementation created
- No generated record created
- No i3.0 validation performed
- No Workbench integration performed

## Gap Register

| ID | Classification | Description |
|----|----------------|-------------|
| G1 | NO CONCRETE FIXTURE | No existing concrete AgeCollisionCertificate specimen |

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Acquisition code: **NONE**  
FDHT v3.1 scope: **UNCHANGED**

## Recommended Next Action

**STOP.**

Do not manufacture the missing fixture.

Do not prove a new refutation.

Do not create a new AgeCollisionCertificate solely to make V₂ pass.
