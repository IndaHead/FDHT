#!/usr/bin/env python3
"""Deterministic tests for Locality L0 POC."""

import sys
sys.path.insert(0, ".")

from research.agents.IndaAgent001.locality.locality_poc import (
    control_route, source_local_route, FROZEN_SOURCE,
    positive_requirement, refuted_requirement, unresolved_requirement,
    EvidenceStatus, ConsumerDecision, a0_consume,
    check_retrieval_collapse, check_possession_collapse,
    check_authority_collapse, check_persistence_collapse,
    check_objective_replacement, check_scope_expansion,
    check_information_volume_attack, check_status_only_collapse,
)

def test_positive_control():
    req = positive_requirement()
    r = control_route(req, FROZEN_SOURCE)
    assert r.status == EvidenceStatus.ESTABLISHED
    assert r.decision == ConsumerDecision.ADMIT
    assert "source_node" in r.information_moved
    print("PASS: positive control")

def test_positive_source_local():
    req = positive_requirement()
    r = source_local_route(req, FROZEN_SOURCE)
    assert r.status == EvidenceStatus.ESTABLISHED
    assert r.decision == ConsumerDecision.ADMIT
    assert "source_node" not in r.information_moved
    assert "target_node" not in r.information_moved
    print("PASS: positive source-local")

def test_negative_control():
    req = refuted_requirement()
    r = control_route(req, FROZEN_SOURCE)
    assert r.status == EvidenceStatus.REFUTED
    assert r.decision == ConsumerDecision.REJECT
    print("PASS: negative control")

def test_negative_source_local():
    req = refuted_requirement()
    r = source_local_route(req, FROZEN_SOURCE)
    assert r.status == EvidenceStatus.REFUTED
    assert r.decision == ConsumerDecision.REJECT
    assert "source_node" not in r.information_moved
    print("PASS: negative source-local")

def test_unresolved_control():
    req = unresolved_requirement()
    r = control_route(req, FROZEN_SOURCE)
    assert r.status == EvidenceStatus.UNRESOLVED
    assert r.decision == ConsumerDecision.STOP
    print("PASS: unresolved control")

def test_unresolved_source_local():
    req = unresolved_requirement()
    r = source_local_route(req, FROZEN_SOURCE)
    assert r.status == EvidenceStatus.UNRESOLVED
    assert r.decision == ConsumerDecision.STOP
    print("PASS: unresolved source-local")

def test_decisions_match():
    for req_fn in [positive_requirement, refuted_requirement, unresolved_requirement]:
        req = req_fn()
        ctrl = control_route(req, FROZEN_SOURCE)
        src = source_local_route(req, FROZEN_SOURCE)
        assert ctrl.status == src.status
        assert ctrl.decision == src.decision
    print("PASS: decisions match across routes")

def test_less_information():
    req = positive_requirement()
    ctrl = control_route(req, FROZEN_SOURCE)
    src = source_local_route(req, FROZEN_SOURCE)
    assert len(src.information_moved) < len(ctrl.information_moved)
    print("PASS: source-local moves less information")

def test_adversarial():
    req = positive_requirement()
    sl = source_local_route(req, FROZEN_SOURCE)
    assert check_retrieval_collapse(sl)
    assert check_possession_collapse(sl)
    assert check_authority_collapse(sl)
    assert check_persistence_collapse()
    assert check_objective_replacement(sl)
    assert check_scope_expansion(sl)
    assert check_information_volume_attack(sl)
    assert check_status_only_collapse(sl)
    print("PASS: all adversarial checks")

if __name__ == "__main__":
    test_positive_control()
    test_positive_source_local()
    test_negative_control()
    test_negative_source_local()
    test_unresolved_control()
    test_unresolved_source_local()
    test_decisions_match()
    test_less_information()
    test_adversarial()
    print()
    print("ALL TESTS PASSED")
