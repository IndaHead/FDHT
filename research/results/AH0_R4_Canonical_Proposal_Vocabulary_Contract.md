# AH₀-R4: Canonical Proposal-Vocabulary Contract

## Classification

B — CONTRACT HARDENED AND VERIFIED WITHOUT STRICT API SCHEMA

## Summary

Single-source operation vocabulary is derived from the Operation enum. The live prompt is generated from that vocabulary and explicitly rejects non-canonical values including INSPECT. The deterministic parser remains fail-closed. Structured JSON schema was not added because the existing transport surface does not support it without API migration. Zero network requests were issued.

## Provenance

- Branch: research/agent-ah0-r4-contract
- Starting HEAD (after PROV-01A): 736803e048d655b7638f7c3e64499109d138b6ca
- Provenance-correction commit: 736803e048d655b7638f7c3e64499109d138b6ca
- fdht/ pre-run diff: empty

## Operation contract

- Source: research/agents/IndaAgent001/ah0/models.py
- Canonical names/values: QUERY_INDEX, INSPECT_RECORD, SUBMIT_EVIDENCE, DECLARE_STATUS, STOP
- AgentProposal serialisation: enum values (str)

## Root cause

NOT UNIQUELY ESTABLISHED. Source shows the original prompt did not list the canonical vocabulary. The recorded INSPECT collision is consistent with that absence. R4 hardens the contract regardless.

## Implementation

- Single-source vocabulary: YES (`canonical_operation_values`)
- Prompt generated from canonical vocabulary: YES
- Structured JSON schema: NO (STRUCTURED_SCHEMA_NOT_IMPLEMENTED — existing transport uses bare "input"; schema would require API migration)
- Parser kept strict: YES
- Alias handling: none
- INSPECT accepted: NO

## Tests

| Test | Result |
|---|---|
| Canonical vocabulary equals Operation | PASS |
| Prompt contains every canonical operation | PASS |
| Prompt does not advertise INSPECT | PASS |
| Canonical operations parse | PASS |
| INSPECT fails closed | PASS |
| Synonyms fail closed | PASS |
| Invalid types fail closed | PASS |
| Malformed JSON fails | PASS |
| Missing required fields fail | PASS |
| Disabled reasoner fails closed | PASS |
| Existing scripted test | PASS |
| lake build | EXIT 0 (49 jobs) |
| Strict axiom audit | PASS |
| Network/API requests | 0 |
| XAI_API_KEY accessed | NO |
| fdht/ changed | NO |

## Integrity

- sorryAx: ABSENT
- Classical.choice: not introduced
- Custom axioms: ABSENT
- Secret scan: no credentials committed (existing Bearer header construction uses env var)

## Evidence-supported claim

The live proposal interface now derives its allowed operation vocabulary from the Operation enum and injects that vocabulary into the prompt. The parser continues to reject non-canonical operations including INSPECT. No downstream AH₀ semantics were changed in the tested controls. Zero live requests were issued.

## Claims explicitly NOT established

- That a future live model response will obey the prompt constraint
- That the original INSPECT response was caused solely by vocabulary absence
- Semantic success on any fixture
- Permanent FDHT pressure
- Promotion of any mathematics

## Permanent FDHT pressure

NO

## Promotion justified

NO

## LIVE-03 eligibility

YES (deterministic contract hardened; parser fail-closed; zero API calls; fdht/ unchanged; provenance corrected; both historical records preserved). LIVE-03 is not executed in this task.
