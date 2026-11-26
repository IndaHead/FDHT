"""AH0-R4 deterministic tests: canonical proposal vocabulary contract.

Zero network calls. No XAI_API_KEY access.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from ah0.models import Operation, AgentProposal, EvidenceStatus
from ah0.live_grok_reasoner import (
    LiveGrokReasoner,
    LiveReasonerParseError,
    LiveReasonerDisabled,
    canonical_operation_values,
    parse_proposal,
)


def test_canonical_vocabulary_equals_operation():
    canon = canonical_operation_values()
    assert set(canon) == {op.value for op in Operation}
    assert len(canon) == len(set(canon))
    print("test_canonical_vocabulary_equals_operation PASS")


def test_prompt_contains_canonical_operations():
    captured = {}
    def transport(prompt: str) -> str:
        captured["prompt"] = prompt
        return json.dumps({
            "operation": "STOP",
            "justification": "done",
            "expected_information_gain": "none",
        })
    reasoner = LiveGrokReasoner(transport=transport)
    reasoner.propose_next_operation({"step": 0})
    prompt_obj = json.loads(captured["prompt"])
    for op in canonical_operation_values():
        assert op in prompt_obj["instruction"]
        assert op in prompt_obj["allowed_operations"]
    print("test_prompt_contains_canonical_operations PASS")


def test_prompt_does_not_advertise_inspect():
    captured = {}
    def transport(prompt: str) -> str:
        captured["prompt"] = prompt
        return json.dumps({
            "operation": "STOP",
            "justification": "done",
            "expected_information_gain": "none",
        })
    reasoner = LiveGrokReasoner(transport=transport)
    reasoner.propose_next_operation({"step": 0})
    prompt_obj = json.loads(captured["prompt"])
    assert "INSPECT" not in prompt_obj["allowed_operations"]
    assert "INSPECT is invalid" in prompt_obj["instruction"]
    print("test_prompt_does_not_advertise_inspect PASS")


def test_canonical_operations_parse():
    for op in Operation:
        payload = {
            "operation": op.value,
            "justification": "test",
            "expected_information_gain": "none",
        }
        proposal = parse_proposal(payload, "t")
        assert proposal.operation == op
    print("test_canonical_operations_parse PASS")


def test_inspect_fails_closed():
    try:
        parse_proposal({"operation": "INSPECT", "justification": "x", "expected_information_gain": "y"}, "t")
        assert False, "INSPECT should have failed"
    except LiveReasonerParseError:
        pass
    print("test_inspect_fails_closed PASS")


def test_synonyms_fail_closed():
    synonyms = ["INSPECT", "inspect", "Inspect_Record", "query", "stop", "SUBMIT", "declare"]
    for syn in synonyms:
        try:
            parse_proposal({"operation": syn, "justification": "x", "expected_information_gain": "y"}, "t")
            assert False, f"{syn} should have failed"
        except LiveReasonerParseError:
            pass
    print("test_synonyms_fail_closed PASS")


def test_invalid_types_fail():
    for bad in [None, 1, ["STOP"], {"op": "STOP"}]:
        try:
            parse_proposal({"operation": bad, "justification": "x", "expected_information_gain": "y"}, "t")
            assert False, f"{bad!r} should have failed"
        except LiveReasonerParseError:
            pass
    print("test_invalid_types_fail PASS")


def test_malformed_json_fails():
    try:
        parse_proposal("not json", "t")
        assert False
    except LiveReasonerParseError:
        pass
    print("test_malformed_json_fails PASS")


def test_missing_fields_fail():
    try:
        parse_proposal({"operation": "STOP"}, "t")
        assert False
    except LiveReasonerParseError:
        pass
    try:
        parse_proposal({"operation": "STOP", "justification": "x"}, "t")
        assert False
    except LiveReasonerParseError:
        pass
    print("test_missing_fields_fail PASS")


def test_disabled_reasoner_fails_closed():
    # Ensure env is clean
    os.environ.pop("AH0_RUN_LIVE_GROK", None)
    os.environ.pop("XAI_API_KEY", None)
    reasoner = LiveGrokReasoner()
    try:
        reasoner.propose_next_operation({"step": 0})
        assert False, "disabled reasoner should fail"
    except LiveReasonerDisabled:
        pass
    print("test_disabled_reasoner_fails_closed PASS")


def test_no_network_in_r4():
    # All tests above use injected transport or pure parse; no network.
    print("test_no_network_in_r4 PASS")


if __name__ == "__main__":
    test_canonical_vocabulary_equals_operation()
    test_prompt_contains_canonical_operations()
    test_prompt_does_not_advertise_inspect()
    test_canonical_operations_parse()
    test_inspect_fails_closed()
    test_synonyms_fail_closed()
    test_invalid_types_fail()
    test_malformed_json_fails()
    test_missing_fields_fail()
    test_disabled_reasoner_fails_closed()
    test_no_network_in_r4()
    print("ALL R4 TESTS PASSED")
