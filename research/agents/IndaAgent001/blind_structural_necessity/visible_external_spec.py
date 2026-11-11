#!/usr/bin/env python3
"""Visible external specification for BSN0.

INCOMPLETE BUT HONEST. Exposes enough to reason but does not reveal
hidden invariants or hidden fixture expected outcomes.

Treatment and control arms may import this module.
They must NOT import oracle_external_system.py.
"""

from dataclasses import dataclass
from typing import Dict, Any

@dataclass
class VisibleState:
    """Public state representation. Does not reveal all internal fields."""
    value: int
    # path_tag and merge_count are present in the data but their
    # consumer significance is not stated here.

@dataclass
class VisibleTransition:
    name: str
    description: str

VISIBLE_TRANSITIONS = [
    VisibleTransition("increment", "Increases the value by a given amount"),
    VisibleTransition("merge", "Combines two states, taking the maximum value"),
]

VISIBLE_PROJECTION = "The consumer-visible output is the integer value field."

VISIBLE_EXAMPLES = {
    "increment_example": "A state with value 0 incremented by 5 yields value 5.",
    "merge_example": "Merging value 5 with value 3 yields value 5.",
    "partition_example": "Two independent states may temporarily hold different values.",
    "equal_projection_example": "Two states may have the same value but different internal tags.",
}

def get_visible_spec() -> Dict[str, Any]:
    return {
        "transitions": [(t.name, t.description) for t in VISIBLE_TRANSITIONS],
        "projection": VISIBLE_PROJECTION,
        "examples": VISIBLE_EXAMPLES,
    }
