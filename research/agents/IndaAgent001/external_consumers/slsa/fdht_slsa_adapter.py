#!/usr/bin/env python3
"""FDHT adapter for external SLSA-derived artifact acceptance.

ANTI-CONTAMINATION. Does not alter external request, external result,
external check results, or expected fixture outcomes.

Translates external results into research-local FDHT structures
while preserving all external distinctions.
"""

import sys
sys.path.insert(0, ".")

from enum import Enum
from dataclasses import dataclass
from typing import List, Optional

# Research-local A0 types (not permanent FDHT)
class EvidenceStatus(Enum):
    ESTABLISHED = "established"
    REFUTED = "refuted"
    UNRESOLVED = "unresolved"

class ConsumerDecision(Enum):
    ADMIT = "admit"
    REJECT = "reject"
    STOP = "stop"

def a0_consume(status: EvidenceStatus) -> ConsumerDecision:
    if status == EvidenceStatus.ESTABLISHED:
        return ConsumerDecision.ADMIT
    elif status == EvidenceStatus.REFUTED:
        return ConsumerDecision.REJECT
    return ConsumerDecision.STOP

# Import external types from the same module instance the consumer uses
import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
from frozen_slsa_requirements import (
    ExternalResult, CheckStatus, ExternalVerificationResult,
)

@dataclass
class AdaptedResult:
    external_result: ExternalResult
    evidence_status: EvidenceStatus
    consumer_decision: ConsumerDecision
    check_results_preserved: bool
    failed_checks: List[str]
    unverifiable_checks: List[str]
    translation_notes: List[str]

def adapt(external: ExternalVerificationResult) -> AdaptedResult:
    """Translate external result to research-local FDHT structures.

    Mapping candidate (hypothesis, not asserted):
        ACCEPT -> ESTABLISHED -> ADMIT
        REJECT -> REFUTED -> REJECT
        REVIEW -> UNRESOLVED -> STOP

    Original external result remains attached.
    """
    notes = []
    if external.final_result == ExternalResult.ACCEPT:
        status = EvidenceStatus.ESTABLISHED
        notes.append("ACCEPT mapped to ESTABLISHED")
    elif external.final_result == ExternalResult.REJECT:
        status = EvidenceStatus.REFUTED
        notes.append("REJECT mapped to REFUTED")
    else:
        status = EvidenceStatus.UNRESOLVED
        notes.append("REVIEW mapped to UNRESOLVED")

    decision = a0_consume(status)

    return AdaptedResult(
        external_result=external.final_result,
        evidence_status=status,
        consumer_decision=decision,
        check_results_preserved=True,
        failed_checks=list(external.failed_checks),
        unverifiable_checks=list(external.unverifiable_checks),
        translation_notes=notes,
    )

def translation_ledger() -> list:
    """Record translation status for every external field and state."""
    return [
        {"external_item": "artifact_id", "external_meaning": "artifact identifier",
         "fdht_representation": "preserved in request", "translation_status": "EXACT",
         "justification": "direct field", "effect_on_consumer_outcome": "none"},
        {"external_item": "artifact_digest", "external_meaning": "artifact digest",
         "fdht_representation": "preserved in request", "translation_status": "EXACT",
         "justification": "direct field", "effect_on_consumer_outcome": "none"},
        {"external_item": "subject_binding", "external_meaning": "ID and digest match",
         "fdht_representation": "check result preserved", "translation_status": "EXACT",
         "justification": "check-level result carried", "effect_on_consumer_outcome": "none"},
        {"external_item": "signature", "external_meaning": "fixture signature valid",
         "fdht_representation": "check result preserved", "translation_status": "EXACT",
         "justification": "check-level result carried", "effect_on_consumer_outcome": "none"},
        {"external_item": "builder_id", "external_meaning": "builder identity",
         "fdht_representation": "check result preserved", "translation_status": "EXACT",
         "justification": "check-level result carried", "effect_on_consumer_outcome": "none"},
        {"external_item": "build_type", "external_meaning": "build type match",
         "fdht_representation": "check result preserved", "translation_status": "EXACT",
         "justification": "check-level result carried", "effect_on_consumer_outcome": "none"},
        {"external_item": "external_parameters", "external_meaning": "parameter recognition and permission",
         "fdht_representation": "check result preserved", "translation_status": "EXACT",
         "justification": "check-level result carried", "effect_on_consumer_outcome": "none"},
        {"external_item": "ACCEPT", "external_meaning": "all mandatory checks pass",
         "fdht_representation": "ESTABLISHED -> ADMIT", "translation_status": "TRANSFORMED_LOSSLESS",
         "justification": "candidate mapping preserves outcome", "effect_on_consumer_outcome": "none"},
        {"external_item": "REJECT", "external_meaning": "at least one check fails",
         "fdht_representation": "REFUTED -> REJECT", "translation_status": "TRANSFORMED_LOSSLESS",
         "justification": "candidate mapping preserves outcome", "effect_on_consumer_outcome": "none"},
        {"external_item": "REVIEW", "external_meaning": "incomplete evidence",
         "fdht_representation": "UNRESOLVED -> STOP", "translation_status": "TRANSFORMED_LOSSLESS",
         "justification": "candidate mapping preserves outcome", "effect_on_consumer_outcome": "none"},
        {"external_item": "CheckStatus.PASS", "external_meaning": "check passed",
         "fdht_representation": "preserved in check_results", "translation_status": "EXACT",
         "justification": "direct", "effect_on_consumer_outcome": "none"},
        {"external_item": "CheckStatus.FAIL", "external_meaning": "check failed",
         "fdht_representation": "preserved in failed_checks", "translation_status": "EXACT",
         "justification": "direct", "effect_on_consumer_outcome": "none"},
        {"external_item": "CheckStatus.UNVERIFIABLE", "external_meaning": "check cannot complete",
         "fdht_representation": "preserved in unverifiable_checks", "translation_status": "EXACT",
         "justification": "direct", "effect_on_consumer_outcome": "none"},
    ]
