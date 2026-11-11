"""
Evidence Obligation Proof-of-Concept for EOP0.

Probe-local only. No permanent FDHT imports.
"""

from enum import Enum
from dataclasses import dataclass
from typing import List, Optional

class EvidenceStatus(Enum):
    ESTABLISHED = "ESTABLISHED"
    REFUTED = "REFUTED"
    UNRESOLVED = "UNRESOLVED"

class ObligationStatus(Enum):
    DISCHARGED = "DISCHARGED"
    FAILED = "FAILED"
    UNVERIFIABLE = "UNVERIFIABLE"
    NOT_APPLICABLE = "NOT_APPLICABLE"

@dataclass
class EvidenceObligation:
    obligation_id: str
    requirement_id: str
    applies_to_status: EvidenceStatus
    proposition: str
    required_scope: str
    provenance_requirement: str
    verifier_id: str
    mandatory: bool

@dataclass
class EvidenceItem:
    item_id: str
    claim: str
    polarity: bool
    source_id: str
    provenance: str
    scope: str
    assumptions: List[str]
    verifier_id: str
    verification_result: bool

def discharges_at(item: EvidenceItem, omega: EvidenceObligation) -> bool:
    return (
        item.verification_result and
        item.scope == omega.required_scope and
        item.provenance == omega.provenance_requirement and
        item.verifier_id == omega.verifier_id and
        item.claim == omega.proposition
    )

def all_mandatory_discharged(payload: List[EvidenceItem], obligations: List[EvidenceObligation], status: EvidenceStatus) -> bool:
    applicable = [o for o in obligations if o.applies_to_status == status and o.mandatory]
    if not applicable:
        return False
    for omega in applicable:
        if not any(discharges_at(item, omega) for item in payload):
            return False
    return True

def blocked(payload: List[EvidenceItem], status: EvidenceStatus) -> bool:
    # Opposing evidence blocks
    if status == EvidenceStatus.ESTABLISHED:
        return any(not item.polarity and item.verification_result for item in payload)
    if status == EvidenceStatus.REFUTED:
        return any(item.polarity and item.verification_result for item in payload)
    return False

def status_admissible(payload: List[EvidenceItem], obligations: List[EvidenceObligation], status: EvidenceStatus) -> bool:
    return all_mandatory_discharged(payload, obligations, status) and not blocked(payload, status)

def judge(payload: List[EvidenceItem], obligations: List[EvidenceObligation]) -> EvidenceStatus:
    est_ok = status_admissible(payload, obligations, EvidenceStatus.ESTABLISHED)
    ref_ok = status_admissible(payload, obligations, EvidenceStatus.REFUTED)
    if est_ok and not ref_ok:
        return EvidenceStatus.ESTABLISHED
    if ref_ok and not est_ok:
        return EvidenceStatus.REFUTED
    return EvidenceStatus.UNRESOLVED
