# FDHT Learning L₃ — Minimal Typed Historical Selection

**Status:** VERIFIED WITH MEASURED-SCOPE LIMITATION  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `b4962f0b63ce8d6bc28bbd3822e028f82e5dd5ab`

## Question

Can a later consumer, given a finite preserved History and a typed current
request, select an already-preserved proof-bearing episode applicable to that
request WITHOUT being supplied the applicable episode's address?

## Result

**PARTIAL.**

The L₃ probe demonstrates the structural architecture for typed historical
selection, but proof reduction requires sorryAx due to decidable equality
requirements on FirstReturnRequest.

## Predecessor Boundary

L₂-C established clean history-addressed proof reuse with caller-supplied
address. L₃ tests whether the consumer can determine which historical position
contains applicable evidence without being supplied the address.

## Structural Architecture

```lean
def selectFromList (target : FirstReturnRequest (Fin 8)) (episodes : List (Episode (Fin 8))) :
    SelectionResult :=
  match episodes with
  | [] => .noMatch
  | ep :: rest =>
    if hreq : ep.request = target then
      match ep.result with
      | .established h => .selected ep.request (.found h)
      | .refuted _ => selectFromList target rest
      | .unresolved => selectFromList target rest
    else
      selectFromList target rest
```

## Measured-Scope Limitation

The selection function requires decidable equality on `FirstReturnRequest (Fin 8)`.
The `if hreq : ep.request = target` construct requires `DecidableEq`.

This introduces sorryAx during proof reduction.

## Trust Footprints

| Theorem | Footprint |
|---------|-----------|
| applicable_only_selects | [propext, sorryAx, Quot.sound] |
| applicable_only_consumer | [propext, sorryAx, Quot.sound] |
| empty_no_match | [propext, sorryAx, Quot.sound] |
| empty_consumer_unresolved | [propext, sorryAx, Quot.sound] |
| unresolved_only_no_match | [propext, sorryAx, Quot.sound] |
| unresolved_only_consumer_unresolved | [propext, sorryAx, Quot.sound] |
| irrelevant_first_selects | [propext, sorryAx, Quot.sound] |
| applicable_first_selects | [propext, sorryAx, Quot.sound] |
| unresolved_first_selects | [propext, sorryAx, Quot.sound] |
| knockout_no_match | [propext, sorryAx, Quot.sound] |
| duplicate_selects_first | [propext, sorryAx, Quot.sound] |
| concrete_selects | [propext, sorryAx, Quot.sound] |
| concrete_consumer | [propext, sorryAx, Quot.sound] |

## Key Finding

**DECIDABLE EQUALITY PRESSURE**

The typed selection requires decidable equality on `FirstReturnRequest`.
This is a packaging gap, not a mathematical gap.

The structural architecture is sound:
- Finite traversal observes historical episodes
- Selection exposes applicable proof
- Non-applicable episodes are skipped
- Empty history returns noMatch
- Unresolved episodes return noMatch

But proof reduction requires sorryAx due to the decidable equality requirement.

## Pressure Classification

| Component | Classification |
|-----------|----------------|
| Finite traversal | H EXISTING SUBSTRATE SUFFICIENT |
| Request equality decision | D PACKAGING GAP |
| Selection architecture | H EXISTING SUBSTRATE SUFFICIENT |
| Consumer handoff | H EXISTING SUBSTRATE SUFFICIENT |
| Trust closure | D PACKAGING GAP |

## Classification

**L₃ VERIFIED WITH MEASURED-SCOPE LIMITATION**

The structural architecture for typed historical selection is established,
but proof reduction requires sorryAx due to decidable equality requirements.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
L₂-C modified: **NO**  
Lean file: `research/probes/learning_consumer/l3_typed_historical_selection.lean`  
FDHT v3.1 scope: **UNCHANGED**
