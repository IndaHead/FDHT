"""AH0-R7 deterministic tests: inspection-transition semantics.

Zero network calls. No XAI_API_KEY access.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from ah0.models import (
    AgentProposal, Operation, EvidenceStatus, ProposalDecision,
    AH0State, AgentRequirement, ObligationDischargeStatus,
)
from ah0.admission_gate import AdmissionGate
from ah0.fixtures import get_catalogue
from ah0.memory import MemoryStore
from ah0.state_machine import AH0StateMachine


def make_state(inspected=None, budget=5, terminal=False):
    req = AgentRequirement(
        requirement_id="req1", objective_id="obj1", proposition="test",
        required_scope="S", accepted_provenance=["P"], accepted_verifiers=["v"],
        evidence_standard="EOP0", retrieval_budget=budget, terminal_conditions=["STOP"],
    )
    return AH0State(
        run_id="R7", fixture_id="F1", frozen_requirement=req,
        current_objective_id="obj1",
        obligation_profiles={"obl1": ObligationDischargeStatus.UNVERIFIABLE},
        visible_memory_index=[{"record_id": "pos1"}, {"record_id": "neg1"}],
        inspected_record_ids=inspected or [],
        remaining_retrieval_budget=budget, terminal=terminal,
    )


def make_proposal(op, **kwargs):
    defaults = {"proposal_id": "t", "operation": op, "justification": "test", "expected_information_gain": "none"}
    defaults.update(kwargs)
    return AgentProposal(**defaults)


class FixedReasoner:
    def __init__(self, proposal):
        self.proposal = proposal
    def propose_next_operation(self, state):
        return self.proposal


def test_valid_inspection():
    catalogue = MemoryStore(get_catalogue())
    state = make_state()
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert event.admission_result == ProposalDecision.ADMITTED
    assert event.operation_result_summary == "INSPECTION_SUCCESS"
    assert "pos1" in sm.state.inspected_record_ids
    assert sm.state.remaining_retrieval_budget == 4
    print("test_valid_inspection PASS")


def test_unknown_target():
    catalogue = MemoryStore(get_catalogue())
    state = make_state()
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="missing_r7")
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert event.admission_result == ProposalDecision.ADMITTED
    assert event.operation_result_summary == "UNKNOWN_RECORD"
    assert "missing_r7" not in sm.state.inspected_record_ids
    assert sm.state.remaining_retrieval_budget == 5
    print("test_unknown_target PASS")


def test_missing_target():
    gate = AdmissionGate()
    state = make_state()
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id=None)
    d, c, r = gate.evaluate(p, state)
    assert d == ProposalDecision.REJECTED
    assert "Missing target_record_id" in r
    print("test_missing_target PASS")


def test_already_inspected():
    gate = AdmissionGate()
    state = make_state(inspected=["pos1"])
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    d, c, r = gate.evaluate(p, state)
    assert d == ProposalDecision.REJECTED
    assert "already inspected" in r.lower()
    print("test_already_inspected PASS")


def test_budget_exhausted():
    gate = AdmissionGate()
    state = make_state(budget=0)
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    d, c, r = gate.evaluate(p, state)
    assert d == ProposalDecision.REJECTED
    assert "budget" in r.lower()
    print("test_budget_exhausted PASS")


def test_terminal():
    gate = AdmissionGate()
    state = make_state(terminal=True)
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    d, c, r = gate.evaluate(p, state)
    assert d == ProposalDecision.REJECTED
    assert "terminal" in r.lower()
    print("test_terminal PASS")


def test_distinguishability():
    catalogue = MemoryStore(get_catalogue())
    # Success
    state1 = make_state()
    p1 = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    sm1 = AH0StateMachine(state1, FixedReasoner(p1), catalogue=catalogue)
    e1 = sm1.step()
    # Unknown
    state2 = make_state()
    p2 = make_proposal(Operation.INSPECT_RECORD, target_record_id="missing_r7")
    sm2 = AH0StateMachine(state2, FixedReasoner(p2), catalogue=catalogue)
    e2 = sm2.step()
    assert e1.operation_result_summary != e2.operation_result_summary
    assert e1.operation_result_summary == "INSPECTION_SUCCESS"
    assert e2.operation_result_summary == "UNKNOWN_RECORD"
    print("test_distinguishability PASS")


if __name__ == "__main__":
    test_valid_inspection()
    test_unknown_target()
    test_missing_target()
    test_already_inspected()
    test_budget_exhausted()
    test_terminal()
    test_distinguishability()
    print("ALL R7 TESTS PASSED")
