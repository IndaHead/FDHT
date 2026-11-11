#!/usr/bin/env python3
"""Neutral prediction schema for BSN0.

Both FDHT treatment and generic control must use this exact schema.
No arm may add extra categories.
"""

from dataclasses import dataclass
from typing import List
from enum import Enum

class PredictedRelation(Enum):
    MUST_REMAIN_DISTINCT = "MUST_REMAIN_DISTINCT"
    MAY_COLLAPSE_FOR_CONSUMER = "MAY_COLLAPSE_FOR_CONSUMER"
    REQUIRED_EQUIVALENCE = "REQUIRED_EQUIVALENCE"
    IRRELEVANT_TO_CONSUMER = "IRRELEVANT_TO_CONSUMER"
    UNKNOWN = "UNKNOWN"

@dataclass
class StructuralPrediction:
    prediction_id: str
    object_or_relation: str
    distinction_a: str
    distinction_b: str
    predicted_relation: PredictedRelation
    justification: str
    visible_evidence: str
    predicted_failure_if_wrong: str
    confidence_basis: str
