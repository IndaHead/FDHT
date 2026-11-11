#!/usr/bin/env python3
"""External state-based G-counter CRDT consumer.

INDEPENDENT. Does not import FDHT, A0, locality, SLSA, or adapter modules.
Operates only from frozen external requirements and external fixtures.
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from frozen_crdt_requirements import (
    ReplicaId, UpdateId, GCounterState, DeliveryEvent, Replica,
    ConvergenceResult, ConvergenceReport,
)
from typing import Dict, Set, List, Optional

def initial_state(replica_ids: List[str]) -> GCounterState:
    return GCounterState(
        components={rid: 0 for rid in replica_ids},
        incorporated_updates=set(),
    )

def increment(state: GCounterState, replica_id: str, seq: int) -> GCounterState:
    """Local increment. Increases only the local component."""
    new_state = state.copy()
    new_state.components[replica_id] = new_state.components.get(replica_id, 0) + 1
    new_state.incorporated_updates.add(UpdateId(replica_id, seq))
    return new_state

def merge(x: GCounterState, y: GCounterState) -> GCounterState:
    """Pointwise maximum merge. No addition, no timestamps, no ordering."""
    all_replicas = set(x.components.keys()) | set(y.components.keys())
    merged_components = {}
    for r in all_replicas:
        merged_components[r] = max(x.components.get(r, 0), y.components.get(r, 0))
    merged_updates = x.incorporated_updates | y.incorporated_updates
    return GCounterState(components=merged_components, incorporated_updates=merged_updates)

def value(state: GCounterState) -> int:
    """Observable scalar value. Not equal to complete state."""
    return sum(state.components.values())

def partial_order_leq(x: GCounterState, y: GCounterState) -> bool:
    """x <= y iff for every component, x[r] <= y[r]."""
    all_replicas = set(x.components.keys()) | set(y.components.keys())
    return all(x.components.get(r, 0) <= y.components.get(r, 0) for r in all_replicas)

def states_equal(x: GCounterState, y: GCounterState) -> bool:
    return x.components == y.components and x.incorporated_updates == y.incorporated_updates

def check_convergence(left: GCounterState, right: GCounterState) -> ConvergenceReport:
    same_updates = left.incorporated_updates == right.incorporated_updates
    full_equal = states_equal(left, right)
    val_equal = value(left) == value(right)

    if not same_updates:
        result = ConvergenceResult.PRECONDITION_NOT_MET
    elif full_equal:
        result = ConvergenceResult.CONVERGED
    else:
        result = ConvergenceResult.DIVERGED

    return ConvergenceReport(
        result=result,
        same_logical_updates=same_updates,
        full_state_equal=full_equal,
        observable_value_equal=val_equal,
        left_state=left,
        right_state=right,
        left_value=value(left),
        right_value=value(right),
        supporting_payload=[f"updates_equal:{same_updates}", f"state_equal:{full_equal}", f"value_equal:{val_equal}"],
        failed_obligations=[],
    )

def broken_additive_merge(x: GCounterState, y: GCounterState) -> GCounterState:
    """Test-only invalid merge that adds instead of taking max."""
    all_replicas = set(x.components.keys()) | set(y.components.keys())
    merged_components = {}
    for r in all_replicas:
        merged_components[r] = x.components.get(r, 0) + y.components.get(r, 0)
    merged_updates = x.incorporated_updates | y.incorporated_updates
    return GCounterState(components=merged_components, incorporated_updates=merged_updates)

def broken_lost_component_merge(x: GCounterState, y: GCounterState) -> GCounterState:
    """Test-only invalid merge that discards replica B's component."""
    merged = merge(x, y)
    merged.components.pop("B", None)
    return merged
