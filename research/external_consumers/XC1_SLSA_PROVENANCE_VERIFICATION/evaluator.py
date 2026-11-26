"""Independent SLSA provenance verification evaluator.

Does not import AH₀ or FDHT modules.
"""

def evaluate(case: dict) -> str:
    if not case.get("provenance_exists"):
        return "REJECT"
    if not case.get("signature_valid"):
        return "REJECT"
    if not case.get("builder_trusted"):
        return "REJECT"
    if not case.get("build_type_matches"):
        return "REJECT"
    if not case.get("external_params_match"):
        return "REJECT"
    if not case.get("digest_matches"):
        return "REJECT"
    return "ACCEPT"


if __name__ == "__main__":
    import json
    with open("FROZEN_FIXTURE.json") as f:
        fixture = json.load(f)
    with open("FROZEN_EXPECTED_RESULTS.json") as f:
        expected = json.load(f)
    passed = 0
    for case in fixture["cases"]:
        result = evaluate(case)
        exp = expected[case["id"]]
        status = "PASS" if result == exp else "FAIL"
        if status == "PASS":
            passed += 1
        print(f"{case['id']}: {result} (expected {exp}) {status}")
    print(f"\n{passed}/{len(fixture['cases'])} PASSED")
