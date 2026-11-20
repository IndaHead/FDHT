# AH0-R3 — Persisted Event-Log Consumer-Sufficiency Audit

## Classification

AH0 PERSISTED EVENTLOG IS INSUFFICIENT FOR NATURAL POST-RUN AUDIT;
CONCRETE COLLISION DEMONSTRATED; NO ENLARGEMENT PERFORMED.

## Starting HEAD

`2a52c9f4ab2ce29089179f2b02c52df281592935`

## Persisted projection

Current `EventLog` retains only:

- sequence_number
- admission_result
- terminal

Runtime `AH0Event` additionally carries:

- proposal (operation, target_record_id, proposed_status, justification, …)
- admission_reason
- obligation_profile_after
- state digests
- current_status_after

## Natural audit consumer

Minimum post-run question:

Did the treatment propose and admit the expected operations, targets,
and status declarations, and did it terminate correctly?

Required distinctions: operation, target, proposed_status, admission result.

## Collision

Three distinct trajectories were run through the frozen state machine
and projected into EventLog:

| Treatment | Runtime operations | Persisted log |
|-----------|--------------------|---------------|
| T1 | INSPECT(pos1) → DECLARE(ESTABLISHED) → STOP | (0,ADMITTED,0) (1,ADMITTED,0) (2,ADMITTED,0) |
| T2 | INSPECT(neg1) → DECLARE(REFUTED) → STOP | (0,ADMITTED,0) (1,ADMITTED,0) (2,ADMITTED,0) |
| T3 | QUERY_INDEX → SUBMIT_EVIDENCE → STOP | (0,ADMITTED,0) (1,ADMITTED,0) (2,ADMITTED,0) |

PersistedLog(T1) = PersistedLog(T2) = PersistedLog(T3)

AuditConsumer(T1) ≠ AuditConsumer(T2) ≠ AuditConsumer(T3)

The persisted log cannot distinguish an ESTABLISHED declaration from a
REFUTED declaration, nor either from an unrelated operation sequence,
provided admission results and length match.

## Boundary

PersistedLog is not sufficient for the natural post-run audit consumer.

No EventLog enlargement was performed. No live treatment was executed.
No API calls were made. fdht/ unchanged.

## Recommended next boundary

If a post-run audit consumer is required before a paid live treatment,
the persisted projection must retain at least:

- operation
- target_record_id
- proposed_status
- admission_result

That enlargement is a separate freeze, not part of this audit.
