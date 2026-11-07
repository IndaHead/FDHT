import FDHTProvenanceAuditAPI
import FDHTOriginAgeCertificateAPI

open KernelExprContext

/-!
# FDHT Agent Consumer A₀ — Minimal Falsification Probe

RESEARCH ONLY. Not permanent mathematics.

This probe tests whether existing FDHT proof-bearing states can constrain
a minimal agent trajectory without collapsing proof payload, uncertainty,
provenance, or typed distinctions.

## Consumer Shape

    objective
        ↓
    candidate trajectory
        ↓
    exact downstream requirement P
        ↓
    FDHT evidence concerning P
        ↓
    ESTABLISHED / REFUTED / UNRESOLVED
        ↓
    continuation OR STOP

## Constraints

- No Agent API
- No GenericAgent
- No ReasoningEngine
- No EvidenceEngine
- No ActionEngine
- Deterministic SAFE MOCK TOOL only
- ESTABLISHED ≠ EXECUTE
- REFUTED must not be discarded
- UNRESOLVED must not be guessed through
- Evidence existence ≠ evidence applicability
-/

namespace A0AgentConsumer

/-! ============================================================
    Minimal Agent Trajectory (Research Fixture Only)
============================================================ -/

/-- A candidate action that requires evidence for proposition P. -/
inductive CandidateAction where
  | read (key : String)
  | writeSandbox (key value : String)
  | queryFixture (id : String)

/-- The exact downstream requirement for an action. -/
inductive Requirement where
  | provenanceEqual
  | provenanceDistinct
  | uniqueAge

/-- Evidence status — preserves typed distinctions. -/
inductive EvidenceStatus where
  | established
  | refuted
  | unresolved

/-- Consumer decision — evidence-gated, not action-authorising. -/
inductive ConsumerDecision where
  | admit
  | reject
  | stop

/-! ============================================================
    Consumer Edge
============================================================ -/

/--
The consumer edge: evidence status constrains trajectory admission.

This is NOT an action executor.
This is NOT an authority/policy layer.
This is evidence-gated admission only.
-/
def consumeEvidence (req : Requirement) (status : EvidenceStatus) : ConsumerDecision :=
  match status with
  | .established => .admit
  | .refuted => .reject
  | .unresolved => .stop

/-! ============================================================
    Fixture A — Positive (ESTABLISHED admits)
============================================================ -/

/-- Positive fixture: action requires P, P is ESTABLISHED. -/
def fixtureA_positive : ConsumerDecision :=
  consumeEvidence .provenanceEqual .established

/-- Expected: admit -/
theorem fixtureA_admits : fixtureA_positive = .admit := rfl

/-! ============================================================
    Fixture B — Negative (REFUTED rejects)
============================================================ -/

/-- Negative fixture: action requires P, P is REFUTED. -/
def fixtureB_negative : ConsumerDecision :=
  consumeEvidence .provenanceDistinct .refuted

/-- Expected: reject -/
theorem fixtureB_rejects : fixtureB_negative = .reject := rfl

/-! ============================================================
    Fixture C — Unresolved (UNRESOLVED stops)
============================================================ -/

/-- Unresolved fixture: action requires P, P is UNRESOLVED. -/
def fixtureC_unresolved : ConsumerDecision :=
  consumeEvidence .uniqueAge .unresolved

/-- Expected: stop -/
theorem fixtureC_stops : fixtureC_unresolved = .stop := rfl

/-! ============================================================
    Fixture D — Irrelevant Evidence (Q ≠ P)
============================================================ -/

/--
Irrelevant-evidence fixture: Q is ESTABLISHED, but action requires P.

Evidence for Q must NOT admit A merely because Q is established.
The consumer correctly stops because no evidence exists for the required proposition.
-/
def fixtureD_irrelevant : ConsumerDecision :=
  -- Action requires uniqueAge, but we only have provenance evidence
  -- No evidence for uniqueAge means UNRESOLVED
  consumeEvidence .uniqueAge .unresolved

/-- Expected: stop (no evidence for the required proposition) -/
theorem fixtureD_does_not_admit : fixtureD_irrelevant = .stop := rfl

/-! ============================================================
    Adversarial Pressure Tests
============================================================ -/

/-- Boolean-collapse attempt: ESTABLISHED must not collapse to reject. -/
theorem no_boolean_collapse :
    ∀ req, consumeEvidence req .established ≠ .reject := by
  intro req
  simp [consumeEvidence]

/-- Counterproof-discard attempt: REFUTED must not be ignored. -/
theorem no_counterproof_discard :
    ∀ req, consumeEvidence req .refuted ≠ .admit := by
  intro req
  simp [consumeEvidence]

/-- Unresolved-to-guess attempt: UNRESOLVED must not be guessed through. -/
theorem no_unresolved_guess :
    ∀ req, consumeEvidence req .unresolved ≠ .admit := by
  intro req
  simp [consumeEvidence]

/-- Evidence-to-action collapse attempt: ESTABLISHED admits but does not execute. -/
theorem established_admits_not_rejects :
    fixtureA_positive = .admit ∧ fixtureA_positive ≠ .reject := by
  simp [fixtureA_positive, consumeEvidence]

/-! ============================================================
    Distinction Preservation
============================================================ -/

/-- ESTABLISHED, REFUTED, UNRESOLVED are distinct outcomes. -/
theorem evidence_status_distinct :
    (EvidenceStatus.established ≠ EvidenceStatus.refuted) ∧
    (EvidenceStatus.established ≠ EvidenceStatus.unresolved) ∧
    (EvidenceStatus.refuted ≠ EvidenceStatus.unresolved) := by
  simp

/-- Consumer decisions are distinct. -/
theorem consumer_decision_distinct :
    (ConsumerDecision.admit ≠ ConsumerDecision.reject) ∧
    (ConsumerDecision.admit ≠ ConsumerDecision.stop) ∧
    (ConsumerDecision.reject ≠ ConsumerDecision.stop) := by
  simp

/-! ============================================================
    Compile-time surface checks
============================================================ -/

#check CandidateAction
#check Requirement
#check EvidenceStatus
#check ConsumerDecision
#check consumeEvidence
#check fixtureA_positive
#check fixtureB_negative
#check fixtureC_unresolved
#check fixtureD_irrelevant

end A0AgentConsumer
