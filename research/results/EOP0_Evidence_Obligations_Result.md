# EOP0 — Evidence Obligation Proof-of-Concept

**Status:** EVIDENCE OBLIGATION MODEL SURVIVES FIXTURE  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `96f5fd013a4cc70171167f68760b015f68a546ee`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/decisive-falsification-consumer2 |
| Starting HEAD | 96f5fd013a4cc70171167f68760b015f68a546ee |
| Working branch | research/evidence-obligations-poc |

## 2. Working Branch

research/evidence-obligations-poc

## 3. Final HEAD

(recorded after commit)

## 4. Frozen Complete Requirement K

Establish whether relation R holds at source X under scope S with accepted provenance P.

Complete requirement includes: correct polarity, applicable witness, current scope, accepted provenance, required verifier acceptance, no undefeated opposing evidence.

## 5. K Digest

`cd58986cba1454ffbbbd8de4286b1b46c94bea821177710a629cf92c68550e03`

## 6. Candidate Obligation Model Omega

| Obligation | Applies To | Mandatory |
|------------|------------|-----------|
| omega_positive_support | ESTABLISHED | YES |
| omega_applicability | ESTABLISHED | YES |
| omega_scope | ESTABLISHED | YES |
| omega_provenance | ESTABLISHED | YES |
| omega_negative_witness | REFUTED | YES |
| omega_refuted_applicability | REFUTED | YES |
| omega_refuted_scope | REFUTED | YES |
| omega_refuted_provenance | REFUTED | YES |

## 7. Omega Digest

`fb23f0fc2a584385a7d8e93f87cf3d02952fb7cfd9d886ec3754122355d5795d`

## 8. Core Types

- EvidenceStatus: ESTABLISHED, REFUTED, UNRESOLVED
- ObligationStatus: DISCHARGED, FAILED, UNVERIFIABLE, NOT_APPLICABLE
- EvidenceObligation
- EvidenceItem

## 9. Applicability Semantics

Applicable(omega, q, x, s) iff omega.applies_to_status == s and omega.mandatory

## 10. Discharge Semantics

DischargesAt(item, omega) requires: verifier accepts, scope compatible, provenance satisfies, claim entails proposition

## 11. Blocker Semantics

Blocked(payload, s) iff applicable verified opposing evidence exists

## 12. Status-Admissibility Semantics

StatusAdmissible iff AllMandatoryDischarged and not Blocked

## 13. Judgement Semantics

ESTABLISHED if ESTABLISHED admissible and REFUTED not; REFUTED if REFUTED admissible and ESTABLISHED not; otherwise UNRESOLVED

## 14. T1 Result

PASS: status_only_not_evidence_sufficient

## 15. T2 Result

PASS: missing_support_not_refutation

## 16. T3 Result

PASS: verified_counterexample_blocks_established

## 17. T4 Result

PASS: conflicting_admissibility_yields_unresolved

## 18. T5 Result

PASS: stale_scope_does_not_discharge_current_obligation

## 19. T6 Result

PASS: provenance_presence_not_provenance_sufficiency

## 20. T7 Result

PASS: obligation_discharge_can_be_monotone_while_status_is_not

## 21. T8 Result

PASS: obligation_dependency_fixture

## 22. Redundancy Fixture

Representational multiplicity ≠ independent evidential requirement. Recorded.

## 23. Independence Fixture

Independent payloads demonstrated. Recorded.

## 24. Negative-Obligation Fixture

Missing evidence ≠ REFUTED. Recorded.

## 25. Obligation-Profile Examples

Profile derivable from obligation list and payload. Recorded.

## 26. F1-F16 Results

| Fixture | Result |
|---------|--------|
| F1 Status-only | PASS |
| F2 Missing-evidence | PASS |
| F3 Scope collapse | PASS |
| F4 Provenance collapse | PASS |
| F5 Verifier collapse | PASS |
| F6 Assumption collapse | PASS |
| F7 Conflict completion | PASS |
| F8 Arrival-order | PASS |
| F9 Duplicate-evidence | PASS |
| F10 Redundant-obligation | PASS |
| F11 Representational-independence | PASS |
| F12 Blocker-deletion | PASS |
| F13 Unresolved-as-empty | PASS |
| F14 Evidence-to-authority | PASS |
| F15 Persistence | PASS |
| F16 Universal-engine | PASS |

## 27. Finite Evidence Universe

Microscopic: verified positive, verified negative, stale, wrong-provenance, unverified

## 28. Payload Count

32 (2^5 subsets)

## 29. Omega-Satisfying Count

4

## 30. K-Satisfying Count

4

## 31. Omega-Satisfying/K-Violating Count

0

## 32. K-Satisfying/Omega-Rejected Count

0

## 33. Minimal Underconstraint Countermodel

NONE

## 34. Minimal Overconstraint Countermodel

NONE

## 35. First Semantic Divergence

NONE

## 36. Classification

**A — EVIDENCE OBLIGATION MODEL SURVIVES FIXTURE**

## 37. Classification Justification

Required theorems T1-T8 compile. All falsification fixtures pass. No Omega-satisfying / K-violating payload exists in the complete frozen finite search. Candidate model survives only in tested scope.

## 38. Justified Claims

- Obligation model distinguishes obligation from evidence.
- Status reproduction ≠ evidence sufficiency.
- Missing support ≠ refutation.
- Opposing evidence blocks without arbitrary completion.
- No contamination occurred.

## 39. Unjustified Claims

- Generic Evidence Engine justified.
- Permanent FDHT abstraction justified.
- Universal obligation DAG architecture.
- Automatic persistence or execution.

## 40. FDHT Pressure

NONE

## 41. New Permanent Mathematics Justified

NO

## 42. New Abstraction Justified

NO

## 43. Generic Evidence Engine Justified

NO

## 44. Promotion Justified

NO

## 45. Next Stage Justified

NO

## 46. Limitations

- Microscopic fixture only.
- Finite search only.
- Probe-local types only.
- No permanent FDHT integration.

## 47. Recommended Action

**STOP**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Generic Evidence Engine: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
