"""Minimal deterministic scripted AH0 test."""
from .scripted_reasoner import ScriptedReasoner
from .models import Operation, AgentProposal, EvidenceStatus

def test_scripted_stop():
    sequence = [
        {"proposal_id": "s1", "operation": Operation.STOP, "justification": "done", "expected_information_gain": "none"}
    ]
    reasoner = ScriptedReasoner(sequence)
    proposal = reasoner.propose_next_operation(None)
    assert proposal.operation == Operation.STOP
    print("scripted stop test passed")

if __name__ == "__main__":
    test_scripted_stop()
