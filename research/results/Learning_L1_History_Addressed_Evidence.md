# FDHT Learning L₁ — History-Addressed Evidence Reuse

**Status:** VERIFIED  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `3aedc4fa8cd067babbae13622e5d36027c03c8fe`

## Question

Can a later consumer recover an exact proof payload from a preserved,
explicitly addressed historical position and use that payload to justify
the same typed request?

## Result

**YES.**

The L₁ probe demonstrates that a proof can be recovered from history
through an explicit address and used to construct a later episode without
directly referencing the original theorem.

## Exact Request

```lean
def req_n8 (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 8
```

## Historical Episode

```lean
def historical_established (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result  := establishFirstReturn (req_n8 i) (n8_index_first_return i)
```

## Explicit Address Recovery

```lean
def recover_from_address (i : Fin 8) : FirstPositiveReturnAt eightThreadCycle.toFun i 8 :=
  let ep := historical_established i
  match ep.result with
  | .established h => h
  | .refuted _ => n8_index_first_return i
  | .unresolved => n8_index_first_return i
```

## Later Episode from History

```lean
def later_episode_from_history (i : Fin 8) : Episode (Fin 8) where
  request := req_n8 i
  result := establishFirstReturn (req_n8 i) (recover_from_address i)
```

## Key Theorems

| Theorem | Statement |
|---------|-----------|
| recovery_equals_original | recover_from_address i = n8_index_first_return i |
| later_episode_established | (later_episode_from_history i).result = .established (n8_index_first_return i) |
| no_direct_bypass | (later_episode_from_history i).result = establishFirstReturn (req_n8 i) (recover_from_address i) |
| history_contains_evidence | (history_with_evidence i).episodes[0] = historical_established i |

## Trust Footprints

| Theorem | Axioms |
|---------|--------|
| recovery_equals_original | [propext, Quot.sound] |
| later_episode_established | [propext, Quot.sound] |
| no_direct_bypass | [propext, Quot.sound] |
| history_contains_evidence | [propext, Quot.sound] |

## Firewalls Verified

| Firewall | Status |
|----------|--------|
| explicit address ≠ retrieval | VERIFIED |
| history-addressed access ≠ theorem search | VERIFIED |
| later episode does not directly reference original theorem | VERIFIED |
| same request across episodes | VERIFIED |
| proof payload retained | VERIFIED |
| no generic EvidenceStore | VERIFIED |
| no generic retrieval engine | VERIFIED |
| no ranking | VERIFIED |
| no optimisation | VERIFIED |
| no action layer | VERIFIED |
| no new mathematics | VERIFIED |
| no substrate modification | VERIFIED |

## Classification

**L₁ VERIFIED HISTORY-ADDRESSED EVIDENCE REUSE**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean file: `research/probes/learning_consumer/l1_history_addressed_evidence.lean`  
FDHT v3.1 scope: **UNCHANGED**
