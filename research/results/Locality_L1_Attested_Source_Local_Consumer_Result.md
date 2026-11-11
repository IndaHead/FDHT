# Locality L1 — Attested Source-Local Policy Consumer

**Status:** GENUINE ATTESTED SOURCE-LOCAL CONSUMER PRESSURE OBSERVED IN FIXTURE  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `fca1a52055f5e5d2dc206708b58f27d8c803fb73`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/locality-poc |
| Starting HEAD | fca1a52055f5e5d2dc206708b58f27d8c803fb73 |
| Working branch | research/locality-attestation |

## 2. Working Branch

research/locality-attestation

## 3. Final HEAD

(recorded after commit)

## 4. Exact Consumer

AdmissionConsumer with requirement:

"May workload W consume protected source S under current policy P?"

The consumer requires a justified result before constructing an admission decision. The consumer is prohibited from receiving the complete policy database, complete ProtectedSource state, unrelated observations, internal records, or private policy material.

## 5. Exact Natural Locality Pressure

The source possesses information required for the decision. The consumer is not authorised to possess that information. Therefore:

evaluation required + source-state export prohibited = candidate source-local consumer pressure.

This is a fixture-local operational requirement. No legal, regulatory, cryptographic or production-grade confidentiality is claimed.

## 6. Exact Protected Source State

| Field | Value |
|-------|-------|
| source_id | source_001 |
| policy_id | policy_P7 |
| policy_version | 7 |
| checkpoint_id | checkpoint_C7 |
| authorised_workloads | (workload_W,) or () |
| excluded_workloads | () or (workload_W,) |
| private_policy_material | SECRET_P7_MATERIAL |

## 7. Synthetic Status

**Synthetic / fixture-local.** No external service. No network. No real credentials. No real TEE. No real TPM. No real remote attestation.

## 8. Attestation Limitation

The attestation is a deterministic fixture-local evidence binding using SHA-256 over a canonical serialisation of bound fields. It detects fixture-local record mutation. It does NOT establish hardware identity, cryptographic source authenticity, remote attestation, trusted execution, tamper-proof execution, or production security.

## 9. Route A Information Flow

```
ProtectedSource (complete, including private_policy_material)
  -> ConsumerLocalCopy
  -> ConsumerEvaluator
  -> EvaluationResult
  -> A0 decision
```

Protected state exported: YES

## 10. Route B Information Flow

```
AdmissionRequirement
  -> Source
  -> SelectiveSourceProjection (source_id, policy_id, policy_version, checkpoint_id, workload_status)
  -> ConsumerEvaluator
  -> EvaluationResult
  -> A0 decision
```

Protected state exported: NO. Policy-derived status leaves source for consumer evaluation.

## 11. Route C Information Flow

```
AdmissionRequirement
  -> SourceLocalEvaluator
  -> Evaluation at source
  -> AttestationRecord (bound to source, evaluator, policy, version, checkpoint, requirement, workload, status, scope)
  -> EvaluationResult
  -> Consumer validates binding
  -> A0 decision
```

Protected state exported: NO. Policy values do not leave source. Only bound attestation returns.

## 12. Per-Field Movement

| Field | Route A | Route B | Route C |
|-------|---------|---------|---------|
| private_policy_material | YES | NO | NO |
| authorised_workloads | YES | NO | NO |
| excluded_workloads | YES | NO | NO |
| workload_status | — | YES | NO |
| attestation_record | NO | NO | YES |
| provenance | YES | YES | YES |

## 13. Serialised Byte Movement

| Route | Approximate Bytes |
|-------|-------------------|
| A | 48 |
| B | 56 |
| C | 55 |

Byte count is a fixture measurement only, not an information-theoretic metric.

## 14. Six-Memory-Class Audit

