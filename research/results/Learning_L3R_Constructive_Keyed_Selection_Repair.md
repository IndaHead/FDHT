# FDHT Learning L₃-R — Constructive Keyed-Selection Repair

**Status:** VERIFIED RESEARCH REPAIR  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `2018e8b557f616fd959e8e9cc682137753f175a5`

## Question

Can L₃ finite historical selection be expressed CLEANLY by selecting on the
smallest constructively decidable key that distinguishes the natural fixture,
while still proving that the selected proof is EXACTLY applicable to the
target request?

## Result

**YES.**

The fixture-local keyed selection using state : Fin 8 is clean.

## L₃-T Verified Boundary

The first sorryAx enters at the decidable equality decision for
FirstReturnRequest (Fin 8), not at the equality itself.

## Fixture Key

The fixture key is `state : Fin 8`, which has constructive decidable equality.

Within the req_n8 family:
- step is fixed: eightThreadCycle.toFun
- k is fixed: 8
- state varies: Fin 8

## Fixture-Local Episode Carrier

```lean
structure N8Episode where
  state : Fin 8
  result : FirstReturnResult (req_n8 state)
```

This preserves the exact dependency between state and request.

## Trust Footprints

| Theorem | Footprint | Status |
|---------|-----------|--------|
| T1_state_eq_decision | (none) | CLEAN |
| empty_no_match | [propext, Quot.sound] | CLEAN |
| empty_consumer_unresolved | [propext, Quot.sound] | CLEAN |
| applicable_selects | [propext, Quot.sound] | CLEAN |
| unresolved_no_match | [propext, Quot.sound] | CLEAN |
| concrete_selects | [propext, Quot.sound] | CLEAN |

## Key Soundness

The state key is sound BY CONSTRUCTION because:
1. N8Episode fixes the request family to req_n8
2. req_n8 fixes step and k
3. Only state varies
4. Result is indexed by req_n8 state

Therefore, matching state i means the stored evidence has EXACTLY the
target FirstPositiveReturnAt proposition required by req_n8 i.

## Collision Analysis

Two fixture-local episodes with the same state key CANNOT have different
step or k because:
1. The episode type fixes the request family to req_n8
2. req_n8 fixes step and k
3. Only state varies

This is the central anti-lossiness check.

## Generality Limitation

This repair is fixture-local. It does NOT work for arbitrary
FirstReturnRequest (Fin 8) because:
- Outside the req_n8 family, state equality is insufficient to establish
  request equality
- Different requests may have different step or k

## Semantic Comparison to L₃

| Requirement | L₃ | L₃-R |
|-------------|----|----- |
| Finite traversal | YES | YES |
| No external address | YES | YES |
| Applicable proof selection | YES | YES |
| Non-applicable skipping | YES | YES |
| UNRESOLVED skipping | YES | YES |
| Empty/no-match | YES | YES |
| Proof retention | YES | YES |
| Read-only history | YES | YES |
| Knockout | YES | YES |
| No theorem fallback | YES | YES |
| Clean trust footprint | NO | YES |

## Pressure Classification

| Component | Classification |
|-----------|----------------|
| State-key equality | H EXISTING SUBSTRATE SUFFICIENT |
| Fixture-local episode | H EXISTING SUBSTRATE SUFFICIENT |
| Target-indexed selection | H EXISTING SUBSTRATE SUFFICIENT |
| Target-indexed consumer | H EXISTING SUBSTRATE SUFFICIENT |
| Key soundness | H EXISTING SUBSTRATE SUFFICIENT |
| Trust closure | H EXISTING SUBSTRATE SUFFICIENT |

## Classification

**CLEAN FIXTURE-LOCAL REPAIR VERIFIED**

L₃ capability works cleanly for req_n8 history using sound state key.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
L₃ modified: **NO**  
Lean file: `research/probes/learning_consumer/l3r_constructive_keyed_selection_repair.lean`  
FDHT v3.1 scope: **UNCHANGED**
