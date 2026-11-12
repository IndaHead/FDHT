"""Deterministic EOP0-compatible evidence evaluator."""
from typing import List
from .models import EvidenceStatus, EvidenceObligation, ObligationDischargeStatus

def evaluate_status(
    obligations: List[EvidenceObligation],
    profiles: dict,
    opposing_ids: List[str],
) -> EvidenceStatus:
    established_ok = all(
        profiles.get(o.obligation_id) == ObligationDischargeStatus.DISCHARGED
        for o in obligations
        if o.candidate_status == EvidenceStatus.ESTABLISHED and o.mandatory
    )
    refuted_ok = all(
        profiles.get(o.obligation_id) == ObligationDischargeStatus.DISCHARGED
        for o in obligations
        if o.candidate_status == EvidenceStatus.REFUTED and o.mandatory
    )
    has_blocker = bool(opposing_ids)
    if established_ok and not refuted_ok and not has_blocker:
        return EvidenceStatus.ESTABLISHED
    if refuted_ok and not established_ok:
        return EvidenceStatus.REFUTED
    return EvidenceStatus.UNRESOLVED
