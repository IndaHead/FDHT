# FDHT CAW₀: Causal Anonymous Walk Sampling-Boundary Intervention Probe

## Classification

E — FIXED-CHECKPOINT INTERVENTION INFEASIBLE

## Summary

The official CAW implementation (snap-stanford/CAW) couples training and evaluation. There is no documented way to load a fixed checkpoint and evaluate with different sampling budgets without retraining. Different budgets would require separately trained checkpoints, confounding the sampling-boundary intervention. Zero live requests were issued.

## Official repository

- URL: https://github.com/snap-stanford/CAW
- Licence: MIT
- Paper: arXiv:2101.05974

## Feasibility assessment

| Requirement | Status |
|---|---|
| Load fixed checkpoint | NOT DOCUMENTED |
| Evaluate without retraining | NOT SUPPORTED |
| Vary sampling budget at evaluation | NOT SUPPORTED |
| Expose sampled walks | NOT INSTRUMENTED |

## Sampling parameters

The `--n_degree` parameter controls sampling budget but is set at training time. Changing it requires retraining.

## Falsifier triggered

F1 — CHECKPOINT CONFOUND

Different budgets require separately trained checkpoints.

## Constraint

"If fixed-checkpoint sampling intervention is not feasible: STOP. Do not redesign CAW-N."

## Integrity

- Network/API requests: 2 (web_search, browse_page)
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Sampling-boundary consumer sensitivity
- Walk-set divergence under budget change
- Consumer-level divergence under budget change
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
