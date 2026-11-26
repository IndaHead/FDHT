"""AH0-R8 deterministic tests: evidence-submission transition semantics.

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


def make_state(inspected=None, admitted=None, opposing=None, budget=5, terminal=False):
    req = AgentRequirement(
        requirement_id="req1", objective_id="obj1", proposition="test",
        required_scope="S", accepted_provenance=["P"], accepted_verifiers=["v"],
        evidence_standard="EOP0", retrieval_budget=budget, terminal_conditions=["STOP"],
    )
    return AH0State(
        run_id="R8", fixture_id="F1", frozen_requirement=req,
        current_objective_id="obj1",
        obligation_profiles={"obl1": ObligationDischargeStatus.UNVERIFIABLE},
        visible_memory_index=[{"record_id": "pos1"}, {"record_id": "neg1"}],
        inspected_record_ids=inspected or [],
        admitted_evidence_ids=admitted or [],
        opposing_evidence_ids=opposing or [],
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


def test_submit_after_inspect():
    catalogue = MemoryStore(get_catalogue())
    state = make_state(inspected=["pos1"])
    p = make_proposal(Operation.SUBMIT_EVIDENCE, target_record_id="pos1")
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert event.operation_result_summary == "EVIDENCE_SUBMISSION_SUCCESS"
    assert "pos1" in sm.state.admitted_evidence_ids
    print("test_submit_after_inspect PASS")


def test_submit_negative():
    catalogue = MemoryStore(get_catalogue())
    state = make_state(inspected=["neg1"])
    p = make_proposal(Operation.SUBMIT_EVIDENCE, target_record_id="neg1")
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert event.operation_result_summary == "EVIDENCE_SUBMISSION_SUCCESS"
    assert "neg1" in sm.state.opposing_evidence_ids
    print("test_submit_negative PASS")


def test_submit_without_inspect():
    catalogue = MemoryStore(get_catalogue())
    state = make_state(inspected=[])
    p = make_proposal(Operation.SUBMIT_EVIDENCE, target_record_id="pos1")
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert event.operation_result_summary == "EVIDENCE_NOT_INSPECTED"
    assert "pos1" not in sm.state.admitted_evidence_ids
    print("test_submit_without_inspect PASS")


def test_submit_unknown():
    catalogue = MemoryStore(get_catalogue())
    state = make_state(inspected=["pos1"])
    p = make_proposal(Operation.SUBMIT_EVIDENCE, target_record_id="missing_r8")
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert event.operation_result_summary == "UNKNOWN_EVIDENCE_RECORD"
    print("test_submit_unknown PASS")


def test_submit_null():
    catalogue = MemoryStore(get_catalogue())
    state = make_state(inspected=["pos1"])
    p = make_proposal(Operation.SUBMIT_EVIDENCE, target_record_id=None)
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert event.operation_result_summary == "MISSING_EVIDENCE_TARGET"
    print("test_submit_null PASS")


def test_duplicate_submission():
    catalogue = MemoryStore(get_catalogue())
    state = make_state(inspected=["pos1"], admitted=["pos1"])
    p = make_proposal(Operation.SUBMIT_EVIDENCE, target_record_id="pos1")
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert event.operation_result_summary == "ALREADY_SUBMITTED"
    assert sm.state.admitted_evidence_ids.count("pos1") == 1
    print("test_duplicate_submission PASS")


def test_inspect_does_not_submit():
    catalogue = MemoryStore(get_catalogue())
    state = make_state()
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert event.operation_result_summary == "INSPECTION_SUCCESS"
    assert "pos1" not in sm.state.admitted_evidence_ids
    print("test_inspect_does_not_submit PASS")


def test_submit_does_not_declare():
    catalogue = MemoryStore(get_catalogue())
    state = make_state(inspected=["pos1"])
    p = make_proposal(Operation.SUBMIT_EVIDENCE, target_record_id="pos1")
    sm = AH0StateMachine(state, FixedReasoner(p), catalogue=catalogue)
    event = sm.step()
    assert sm.state.current_status is None
    print("test_submit_does_not_declare PASS")


if __name__ == "__main__":
    test_submit_after_inspect()
    test_submit_negative()
    test_submit_without_inspect()
    test_submit_unknown()
    test_submit_null()
    test_duplicate_submission()
    test_inspect_does_not_submit()
    test_submit_does_not_declare()
    print("ALL R8 TESTS PASSED")
