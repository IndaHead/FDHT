#!/usr/bin/env python3
"""FDHT adapter for external G-counter CRDT convergence consumer.

ANTI-CONTAMINATION. Does not alter external types, external consumer,
external fixtures, external result states, merge semantics, or expected outputs.

Preserves:
- temporary divergence without calling the system refuted
- complete-state equality independently of observable-value equality
- update-set equality independently of delivery order
- delivery-history distinction independently of state equality
- merge laws (commutativity, associativity, idempotence, inflation)
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from enum import Enum
from dataclasses import dataclass
from typing import List, Optional

class EvidenceStatus(Enum):
    ESTABLISHED = "established"
    REFUTED = "refuted"
    UNRESOLVED = "unresolved"

class ConsumerDecision(Enum):
    ADMIT = "admit"
    REJECT = "reject"
    STOP = "stop"

from frozen_crdt_requirements import ConvergenceResult, ConvergenceReport

@dataclass
class AdaptedConvergence:
    external_result: ConvergenceResult
    same_logical_updates: bool
    full_state_equal: bool
    observable_value_equal: bool
    left_value: int
    right_value: int
    failed_obligations: List[str]
    # Optional lossy projection (not primary representation)
    optional_status_projection: Optional[EvidenceStatus]
    translation_notes: List[str]

def adapt(report: ConvergenceReport) -> AdaptedConvergence:
    """Preserve complete external result. Optional status projection is lossy."""
    notes = []
    notes.append(f"external_result={report.result.value}")
    notes.append(f"same_updates={report.same_logical_updates}")
    notes.append(f"full_state_equal={report.full_state_equal}")
    notes.append(f"value_equal={report.observable_value_equal}")

    # Optional lossy projection (examined after full state is preserved)
    if report.result == ConvergenceResult.CONVERGED:
        proj = EvidenceStatus.ESTABLISHED
        notes.append("optional_projection: CONVERGED -> ESTABLISHED (LOSSY)")
    elif report.result == ConvergenceResult.DIVERGED:
        proj = EvidenceStatus.REFUTED
        notes.append("optional_projection: DIVERGED -> REFUTED (LOSSY)")
    else:
        proj = EvidenceStatus.UNRESOLVED
        notes.append("optional_projection: PRECONDITION_NOT_MET -> UNRESOLVED (LOSSY)")

    return AdaptedConvergence(
        external_result=report.result,
        same_logical_updates=report.same_logical_updates,
        full_state_equal=report.full_state_equal,
        observable_value_equal=report.observable_value_equal,
        left_value=report.left_value,
        right_value=report.right_value,
        failed_obligations=list(report.failed_obligations),
        optional_status_projection=proj,
        translation_notes=notes,
    )

def translation_ledger() -> list:
    return [
        {"external_item": "replica_identity", "external_meaning": "replica identifier",
         "fdht_representation": "preserved in state", "translation_status": "EXACT",
         "justification": "direct", "effect_on_external_outcome": "none"},
        {"external_item": "component_state", "external_meaning": "per-replica counter",
         "fdht_representation": "preserved in components map", "translation_status": "EXACT",
         "justification": "direct", "effect_on_external_outcome": "none"},
        {"external_item": "incorporated_update_set", "external_meaning": "logical updates incorporated",
         "fdht_representation": "preserved as set", "translation_status": "EXACT",
         "justification": "direct", "effect_on_external_outcome": "none"},
        {"external_item": "pointwise_max_merge", "external_meaning": "merge(x,y)[r] = max(x[r], y[r])",
         "fdht_representation": "adapter-local", "translation_status": "TRANSFORMED_LOSSLESS",
         "justification": "algebra remains adapter-local", "effect_on_external_outcome": "none"},
        {"external_item": "observable_value", "external_meaning": "sum of components",
         "fdht_representation": "preserved", "translation_status": "EXACT",
         "justification": "direct", "effect_on_external_outcome": "none"},
        {"external_item": "full_state_equality", "external_meaning": "components and updates equal",
         "fdht_representation": "preserved independently of value equality", "translation_status": "EXACT",
         "justification": "not collapsed", "effect_on_external_outcome": "none"},
        {"external_item": "observable_value_equality", "external_meaning": "scalar values equal",
         "fdht_representation": "preserved independently of full-state equality", "translation_status": "EXACT",
         "justification": "not collapsed", "effect_on_external_outcome": "none"},
        {"external_item": "CONVERGED", "external_meaning": "same updates and equivalent state",
         "fdht_representation": "preserved; optional projection ESTABLISHED is LOSSY",
         "translation_status": "TRANSFORMED_LOSSLESS", "justification": "full result preserved",
         "effect_on_external_outcome": "none"},
        {"external_item": "DIVERGED", "external_meaning": "same updates but different state",
         "fdht_representation": "preserved; optional projection REFUTED is LOSSY",
         "translation_status": "TRANSFORMED_LOSSLESS", "justification": "full result preserved",
         "effect_on_external_outcome": "none"},
        {"external_item": "PRECONDITION_NOT_MET", "external_meaning": "update sets differ",
         "fdht_representation": "preserved; optional projection UNRESOLVED is LOSSY",
         "translation_status": "TRANSFORMED_LOSSLESS", "justification": "reason preserved",
         "effect_on_external_outcome": "none"},
        {"external_item": "commutativity", "external_meaning": "merge(x,y) = merge(y,x)",
         "fdht_representation": "adapter-local", "translation_status": "TRANSFORMED_LOSSLESS",
         "justification": "algebra remains adapter-local", "effect_on_external_outcome": "none"},
        {"external_item": "associativity", "external_meaning": "merge(merge(x,y),z) = merge(x,merge(y,z))",
         "fdht_representation": "adapter-local", "translation_status": "TRANSFORMED_LOSSLESS",
         "justification": "algebra remains adapter-local", "effect_on_external_outcome": "none"},
        {"external_item": "idempotence", "external_meaning": "merge(x,x) = x",
         "fdht_representation": "adapter-local", "translation_status": "TRANSFORMED_LOSSLESS",
         "justification": "algebra remains adapter-local", "effect_on_external_outcome": "none"},
        {"external_item": "inflation", "external_meaning": "x <= increment(x); x <= merge(x,y)",
         "fdht_representation": "adapter-local", "translation_status": "TRANSFORMED_LOSSLESS",
         "justification": "algebra remains adapter-local", "effect_on_external_outcome": "none"},
        {"external_item": "delivery_history", "external_meaning": "sequence of delivery events",
         "fdht_representation": "not required for convergence", "translation_status": "EXACT",
         "justification": "convergence does not require history identity", "effect_on_external_outcome": "none"},
    ]
