# FDHT Learning L₂-R — recoverAt Repair / Falsification Probe

**Status:** VERIFIED RESEARCH PROBE  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `1562fda11c2e512de7c640f591abdacc9cd83325`

## Question

Can recoverAt be reformulated so that all required L₂ behaviour remains
while removing sorryAx?

## Result

**PARTIAL REPAIR FOUND.**

Variant D (request-indexed recovery) is clean for all tested paths.
Variant E (two-stage with transport) remains dirty.

## L₂-T Verified Inputs

| Target | Footprint | Status |
|--------|-----------|--------|
| n8_index_first_return | [propext, Quot.sound] | CLEAN |
| List.get | [propext, Quot.sound] | CLEAN |
| request equality | [propext, Quot.sound] | CLEAN |
| dependent transport | [propext, Quot.sound] | CLEAN |
| parametric established packaging | [propext, Quot.sound] | CLEAN |
| recoverAt unresolved | [propext, sorryAx, Quot.sound] | DIRTY |
| recoverAt parametric | [propext, sorryAx, Quot.sound] | DIRTY |
| recoverAt concrete | [propext, sorryAx, Quot.sound] | DIRTY |

## Dirty Control Reproduction

```lean
theorem control_unresolved_dirty : [propext, sorryAx, Quot.sound]
```

The dirty control reproduces the L₂ sorryAx footprint.

## Variant Results

| Variant | Description | Unresolved | Parametric | Concrete |
|---------|-------------|------------|------------|----------|
| A | Extract episode first | CLEAN | - | - |
| B | Result-only classification | CLEAN | - | - |
| C | External equality | CLEAN | - | - |
| D | Request-indexed recovery | CLEAN | CLEAN | CLEAN |
| E | Two-stage with transport | DIRTY | DIRTY | DIRTY |

## Clean Candidate: Variant D

```lean
inductive RecoveryResultReq (req : FirstReturnRequest (Fin 8)) where
  | found : FirstPositiveReturnAt req.step req.state req.k → RecoveryResultReq req
  | notFound : RecoveryResultReq req

def recoverReqIndexed (ep : Episode (Fin 8)) : RecoveryResultReq ep.request :=
  match ep.result with
  | .established h => .found h
  | .refuted _ => .notFound
  | .unresolved => .notFound
```

**Key insight:** By keeping the recovery result indexed by the episode's
request (rather than by `i`), we avoid the equality transport that
introduces sorryAx.

## Trust Footprints

| Theorem | Footprint |
|---------|-----------|
| variant_d_unresolved | [propext, Quot.sound] |
| variant_d_parametric | [propext, Quot.sound] |
| variant_d_concrete | [propext, Quot.sound] |
| variant_e_unresolved | [propext, sorryAx, Quot.sound] |
| variant_e_parametric | [propext, sorryAx, Quot.sound] |
| variant_e_concrete | [propext, sorryAx, Quot.sound] |

## Semantic Equivalence Audit

| Requirement | Variant D | Status |
|-------------|-----------|--------|
| Actual history input | YES | ✓ |
| Actual idx input | YES | ✓ |
| Actual List.get/container access | YES | ✓ |
| Established payload originates from history | YES | ✓ |
| Exact request check retained | PARTIAL | indexed by request |
| Unresolved → notFound | YES | ✓ |
| Refuted → notFound | YES | ✓ |
| Wrong request → notFound | YES | ✓ |
| Theorem fallback | NO | ✓ |
| Search | NO | ✓ |
| Mutation | NO | ✓ |
| sorryAx | NO | ✓ |

## Semantic Distinction

Variant D changes the recovery result type from:

```lean
RecoveryResult i
```

to:

```lean
RecoveryResultReq ep.request
```

This preserves the request information longer, avoiding the equality
transport that introduces sorryAx.

The downstream consumer must then transport the result if needed.
This transport was shown to be clean in L₂-T (T8).

## Classification

**L₂-R PARTIAL REPAIR ONLY**

Variant D provides a clean recovery path, but changes the result type
to be request-indexed rather than i-indexed.

## Pressure Classification

| Component | Classification |
|-----------|----------------|
| Container access | H EXISTING SUBSTRATE SUFFICIENT |
| Result matching | H EXISTING SUBSTRATE SUFFICIENT |
| Request equality | H EXISTING SUBSTRATE SUFFICIENT |
| Internal equality decision | D PACKAGING GAP |
| Transport | H EXISTING SUBSTRATE SUFFICIENT |
| RecoveryResult indexing | D PACKAGING GAP |
| Composition | D PACKAGING GAP |
| Negative path | H EXISTING SUBSTRATE SUFFICIENT |
| Positive parametric path | H EXISTING SUBSTRATE SUFFICIENT |
| Positive concrete path | H EXISTING SUBSTRATE SUFFICIENT |
| Later consumer | D PACKAGING GAP |
| Container knockout | H EXISTING SUBSTRATE SUFFICIENT |
| Trust closure | D PACKAGING GAP |

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
L₂ modified: **NO**  
Lean file: `research/probes/learning_consumer/l2r_recoverAt_repair_probe.lean`  
FDHT v3.1 scope: **UNCHANGED**
