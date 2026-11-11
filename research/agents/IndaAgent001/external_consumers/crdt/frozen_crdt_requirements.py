#!/usr/bin/env python3
"""Frozen external requirements for state-based G-counter CRDT.

This module contains only external types and constants.
It does not import FDHT, A0, locality, SLSA, or adapter modules.
"""

from dataclasses import dataclass, field
from typing import Dict, Set, Tuple, Optional, List
from enum import Enum

class ConvergenceResult(Enum):
    CONVERGED = "CONVERGED"
    DIVERGED = "DIVERGED"
    PRECONDITION_NOT_MET = "PRECONDITION_NOT_MET"

@dataclass(frozen=True)
class ReplicaId:
    identifier: str

@dataclass(frozen=True)
class UpdateId:
    replica_id: str
    local_sequence_number: int

@dataclass
class GCounterState:
    components: Dict[str, int] = field(default_factory=dict)
    incorporated_updates: Set[UpdateId] = field(default_factory=set)

    def copy(self):
        return GCounterState(
            components=dict(self.components),
            incorporated_updates=set(self.incorporated_updates),
        )

@dataclass
class DeliveryEvent:
    event_id: str
    sender: str
    receiver: str
    delivered_state: GCounterState
    sequence_number: int

@dataclass
class Replica:
    replica_id: str
    state: GCounterState
    delivery_history: List[DeliveryEvent] = field(default_factory=list)

@dataclass
class ConvergenceReport:
    result: ConvergenceResult
    same_logical_updates: bool
    full_state_equal: bool
    observable_value_equal: bool
    left_state: GCounterState
    right_state: GCounterState
    left_value: int
    right_value: int
    supporting_payload: List[str]
    failed_obligations: List[str]
