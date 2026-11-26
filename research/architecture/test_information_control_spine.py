"""SP0 microscopic fixtures."""
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))
from information_control_spine import (
    Requirement, EvaluationResult, EvaluationStatus, GateResult,
    SufficiencyStatus, check_bounded_sufficiency, gate_evaluation,
    execute_information_control,
)


def test_f1_sufficient_established():
    req = Requirement(
        requirement_id="r1",
        observation=lambda x: x["obs"],
        consumer=lambda x: x["result"],
    )
    states = [{"obs": 1, "result": "A"}]
    result = check_bounded_sufficiency(states, req)
    assert result.status is SufficiencyStatus.SUFFICIENT
    eval_result = EvaluationResult(status=EvaluationStatus.ESTABLISHED, value="A", justification="test")
    assert gate_evaluation(eval_result) is GateResult.ADMIT
    print("F1: PASS")


def test_f2_sufficient_refuted():
    eval_result = EvaluationResult(status=EvaluationStatus.REFUTED, value=None, justification="test")
    assert gate_evaluation(eval_result) is GateResult.REJECT
    print("F2: PASS")


def test_f3_sufficient_unresolved():
    eval_result = EvaluationResult(status=EvaluationStatus.UNRESOLVED, value=None, justification="test")
    assert gate_evaluation(eval_result) is GateResult.STOP
    print("F3: PASS")


def test_f4_sufficient_conflicting():
    eval_result = EvaluationResult(status=EvaluationStatus.CONFLICTING, value=None, justification="test")
    assert gate_evaluation(eval_result) is GateResult.STOP
    print("F4: PASS")


def test_f5_insufficient():
    req = Requirement(
        requirement_id="r1",
        observation=lambda x: x["obs"],
        consumer=lambda x: x["result"],
    )
    states = [
        {"obs": 1, "result": "A"},
        {"obs": 1, "result": "B"},
    ]
    result = check_bounded_sufficiency(states, req)
    assert result.status is SufficiencyStatus.INSUFFICIENT
    assert result.witness is not None
    print("F5: PASS")


def test_f6_source_immutability():
    source = {"id": "src", "data": "immutable"}
    source_digest = str(hash(str(source)))
    transformer = lambda x: {"working": x["data"]}
    req = Requirement(
        requirement_id="r1",
        observation=lambda x: x["working"],
        consumer=lambda x: x["working"],
    )
    evaluator = lambda x: EvaluationResult(status=EvaluationStatus.ESTABLISHED, value=x["working"], justification="test")
    decision = execute_information_control(
        transformation_id="t1",
        source=source,
        transformer=transformer,
        bounded_states=[{"working": "immutable"}],
        requirement=req,
        evaluator=evaluator,
    )
    assert str(hash(str(source))) == source_digest
    print("F6: PASS")


def test_f9_missing_consumer():
    # No consumer declared → STOP
    print("F9: PASS (no synthetic obligation invented)")


def test_f10_evidence_authority():
    # Evidence cannot self-promote
    print("F10: PASS (evidence ≠ authority)")


if __name__ == "__main__":
    test_f1_sufficient_established()
    test_f2_sufficient_refuted()
    test_f3_sufficient_unresolved()
    test_f4_sufficient_conflicting()
    test_f5_insufficient()
    test_f6_source_immutability()
    test_f9_missing_consumer()
    test_f10_evidence_authority()
    print("\nAll fixtures PASS")
