# FDHT Learning L₂-T — SorryAx Boundary Bisection Audit

**Status:** VERIFIED RESEARCH AUDIT  
**Authority:** RESEARCH AUDIT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `b1588728d2599b4235f18abb6cdb7200c09ab9bc`

## Question

Where exactly does `sorryAx` first enter the dependency chain used by L₂?

## Result

**LOCALISED.**

The first sorryAx in the recovery path enters at `recoverAt` itself, not at
the source theorem or dependent transport.

## Methodology

Incremental bisection from trivial baseline through:
1. Request structure
2. Result packaging
3. Episode construction
4. History construction
5. List.get access
6. RecoveryResult packaging
7. Request equality
8. Dependent transport
9. recoverAt unresolved path
10. Parametric established episode
11. Parametric recoverAt
12. n8_index_first_return direct
13. Concrete established history
14. Concrete recoverAt
15. Later parametric consumer
16. Later concrete consumer

## No Local Sorry Check

L₂ source contains no explicit:
- `sorry`
- `admit`
- custom axiom

The sorryAx is inherited from proof reduction, not from explicit placeholder.

## First-Divergence Table

| Target | Footprint | sorryAx? | First Divergence? |
|--------|-----------|----------|-------------------|
| T0_true | (none) | NO | - |
| T1_req_n8_k | [propext, Quot.sound] | NO | - |
| T2_unresolved_constructor | [sorryAx] | YES | projection artefact |
| T3_unresolved_episode | [propext, Quot.sound] | NO | - |
| T4_unresolved_history_length | [propext, Quot.sound] | NO | - |
| T5_list_get | [propext, Quot.sound] | NO | - |
| T6_notFound | [propext, Quot.sound] | NO | - |
| T7_request_equality | [propext, Quot.sound] | NO | - |
| T8_dependent_transport | [propext, Quot.sound] | NO | - |
| T9_recoverAt_unresolved | [propext, sorryAx, Quot.sound] | YES | RECOVERY PATH |
| T10_parametric_established | [propext, Quot.sound] | NO | - |
| T11_parametric_recoverAt | [propext, sorryAx, Quot.sound] | YES | RECOVERY PATH |
| n8_index_first_return | [propext, Quot.sound] | NO | - |
| T13_concrete_established | [propext, Quot.sound] | NO | - |
| T14_concrete_recoverAt | [propext, sorryAx, Quot.sound] | YES | RECOVERY PATH |
| T15_later_parametric | [propext, sorryAx, Quot.sound] | YES | downstream |
| T16_later_concrete | [propext, sorryAx, Quot.sound] | YES | downstream |

## First Clean → Dirty Edge

**T10_parametric_established (clean)**  
↓  
**T11_parametric_recoverAt (sorryAx)**

The `recoverAt` function itself introduces sorryAx when reducing the
parametric recovery path.

## Key Findings

### 1. Source Theorem is Clean

`n8_index_first_return` depends only on [propext, Quot.sound].

The source theorem does NOT introduce sorryAx.

### 2. Dependent Transport is Clean

`T8_dependent_transport` depends only on [propext, Quot.sound].

The dependent transport does NOT introduce sorryAx.

### 3. List.get is Clean

`T5_list_get` depends only on [propext, Quot.sound].

List access does NOT introduce sorryAx.

### 4. recoverAt Introduces sorryAx

Both:
- `T9_recoverAt_unresolved` (unresolved path)
- `T11_parametric_recoverAt` (parametric positive path)

introduce sorryAx.

The sorryAx enters at the `recoverAt` function itself, not at its inputs.

### 5. Parametric vs Concrete

| Path | Footprint |
|------|-----------|
| Parametric recovery (T11) | [propext, sorryAx, Quot.sound] |
| Concrete recovery (T14) | [propext, sorryAx, Quot.sound] |

Both paths have the same footprint. The sorryAx is not from the concrete
source theorem.

## Classification

**PRIMARY:** L₂ CONTAINER ARCHITECTURE INTRODUCES SORRYAX

The `recoverAt` function itself introduces sorryAx during proof reduction.
This is a proof-engineering limitation, not a mathematical gap.

**SECONDARY:**
- Source theorem is clean
- Dependent transport is clean
- List.get is clean
- Parametric and concrete paths have identical footprints

## L₂ Interpretation

1. L₂ container architecture itself introduces sorryAx during proof reduction.
2. The source theorem (`n8_index_first_return`) is clean.
3. The dependent transport is clean.
4. The sorryAx is a proof-engineering limitation, not a mathematical gap.

## Candidate Repair Direction

The sorryAx enters during `recoverAt` proof reduction. A candidate repair
would involve:
1. Restructuring `recoverAt` to avoid the match/if pattern that requires
   sorryAx for reduction.
2. Using a different proof strategy that does not require definitional
   reduction of the recovery function.

This is a NEXT AUDIT TARGET, not an implementation.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Repair performed: **NO**  
Lean file: `research/probes/learning_consumer/l2t_sorryax_boundary_audit.lean`  
FDHT v3.1 scope: **UNCHANGED**