| Class | Route A | Route B | Route C |
|-------|---------|---------|---------|
| ObservationRecord | absent | absent | absent |
| ClaimRecord | absent | absent | absent |
| EvidenceRecord | constructed at consumer | constructed at consumer | returned from source |
| NegativeRecord | absent | absent | absent |
| ObjectiveRecord | stays consumer | stays consumer | stays consumer |
| CheckpointRecord | crosses as identity | crosses as identity | crosses as binding |

## 15. Positive Fixture

W authorised under P7/C7. All routes: ESTABLISHED → ADMIT. Route C attestation validates.

## 16. Refuted Fixture

W excluded under P7/C7. All routes: REFUTED → REJECT. Route C attestation validates.

## 17. Unresolved-Policy Fixture

Requires P8; source has P7. All routes: UNRESOLVED → STOP. P7 evidence does not satisfy P8 requirement.

## 18. Unresolved-Checkpoint Fixture

Requires C8; source has C7. All routes: UNRESOLVED → STOP. Prior checkpoint does not establish current validity.

## 19. Stale-Attestation Fixture

P6/C6 attestation produced at t0 (W authorised). At t1, P7/C7 with W excluded. Stale attestation does not validate against current P7/C7 requirement. Historical evidence remains valid in historical scope; it does not satisfy the current requirement.

## 20. Adversarial Results

| Attack | Result |
|--------|--------|
| Selective-retrieval parity | PASS — Route C provides binding Route B lacks |
| Private-state leak | PASS |
| Stale-attestation replay | PASS |
| Policy swap | PASS |
| Workload swap | PASS |
| Source swap | PASS |
| Requirement swap | PASS |
| Checkpoint swap | PASS |
| Evaluator swap | PASS |
| Status tamper | PASS |
| Status-only collapse | PASS |
| Authority collapse | PASS |
| Persistence collapse | PASS |
| Objective replacement | PASS |
| Scope expansion | PASS |
| Attestation-truth collapse | PASS |

## 21. First Divergence Between Routes B and C

Route B returns workload_status for consumer-side evaluation. Route C returns only a bound attestation; the consumer does not evaluate policy values. Route C binds the result to the exact source-state checkpoint and evaluator identity without requiring the consumer to possess or evaluate policy-derived status.

## 22. Whether Route B Satisfies the Consumer Equally

NO. Route B requires policy-derived status to leave the source so the consumer can evaluate it. Route C keeps policy evaluation at source and returns only a result bound to the exact source-state version and requirement. The binding is a consumer-required property that Route B does not provide.

## 23. Authority Escalations

0

## 24. Objective Replacements

0

## 25. Persistence Differences

None. No memory classes are auto-persisted.

## 26. Classification

**A — GENUINE ATTESTED SOURCE-LOCAL CONSUMER PRESSURE OBSERVED IN FIXTURE**

## 27. Justified Claims

- Route C preserves the same justified EvidenceStatus and decision as valid controls.
- Protected policy material remains source-local in Routes B and C.
- The returned result is bound to the exact source, evaluator, policy, version, checkpoint, requirement, workload and scope.
- Stale or mismatched evidence cannot satisfy the current requirement.
- The result contains sufficient evidence for A0 consumption.
- No authority escalation occurs.
- No objective replacement occurs.
- No unjustified persistence occurs.
- Route C provides a concrete consumer-required property (source-state binding without policy-value export) that strongest Route B does not provide equally.

## 28. Unjustified Claims

- Real cryptographic security.
- Hardware attestation.
- Remote attestation.
- Production confidentiality.
- Universal superiority of source-local evaluation.
- Generic locality architecture.
- Any permanent FDHT mathematics.

## 29. FDHT Pressure

NONE

## 30. New Mathematics Justified

NO

## 31. New Abstraction Justified

NO

## 32. Promotion Justified

NO

## 33. L2 Justified

NO

This fixture does not expose a concrete, natural, untested requirement not absorbed by selective retrieval, ordinary server-side projection, A0 or existing memory discipline.

## 34. Recommended Action

**STOP**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Generic attestation infrastructure: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
