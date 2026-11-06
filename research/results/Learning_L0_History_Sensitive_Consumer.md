# FDHT Learning L₀ — History-Sensitive Consumer

**Status:** VERIFIED  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `1235663147850e6b8343c5b1498ae254b48cf3c9`

## Question

Can preserved historical evidence change a later justified result for the same
request?

## Result

**YES.**

The L₀ probe demonstrates that applicable evidence supplied in a later episode
can change the result from UNRESOLVED to ESTABLISHED for the same request.

## Exact Request

```lean
def req_n8 (i : Fin 8) : FirstReturnRequest (Fin 8) where
  step  := eightThreadCycle.toFun
  state := i
  k     := 8
```

## Episode Trajectory

| Episode | Evidence Supplied | Result | Status |
|---------|-------------------|--------|--------|
| 0 | none | UNRESOLVED | .unresolved |
| 1 | irrelevant (n=4 first-return) | UNRESOLVED | .unresolved |
| 2 | applicable (n=8 first-return) | ESTABLISHED | .established |

## Learning Transition

```lean
theorem learning_transition (i : Fin 8) :
    (episode0_unresolved i).result.status = .unresolved ∧
    (episode2_established i).result.status = .established
```

## Historical Specificity

Irrelevant evidence does not change the result:

```lean
theorem irrelevant_does_not_establish (i : Fin 8) :
    (episode1_irrelevant i).result.status = .unresolved
```

## History Preservation

Later knowledge does not retroactively mutate earlier episodes:

```lean
theorem history_preserves_episode0 (i : Fin 8) :
    ((history_n8 i).episodes[0]'(...)).result.status = .unresolved
```

## Proof Retention

The ESTABLISHED result retains the proof payload:

```lean
theorem proof_retained (i : Fin 8) :
    FirstPositiveReturnAt eightThreadCycle.toFun i 8
```

## Trust Footprints

| Theorem | Axioms |
|---------|--------|
| episode0_status | [propext, Quot.sound] |
| episode2_status | [propext, Quot.sound] |
| learning_transition | [propext, Quot.sound] |
| proof_retained | [propext, Quot.sound] |

## Firewalls Verified

| Firewall | Status |
|----------|--------|
| history ≠ authority | VERIFIED |
| unresolved ≠ false | VERIFIED |
| status ≠ evidence | VERIFIED |
| more history ≠ stronger evidence | VERIFIED |
| retrieval not implemented | VERIFIED |
| proof search not implemented | VERIFIED |
| no weights/confidence | VERIFIED |
| no automatic evaluator | VERIFIED |
| no action layer | VERIFIED |
| no generic Learning API | VERIFIED |
| no substrate modification | VERIFIED |

## Classification

**L₀ VERIFIED HISTORY-SENSITIVE CONSUMER**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean file: `research/probes/learning_consumer/l0_first_return_history_consumer.lean`  
FDHT v3.1 scope: **UNCHANGED**
