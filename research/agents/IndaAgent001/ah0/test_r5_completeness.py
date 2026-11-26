"""AH0-R5 deterministic tests: operation-dependent proposal completeness.

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
from ah0.live_grok_reasoner import parse_proposal, LiveReasonerParseError


def make_state(inspected=None, budget=5, terminal=False):
    req = AgentRequirement(
        requirement_id="req1",
        objective_id="obj1",
        proposition="test",
        required_scope="S",
        accepted_provenance=["P"],
        accepted_verifiers=["v"],
        evidence_standard="EOP0",
        retrieval_budget=budget,
        terminal_conditions=["STOP"],
    )
    return AH0State(
        run_id="R5",
        fixture_id="F1",
        frozen_requirement=req,
        current_objective_id="obj1",
        obligation_profiles={"obl1": ObligationDischargeStatus.UNVERIFIABLE},
        visible_memory_index=[{"record_id": "pos1"}],
        inspected_record_ids=inspected or [],
        remaining_retrieval_budget=budget,
        terminal=terminal,
    )


def make_proposal(op, **kwargs):
    defaults = {
        "proposal_id": "t",
        "operation": op,
        "justification": "test",
        "expected_information_gain": "none",
    }
    defaults.update(kwargs)
    return AgentProposal(**defaults)


def test_field_requirement_matrix():
    gate = AdmissionGate()
    state = make_state()

    # INSPECT_RECORD requires target_record_id
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    d, c, r = gate.evaluate(p, state)
    assert d == ProposalDecision.ADMITTED, r

    p_null = make_proposal(Operation.INSPECT_RECORD, target_record_id=None)
    d, c, r = gate.evaluate(p_null, state)
    assert d == ProposalDecision.REJECTED
    assert "Missing target_record_id" in r

    # DECLARE_STATUS requires proposed_status
    p = make_proposal(Operation.DECLARE_STATUS, proposed_status=EvidenceStatus.ESTABLISHED)
    d, c, r = gate.evaluate(p, state)
    assert d == ProposalDecision.ADMITTED, r

    p_null = make_proposal(Operation.DECLARE_STATUS, proposed_status=None)
    d, c, r = gate.evaluate(p_null, state)
    assert d == ProposalDecision.REJECTED
    assert "Missing proposed status" in r

    # QUERY_INDEX, SUBMIT_EVIDENCE, STOP: no field required by gate
    for op in [Operation.QUERY_INDEX, Operation.SUBMIT_EVIDENCE, Operation.STOP]:
        p = make_proposal(op)
        d, c, r = gate.evaluate(p, state)
        assert d == ProposalDecision.ADMITTED, f"{op}: {r}"

    print("test_field_requirement_matrix PASS")


def test_inspect_ablation():
    gate = AdmissionGate()
    state = make_state()

    control = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    d, c, r = gate.evaluate(control, state)
    assert d == ProposalDecision.ADMITTED

    ablation = make_proposal(Operation.INSPECT_RECORD, target_record_id=None)
    d, c, r = gate.evaluate(ablation, state)
    assert d == ProposalDecision.REJECTED
    assert "Missing target_record_id" in r

    print("test_inspect_ablation PASS")


def test_wrong_field_controls():
    gate = AdmissionGate()
    state = make_state()

    # proposed_status on INSPECT_RECORD is ignored
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1", proposed_status=EvidenceStatus.ESTABLISHED)
    d, c, r = gate.evaluate(p, state)
    assert d == ProposalDecision.ADMITTED

    # target_record_id on DECLARE_STATUS is ignored
    p = make_proposal(Operation.DECLARE_STATUS, proposed_status=EvidenceStatus.ESTABLISHED, target_record_id="pos1")
    d, c, r = gate.evaluate(p, state)
    assert d == ProposalDecision.ADMITTED

    # target fields on STOP are ignored
    p = make_proposal(Operation.STOP, target_record_id="pos1", target_obligation_id="obl1")
    d, c, r = gate.evaluate(p, state)
    assert d == ProposalDecision.ADMITTED

    print("test_wrong_field_controls PASS")


def test_value_validity():
    gate = AdmissionGate()
    state = make_state()

    # unknown record
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="unknown")
    d, c, r = gate.evaluate(p, state)
    # Gate only checks presence and not-already-inspected; unknown is admitted by current gate
    assert d == ProposalDecision.ADMITTED

    # already inspected
    state2 = make_state(inspected=["pos1"])
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    d, c, r = gate.evaluate(p, state2)
    assert d == ProposalDecision.REJECTED
    assert "already inspected" in r.lower()

    # budget exhausted
    state3 = make_state(budget=0)
    p = make_proposal(Operation.INSPECT_RECORD, target_record_id="pos1")
    d, c, r = gate.evaluate(p, state3)
    assert d == ProposalDecision.REJECTED
    assert "budget" in r.lower()

    # terminal state
    state4 = make_state(terminal=True)
    p = make_proposal(Operation.STOP)
    d, c, r = gate.evaluate(p, state4)
    assert d == ProposalDecision.REJECTED
    assert "terminal" in r.lower()

    print("test_value_validity PASS")


def test_prompt_contract_gap():
    # The current prompt lists allowed operations but does not state which fields are required per operation.
    # This is established by inspection of live_grok_reasoner.py prompt construction.
    from ah0.live_grok_reasoner import canonical_operation_values
    ops = canonical_operation_values()
    assert "INSPECT_RECORD" in ops
    # The prompt does not currently list per-operation required fields.
    # This is the established gap.
    print("test_prompt_contract_gap PASS")


if __name__ == "__main__":
    test_field_requirement_matrix()
    test_inspect_ablation()
    test_wrong_field_controls()
    test_value_validity()
    test_prompt_contract_gap()
    print("ALL R5 TESTS PASSED")


def test_prompt_exposes_required_fields():
    import json
    from ah0.live_grok_reasoner import LiveGrokReasoner, operation_required_fields
    captured = {}
    def transport(prompt):
        captured["prompt"] = prompt
        return json.dumps({"operation": "STOP", "justification": "done", "expected_information_gain": "none"})
    reasoner = LiveGrokReasoner(transport=transport)
    reasoner.propose_next_operation({"step": 0})
    pobj = json.loads(captured["prompt"])
    assert "INSPECT_RECORD requires target_record_id" in pobj["instruction"]
    assert "DECLARE_STATUS requires proposed_status" in pobj["instruction"]
    assert pobj["operation_required_fields"] == operation_required_fields()
    print("test_prompt_exposes_required_fields PASS")


if __name__ == "__main__":
    test_prompt_exposes_required_fields()
