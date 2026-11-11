#!/usr/bin/env python3
"""Deterministic tests for FDHT CRDT adapter. Anti-contamination."""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from frozen_crdt_requirements import ConvergenceResult, GCounterState, UpdateId
from external_gcounter import (
    initial_state, increment, merge, check_convergence, states_equal,
)
from fdht_crdt_adapter import adapt, EvidenceStatus

def test_converged_preserved():
    a = initial_state(["A", "B"]); a = increment(a, "A", 1); a = increment(a, "A", 2)
    b = initial_state(["A", "B"]); b = increment(b, "B", 1)
    final_a = merge(a, b); final_b = merge(b, a)
    r = check_convergence(final_a, final_b)
    adapted = adapt(r)
    assert adapted.external_result == ConvergenceResult.CONVERGED
    assert adapted.full_state_equal
    assert adapted.same_logical_updates
    print("PASS: CONVERGED preserved")

def test_precondition_not_met_preserved():
    a = initial_state(["A", "B"]); a = increment(a, "A", 1)
    b = initial_state(["A", "B"]); b = increment(b, "B", 1)
    r = check_convergence(a, b)
    adapted = adapt(r)
    assert adapted.external_result == ConvergenceResult.PRECONDITION_NOT_MET
    assert not adapted.same_logical_updates
    print("PASS: PRECONDITION_NOT_MET preserved")

def test_diverged_preserved():
    updates = {UpdateId("A", 1)}
    x = GCounterState({"A": 1, "B": 0}, updates)
    y = GCounterState({"A": 0, "B": 0}, updates)
    r = check_convergence(x, y)
    adapted = adapt(r)
    assert adapted.external_result == ConvergenceResult.DIVERGED
    assert adapted.same_logical_updates
    assert not adapted.full_state_equal
    print("PASS: DIVERGED preserved")

def test_value_state_independence():
    x = GCounterState({"A": 2, "B": 1}, {UpdateId("A", 1)})
    y = GCounterState({"A": 1, "B": 2}, {UpdateId("B", 1)})
    r = check_convergence(x, y)
    adapted = adapt(r)
    assert adapted.observable_value_equal
    assert not adapted.full_state_equal
    print("PASS: value equality independent of state equality")

def test_a0_coercion_fails():
    # A0 projection alone is insufficient
    a = initial_state(["A", "B"]); a = increment(a, "A", 1)
    b = initial_state(["A", "B"]); b = increment(b, "B", 1)
    r = check_convergence(a, b)
    adapted = adapt(r)
    # Optional projection exists but full result is preserved
    assert adapted.external_result == ConvergenceResult.PRECONDITION_NOT_MET
    assert adapted.optional_status_projection == EvidenceStatus.UNRESOLVED
    # The full state relation is still attached
    assert not adapted.same_logical_updates
    print("PASS: A0 coercion fails as complete representation")

def test_temporary_divergence_not_failure():
    a = initial_state(["A", "B"]); a = increment(a, "A", 1); a = increment(a, "A", 2)
    b = initial_state(["A", "B"]); b = increment(b, "B", 1)
    r = check_convergence(a, b)
    adapted = adapt(r)
    assert adapted.external_result == ConvergenceResult.PRECONDITION_NOT_MET
    assert adapted.external_result != ConvergenceResult.DIVERGED
    print("PASS: temporary divergence not classified as DIVERGED")

def test_history_not_required():
    a = initial_state(["A", "B"]); a = increment(a, "A", 1)
    b = initial_state(["A", "B"]); b = increment(b, "B", 1)
    final_a = merge(merge(a, b), a)
    final_b = merge(b, a)
    r = check_convergence(final_a, final_b)
    adapted = adapt(r)
    assert adapted.external_result == ConvergenceResult.CONVERGED
    print("PASS: convergence does not require history identity")

def test_all_outcomes_preserved():
    cases = []
    # CONVERGED
    a = initial_state(["A", "B"]); a = increment(a, "A", 1)
    b = initial_state(["A", "B"]); b = increment(b, "B", 1)
    cases.append((check_convergence(merge(a, b), merge(b, a)), ConvergenceResult.CONVERGED))
    # PRECONDITION_NOT_MET
    cases.append((check_convergence(a, b), ConvergenceResult.PRECONDITION_NOT_MET))
    # DIVERGED
    updates = {UpdateId("A", 1)}
    x = GCounterState({"A": 1, "B": 0}, updates)
    y = GCounterState({"A": 0, "B": 0}, updates)
    cases.append((check_convergence(x, y), ConvergenceResult.DIVERGED))
    for report, expected in cases:
        adapted = adapt(report)
        assert adapted.external_result == expected
    print("PASS: all external outcomes preserved")

if __name__ == "__main__":
    test_converged_preserved()
    test_precondition_not_met_preserved()
    test_diverged_preserved()
    test_value_state_independence()
    test_a0_coercion_fails()
    test_temporary_divergence_not_failure()
    test_history_not_required()
    test_all_outcomes_preserved()
    print()
    print("ALL ADAPTER TESTS PASSED")
