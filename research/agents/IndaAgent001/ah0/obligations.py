"""Deterministic obligation-profile construction."""
from typing import List, Dict
from .models import EvidenceObligation, EvidenceStatus, ObligationDischargeStatus

def verification_status_to_result(status: str) -> bool:
    """Map verification_status to bool. Only 'verified' maps to True. All others fail closed."""
    return status == "verified"


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
        discharged = any(
            getattr(item, "claim", None) == omega.proposition
            and verification_status_to_result(getattr(item, "verification_status", ""))
            for item in evidence_items
        )
        profiles[omega.obligation_id] = (
            ObligationDischargeStatus.DISCHARGED if discharged else ObligationDischargeStatus.FAILED
        )
    return profiles
