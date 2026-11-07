import FDHTProvenanceAuditAPI
import FDHTOriginAgeCertificateAPI

open KernelExprContext

/-!
# FDHT Agent-State S₀ — Structured State and Token-Minimisation Probe

RESEARCH ONLY. Not permanent mathematics.

This probe tests whether a minimal structured AgentState can reuse existing
A₀ and FDHT proof-bearing surfaces to replace language-model decision steps
with deterministic typed transitions, while preserving the same observable
ADMIT / REJECT / STOP decisions.

## Constraints

- No Agent API
- No GenericAgent
- No ReasoningEngine
- No EvidenceEngine
- No ActionEngine
- Exact evidence/requirement coupling
- ESTABLISHED ≠ EXECUTE
- REFUTED must not be discarded
- UNRESOLVED must not be guessed through
- Authority and execution remain external
-/

namespace S0AgentState

/-! ============================================================
    Minimal Schema (Reduced from Candidate)
============================================================ -/

/-- Evidence status — reuses A₀ definition. -/
inductive EvidenceStatus where
  | established
  | refuted
  | unresolved

/-- Consumer decision — reuses A₀ definition. -/
inductive ConsumerDecision where
  | admit
  | reject
  | stop

/-- Requirement — reuses A₀ definition. -/
inductive Requirement where
  | provenanceEqual
  | provenanceDistinct
  | uniqueAge

/--
Minimal decision record.

Retained fields:
- requirement: exact downstream requirement
- evidence: proof-bearing evidence status
- decision: observable decision

Removed fields (decorative):
- ObjectiveId: no fixture uses it
- TrajectoryId: no fixture uses it
- EvidenceId: no fixture uses it
- ActionId: no fixture uses it
- ObservationId: no fixture uses it
- AuthorityDecision: external to evidence admission
- ExecutionState: external to evidence admission
-/
structure DecisionRecord where
  requirement : Requirement
  evidence : EvidenceStatus
  decision : ConsumerDecision

/--
Minimal agent state.

Retained fields:
- decisionHistory: preserves evidence and decisions

Removed fields (decorative or external):
- objectiveId: no fixture uses it
- activeTrajectories: no fixture uses it
- evidenceHistory: subsumed by decisionHistory
- authorityState: external to evidence admission
- executionState: external to evidence admission
- observations: no fixture uses it
-/
structure AgentState where
  decisionHistory : List DecisionRecord

/-! ============================================================
    Consumer Edge (Reuses A₀)
============================================================ -/

/-- Consumer edge — reuses A₀ consumeEvidence. -/
def consumeEvidence (req : Requirement) (status : EvidenceStatus) : ConsumerDecision :=
  match status with
  | .established => .admit
  | .refuted => .reject
  | .unresolved => .stop

/--
Structured-state transition.

    AgentState S₀
        +
    Requirement P
        +
    EvidenceStatus P
        ↓
    DecisionRecord
        ↓
    AgentState S₁
-/
def transition (s : AgentState) (req : Requirement) (status : EvidenceStatus) : AgentState :=
  let decision := consumeEvidence req status
  let record : DecisionRecord := { requirement := req, evidence := status, decision := decision }
  { decisionHistory := record :: s.decisionHistory }

/-! ============================================================
    Fixture A — Positive (ESTABLISHED admits)
============================================================ -/

def fixtureA_state : AgentState :=
  transition { decisionHistory := [] } .provenanceEqual .established

theorem fixtureA_admits : fixtureA_state.decisionHistory.head?.map (·.decision) = some .admit := by
  simp [fixtureA_state, transition, consumeEvidence]

theorem fixtureA_preserves_evidence : fixtureA_state.decisionHistory.head?.map (·.evidence) = some .established := by
  simp [fixtureA_state, transition, consumeEvidence]

/-! ============================================================
    Fixture B — Negative (REFUTED rejects)
============================================================ -/

def fixtureB_state : AgentState :=
  transition { decisionHistory := [] } .provenanceDistinct .refuted

theorem fixtureB_rejects : fixtureB_state.decisionHistory.head?.map (·.decision) = some .reject := by
  simp [fixtureB_state, transition, consumeEvidence]

theorem fixtureB_preserves_evidence : fixtureB_state.decisionHistory.head?.map (·.evidence) = some .refuted := by
  simp [fixtureB_state, transition, consumeEvidence]

/-! ============================================================
    Fixture C — Unresolved (UNRESOLVED stops)
============================================================ -/

def fixtureC_state : AgentState :=
  transition { decisionHistory := [] } .uniqueAge .unresolved

theorem fixtureC_stops : fixtureC_state.decisionHistory.head?.map (·.decision) = some .stop := by
  simp [fixtureC_state, transition, consumeEvidence]

theorem fixtureC_preserves_evidence : fixtureC_state.decisionHistory.head?.map (·.evidence) = some .unresolved := by
  simp [fixtureC_state, transition, consumeEvidence]

/-! ============================================================
    Fixture D — Irrelevant Evidence (Q ≠ P)
============================================================ -/

def fixtureD_state : AgentState :=
  -- Action requires uniqueAge, but we only have provenance evidence
  -- No evidence for uniqueAge means UNRESOLVED
  transition { decisionHistory := [] } .uniqueAge .unresolved

theorem fixtureD_does_not_admit : fixtureD_state.decisionHistory.head?.map (·.decision) = some .stop := by
  simp [fixtureD_state, transition, consumeEvidence]

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

/-- Evidence preserved in history. -/
theorem evidence_preserved_in_history (s : AgentState) (req : Requirement) (status : EvidenceStatus) :
    (transition s req status).decisionHistory.head?.map (·.evidence) = some status := by
  simp [transition]

/-- Decision matches evidence status. -/
theorem decision_matches_evidence (s : AgentState) (req : Requirement) (status : EvidenceStatus) :
    (transition s req status).decisionHistory.head?.map (·.decision) = some (consumeEvidence req status) := by
  simp [transition]

/-! ============================================================
    Distinction Preservation
============================================================ -/

theorem evidence_status_distinct :
    (EvidenceStatus.established ≠ EvidenceStatus.refuted) ∧
    (EvidenceStatus.established ≠ EvidenceStatus.unresolved) ∧
    (EvidenceStatus.refuted ≠ EvidenceStatus.unresolved) := by
  simp

theorem consumer_decision_distinct :
    (ConsumerDecision.admit ≠ ConsumerDecision.reject) ∧
    (ConsumerDecision.admit ≠ ConsumerDecision.stop) ∧
    (ConsumerDecision.reject ≠ ConsumerDecision.stop) := by
  simp

/-! ============================================================
    Compile-time surface checks
============================================================ -/

#check EvidenceStatus
#check ConsumerDecision
#check Requirement
#check DecisionRecord
#check AgentState
#check consumeEvidence
#check transition
#check fixtureA_state
#check fixtureB_state
#check fixtureC_state
#check fixtureD_state

end S0AgentState
