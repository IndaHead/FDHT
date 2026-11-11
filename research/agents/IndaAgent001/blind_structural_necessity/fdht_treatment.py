#!/usr/bin/env python3
"""FDHT treatment arm for BSN0.

Receives only visible specification and visible fixtures.
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

def fdht_predict() -> list:
    """Generate predictions from visible information only.
    
    FDHT reasoning uses: history, trajectory, state, projection,
    equivalence, provenance, scope, transformation, consumer dependency.
    """
    spec = get_visible_spec()
    fixtures = load_visible_fixtures()
    predictions = []

    # P1: Value vs internal tag
    predictions.append(StructuralPrediction(
        prediction_id="FDHT_P1",
        object_or_relation="state_fields",
        distinction_a="value",
        distinction_b="path_tag",
        predicted_relation=PredictedRelation.MUST_REMAIN_DISTINCT,
        justification="Visible equal_projection example shows two states with same value but different tags. FDHT projection discipline requires distinguishing projected equality from full-state equality.",
        visible_evidence="v4_equal_projection shows x and y with same value but different tags",
        predicted_failure_if_wrong="Consumer may accept a state that fails a later path-sensitive check",
        confidence_basis="FDHT projection != full state principle",
    ))

    # P2: Temporary partition
    predictions.append(StructuralPrediction(
        prediction_id="FDHT_P2",
        object_or_relation="partition_state",
        distinction_a="temporary_disagreement",
        distinction_b="permanent_failure",
        predicted_relation=PredictedRelation.MUST_REMAIN_DISTINCT,
        justification="Visible partition example shows independent states with different values. FDHT does not treat temporary divergence as failure.",
        visible_evidence="v2_partition shows two states with different projections",
        predicted_failure_if_wrong="Valid intermediate states may be rejected",
        confidence_basis="FDHT temporary divergence != failure",
    ))

    # P3: Merge order
    predictions.append(StructuralPrediction(
        prediction_id="FDHT_P3",
        object_or_relation="merge_order",
        distinction_a="merge(a,b)",
        distinction_b="merge(b,a)",
        predicted_relation=PredictedRelation.MAY_COLLAPSE_FOR_CONSUMER,
        justification="Visible merge takes maximum value. Order may not affect consumer-visible output.",
        visible_evidence="merge_example shows max-value merge",
        predicted_failure_if_wrong="None if merge is commutative for consumer",
        confidence_basis="Visible merge semantics",
    ))

    # P4: Merge count
    predictions.append(StructuralPrediction(
        prediction_id="FDHT_P4",
        object_or_relation="merge_count",
        distinction_a="merge_count_0",
        distinction_b="merge_count_3",
        predicted_relation=PredictedRelation.UNKNOWN,
        justification="Visible spec does not state whether merge_count has consumer significance. FDHT cannot determine from visible information alone.",
        visible_evidence="merge_count appears in fixture data but no consumer rule stated",
        predicted_failure_if_wrong="Unknown",
        confidence_basis="Insufficient visible evidence",
    ))

    # P5: History identity for convergence
    predictions.append(StructuralPrediction(
        prediction_id="FDHT_P5",
        object_or_relation="history_vs_state",
        distinction_a="delivery_history",
        distinction_b="final_state",
        predicted_relation=PredictedRelation.MAY_COLLAPSE_FOR_CONSUMER,
        justification="FDHT distinguishes history from state. Visible merge produces equivalent states from different paths. History identity may not be required for consumer.",
        visible_evidence="merge produces single result regardless of input order",
        predicted_failure_if_wrong="None if consumer only needs final state",
        confidence_basis="FDHT history != state equivalence",
    ))

    return predictions
