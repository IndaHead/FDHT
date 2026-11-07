# FDHT Learning L₃-T — Decidable Equality / Selection Trust-Boundary Bisection

**Status:** VERIFIED RESEARCH AUDIT  
**Authority:** RESEARCH AUDIT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `0b7ea67cf8cac3b4d7b895f114146d19609bf28a`

## Question

Where exactly does sorryAx enter L₃?

## Result

**LOCALISED.**

The first sorryAx enters at the decidable equality decision, not at the
equality itself.

## L₃ Verified Inputs

L₃ established structural architecture for typed historical selection, but
central theorems report [propext, sorryAx, Quot.sound].

## Current Causal Hypothesis

L₃ attributed pressure to decidable equality on FirstReturnRequest (Fin 8).

## First-Divergence Table

| Target | Mechanism | Footprint | sorryAx? | First Divergence? |
|--------|-----------|-----------|----------|-------------------|
| T0_true | trivial | (none) | NO | - |
| T1_req_n8_k | request construction | [propext, Quot.sound] | NO | - |
| T2_req_n8_rfl | reflexive equality | [propext, Quot.sound] | NO | - |
| T3_req_eq_decision | decidable equality | [propext, sorryAx] | YES | FIRST |
| T4_state_eq | state equality | [propext, Quot.sound] | NO | - |
| T5_result_match | result matching | [propext, Quot.sound] | NO | - |
| T7_matches_empty | equality + traversal | [propext, sorryAx, Quot.sound] | YES | downstream |
| T8_dependent_transport | supplied equality | [propext, Quot.sound] | NO | - |
| T9_select_single_unresolved | single-cell selection | [propext, sorryAx, Quot.sound] | YES | downstream |
| T10_select_empty | recursive selection | [propext, sorryAx, Quot.sound] | YES | downstream |
| T11_select_applicable_empty | selectApplicable | [propext, sorryAx, Quot.sound] | YES | downstream |
| T12_consume_noMatch | consumeSelection | [propext, sorryAx, Quot.sound] | YES | downstream |
| T13_consume_noMatch_explicit | consumeSelection | [propext, sorryAx, Quot.sound] | YES | downstream |
| T14_consume_req_noMatch | target-indexed consumer | [propext, Quot.sound] | NO | CLEAN |
| T15_select_single_req_unresolved | target-indexed selector | [propext, sorryAx, Quot.sound] | YES | downstream |
| T16_select_req_empty | target-indexed recursive | [propext, sorryAx, Quot.sound] | YES | downstream |
| T17_empty_req | empty target-indexed | [propext, sorryAx, Quot.sound] | YES | downstream |
| T18_unresolved_req | unresolved target-indexed | [propext, sorryAx, Quot.sound] | YES | downstream |
| T19_irrelevant_first_req | irrelevant-first | [propext, sorryAx, Quot.sound] | YES | downstream |
| n8_index_first_return | source theorem | [propext, Quot.sound] | NO | CLEAN |

## First Clean → Dirty Edge

**T2_req_n8_rfl (clean)**  
↓  
**T3_req_eq_decision (sorryAx)**

The decidable equality decision introduces sorryAx.

## Key Findings

### 1. Reflexive Equality is Clean

`T2_req_n8_rfl` depends only on [propext, Quot.sound].

Using equality is clean. Deciding equality is dirty.

### 2. Decidable Equality Decision is Dirty

`T3_req_eq_decision` depends on [propext, sorryAx].

The `if h : req_n8 i = req_n8 i` construct requires a DecidableEq instance,
which is not available for FirstReturnRequest (Fin 8).

### 3. Target-Indexed Consumer is Clean

`T14_consume_req_noMatch` depends only on [propext, Quot.sound].

The target-indexed consumer that does NOT need to decide equality is clean.

### 4. Target-Indexed Selector is Still Dirty

`T15_select_single_req_unresolved` depends on [propext, sorryAx, Quot.sound].

Even with target-indexed result, the selector still needs to decide equality
internally.

### 5. Source Theorem is Clean

`n8_index_first_return` depends only on [propext, Quot.sound].

The source theorem does NOT introduce sorryAx.

## Decidable Instance Origin

The error message `failed to synthesize instance of type class` indicates that
Lean cannot synthesize a `DecidableEq (FirstReturnRequest (Fin 8))` instance.

This is because `FirstReturnRequest` contains a function field (`step : X → X`),
and function equality is not decidable in general.

## Classification

**PRIMARY:** DECIDABLE EQUALITY DECISION INTRODUCES SORRYAX

The `if h : ep.request = target` construct requires a DecidableEq instance
that is not available for FirstReturnRequest (Fin 8).

**SECONDARY:**
- Reflexive equality is clean
- Target-indexed consumer is clean
- Source theorem is clean
- Dependent transport with supplied equality is clean

## L₃ Causal Claim Assessment

**CONFIRMED**

The L₃ claim "proof reduction requires sorryAx due to decidable equality
requirements on FirstReturnRequest" is confirmed.

## Candidate L₃-R Repair

A candidate repair would involve:
1. Avoiding internal equality decision in the selector.
2. Using a fixture-specific key (e.g., Fin 8 state) that is decidable.
3. Preserving target index through traversal.

This is a NEXT AUDIT TARGET, not an implementation.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Repair performed: **NO**  
Lean file: `research/probes/learning_consumer/l3t_decidable_equality_boundary_audit.lean`  
FDHT v3.1 scope: **UNCHANGED**
