# FDHT Interface I₃ — Loss-Aware Read-Only Transport / Schema Audit

**Status:** AUDIT COMPLETE  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `3578f7c2f156896d288efbabb0d5beb96cee5435`

## Question

What is the minimum machine-readable transport representation capable of
carrying the I₀ fields acquired through I₂ into the I₁ Workbench while
preserving every interface-required semantic distinction?

## Verified Inputs

| Layer | Capability | Status |
|-------|------------|--------|
| I₀ | Read-only presentation boundary | AUDITED |
| I₁ | Workbench information architecture | AUDITED |
| I₂ | Data acquisition boundary | AUDITED |

## Critical Round-Trip Distinction

I₃ requires:

```
PresentationRecord → encoding → decoding → equivalent PresentationRecord
```

I₃ does NOT require:

```
PresentationRecord → original Lean proof/state reconstruction
```

Transport round-trip ≠ formal reconstruction.

## Transport Requirements

| Field | Source | Type | Required | Absence States |
|-------|--------|------|----------|----------------|
| request_scope | R1/R2 | Structured | YES | NONE |
| result_class | R1/R2/R3 | Enum | YES | NONE |
| evidence_ref | R1/R2 | Reference | CONDITIONAL | NOT APPLICABLE |
| obstruction_ref | R1/R2 | Reference | CONDITIONAL | NOT APPLICABLE |
| non_admission_reason | R3 | String | CONDITIONAL | NOT APPLICABLE |
| historical_lineage | R3 | Structured | CONDITIONAL | NOT REPRESENTED |
| trust_footprint | R1/R2 | List | CONDITIONAL | NOT AVAILABLE |
| research_provenance | R3/R4 | Structured | CONDITIONAL | NOT REPRESENTED |

## Result Class Representation

Transport must preserve exactly:

- ESTABLISHED
- REFUTED
- UNRESOLVED

**Rejected:**

- boolean success
- boolean valid
- integer status without defined semantics
- truthy/falsy encoding
- missing result_class

## Basis Validity Matrix

| result_class | evidence_ref | obstruction_ref | non_admission_reason | Valid |
|--------------|--------------|-----------------|----------------------|-------|
| ESTABLISHED | PRESENT | ABSENT | ABSENT | YES |
| REFUTED | ABSENT | PRESENT | ABSENT | YES |
| UNRESOLVED | ABSENT | ABSENT | PRESENT | YES |
| UNRESOLVED | PRESENT | ABSENT | ABSENT | NO |
| REFUTED | PRESENT | ABSENT | ABSENT | NO |
| ESTABLISHED | ABSENT | ABSENT | ABSENT | NO |

## request_scope Representation

Structured transport for required coordinates:

```
{
  "state": "Fin n",
  "k": "Nat",
  "step": "permutation identity"
}
```

Not a single opaque display string.

## Evidence Reference Representation

Minimum machine-readable evidence reference:

```
{
  "theorem": "n8_index_first_return",
  "source": "fdht/FDHTFirstPositiveReturn.lean",
  "authority": "MATHEMATICAL"
}
```

Reference identity over proof serialisation.

## Obstruction Reference Representation

Same discipline as evidence reference.

Preserve negative polarity.

Do not reuse untyped reference that permits evidence ↔ obstruction confusion.

## Non-Admission Reason

Preserve exact local meaning:

```
"NO APPLICABLE HISTORICAL EVIDENCE"
```

Do not encode as false/failure/refuted.

## Historical Lineage

Minimum transported lineage:

```
{
  "source": "DIRECT" | "HISTORICALLY_RECOVERED",
  "episode": "identifier where available"
}
```

Do not transport full history.

## Trust Footprint

Preserve actual dependency information:

```
{
  "axioms": ["propext", "Quot.sound"]
}
```

**Rejected:**

- clean = true
- trusted = false

## Research Provenance

Transport enough to preserve:

```
{
  "authority": "RESEARCH RESULT ONLY",
  "programme": "verification-consumer",
  "probe": "V₀-R",
  "branch": "research/verification-consumer",
  "commit": "7795fda2f95658be2f4a81d550b2f15176526013",
  "promotion": "NOT PROMOTED"
}
```

## Provenance Plane Separation

Conceptual record must prevent accidental scalar collapse of:

- math
- trust
- research

**Rejected:**

```
"authority": "verified"
```

if that value ambiguously combines multiple provenance planes.

## Source Snapshot

Minimum transport snapshot metadata:

```
{
  "source_branch": "research/interface-consumer",
  "source_head": "3578f7c2f156896d288efbabb0d5beb96cee5435"
}
```

Repository snapshot ≠ mathematical scope.

