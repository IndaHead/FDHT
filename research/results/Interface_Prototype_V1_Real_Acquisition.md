# FDHT Interface Prototype V₁ — Real-Artefact Acquisition Integration

**Status:** PROTOTYPE COMPLETE  
**Authority:** RESEARCH INTERFACE TOOLING  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `b8abf914de24c71f57b0a8d57f5a23587aea3da0`

## Question

Can the existing Workbench consume at least ONE i3.0 presentation record whose
semantic fields are populated by executable read-only acquisition from ACTUAL
existing FDHT repository artefacts rather than manually authored presentation
JSON?

## Answer

**YES.**

## Acquisition Tool

**Location:** `research/interface/workbench/acquire_n8.py`

**Method:** Executable read-only acquisition from actual Lean source.

## Field Lineage

| Field | Source Artefact | Extraction Rule | Direct/Derived |
|-------|-----------------|-----------------|----------------|
| request_scope | `fdht/FDHTFirstPositiveReturn.lean` | Parsed from theorem type signature | DIRECT |
| result_class | Theorem existence + consumer context | Derived from theorem existence | DERIVED |
| evidence_ref | `fdht/FDHTFirstPositiveReturn.lean` | Extracted from theorem declaration | DIRECT |
| trust_footprint | Lean `#print axioms` | Acquired via `lake env lean` | DIRECT |
| source_snapshot | Git | Acquired via `git rev-parse` | DIRECT |
| research_provenance | Git + programme context | Derived from snapshot + programme | DERIVED |

## Acquired Record

**Location:** `research/interface/workbench/generated/acquired_n8.json`

```json
{
  "schema_version": "i3.0",
  "source_snapshot": {
    "source_branch": "research/interface-consumer",
    "source_head": "b8abf914de24c71f57b0a8d57f5a23587aea3da0"
  },
  "request_scope": {
    "state": "Fin 8",
    "k": 8,
    "step": "eightThreadCycle.toFun"
  },
  "result_class": "ESTABLISHED",
  "evidence_ref": {
    "theorem": "n8_index_first_return",
    "source": "fdht/FDHTFirstPositiveReturn.lean",
    "authority": "MATHEMATICAL"
  },
  "trust_footprint": {
    "axioms": ["propext", "Quot.sound"]
  },
  "research_provenance": {
    "authority": "RESEARCH RESULT ONLY",
    "programme": "interface-consumer",
    "probe": "V₁",
    "promotion": "NOT PROMOTED"
  }
}
```

## Non-Circularity

The acquisition tool:

- Does NOT hard-code result_class for the specific fixture
- Does NOT hard-code trust footprint for the specific theorem
- Does NOT hard-code request scope copied manually from prior research
- Does NOT use fixture-specific lookup table
- Does NOT read expected-result document to determine output
- Does NOT copy semantic values from prompt into generated JSON
- Does NOT use existing synthetic V₀ JSON fixture as semantic acquisition input

**SOURCE CHANGE → OUTPUT CHANGE / REJECTION.**

## Validation

Generated record passes I₃ i3.0 validation:

- schema_version: i3.0
- request_scope: present with required coordinates
- result_class: ESTABLISHED
- evidence_ref: present
- trust_footprint: present
- source_snapshot: present

## Workbench Integration

Generated record can be loaded into existing V₀ Workbench.

No second renderer required.

## Authority Firewall

Generated JSON inherits no independent authority.

Authority belongs to represented sources.

The acquisition tool is not:

- a theorem prover
- a verifier of mathematical truth
- a certification engine

It only acquires presentation facts from configured sources.

## Gap Register

| ID | Classification | Description | Disposition |
|----|----------------|-------------|-------------|
| G1 | IMPLEMENTATION-ONLY | Trust acquisition requires `lake env` | ACCEPTABLE |
| G2 | FALSE REQUIREMENT | No historical lineage for direct theorem | ACCEPTABLE |

## Classification

**PROTOTYPE V₁ REAL-ARTEFACT ACQUISITION IMPLEMENTED.**

Executable read-only acquisition from actual FDHT repository artefacts.  
Non-circular: source change → output change.  
I₃ validation passed.  
Workbench integration verified.  
No new mathematics.  
No substrate modification.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
FDHT v3.1 scope: **UNCHANGED**
