#!/usr/bin/env python3
"""Frozen external requirements for SLSA-derived artifact acceptance.

This module contains only external types and constants.
It does not import FDHT, A0, locality, or adapter modules.
"""

from dataclasses import dataclass
from typing import List, Optional, Dict, Set, Tuple
from enum import Enum

class CheckStatus(Enum):
    PASS = "PASS"
    FAIL = "FAIL"
    UNVERIFIABLE = "UNVERIFIABLE"

class ExternalResult(Enum):
    ACCEPT = "ACCEPT"
    REJECT = "REJECT"
    REVIEW = "REVIEW"

@dataclass(frozen=True)
class ProvenanceEnvelope:
    subject_artifact_id: str
    subject_digest: str
    builder_id: Optional[str]
    build_type: Optional[str]
    external_parameters: Dict[str, str]
    signature: Optional[str]
    signature_key_id: Optional[str]

@dataclass(frozen=True)
class ArtifactAcceptanceRequest:
    artifact_id: str
    artifact_digest: str
    provenance_envelope: Optional[ProvenanceEnvelope]
    expected_subject_digest: str
    accepted_builder_identities: Tuple[str, ...]
    required_build_type: str
    permitted_external_parameters: Dict[str, Tuple[str, ...]]
    available_trust_material: Optional[str]

@dataclass
class CheckResult:
    check_name: str
    status: CheckStatus
    supporting_payload: List[str]
    failed_condition: Optional[str]

@dataclass
class ExternalVerificationResult:
    request: ArtifactAcceptanceRequest
    check_results: List[CheckResult]
    final_result: ExternalResult
    supporting_payload: List[str]
    failed_checks: List[str]
    unverifiable_checks: List[str]
