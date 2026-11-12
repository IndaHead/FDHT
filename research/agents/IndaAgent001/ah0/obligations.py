"""Deterministic obligation-profile construction."""
from typing import List, Dict
from .models import EvidenceObligation, EvidenceStatus, ObligationDischargeStatus, EvidenceItem

def build_obligation_profiles(
    obligations: List[EvidenceObligation],
    evidence_items: List,
    candidate_status: EvidenceStatus,
) -> Dict[str, ObligationDischargeStatus]:
    profiles = {}
    for omega in obligations:
        if omega.candidate_status != candidate_status:
            profiles[omega.obligation_id] = ObligationDischargeStatus.NOT_APPLICABLE
            continue
        # Simplified: mark as DISCHARGED if any matching evidence exists
        discharged = any(
            getattr(item, "claim", None) == omega.proposition
            and getattr(item, "verification_result", False)
            for item in evidence_items
        )
        profiles[omega.obligation_id] = (
            ObligationDischargeStatus.DISCHARGED if discharged else ObligationDischargeStatus.FAILED
        )
    return profiles
