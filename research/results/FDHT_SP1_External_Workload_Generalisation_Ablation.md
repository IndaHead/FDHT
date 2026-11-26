# FDHT SP₁: External-Workload Generalisation and Ablation

## Classification

B — SELECTIVE UTILITY OBSERVED

## Summary

T1 (full SP0) preserves consumer outcomes and provides material benefit on W5 (insufficiency). T3 (no insufficiency stop) proceeds to false completion on W5. T2 (no sufficiency) performs equivalently to T0 on all cells. Selective utility observed; STOP ablation is not inert. Zero live requests were issued.

## Treatment definitions

| ID | Name | Sufficiency | Stop on insufficient |
|---|---|---|---|
| T0 | BASELINE | NO | NO |
| T1 | FULL_SP0 | YES | YES |
| T2 | NO_SUFFICIENCY | NO | NO |
| T3 | NO_INSUFFICIENCY_STOP | YES | NO |

## Treatment SHA-256

ba1d461b56386b5667df2d140381d4ce4259829c78e77c11c1f0380e993f226c

## Workload definitions

| ID | Name | Consumer requirement |
|---|---|---|
| W1 | LONG_RANGE_RETRIEVAL | Historical distinction outside local subset |
| W2 | EVOLVING_INFORMATION | Present applicability with historical provenance |
| W3 | NEGATIVE_INFORMATION_DEPENDENCY | Negative information changes satisfaction |
| W4 | CONFLICTING_EVIDENCE | Preserve conflict |
| W5 | INFORMATION_INSUFFICIENT | STOP when distinction absent |
| W6 | EXTERNAL_CONSUMER_BOUNDARY | Domain-specific verification stays adapter-local |

## Workload SHA-256

3f240c8b9d310a5cbe8a19dcc2306e6032c36c194e9d3bf1e7c4abaf4525b974

## Primary comparisons

### C1 — SP0 utility (T1 vs T0)

T1 and T0 produce equivalent consumer outcomes on W1–W4, W6. T1 provides material benefit on W5 by returning STOP when information is insufficient.

### C2 — Sufficiency necessity (T1 vs T2)

T2 performs equivalently to T0 on all cells. Sufficiency check does not alter outcomes when information is sufficient.

### C3 — STOP necessity (T1 vs T3)

T1 returns STOP on W5. T3 returns ADMIT on W5 (false completion). STOP ablation is not inert.

## W5 insufficiency centrepiece

| Treatment | Gate | Sufficiency | Result |
|---|---|---|---|
| T1 | STOP | INSUFFICIENT | Correct |
| T3 | ADMIT | INSUFFICIENT | False completion |

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS
- Cells executed: 144

## Evidence-supported claim

T1 (full SP0) preserves consumer outcomes and provides material benefit on W5 by returning STOP when information is insufficient. T3 (no insufficiency stop) proceeds to false completion on W5. Selective utility observed; STOP ablation is not inert.

## Claims explicitly NOT established

- That SP0 is permanent-necessary
- That bounded checks are universal proofs
- Permanent FDHT pressure
- Promotion of any mathematics

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
