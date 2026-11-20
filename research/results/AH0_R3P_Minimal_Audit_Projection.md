# AH0-R3P — Minimal Audit-Sufficient Event-Log Projection

## Classification

UNIQUE MINIMAL SUFFICIENT EXTENSION OF B IDENTIFIED;
PURE OTS ALSO SUFFICIENT ON TESTED CORPUS;
NO LOGGER ENLARGEMENT PERFORMED.

## Starting HEAD

`98d95323b7aaee72363169be4870cb00e3e63043`

Ancestors verified: R1, R2, R2B, R3. fdht/ empty diff.

## Audit consumer (frozen from R3)

For each event: (operation, relevant target, relevant proposed_status, admission_result, terminal).

## Baseline regression

B = {sequence_number, admission_result, terminal}

B is insufficient. T1/T2/T3 collision reproduced. 24 audit-distinct pairs share B projections on the expanded corpus.

## Field lattice

Candidate extensions tested against B:

| Extension | Result |
|-----------|--------|
| operation | INSUFFICIENT (collapses target and status variants) |
| target_record_id | INSUFFICIENT |
| proposed_status | INSUFFICIENT |
| admission_reason | INSUFFICIENT |
| operation + target | INSUFFICIENT (status collision survives) |
| operation + status | INSUFFICIENT (target collision survives) |
| target + status | INSUFFICIENT (null-payload operation variants collide) |
| operation + target + status | SUFFICIENT |
| OTS + admission_reason | SUFFICIENT (reason not required) |

## Unique minimal sufficient extension of B

```text
B ∪ {operation, target_record_id, proposed_status}
```

No smaller extension of B is sufficient. Adding admission_reason does not change sufficiency.

## Base-field ablation

Once OTS is present:

- sequence_number is redundant (order is recoverable from persistence order)
- admission_result is redundant on this corpus (all tested events ADMITTED)
- terminal is redundant on this corpus (derived from final position / STOP)

Pure {operation, target_record_id, proposed_status} is sufficient on the tested corpus.

## Inert fields (no consumer pressure)

- target_obligation_id: R3 consumer does not distinguish obligation targets
- justification: equal audit results for differing justifications
- expected_information_gain: same
- state_digest_before / after: no state-integrity collision in corpus
- timestamp: sequence_number (or persistence order) supplies ordering

## Adversarial confirmation

Null-payload operation variants (QUERY/SUBMIT/STOP permutations) collide under target+status without operation. Operation is independently required.

## Boundary

No EventLog enlargement was performed. No live treatment. No API calls. fdht/ unchanged.

## Recommended next boundary

If a post-run audit consumer is required before a paid live treatment, the separate freeze should persist at least:

- operation
- target_record_id
- proposed_status

admission_result should be retained if future corpora include actual rejections. That decision is not part of this audit.