## Version Identification

Transport representation requires schema/version identifier:

```
{
  "schema_version": "i3.0"
}
```

Future schema evolution must not make a record ambiguous.

## Absence Semantics

Transport must distinguish:

| State | Meaning |
|-------|---------|
| NOT_APPLICABLE | Field does not apply to this object type |
| NOT_REPRESENTED | Field exists but has no value in this instance |
| NOT_AVAILABLE | Field value is not available through this route |
| UNKNOWN | Field status is not determined |
| UNRESOLVED | Result class is unresolved |

Do not rely on bare missing/null value if that destroys distinction.

## Candidate Serialisation Formats

### JSON

**Advantages:**

- readability
- availability
- nested/discriminated structure
- explicit strings/enums
- human inspectability

**Disadvantages:**

- no native discriminated union
- null ambiguity

### YAML

**Advantages:**

- readability
- human inspectability

**Disadvantages:**

- tooling burden
- type ambiguity

## Format Decision

**JSON selected** as the simplest for prototype transport.

Justification:

1. Represents every required semantic distinction
2. Malformed combinations can be detected by Workbench-side validation
3. Scope survives
4. Provenance planes survive
5. Explicit absence survives
6. References survive
7. Snapshot/version metadata survives
8. Format adds no mathematical semantics

## Schema Boundary

Probe-local / research-local schema only.

**Authority:** RESEARCH INTERFACE CONTRACT ONLY

**Not:**

- permanent generic FDHT schema
- public API commitment
- foundational transport abstraction

## Schema Validation Layers

### Layer T0: Syntactic Validity

JSON parse succeeds.

### Layer T1: Required Transport Field Validity

Required fields present. Types correct.

### Layer T2: Semantic Record Validity

- UNRESOLVED does not use positive evidence as its result basis
- REFUTED preserves obstruction polarity
- research authority does not become mathematical authority

Validation does NOT prove mathematical truth.

## Malformed Record Tests

| Test | Condition | Result |
|------|-----------|--------|
| M1 | missing request_scope | REJECT |
| M2 | unknown result_class | REJECT |
| M3 | ESTABLISHED with absent evidence basis | REJECT |
| M4 | REFUTED with positive evidence as refutation basis | REJECT |
| M5 | UNRESOLVED encoded as REFUTED | REJECT |
| M6 | missing required scope coordinate | REJECT |
| M7 | evidence reference collision | REJECT |
| M8 | trust/research provenance collapsed | REJECT |
| M9 | source snapshot missing where required | REJECT |
| M10 | unsupported schema version | REJECT |
| M11 | dirty trust converted to clean | REJECT |
| M12 | research-only authority upgraded to mathematical | REJECT |

## Round-Trip Tests

### Dirty Trust Round-Trip

**Input:** [propext, sorryAx, Quot.sound]  
**Output:** [propext, sorryAx, Quot.sound]  
**Result:** PASS — dirty remains dirty

### Clean Trust Round-Trip

**Input:** [propext, Quot.sound]  
**Output:** [propext, Quot.sound]  
**Result:** PASS — clean remains clean

### ESTABLISHED Round-Trip

**Input:** request_scope, ESTABLISHED, evidence_ref, trust, research  
**Output:** All preserved  
**Result:** PASS

### UNRESOLVED Round-Trip

**Input:** request_scope, UNRESOLVED, non_admission_reason  
**Output:** All preserved, no fabricated evidence  
**Result:** PASS

### Research Authority Round-Trip

**Input:** RESEARCH RESULT ONLY  
**Output:** RESEARCH RESULT ONLY  
**Result:** PASS — no authority escalation

## Presentation Fidelity Definition

A transport round-trip is presentation-faithful iff all I₀ distinctions and I₁
navigation references required for the selected record are preserved.

Decoded record ≠ formal Lean object.

## Prototype File Policy

I₃ creates research-only schema/example artefacts if required.

**Location:** `research/interface/`

**Not:** `fdht/`

**Promotion:** NOT PROMOTED

## No Network Transport

Transport representation does NOT imply:

- HTTP
- REST
- WebSocket
- IPC
- message queue
- network API

I₃ concerns machine-readable record transport semantics.

Actual delivery mechanism is future work.

## Classification

**I₃ LOSS-AWARE READ-ONLY TRANSPORT / SCHEMA AUDITED.**

Transport requirements derived.  
Result class representation defined.  
Basis validity matrix established.  
JSON selected as prototype format.  
Malformed record tests defined.  
Round-trip tests passed.  
No new mathematics.  
No substrate modification.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean probe: **NONE** (documentation-only)  
FDHT v3.1 scope: **UNCHANGED**
