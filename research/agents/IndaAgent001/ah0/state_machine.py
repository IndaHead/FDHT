"""AH0 runtime state machine (deterministic)."""
from .models import AH0State, AH0Event, AgentProposal, ProposalDecision
from .admission_gate import AdmissionGate
from .evidence_evaluator import evaluate_status
from .scripted_reasoner import ScriptedReasoner
import hashlib
import json

class AH0StateMachine:
    def __init__(self, initial_state: AH0State, reasoner, catalogue=None):
        self.state = initial_state
        self.reasoner = reasoner
        self.gate = AdmissionGate()
        self.events = []
        self.catalogue = catalogue

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
        if decision == ProposalDecision.ADMITTED:
            if proposal.operation.value == "STOP":
                self.state.terminal = True
                event.executed_operation = "STOP"
                event.operation_result_summary = "TERMINAL"
            elif proposal.operation.value == "INSPECT_RECORD":
                event.executed_operation = "INSPECT_RECORD"
                if self.catalogue is None:
                    event.operation_result_summary = "NO_CATALOGUE"
                else:
                    record = self.catalogue.inspect_record(proposal.target_record_id)
                    if record is None:
                        event.operation_result_summary = "UNKNOWN_RECORD"
                    else:
                        if proposal.target_record_id not in self.state.inspected_record_ids:
                            self.state.inspected_record_ids.append(proposal.target_record_id)
                        self.state.remaining_retrieval_budget = max(0, self.state.remaining_retrieval_budget - 1)
                        event.operation_result_summary = "INSPECTION_SUCCESS"
            elif proposal.operation.value == "SUBMIT_EVIDENCE":
                event.executed_operation = "SUBMIT_EVIDENCE"
                if not proposal.target_record_id:
                    event.operation_result_summary = "MISSING_EVIDENCE_TARGET"
                elif self.catalogue is None:
                    event.operation_result_summary = "NO_CATALOGUE"
                else:
                    record = self.catalogue.inspect_record(proposal.target_record_id)
                    if record is None:
                        event.operation_result_summary = "UNKNOWN_EVIDENCE_RECORD"
                    elif proposal.target_record_id not in self.state.inspected_record_ids:
                        event.operation_result_summary = "EVIDENCE_NOT_INSPECTED"
                    elif proposal.target_record_id in self.state.admitted_evidence_ids or proposal.target_record_id in self.state.opposing_evidence_ids:
                        event.operation_result_summary = "ALREADY_SUBMITTED"
                    else:
                        if getattr(record, "polarity", True):
                            self.state.admitted_evidence_ids.append(proposal.target_record_id)
                        else:
                            self.state.opposing_evidence_ids.append(proposal.target_record_id)
                        event.operation_result_summary = "EVIDENCE_SUBMISSION_SUCCESS"
        self.state.step_number += 1
        return event
