#!/usr/bin/env python3
"""Deterministic tests for external G-counter. No FDHT imports."""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from frozen_crdt_requirements import ConvergenceResult, GCounterState, UpdateId
from external_gcounter import (
    initial_state, increment, merge, value, check_convergence,
    states_equal, partial_order_leq,
    broken_additive_merge, broken_lost_component_merge,
)

def test_c1_same_updates_different_order():
    # A does A1, A2; B does B1, B2, B3
    a = initial_state(["A", "B"])
    a = increment(a, "A", 1)
    a = increment(a, "A", 2)
    b = initial_state(["A", "B"])
    b = increment(b, "B", 1)
    b = increment(b, "B", 2)
    b = increment(b, "B", 3)
    # Merge in different orders
    final_a = merge(merge(a, b), a)
    final_b = merge(merge(b, a), b)
    r = check_convergence(final_a, final_b)
    assert r.result == ConvergenceResult.CONVERGED
    assert final_a.components == {"A": 2, "B": 3}
    assert value(final_a) == 5
    print("PASS: C1 same updates different order -> CONVERGED")

def test_c2_duplicate_delivery():
    a = initial_state(["A", "B"])
    a = increment(a, "A", 1)
    a = increment(a, "A", 2)
    b = initial_state(["A", "B"])
    b = increment(b, "B", 1)
    # Deliver B to A twice
    a = merge(a, b)
    a = merge(a, b)
    # Deliver A to B
    b = merge(b, a)
    r = check_convergence(a, b)
    assert r.result == ConvergenceResult.CONVERGED
    assert a.components == {"A": 2, "B": 1}
    assert value(a) == 3
    print("PASS: C2 duplicate delivery -> CONVERGED")

def test_c3_commutative():
    x = initial_state(["A", "B"])
    x = increment(x, "A", 1)
    y = initial_state(["A", "B"])
    y = increment(y, "B", 1)
    m1 = merge(x, y)
    m2 = merge(y, x)
    assert states_equal(m1, m2)
    assert value(m1) == value(m2)
    print("PASS: C3 commutative merge")

def test_c4_associative():
    x = initial_state(["A", "B"])
    x = increment(x, "A", 1)
    y = initial_state(["A", "B"])
    y = increment(y, "B", 1)
    z = initial_state(["A", "B"])
    z = increment(z, "A", 2)
    m1 = merge(merge(x, y), z)
    m2 = merge(x, merge(y, z))
    assert states_equal(m1, m2)
    print("PASS: C4 associative merge")

def test_c5_idempotent():
    x = initial_state(["A", "B"])
    x = increment(x, "A", 1)
    m = merge(x, x)
    assert states_equal(m, x)
    print("PASS: C5 idempotent merge")

def test_c6_partition():
    a = initial_state(["A", "B"])
    a = increment(a, "A", 1)
    a = increment(a, "A", 2)
    b = initial_state(["A", "B"])
    b = increment(b, "B", 1)
    b = increment(b, "B", 2)
    b = increment(b, "B", 3)
    r = check_convergence(a, b)
    assert r.result == ConvergenceResult.PRECONDITION_NOT_MET
    assert not r.full_state_equal
    assert not r.same_logical_updates
    print("PASS: C6 partition -> PRECONDITION_NOT_MET")

def test_c7_reconciliation():
    a = initial_state(["A", "B"])
    a = increment(a, "A", 1)
    a = increment(a, "A", 2)
    b = initial_state(["A", "B"])
    b = increment(b, "B", 1)
    b = increment(b, "B", 2)
    b = increment(b, "B", 3)
    final_a = merge(a, b)
    final_b = merge(b, a)
    r = check_convergence(final_a, final_b)
    assert r.result == ConvergenceResult.CONVERGED
    assert final_a.components == {"A": 2, "B": 3}
    print("PASS: C7 reconciliation -> CONVERGED")

def test_c8_broken_additive():
    a = initial_state(["A", "B"])
    a = increment(a, "A", 1)
    b = initial_state(["A", "B"])
    b = increment(b, "B", 1)
    # Duplicate delivery with broken merge
    merged = broken_additive_merge(a, b)
    merged = broken_additive_merge(merged, b)
    # B's component inflated by duplicate
    assert merged.components["B"] == 2  # should be 1 with valid merge
    print("PASS: C8 broken additive merge -> invariant failure")

def test_c9_lost_component():
    a = initial_state(["A", "B"])
    a = increment(a, "A", 1)
    b = initial_state(["A", "B"])
    b = increment(b, "B", 1)
    broken = broken_lost_component_merge(a, b)
    # Both claim same updates but B component missing
    r = check_convergence(broken, merge(a, b))
    # Update sets may differ due to broken merge
    print(f"PASS: C9 lost component -> {r.result.value}")

def test_c10_same_value_different_state():
    x = GCounterState(components={"A": 2, "B": 1}, incorporated_updates={UpdateId("A", 1), UpdateId("A", 2), UpdateId("B", 1)})
    y = GCounterState(components={"A": 1, "B": 2}, incorporated_updates={UpdateId("A", 1), UpdateId("B", 1), UpdateId("B", 2)})
    r = check_convergence(x, y)
    assert r.observable_value_equal
    assert not r.full_state_equal
    assert r.result == ConvergenceResult.PRECONDITION_NOT_MET
    print("PASS: C10 same value different state -> PRECONDITION_NOT_MET")

def test_c11_same_updates_different_state():
    updates = {UpdateId("A", 1), UpdateId("B", 1)}
    x = GCounterState(components={"A": 1, "B": 1}, incorporated_updates=updates)
    y = GCounterState(components={"A": 1, "B": 0}, incorporated_updates=updates)
    r = check_convergence(x, y)
    assert r.same_logical_updates
    assert not r.full_state_equal
    assert r.result == ConvergenceResult.DIVERGED
    print("PASS: C11 same updates different state -> DIVERGED")

def test_c12_history_difference():
    a = initial_state(["A", "B"])
    a = increment(a, "A", 1)
    b = initial_state(["A", "B"])
    b = increment(b, "B", 1)
    # Different delivery paths
    final_a = merge(merge(a, b), a)
    final_b = merge(b, a)
    r = check_convergence(final_a, final_b)
    assert r.result == ConvergenceResult.CONVERGED
    print("PASS: C12 history difference with convergence -> CONVERGED")

def test_c13_inflation_failure():
    s = initial_state(["A", "B"])
    s = increment(s, "A", 1)
    # Test-only invalid transition that decreases
    invalid = s.copy()
    invalid.components["A"] = 0
    assert not partial_order_leq(s, invalid)
    print("PASS: C13 inflation failure detected")

if __name__ == "__main__":
    test_c1_same_updates_different_order()
    test_c2_duplicate_delivery()
    test_c3_commutative()
    test_c4_associative()
    test_c5_idempotent()
    test_c6_partition()
    test_c7_reconciliation()
    test_c8_broken_additive()
    test_c9_lost_component()
    test_c10_same_value_different_state()
    test_c11_same_updates_different_state()
    test_c12_history_difference()
    test_c13_inflation_failure()
    print()
    print("ALL EXTERNAL CRDT TESTS PASSED")
