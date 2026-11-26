# FDHT ECD₀: External Consumer Discovery Audit

## Classification

D — ALL CANDIDATES REQUIRE ARTIFICIAL TRANSLATION

## Summary

TGB is a legitimate external benchmark but its task is dynamic link prediction, not reachability. Converting TGB to a reachability consumer would require artificial translation. SLSA provenance verification is identity-equivalent. No natural external consumer survives that provides relational-temporal reachability pressure. Zero live requests were issued.

## External sources inspected

| Source | URL | Task | Classification |
|---|---|---|---|
| TGB | https://tgb.complexdatalab.com/ | Dynamic link property prediction | TGB_NATURAL_BUT_WRONG_PRESSURE |
| SLSA | https://slsa.dev/spec/v1.0/requirements | Provenance verification | NATURAL_BUT_IDENTITY_EQUIVALENT |

## TGB task definition

**Task**: Dynamic link property prediction

**Input**: Temporal graph (nodes, edges, timestamps)

**Output**: Ranking of candidate edges at a future timestamp

**Evaluation metric**: Mean Reciprocal Rank (MRR)

**Official evaluator**: YES (tgb.linkproppred.evaluate.Evaluator)

**Temporal distinction required**: YES (timestamps are part of the data)

**Relational distinction required**: YES (edges between nodes)

**Classification**: TGB_NATURAL_BUT_WRONG_PRESSURE

TGB predicts whether an edge will exist at a future timestamp. It does not evaluate reachability, path composition, or deadline satisfaction. Converting TGB to a reachability consumer would require inventing a new target variable.

## SLSA task definition

**Task**: Provenance verification

**Input**: Artefact + provenance attestation

**Output**: ACCEPT/REJECT/REVIEW

**Evaluation metric**: Boolean verification of signature, builder trust, digest match

**Classification**: NATURAL_BUT_IDENTITY_EQUIVALENT

SLSA verifies that provenance exists and is valid. This is identity-equivalent: the consumer asks "does this provenance verify?" not "is there a path from A to B?"

## Candidate classifications

| Candidate | Classification | Reason |
|---|---|---|
| TGB | TGB_NATURAL_BUT_WRONG_PRESSURE | Prediction task, not reachability |
| SLSA | NATURAL_BUT_IDENTITY_EQUIVALENT | Identity verification, not relational |

## Natural consumers surviving

NONE

## Structural distinction from IDENTITY_SET

TGB requires temporal ordering and edge existence prediction. This is structurally distinct from identity-set membership. However, the task is prediction, not reachability.

## Contamination result

Converting TGB to reachability would require:
- New target variable (path existence vs edge prediction)
- New metric (ADMIT/REJECT vs MRR)
- New temporal interpretation (deadline vs timestamp)

This is ARTIFICIAL_TRANSLATION_REQUIRED.

## Best candidate

TGB

## Best-candidate evidence

- Official repository: https://github.com/shenyangHuang/TGB
- Official documentation: https://tgb.complexdatalab.com/
- Paper: https://arxiv.org/abs/2307.01026
- Task: Dynamic link property prediction
- Metric: MRR

## Best-candidate limitation

TGB is a prediction benchmark. Its success criterion is ranking accuracy, not reachability. Using TGB as a reachability consumer would require artificial translation.

## Consumer freeze justified?

NO

## Cross-consumer experiment justified?

NO

## Integrity

- Network/API requests: 2 (web_search)
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Relational-temporal reachability consumer exists externally
- TGB provides reachability pressure
- Cross-consumer active-frontier replication is justified
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
