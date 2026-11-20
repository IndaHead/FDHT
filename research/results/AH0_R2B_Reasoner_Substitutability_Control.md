# AH0-R2B — Zero-Cost Reasoner Substitutability Control

## Classification

AH0 REASONER SUBSTITUTABILITY CONFIRMED UNDER FIXED PROPOSAL CONTENT;
ZERO API CALLS; NO LIVE GROK EVIDENCE.

## Setup

Starting HEAD: `cd36d4f596fb6759b3513455c8d3f508785fa5e0`

Identical inputs for both treatments:

- initial `AH0State`
- fixture F1 catalogue
- retrieval budget 2
- proposal sequence: INSPECT_RECORD(pos1) → DECLARE_STATUS(ESTABLISHED) → STOP

Treatment S: `ScriptedReasoner`
Treatment L: `LiveGrokReasoner` with injected local transport only

`AH0_RUN_LIVE_GROK` unset. `XAI_API_KEY` not used. Network calls: 0.

## Result

| Field | S | L | Equal |
|-------|---|---|-------|
| event count | 3 | 3 | YES |
| event trajectory | inspect/declare/stop | inspect/declare/stop | YES |
| admission sequence | ADMITTED × 3 | ADMITTED × 3 | YES |
| terminal | True | True | YES |
| step count | 3 | 3 | YES |
| inspected_record_ids | equal | equal | YES |
| obligation_profiles | equal | equal | YES |

Default `LiveGrokReasoner()` (no transport, no enablement) still raises `LiveReasonerDisabled`.

## Boundary

When proposal content is held fixed, replacing `ScriptedReasoner` with
`LiveGrokReasoner(FakeTransport)` does not change downstream deterministic
AH0 admission, terminal, or protected-state behaviour.

This is not a live Grok treatment. No model reasoning was exercised.
