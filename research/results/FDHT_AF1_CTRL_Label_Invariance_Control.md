# FDHT AF₁-CTRL: Label-Invariance and Source-Responsiveness Control

## Classification

A — CONTROL MATRIX PASSES;
LABEL INVARIANCE AND SOURCE/REQUIREMENT RESPONSIVENESS ESTABLISHED

## Summary

Label permutations do not change outcomes. Source perturbations change outcomes appropriately. Requirement identity changes cause active state to follow the new requirement. Zero live requests were issued.

## Control matrix

| Control | Type | Result |
|---|---|---|
| C1 | GEOMETRY_LABEL_PERMUTATION | INVARIANT |
| C2 | ATTACK_LABEL_PERMUTATION | INVARIANT |
| C3 | SHADOW_LABEL_PERMUTATION | INVARIANT |
| C4 | ALL_LABELS_PERMUTED | INVARIANT |
| C5 | REMOVE_ONE_REQUIRED_IDENTITY | RESPONSIVE |
| C6 | RESTORE_ONE_MISSING_IDENTITY | RESPONSIVE |
| C7 | REPLACE_REQUIRED_WITH_NEAR_MATCH | RESPONSIVE |
| C8 | DUPLICATE_PRESENT_WHILE_MISSING_REMAINS | RESPONSIVE |
| C9 | PROVENANCE_ONLY_CHANGE | INERT |
| C10 | SOURCE_REORDER | INVARIANT |
| C11 | REQUIREMENT_IDENTITY_SWAP | RESPONSIVE |

## Metamorphic properties

| Property | Result |
|---|---|
| MORPH-1 LABEL INVARIANCE | PASS |
| MORPH-2 SOURCE RELEVANCE | PASS |
| MORPH-3 IRRELEVANT SOURCE INERTNESS | PASS |
| MORPH-4 REQUIREMENT IDENTITY | PASS |
| MORPH-5 REPRESENTATION INVARIANCE | NOT TESTED |
| MORPH-6 MULTIPLICITY NON-SUBSTITUTION | PASS |
| MORPH-7 NEAR-MATCH NON-SUBSTITUTION | PASS |

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS
- Control cells executed: 3960

## Evidence-supported claim

Within the tested AF₁-ADV2 concrete fixture family and frozen metamorphic controls, treatment behaviour depended on concrete source and semantic requirement rather than fixture metadata labels. Label permutations were inert. Source perturbations were responsive. Requirement identity changes caused active state to follow the new requirement.

## Claims explicitly NOT established

- Universal label blindness
- Universal source responsiveness
- Universal representation invariance
- Generic requirement scaling
- Asymptotic complexity
- Compute reduction
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
