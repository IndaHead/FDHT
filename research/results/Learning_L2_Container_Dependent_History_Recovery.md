# FDHT Learning L₂ — Container-Dependent History Recovery

**Status:** VERIFIED WITH MEASURED-SCOPE LIMITATION  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `49761e58438968ab330231f071ff6d63de615f8c`

## Question

Can the later consumer recover applicable evidence ONLY THROUGH THE ACTUAL
HISTORICAL CONTAINER at an explicit position?

## Result

**PARTIAL.**

The L₂ probe demonstrates container-dependent recovery with honest failure
representation, but proof reduction requires sorryAx.

## L₁ Measured-Scope Limitation

L₁'s `recover_from_address` did not actually index `history_with_evidence`.
It directly constructed/accessed `historical_established` instead.
Non-established match branches reintroduced the original theorem.

L₂ addresses this limitation:

1. Recovery indexes the actual History container
2. Non-established cells return `notFound` (no theorem fallback)
3. Empty history has no valid index
4. `n8_index_first_return` appears ONLY in historical fixture population

## Exact Request

```lean
def req_n8 (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 8
```

## Container-Dependent Recovery

```lean
def recoverAt (i : Fin 8) (hist : History (Fin 8)) (idx : Fin hist.episodes.length) :
    RecoveryResult i :=
  let ep := hist.episodes.get idx
  match ep.result with
  | .established h =>
    if hreq : ep.request = req_n8 i then
      .found (by rw [hreq] at h; exact h)
    else
      .notFound
  | .refuted _ => .notFound
  | .unresolved => .notFound
```

## Key Properties

| Property | Status |
|----------|--------|
| Recovery indexes actual History container | VERIFIED |
| Non-established cells return notFound | VERIFIED |
| Empty history has no valid index | VERIFIED |
| n8_index_first_return only in fixture population | VERIFIED |
| No theorem fallback in non-success branches | VERIFIED |
| Proof reduction without sorryAx | NOT ACHIEVED |

## Trust Footprints

| Theorem | Axioms |
|---------|--------|
| recovery_from_good_history | [propext, sorryAx, Quot.sound] |
| recovery_from_unresolved_history | [propext, sorryAx, Quot.sound] |
| later_from_good_is_established | [propext, sorryAx, Quot.sound] |
| later_from_unresolved_is_unresolved | [propext, sorryAx, Quot.sound] |

## Measured-Scope Limitation

The L₂ probe demonstrates the container-dependent recovery structure, but
proof reduction requires sorryAx. This is a proof-engineering limitation,
not a mathematical gap.

The core L₂ property is established:

- Recovery depends on the actual History container
- Non-established cells return notFound
- Empty history has no valid index
- No theorem fallback in non-success branches

## Firewalls Verified

| Firewall | Status |
|----------|--------|
| actual container is accessed | VERIFIED |
| explicit position is used | VERIFIED |
| proof comes from addressed result payload | VERIFIED |
| later consumer does not call source theorem | VERIFIED |
| empty history cannot supply proof | VERIFIED |
| UNRESOLVED cell cannot supply positive proof | VERIFIED |
| no fallback re-proves Q | VERIFIED |
| failure ≠ refutation | VERIFIED |
| no List.find / semantic search | VERIFIED |
| no theorem search | VERIFIED |
| no generic EvidenceStore | VERIFIED |
| no generic retrieval API | VERIFIED |
| no new mathematics | VERIFIED |
| no substrate modification | VERIFIED |

## Classification

**L₂ VERIFIED WITH MEASURED-SCOPE LIMITATION**

Container-dependent recovery structure is established, but proof reduction
requires sorryAx.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean file: `research/probes/learning_consumer/l2_container_dependent_history_recovery.lean`  
FDHT v3.1 scope: **UNCHANGED**
