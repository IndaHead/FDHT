"""Frozen fixture-level OracleResult (hidden from reasoner)."""
from pydantic import BaseModel
from typing import List
from .models import EvidenceStatus, ConsumerDecision

class OracleResult(BaseModel):
    fixture_id: str
    expected_status: EvidenceStatus
    expected_decision: ConsumerDecision
    minimally_relevant_record_ids: List[str]
    earliest_justified_terminal_step: int
