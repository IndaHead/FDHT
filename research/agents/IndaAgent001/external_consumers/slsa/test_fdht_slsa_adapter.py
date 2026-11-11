#!/usr/bin/env python3
"""Deterministic tests for FDHT SLSA adapter. Anti-contamination."""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

from frozen_slsa_requirements import ExternalResult, CheckStatus, ArtifactAcceptanceRequest
from external_slsa_consumer import evaluate
from fdht_slsa_adapter import adapt, EvidenceStatus, ConsumerDecision
from test_external_slsa_consumer import make_req, make_env, TRUST_KEY, ACCEPTED_BUILDERS, REQUIRED_TYPE, PERMITTED_PARAMS

def test_positive_mapping():
    r = evaluate(make_req())
    a = adapt(r)
    assert r.final_result == ExternalResult.ACCEPT
    assert a.evidence_status == EvidenceStatus.ESTABLISHED
    assert a.consumer_decision == ConsumerDecision.ADMIT
    assert a.check_results_preserved
    print("PASS: E1 ACCEPT -> ESTABLISHED -> ADMIT")

def test_reject_mapping():
    env = make_env(digest="d_wrong")
    r = evaluate(make_req(env=env))
    a = adapt(r)
    assert r.final_result == ExternalResult.REJECT
    assert a.evidence_status == EvidenceStatus.REFUTED
    assert a.consumer_decision == ConsumerDecision.REJECT
    assert "subject_binding" in a.failed_checks
    print("PASS: E2 REJECT -> REFUTED -> REJECT")

def test_review_mapping():
    env = make_env()
    r = evaluate(make_req(env=env, trust=None))
    a = adapt(r)
    assert r.final_result == ExternalResult.REVIEW
    assert a.evidence_status == EvidenceStatus.UNRESOLVED
    assert a.consumer_decision == ConsumerDecision.STOP
    assert "signature" in a.unverifiable_checks
    print("PASS: E5 REVIEW -> UNRESOLVED -> STOP")

def test_multiple_failures_preserved():
    env = make_env(digest="d_wrong", builder="builder_X", btype="https://other.dev/build/v1")
    r = evaluate(make_req(env=env))
    a = adapt(r)
    assert len(a.failed_checks) == 3
    assert "subject_binding" in a.failed_checks
    assert "builder" in a.failed_checks
    assert "build_type" in a.failed_checks
    print("PASS: E13 multiple failures all preserved")

def test_authority_applicability_collapse():
    # Accepted builder does not imply artifact accepted
    env = make_env(builder="builder_A", digest="d_wrong")
    r = evaluate(make_req(env=env))
    a = adapt(r)
    assert a.external_result == ExternalResult.REJECT
    print("PASS: authority-applicability collapse rejected")

def test_signature_truth_collapse():
    # Valid signature does not imply all claims true
    env = make_env(digest="d_wrong")
    r = evaluate(make_req(env=env))
    # Signature check may pass or fail depending on digest used in sig
    # But the overall result is REJECT due to subject binding
    a = adapt(r)
    assert a.external_result == ExternalResult.REJECT
    print("PASS: signature-truth collapse rejected")

def test_provenance_decision_collapse():
    # Provenance exists does not imply accepted
    env = make_env(builder="builder_X")
    r = evaluate(make_req(env=env))
    a = adapt(r)
    assert a.external_result == ExternalResult.REJECT
    print("PASS: provenance-decision collapse rejected")

def test_review_to_reject_collapse():
    # Missing evidence must not become REJECT
    env = make_env()
    r = evaluate(make_req(env=env, trust=None))
    a = adapt(r)
    assert a.external_result == ExternalResult.REVIEW
    assert a.consumer_decision == ConsumerDecision.STOP
    print("PASS: review-to-reject collapse rejected")

def test_review_to_accept_collapse():
    # Absence of contradiction must not become ACCEPT
    env = make_env()
    r = evaluate(make_req(env=env, trust=None))
    a = adapt(r)
    assert a.external_result != ExternalResult.ACCEPT
    print("PASS: review-to-accept collapse rejected")

def test_result_name_substitution():
    # External result remains attached
    r = evaluate(make_req())
    a = adapt(r)
    assert a.external_result == ExternalResult.ACCEPT
    assert a.external_result is not None
    print("PASS: result-name substitution rejected")

def test_all_fixtures_preserved():
    # Spot-check that adapter does not change external outcomes
    cases = [
        (make_req(), ExternalResult.ACCEPT),
        (make_req(env=make_env(digest="d_wrong")), ExternalResult.REJECT),
        (make_req(env=make_env(), trust=None), ExternalResult.REVIEW),
    ]
    for req, expected in cases:
        r = evaluate(req)
        a = adapt(r)
        assert r.final_result == expected
        assert a.external_result == expected
    print("PASS: all fixture outcomes preserved")

if __name__ == "__main__":
    test_positive_mapping()
    test_reject_mapping()
    test_review_mapping()
    test_multiple_failures_preserved()
    test_authority_applicability_collapse()
    test_signature_truth_collapse()
    test_provenance_decision_collapse()
    test_review_to_reject_collapse()
    test_review_to_accept_collapse()
    test_result_name_substitution()
    test_all_fixtures_preserved()
    print()
    print("ALL ADAPTER TESTS PASSED")
