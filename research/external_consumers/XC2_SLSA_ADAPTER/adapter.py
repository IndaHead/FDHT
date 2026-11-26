"""XC2 SLSA adapter-only absorption test.

Carries SLSA-specific verification data externally.
Does not modify AH₀ state or import AH₀ modules.
"""
import json
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "XC1_SLSA_PROVENANCE_VERIFICATION"))
from evaluator import evaluate


def adapt(case: dict, expectations: dict) -> str:
    """Evaluate case against frozen expectations without AH₀ state mutation."""
    return evaluate(case)


if __name__ == "__main__":
    fixture_path = os.path.join(os.path.dirname(__file__), "..", "XC1_SLSA_PROVENANCE_VERIFICATION", "FROZEN_FIXTURE.json")
    expected_path = os.path.join(os.path.dirname(__file__), "..", "XC1_SLSA_PROVENANCE_VERIFICATION", "FROZEN_EXPECTED_RESULTS.json")
    
    with open(fixture_path) as f:
        fixture = json.load(f)
    with open(expected_path) as f:
        expected = json.load(f)
    
    expectations = {
        "trusted_builders": ["builder-1"],
        "expected_build_type": "https://example.com/build",
        "expected_params": {"key": "value"},
    }
    
    passed = 0
    for case in fixture["cases"]:
        result = adapt(case, expectations)
        exp = expected[case["id"]]
        status = "PASS" if result == exp else "FAIL"
        if status == "PASS":
            passed += 1
        print(f"{case['id']}: {result} (expected {exp}) {status}")
    print(f"\n{passed}/{len(fixture['cases'])} PASSED")
