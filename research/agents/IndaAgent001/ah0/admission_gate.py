"""Deterministic AH0 proposal admission gate."""
from .models import AgentProposal, ProposalDecision, Operation, AH0State

class AdmissionGate:
    def evaluate(self, proposal: AgentProposal, state: AH0State) -> tuple:
        if state.terminal:
            return ProposalDecision.REJECTED, "TERMINAL_STATE_REACHED", "Terminal state already reached"
        if proposal.operation == Operation.INSPECT_RECORD:
            if not proposal.target_record_id:
                return ProposalDecision.REJECTED, "UNKNOWN_RECORD", "Missing target_record_id"
            if proposal.target_record_id in state.inspected_record_ids:
                return ProposalDecision.REJECTED, "RECORD_ALREADY_INSPECTED", "Record already inspected"
            if state.remaining_retrieval_budget <= 0:
                return ProposalDecision.REJECTED, "BUDGET_EXHAUSTED", "Retrieval budget exhausted"
        if proposal.operation == Operation.DECLARE_STATUS and not proposal.proposed_status:
            return ProposalDecision.REJECTED, "INVALID_STATUS_DECLARATION", "Missing proposed status"
        return ProposalDecision.ADMITTED, "OK", "Proposal admitted"
