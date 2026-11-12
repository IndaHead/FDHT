"""Scripted reasoner for deterministic AH0 controls."""
from .models import AgentProposal, Operation, EvidenceStatus

class ScriptedReasoner:
    def __init__(self, sequence: list):
        self.sequence = sequence
        self.index = 0

    def propose_next_operation(self, visible_state) -> AgentProposal:
        if self.index >= len(self.sequence):
            return AgentProposal(
                proposal_id=f"stop-{self.index}",
                operation=Operation.STOP,
                justification="Scripted sequence exhausted",
                expected_information_gain="none",
            )
        step = self.sequence[self.index]
        self.index += 1
        return AgentProposal(**step)
