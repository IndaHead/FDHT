# FDHT MRT-05B-PD2: Lean 4.35 Helper-Lemma Proof Repair

## Classification

G — GENUINE PINNED-TOOLCHAIN BLOCKER ESTABLISHED AFTER INDUCTION ATTEMPTS

## Summary

The four structural theorems cannot be discharged with elementary induction on Lean 4.35. The zipIdx offset causes induction hypotheses to not match the required form. Zero live requests were issued.

## Proof status

| Theorem | Status | Reason |
|---|---|---|
| c0_membership_structural | BLOCKED | zipIdx offset breaks induction |
| c1_multiplicity_structural | BLOCKED | zipIdx offset breaks induction |
| c4_verified_structural | BLOCKED | find? case analysis incomplete |
| c5_verified_completeRecord_structural | BLOCKED | encoding injectivity incomplete |

## Induction attempts

1. Direct induction on source list: FAILED (zipIdx offset)
2. Offset-aware helper lemmas: FAILED (rewrite issues)
3. Direct case analysis: FAILED (match issues)

## Negative results

| Theorem | Status |
|---|---|
| c2_observableLoss_completeRecord | COMPILED |
| c3_observableLoss_provenance | COMPILED |

## Toolchain issue

The zipIdx function introduces position offsets that break the induction hypothesis. The tail's zipIdx starts at 1, not 0, causing the induction hypothesis to not match.

## Claims explicitly NOT established

- All four theorems proved constructively
- Pinned-toolchain blocker resolved
- Permanent FDHT pressure
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

CONTROLLED TOOLCHAIN COMPARISON JUSTIFIED
