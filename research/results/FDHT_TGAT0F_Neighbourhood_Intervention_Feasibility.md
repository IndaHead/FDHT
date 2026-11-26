# FDHT TGAT₀-F: Fixed-Checkpoint Temporal-Neighbourhood Intervention Feasibility Audit

## Classification

E — FIXED-CHECKPOINT INTERVENTION INFEASIBLE

## Summary

The official TGAT implementation (StatsDLMathsRecomSys/Inductive-representation-learning-on-temporal-graphs) sets the neighbour sampling budget (`--n_degree`) at training time. There is no documented standalone evaluation path that loads a fixed checkpoint and evaluates with a different neighbour budget without retraining. Evaluation is coupled to training. Zero live requests were issued.

## Official repository

- URL: https://github.com/StatsDLMathsRecomSys/Inductive-representation-learning-on-temporal-graphs
- Paper: arXiv:2002.07962
- Authors: Da Xu, Chuanwei Ruan, Evren Korpeoglu, Sushant Kumar, Kannan Achan

## Neighbour sampling

| Parameter | Status |
|---|---|
| --n_degree | SAMPLER_PARAMETER (set at training) |
| --uniform | SAMPLER_PARAMETER (set at training) |
| Evaluation-time budget change | NOT SUPPORTED |

## Checkpoint handling

| Feature | Status |
|---|---|
| Save state_dict | YES |
| Load state_dict | YES (via --prefix matching) |
| Standalone evaluation | NOT DOCUMENTED |
| Budget change at evaluation | NOT SUPPORTED |

## Evaluation path

Evaluation is performed during training. Node classification reuses the trained network by matching the `--prefix`. There is no standalone evaluation script that loads a checkpoint and runs with a different neighbour budget.

## Falsifiers triggered

- F2 — TRAINING COUPLING: Evaluation cannot run independently of training
- F3 — BUDGET/TRAINING CONFOUND: Neighbour budget is inseparable from training configuration
- F11 — RETRAINING REQUIRED: Each budget requires a separately trained model

## Constraint

"If no clean intervention survives: STOP."

## Integrity

- Network/API requests: 4 (web_search, browse_page)
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Fixed-checkpoint neighbourhood intervention is feasible
- Neighbour budget can be changed at evaluation
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
