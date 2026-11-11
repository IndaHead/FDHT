#!/usr/bin/env python3
"""External SLSA-derived software-artifact acceptance consumer.

INDEPENDENT. Does not import FDHT, A0, locality, or adapter modules.
Operates only from frozen external requirements, fixture request,
fixture provenance, and fixture trust material.
"""

import hmac
import hashlib
from typing import List, Optional

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from frozen_slsa_requirements import (
    CheckStatus, ExternalResult,
    ProvenanceEnvelope, ArtifactAcceptanceRequest,
    CheckResult, ExternalVerificationResult,
)

def fixture_signature(key: str, message: str) -> str:
    """Deterministic fixture-local HMAC-SHA256. Not production cryptography."""
    return hmac.new(key.encode(), message.encode(), hashlib.sha256).hexdigest()[:16]

def check_subject_binding(req: ArtifactAcceptanceRequest) -> CheckResult:
    env = req.provenance_envelope
    if env is None:
        return CheckResult("subject_binding", CheckStatus.UNVERIFIABLE, [], "provenance absent")
    if not env.subject_artifact_id or not env.subject_digest:
        return CheckResult("subject_binding", CheckStatus.UNVERIFIABLE, [], "subject unreadable")
    if env.subject_artifact_id != req.artifact_id:
        return CheckResult("subject_binding", CheckStatus.FAIL, [f"id:{env.subject_artifact_id}"], "artifact ID mismatch")
    if env.subject_digest != req.expected_subject_digest:
        return CheckResult("subject_binding", CheckStatus.FAIL, [f"digest:{env.subject_digest}"], "digest mismatch")
    return CheckResult("subject_binding", CheckStatus.PASS, [f"id:{env.subject_artifact_id}", f"digest:{env.subject_digest}"], None)

def check_signature(req: ArtifactAcceptanceRequest) -> CheckResult:
    env = req.provenance_envelope
    if env is None:
        return CheckResult("signature", CheckStatus.UNVERIFIABLE, [], "provenance absent")
    if not env.signature or not env.signature_key_id:
        return CheckResult("signature", CheckStatus.UNVERIFIABLE, [], "signature fields absent")
    if not req.available_trust_material:
        return CheckResult("signature", CheckStatus.UNVERIFIABLE, [], "trust material absent")
    expected = fixture_signature(req.available_trust_material, f"{env.subject_artifact_id}:{env.subject_digest}")
    if env.signature == expected:
        return CheckResult("signature", CheckStatus.PASS, [f"key:{env.signature_key_id}"], None)
    return CheckResult("signature", CheckStatus.FAIL, [f"sig:{env.signature}"], "signature invalid")

def check_builder(req: ArtifactAcceptanceRequest) -> CheckResult:
    env = req.provenance_envelope
    if env is None:
        return CheckResult("builder", CheckStatus.UNVERIFIABLE, [], "provenance absent")
    if not env.builder_id:
        return CheckResult("builder", CheckStatus.UNVERIFIABLE, [], "builder identity absent")
    if env.builder_id in req.accepted_builder_identities:
        return CheckResult("builder", CheckStatus.PASS, [f"builder:{env.builder_id}"], None)
    return CheckResult("builder", CheckStatus.FAIL, [f"builder:{env.builder_id}"], "builder not accepted")

def check_build_type(req: ArtifactAcceptanceRequest) -> CheckResult:
    env = req.provenance_envelope
    if env is None:
        return CheckResult("build_type", CheckStatus.UNVERIFIABLE, [], "provenance absent")
    if not env.build_type:
        return CheckResult("build_type", CheckStatus.UNVERIFIABLE, [], "build_type absent")
    if env.build_type == req.required_build_type:
        return CheckResult("build_type", CheckStatus.PASS, [f"type:{env.build_type}"], None)
    return CheckResult("build_type", CheckStatus.FAIL, [f"type:{env.build_type}"], "build_type mismatch")

def check_external_parameters(req: ArtifactAcceptanceRequest) -> CheckResult:
    env = req.provenance_envelope
    if env is None:
        return CheckResult("external_parameters", CheckStatus.UNVERIFIABLE, [], "provenance absent")
    if env.external_parameters is None:
        return CheckResult("external_parameters", CheckStatus.UNVERIFIABLE, [], "parameters absent")
    for name, value in env.external_parameters.items():
        if name not in req.permitted_external_parameters:
            return CheckResult("external_parameters", CheckStatus.FAIL, [f"unrecognised:{name}"], "unrecognised parameter")
        if value not in req.permitted_external_parameters[name]:
            return CheckResult("external_parameters", CheckStatus.FAIL, [f"forbidden:{name}={value}"], "forbidden value")
    return CheckResult("external_parameters", CheckStatus.PASS, [f"params:{len(env.external_parameters)}"], None)

def evaluate(req: ArtifactAcceptanceRequest) -> ExternalVerificationResult:
    checks = [
        check_subject_binding(req),
        check_signature(req),
        check_builder(req),
        check_build_type(req),
        check_external_parameters(req),
    ]
    failed = [c.check_name for c in checks if c.status == CheckStatus.FAIL]
    unverifiable = [c.check_name for c in checks if c.status == CheckStatus.UNVERIFIABLE]
    if failed:
        final = ExternalResult.REJECT
    elif unverifiable:
        final = ExternalResult.REVIEW
    else:
        final = ExternalResult.ACCEPT
    supporting = []
    for c in checks:
        supporting.extend(c.supporting_payload)
    return ExternalVerificationResult(
        request=req,
        check_results=checks,
        final_result=final,
        supporting_payload=supporting,
        failed_checks=failed,
        unverifiable_checks=unverifiable,
    )
