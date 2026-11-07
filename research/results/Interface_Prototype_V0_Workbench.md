# FDHT Interface Prototype V₀ — Read-Only Workbench

**Status:** PROTOTYPE COMPLETE  
**Authority:** RESEARCH INTERFACE TOOLING  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `6c35634da10b1a2213b01cbdf6d811064471e665`

## Question

Can a minimal running read-only Workbench consume validated I₃ JSON records and
provide the I₁ navigation paths while preserving all I₀ semantic distinctions?

## Implementation Stack

**Chosen:** Single HTML file with embedded JavaScript

**Why:**

- No build system required
- No server required
- No dependencies
- Local read-only prototype
- JSON i3.0 ingestion
- Validation
- Five I₁ views
- Contextual Inspector
- Deterministic navigation

**Rejected alternatives:**

- React/Vue/Svelte: unnecessary build complexity
- Python + Flask: unnecessary server
- Electron/Tauri: unnecessary desktop packaging

**Run command:** Open `research/interface/workbench/index.html` in a browser

## Implementation Location

`research/interface/workbench/`

## Fixtures

| ID | Description | Provenance |
|----|-------------|------------|
| F1 | ESTABLISHED / clean trust | Manually constructed from V₀-R source data |
| F2 | UNRESOLVED / no applicable evidence | Manually constructed from V₀-R baseline source data |
| F3 | dirty historical trust | Manually constructed from V₀ historical dirty source data |

All fixtures are SYNTHETIC PRESENTATION FIXTURES.  
Synthetic presentation fixture ≠ new FDHT evidence.

## Validation

Workbench rejects malformed transport records before rendering semantic UI.

Checks:

- schema/version supported
- request_scope present
- result_class recognised
- result/basis combination valid
- required scope coordinates present

## Validation Failure UI

Malformed data produces clear inspection failure:

**TRANSPORT INVALID**

Transport failure ≠ mathematical result.

## Views Implemented

| View | Status |
|------|--------|
| REQUESTS | IMPLEMENTED |
| HISTORY | IMPLEMENTED |
| EVIDENCE | IMPLEMENTED |
| VERIFICATION | IMPLEMENTED |
| RESEARCH | IMPLEMENTED |
| INSPECTOR | IMPLEMENTED |

## Semantic Distinctions Preserved

| Distinction | Preserved |
|-------------|-----------|
| ESTABLISHED ≠ REFUTED ≠ UNRESOLVED | YES |
| UNRESOLVED ≠ FALSE | YES |
| NO APPLICABLE EVIDENCE ≠ REFUTATION | YES |
| VERIFIED ≠ CERTIFIED | YES |
| EVIDENCE NOT AVAILABLE ≠ REFUTED | YES |
| Transport failure ≠ mathematical result | YES |

## Provenance Planes

Inspector sections:

- MATHEMATICAL
- TRUST
- RESEARCH
- HISTORY
- SOURCE SNAPSHOT

No combined trust score, authority score, confidence score, or health score.

## Source Context

Source snapshot exposed separately from mathematical request scope.

## Navigation

I₁ justified read-only navigation graph implemented.

Navigation changes focus.  
Navigation does not change FDHT state.

## Read-Only Guarantee

Prototype contains no controls which:

- edit records
- write JSON
- modify history
- inject evidence
- change result
- promote research
- certify
- trigger actions

## End-to-End Walk

1. Load F1 ESTABLISHED fixture
2. Validate i3.0
3. REQUESTS: scope preserved, result ESTABLISHED, evidence n8_index_first_return
4. EVIDENCE: theorem, source, authority, scope, trust
5. HISTORY: DIRECT lineage
6. RESEARCH: RESEARCH RESULT ONLY
7. REQUESTS: same scope, same basis

**Result:** Scope preserved. Result identity preserved. Trust preserved. Research authority preserved. No state mutation.

## UNRESOLVED Walk

1. Load F2 UNRESOLVED fixture
2. REQUESTS: result UNRESOLVED, non-admission reason displayed
3. VERIFICATION: EVIDENCE NOT AVAILABLE ≠ REFUTED
4. INSPECTOR: non-admission reason visible
5. RESEARCH: RESEARCH RESULT ONLY

**Result:** No positive evidence appears as admitted basis.

## Dirty Trust Walk

1. Load F3 dirty historical trust fixture
2. EVIDENCE: sorryAx visible in trust footprint
3. INSPECTOR/TRUST: [propext, sorryAx, Quot.sound]
4. RESEARCH: V₀ probe, RESEARCH RESULT ONLY

**Result:** Dirty trust remains visible. Not sanitised. Not replaced with clean repair.

## Gap Register

| ID | Observed Behaviour | Layer | Workaround | Disposition |
|----|-------------------|-------|------------|-------------|
| G1 | No live acquisition | I₂ | Static fixtures | ACCEPTABLE for prototype |
| G2 | No REFUTED fixture | I₀ | Not tested | ACCEPTABLE — no natural fixture |
| G3 | Fixtures manually constructed | I₃ | Documented as synthetic | ACCEPTABLE |

## Classification

**PROTOTYPE V₀ READ-ONLY WORKBENCH IMPLEMENTED.**

Minimal running workbench consumes validated I₃ JSON records.  
I₁ navigation paths provided.  
I₀ semantic distinctions preserved.  
No new mathematics.  
No substrate modification.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
FDHT v3.1 scope: **UNCHANGED**
