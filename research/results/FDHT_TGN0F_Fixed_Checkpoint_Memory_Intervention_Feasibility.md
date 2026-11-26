# FDHT TGN₀-F: Fixed-Checkpoint Memory-Intervention Feasibility Audit

## Classification

E — FIXED-CHECKPOINT INTERVENTION INFEASIBLE

## Summary

The official TGN implementation (twitter-research/tgn) provides memory backup/restore methods and treats memory as a model parameter. However, there is no documented standalone evaluation path that loads a fixed checkpoint, restores memory to a controlled state, and runs link-prediction evaluation without retraining. Evaluation is coupled to training. Zero live requests were issued.

## Official repository

- URL: https://github.com/twitter-research/tgn
- Licence: Apache-2.0
- Paper: arXiv:2006.10637

## Memory state inventory

| Component | Status |
|---|---|
| Memory tensor | Parameter (included in state_dict) |
| Last-update timestamps | Parameter (included in state_dict) |
| Pending messages | Runtime only (not in state_dict) |
| backup_memory() | EXISTS |
| restore_memory() | EXISTS |

## Checkpoint handling

| Feature | Status |
|---|---|
| Save state_dict | YES |
| Load state_dict | YES (early stopping) |
| Standalone evaluation | NOT DOCUMENTED |
| Memory restoration in evaluation | NOT DOCUMENTED |

## Evaluation path

Evaluation is performed during training via `eval_edge_prediction()`. There is no standalone evaluation script that loads a checkpoint and runs evaluation independently.

## Falsifiers triggered

- F1 — CHECKPOINT INCOMPLETE: Pending messages not persisted
- F6 — EVALUATION-MUTATES-STATE: Evaluation updates memory during training
- F8 — RETRAINING REQUIRED: No standalone evaluation path

## Constraint

"If no clean intervention survives: STOP."

## Integrity

- Network/API requests: 4 (web_search, browse_page)
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Fixed-checkpoint memory intervention is feasible
- Memory snapshot/restore is sufficient for evaluation
- Query-level outputs are exposable without patch
- FDHT equivalence
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
