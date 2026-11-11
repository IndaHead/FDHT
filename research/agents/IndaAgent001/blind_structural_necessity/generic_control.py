#!/usr/bin/env python3
"""Generic control arm for BSN0.

Receives only visible specification and visible fixtures.
Uses only conventional structures: TypedRecord, Event, State, Relation,
History, Provenance, Projection, Result.

Must NOT import FDHT, A0, FoldKernel, TrajectoryBoundary, locality,
or external-consumer adapters.
Must NOT import oracle_external_system.py or read hidden_fixtures.json.
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from prediction_schema import StructuralPrediction, PredictedRelation
from visible_external_spec import get_visible_spec
import json

def load_visible_fixtures():
    path = os.path.join(os.path.dirname(__file__), "visible_fixtures.json")
    with open(path) as f:
        return json.load(f)

def generic_predict() -> list:
    """Generate predictions from visible information only.
    
    Generic reasoning uses ordinary logical analysis of visible types,
    transitions, and fixtures.
    """
    spec = get_visible_spec()
    fixtures = load_visible_fixtures()
    predictions = []

    # P1: Value vs internal tag
    predictions.append(StructuralPrediction(
        prediction_id="GEN_P1",
        object_or_relation="state_fields",
        distinction_a="value",
        distinction_b="path_tag",
        predicted_relation=PredictedRelation.MUST_REMAIN_DISTINCT,
        justification="Visible fixture shows two states with equal value but different tags. If the tag is present in the data, it may carry information not captured by the value alone.",
        visible_evidence="v4_equal_projection shows same value, different tags",
        predicted_failure_if_wrong="Consumer may miss a distinction encoded in the tag",
        confidence_basis="Ordinary data-structure reasoning",
    ))

    # P2: Temporary partition
    predictions.append(StructuralPrediction(
        prediction_id="GEN_P2",
        object_or_relation="partition_state",
        distinction_a="temporary_disagreement",
        distinction_b="permanent_failure",
        predicted_relation=PredictedRelation.MUST_REMAIN_DISTINCT,
        justification="Visible partition example shows independent states. No visible rule says disagreement is failure. Ordinary distributed-systems reasoning treats temporary divergence as normal.",
        visible_evidence="v2_partition shows different values",
        predicted_failure_if_wrong="Valid intermediate states may be rejected",
        confidence_basis="Ordinary distributed-systems reasoning",
    ))

    # P3: Merge order
    predictions.append(StructuralPrediction(
        prediction_id="GEN_P3",
        object_or_relation="merge_order",
        distinction_a="merge(a,b)",
        distinction_b="merge(b,a)",
        predicted_relation=PredictedRelation.MAY_COLLAPSE_FOR_CONSUMER,
        justification="Visible merge takes maximum. max(a,b) = max(b,a). Order likely does not affect consumer-visible result.",
        visible_evidence="merge_example describes max-value merge",
        predicted_failure_if_wrong="None if merge is commutative",
        confidence_basis="Ordinary arithmetic reasoning",
    ))

    # P4: Merge count
    predictions.append(StructuralPrediction(
        prediction_id="GEN_P4",
        object_or_relation="merge_count",
        distinction_a="merge_count_0",
        distinction_b="merge_count_3",
        predicted_relation=PredictedRelation.UNKNOWN,
        justification="Visible spec does not state a consumer rule for merge_count. Cannot determine significance from visible information.",
        visible_evidence="merge_count appears in data but no rule stated",
        predicted_failure_if_wrong="Unknown",
        confidence_basis="Insufficient visible evidence",
    ))

    # P5: History identity
    predictions.append(StructuralPrediction(
        prediction_id="GEN_P5",
        object_or_relation="history_vs_state",
        distinction_a="delivery_history",
        distinction_b="final_state",
        predicted_relation=PredictedRelation.MAY_COLLAPSE_FOR_CONSUMER,
        justification="Visible merge produces a result. No visible rule requires preserving input order for the consumer. Ordinary reasoning suggests final state may suffice.",
        visible_evidence="merge produces single result",
        predicted_failure_if_wrong="None if consumer only needs final state",
        confidence_basis="Ordinary state-machine reasoning",
    ))

    return predictions
