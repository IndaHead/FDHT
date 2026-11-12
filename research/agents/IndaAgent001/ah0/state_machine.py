"""AH0 runtime state machine (deterministic)."""
from .models import AH0State, AH0Event, AgentProposal, ProposalDecision
from .admission_gate import AdmissionGate
from .evidence_evaluator import evaluate_status
from .scripted_reasoner import ScriptedReasoner
import hashlib
import json

class AH0StateMachine:
    def __init__(self, initial_state: AH0State, reasoner):
        self.state = initial_state
        self.reasoner = reasoner
        self.gate = AdmissionGate()
        self.events = []

    def step(self):
        if self.state.terminal:
            return None
        proposal = self.reasoner.propose_next_operation(self.state)
        decision, code, reason = self.gate.evaluate(proposal, self.state)
        event = AH0Event(
            run_id=self.state.run_id,
            sequence_number=self.state.step_number,
            state_digest_before=self.state.state_digest,
            proposal=proposal,
            admission_result=decision,
            admission_reason=reason,
            obligation_profile_after=self.state.obligation_profiles,
            state_digest_after=self.state.state_digest,
            terminal=self.state.terminal,
            timestamp="deterministic",
        )
        self.events.append(event)
        if decision == ProposalDecision.ADMITTED and proposal.operation.value == "STOP":
            self.state.terminal = True
        self.state.step_number += 1
        return event
