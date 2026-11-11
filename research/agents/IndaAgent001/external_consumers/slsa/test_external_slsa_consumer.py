#!/usr/bin/env python3
"""Deterministic tests for external SLSA consumer. No FDHT imports."""

import sys
sys.path.insert(0, ".")

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
from frozen_slsa_requirements import (
    ProvenanceEnvelope, ArtifactAcceptanceRequest, ExternalResult, CheckStatus,
)
from external_slsa_consumer import (
    evaluate, fixture_signature,
)

TRUST_KEY = "fixture_key_001"
ACCEPTED_BUILDERS = ("builder_A", "builder_B")
REQUIRED_TYPE = "https://slsa.dev/build/v1"
PERMITTED_PARAMS = {"source_uri": ("https://example.com/repo",), "commit": ("abc123",)}

def make_env(aid="art_001", digest="d_abc", builder="builder_A", btype=REQUIRED_TYPE,
             params=None, sig=None, key_id="key_001"):
    if params is None:
        params = {"source_uri": "https://example.com/repo", "commit": "abc123"}
    if sig is None:
        sig = fixture_signature(TRUST_KEY, f"{aid}:{digest}")
    return ProvenanceEnvelope(aid, digest, builder, btype, params, sig, key_id)

def make_req(aid="art_001", digest="d_abc", env=None, trust=TRUST_KEY):
    if env is None:
        env = make_env(aid, digest)
    return ArtifactAcceptanceRequest(
        artifact_id=aid,
        artifact_digest=digest,
        provenance_envelope=env,
        expected_subject_digest=digest,
        accepted_builder_identities=ACCEPTED_BUILDERS,
        required_build_type=REQUIRED_TYPE,
        permitted_external_parameters=PERMITTED_PARAMS,
        available_trust_material=trust,
    )

def test_e1_positive():
    req = make_req()
    r = evaluate(req)
    print(f"DEBUG: result={r.final_result} failed={r.failed_checks} unver={r.unverifiable_checks}")
    for c in r.check_results:
        print(f"  {c.check_name}: {c.status.value}")
    assert r.final_result == ExternalResult.ACCEPT
    print("PASS: E1 positive -> ACCEPT")

def test_e2_wrong_digest():
    env = make_env(digest="d_wrong")
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REJECT
    assert "subject_binding" in r.failed_checks
    print("PASS: E2 wrong digest -> REJECT")

def test_e3_wrong_id():
    env = make_env(aid="art_999")
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REJECT
    assert "subject_binding" in r.failed_checks
    print("PASS: E3 wrong ID -> REJECT")

def test_e4_invalid_signature():
    env = make_env(sig="invalid_sig")
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REJECT
    assert "signature" in r.failed_checks
    print("PASS: E4 invalid signature -> REJECT")

def test_e5_unverifiable_signature():
    env = make_env()
    req = make_req(env=env, trust=None)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REVIEW
    assert "signature" in r.unverifiable_checks
    print("PASS: E5 unverifiable signature -> REVIEW")

def test_e6_unaccepted_builder():
    env = make_env(builder="builder_X")
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REJECT
    assert "builder" in r.failed_checks
    print("PASS: E6 unaccepted builder -> REJECT")

def test_e7_missing_builder():
    env = make_env(builder=None)
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REVIEW
    assert "builder" in r.unverifiable_checks
    print("PASS: E7 missing builder -> REVIEW")

def test_e8_wrong_build_type():
    env = make_env(btype="https://other.dev/build/v1")
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REJECT
    assert "build_type" in r.failed_checks
    print("PASS: E8 wrong build type -> REJECT")

def test_e9_missing_build_type():
    env = make_env(btype=None)
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REVIEW
    assert "build_type" in r.unverifiable_checks
    print("PASS: E9 missing build type -> REVIEW")

def test_e10_unrecognised_param():
    env = make_env(params={"source_uri": "https://example.com/repo", "unknown_param": "x"})
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REJECT
    assert "external_parameters" in r.failed_checks
    print("PASS: E10 unrecognised param -> REJECT")

def test_e11_forbidden_value():
    env = make_env(params={"source_uri": "https://evil.com/repo", "commit": "abc123"})
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REJECT
    assert "external_parameters" in r.failed_checks
    print("PASS: E11 forbidden value -> REJECT")

def test_e12_missing_provenance():
    req = ArtifactAcceptanceRequest(
        artifact_id="art_001", artifact_digest="d_abc",
        provenance_envelope=None, expected_subject_digest="d_abc",
        accepted_builder_identities=ACCEPTED_BUILDERS,
        required_build_type=REQUIRED_TYPE,
        permitted_external_parameters=PERMITTED_PARAMS,
        available_trust_material=TRUST_KEY,
    )
    r = evaluate(req)
    assert r.final_result == ExternalResult.REVIEW
    assert len(r.unverifiable_checks) == 5
    print("PASS: E12 missing provenance -> REVIEW")

def test_e13_multiple_failures():
    env = make_env(digest="d_wrong", builder="builder_X", btype="https://other.dev/build/v1")
    req = make_req(env=env)
    r = evaluate(req)
    assert r.final_result == ExternalResult.REJECT
    assert "subject_binding" in r.failed_checks
    assert "builder" in r.failed_checks
    assert "build_type" in r.failed_checks
    print("PASS: E13 multiple failures -> REJECT (all visible)")

if __name__ == "__main__":
    test_e1_positive()
    test_e2_wrong_digest()
    test_e3_wrong_id()
    test_e4_invalid_signature()
    test_e5_unverifiable_signature()
    test_e6_unaccepted_builder()
    test_e7_missing_builder()
    test_e8_wrong_build_type()
    test_e9_missing_build_type()
    test_e10_unrecognised_param()
    test_e11_forbidden_value()
    test_e12_missing_provenance()
    test_e13_multiple_failures()
    print()
    print("ALL EXTERNAL TESTS PASSED")
