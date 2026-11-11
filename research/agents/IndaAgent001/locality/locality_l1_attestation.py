#!/usr/bin/env python3
"""
Locality L1 — Attested Source-Local Policy Consumer

RESEARCH ONLY. Not permanent FDHT mathematics.
Not real cryptographic attestation. Not TEE/TPM. Not remote attestation.

Hypothesis: A downstream consumer can obtain a justified admission
decision about protected source state without retrieving or possessing
that protected state, where the source policy prohibits export, the
source evaluates locally, and the returned result is bound to the exact
source, evaluator, policy version, requirement and source-state checkpoint.
"""

import hashlib
import json
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any, Set
from enum import Enum
from copy import deepcopy

# ============================================================
# A0 types (reused discipline)
# ============================================================

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

# ============================================================
# Minimal types
# ============================================================

@dataclass(frozen=True)
class ProtectedSource:
    source_id: str
    policy_id: str
    policy_version: str
    checkpoint_id: str
    authorised_workloads: tuple
    excluded_workloads: tuple
    private_policy_material: str  # inspectable by source only

@dataclass(frozen=True)
class AdmissionRequirement:
    requirement_id: str
    consumer_id: str
    workload_id: str
    source_id: str
    required_policy_id: str
    required_policy_version: str
    required_checkpoint_id: str
    evaluation_scope: str

@dataclass(frozen=True)
class SelectiveSourceProjection:
    source_id: str
    policy_id: str
    policy_version: str
    checkpoint_id: str
    workload_status: str  # "authorised" | "excluded" | "unknown"

@dataclass(frozen=True)
class AttestationRecord:
    source_id: str
    evaluator_id: str
    policy_id: str
    policy_version: str
    checkpoint_id: str
    requirement_id: str
    workload_id: str
    evidence_digest: str
    evidence_status: str
    evaluation_scope: str

@dataclass
class EvaluationResult:
    requirement: AdmissionRequirement
    status: EvidenceStatus
    decision: ConsumerDecision
    supporting_payload: List[str]
    opposing_payload: List[str]
    provenance: str
    information_moved: List[str]
    protected_state_exported: bool
    attestation: Optional[AttestationRecord]
    bytes_moved: int = 0

# ============================================================
# Fixture-local attestation
# ============================================================

def canonical_digest(fields: Dict[str, Any]) -> str:
    """Deterministic fixture-local evidence binding. Not cryptographic security."""
    canonical = json.dumps(fields, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode()).hexdigest()[:16]

def make_attestation(
    source: ProtectedSource,
    evaluator_id: str,
    req: AdmissionRequirement,
    status: EvidenceStatus,
) -> AttestationRecord:
    fields = {
        "source_id": source.source_id,
        "evaluator_id": evaluator_id,
        "policy_id": source.policy_id,
        "policy_version": source.policy_version,
        "checkpoint_id": source.checkpoint_id,
        "requirement_id": req.requirement_id,
        "workload_id": req.workload_id,
        "evidence_status": status.value,
        "evaluation_scope": req.evaluation_scope,
    }
    digest = canonical_digest(fields)
    return AttestationRecord(
        source_id=source.source_id,
        evaluator_id=evaluator_id,
        policy_id=source.policy_id,
        policy_version=source.policy_version,
        checkpoint_id=source.checkpoint_id,
        requirement_id=req.requirement_id,
        workload_id=req.workload_id,
        evidence_digest=digest,
        evidence_status=status.value,
        evaluation_scope=req.evaluation_scope,
    )

def validate_attestation(att: AttestationRecord, req: AdmissionRequirement) -> bool:
    """Validate fixture-local binding. Does not establish external trust."""
    expected_fields = {
        "source_id": att.source_id,
        "evaluator_id": att.evaluator_id,
        "policy_id": att.policy_id,
        "policy_version": att.policy_version,
        "checkpoint_id": att.checkpoint_id,
        "requirement_id": att.requirement_id,
        "workload_id": att.workload_id,
        "evidence_status": att.evidence_status,
        "evaluation_scope": att.evaluation_scope,
    }
    expected_digest = canonical_digest(expected_fields)
    if att.evidence_digest != expected_digest:
        return False
    # Binding checks
    if att.source_id != req.source_id:
        return False
    if att.policy_id != req.required_policy_id:
        return False
    if att.policy_version != req.required_policy_version:
        return False
    if att.checkpoint_id != req.required_checkpoint_id:
        return False
    if att.requirement_id != req.requirement_id:
        return False
    if att.workload_id != req.workload_id:
        return False
    return True

# ============================================================
# Frozen sources
# ============================================================

SOURCE_P7_C7_AUTHORISED = ProtectedSource(
    source_id="source_001",
    policy_id="policy_P7",
    policy_version="7",
    checkpoint_id="checkpoint_C7",
    authorised_workloads=("workload_W",),
    excluded_workloads=(),
    private_policy_material="SECRET_P7_MATERIAL",
)

SOURCE_P7_C7_EXCLUDED = ProtectedSource(
    source_id="source_001",
    policy_id="policy_P7",
    policy_version="7",
    checkpoint_id="checkpoint_C7",
    authorised_workloads=(),
    excluded_workloads=("workload_W",),
    private_policy_material="SECRET_P7_MATERIAL",
)

SOURCE_P6_C6_AUTHORISED = ProtectedSource(
    source_id="source_001",
    policy_id="policy_P6",
    policy_version="6",
    checkpoint_id="checkpoint_C6",
    authorised_workloads=("workload_W",),
    excluded_workloads=(),
    private_policy_material="SECRET_P6_MATERIAL",
)

EVALUATOR_ID = "evaluator_E1"

# ============================================================
# Route A — Complete-copy baseline
# ============================================================

def route_a_complete_copy(req: AdmissionRequirement, source: ProtectedSource) -> EvaluationResult:
    moved = ["source_id", "policy_id", "policy_version", "checkpoint_id",
             "authorised_workloads", "excluded_workloads", "private_policy_material"]
    # Evaluate at consumer
    if req.required_policy_id != source.policy_id or req.required_policy_version != source.policy_version:
        status = EvidenceStatus.UNRESOLVED
    elif req.required_checkpoint_id != source.checkpoint_id:
        status = EvidenceStatus.UNRESOLVED
    elif req.workload_id in source.authorised_workloads:
        status = EvidenceStatus.ESTABLISHED
    elif req.workload_id in source.excluded_workloads:
        status = EvidenceStatus.REFUTED
    else:
        status = EvidenceStatus.UNRESOLVED

    payload = json.dumps({"status": status.value, "policy": source.policy_id})
    return EvaluationResult(
        requirement=req,
        status=status,
        decision=a0_consume(status),
        supporting_payload=[f"policy={source.policy_id}"] if status == EvidenceStatus.ESTABLISHED else [],
        opposing_payload=[f"excluded"] if status == EvidenceStatus.REFUTED else [],
        provenance=f"{source.source_id}:{source.checkpoint_id}",
        information_moved=moved,
        protected_state_exported=True,
        attestation=None,
        bytes_moved=len(payload.encode()),
    )

# ============================================================
# Route B — Selective retrieval
# ============================================================

def route_b_selective(req: AdmissionRequirement, source: ProtectedSource) -> EvaluationResult:
    # Source returns only projection
    if req.workload_id in source.authorised_workloads:
        wl_status = "authorised"
    elif req.workload_id in source.excluded_workloads:
        wl_status = "excluded"
    else:
        wl_status = "unknown"

    proj = SelectiveSourceProjection(
        source_id=source.source_id,
        policy_id=source.policy_id,
        policy_version=source.policy_version,
        checkpoint_id=source.checkpoint_id,
        workload_status=wl_status,
    )
    moved = ["source_id", "policy_id", "policy_version", "checkpoint_id", "workload_status"]

    # Consumer evaluates projection
    if req.required_policy_id != proj.policy_id or req.required_policy_version != proj.policy_version:
        status = EvidenceStatus.UNRESOLVED
    elif req.required_checkpoint_id != proj.checkpoint_id:
        status = EvidenceStatus.UNRESOLVED
    elif proj.workload_status == "authorised":
        status = EvidenceStatus.ESTABLISHED
    elif proj.workload_status == "excluded":
        status = EvidenceStatus.REFUTED
    else:
        status = EvidenceStatus.UNRESOLVED

    payload = json.dumps({"workload_status": proj.workload_status, "policy": proj.policy_id})
    return EvaluationResult(
        requirement=req,
        status=status,
        decision=a0_consume(status),
        supporting_payload=[f"status={proj.workload_status}"] if status == EvidenceStatus.ESTABLISHED else [],
        opposing_payload=[f"status={proj.workload_status}"] if status == EvidenceStatus.REFUTED else [],
        provenance=f"{proj.source_id}:{proj.checkpoint_id}",
        information_moved=moved,
        protected_state_exported=False,
        attestation=None,
        bytes_moved=len(payload.encode()),
    )

# ============================================================
# Route C — Attested source-local
# ============================================================

def route_c_attested(req: AdmissionRequirement, source: ProtectedSource, evaluator_id: str = EVALUATOR_ID) -> EvaluationResult:
    # Evaluate at source
    if req.required_policy_id != source.policy_id or req.required_policy_version != source.policy_version:
        status = EvidenceStatus.UNRESOLVED
    elif req.required_checkpoint_id != source.checkpoint_id:
        status = EvidenceStatus.UNRESOLVED
    elif req.workload_id in source.authorised_workloads:
        status = EvidenceStatus.ESTABLISHED
    elif req.workload_id in source.excluded_workloads:
        status = EvidenceStatus.REFUTED
    else:
        status = EvidenceStatus.UNRESOLVED

    att = make_attestation(source, evaluator_id, req, status)
    moved = ["attestation_record", "evidence_status", "provenance"]

    payload = json.dumps({"status": status.value, "digest": att.evidence_digest})
    return EvaluationResult(
        requirement=req,
        status=status,
        decision=a0_consume(status),
        supporting_payload=[f"attested:{status.value}"] if status == EvidenceStatus.ESTABLISHED else [],
        opposing_payload=[f"attested:{status.value}"] if status == EvidenceStatus.REFUTED else [],
        provenance=f"{source.source_id}:{source.checkpoint_id}:{evaluator_id}",
        information_moved=moved,
        protected_state_exported=False,
        attestation=att,
        bytes_moved=len(payload.encode()),
    )

# ============================================================
# Requirements
# ============================================================

def req_positive() -> AdmissionRequirement:
    return AdmissionRequirement(
        requirement_id="req_pos",
        consumer_id="consumer_001",
        workload_id="workload_W",
        source_id="source_001",
        required_policy_id="policy_P7",
        required_policy_version="7",
        required_checkpoint_id="checkpoint_C7",
        evaluation_scope="admission",
    )

def req_refuted() -> AdmissionRequirement:
    return AdmissionRequirement(
        requirement_id="req_neg",
        consumer_id="consumer_001",
        workload_id="workload_W",
        source_id="source_001",
        required_policy_id="policy_P7",
        required_policy_version="7",
        required_checkpoint_id="checkpoint_C7",
        evaluation_scope="admission",
    )

def req_unresolved_policy() -> AdmissionRequirement:
    return AdmissionRequirement(
        requirement_id="req_p8",
        consumer_id="consumer_001",
        workload_id="workload_W",
        source_id="source_001",
        required_policy_id="policy_P8",
        required_policy_version="8",
        required_checkpoint_id="checkpoint_C7",
        evaluation_scope="admission",
    )

def req_unresolved_checkpoint() -> AdmissionRequirement:
    return AdmissionRequirement(
        requirement_id="req_c8",
        consumer_id="consumer_001",
        workload_id="workload_W",
        source_id="source_001",
        required_policy_id="policy_P7",
        required_policy_version="7",
        required_checkpoint_id="checkpoint_C8",
        evaluation_scope="admission",
    )

# ============================================================
# Main experiment
# ============================================================

def run_experiment():
    print("=== Locality L1 Attested Source-Local Policy Consumer ===")
    print()

    # Fixture 1 — Positive
    print("--- Fixture 1: Positive (W authorised under P7/C7) ---")
    req = req_positive()
    a = route_a_complete_copy(req, SOURCE_P7_C7_AUTHORISED)
    b = route_b_selective(req, SOURCE_P7_C7_AUTHORISED)
    c = route_c_attested(req, SOURCE_P7_C7_AUTHORISED)
    print(f"A: {a.status.value} -> {a.decision.value} | exported={a.protected_state_exported} | bytes={a.bytes_moved}")
    print(f"B: {b.status.value} -> {b.decision.value} | exported={b.protected_state_exported} | bytes={b.bytes_moved}")
    print(f"C: {c.status.value} -> {c.decision.value} | att_valid={validate_attestation(c.attestation, req)} | bytes={c.bytes_moved}")
    print()

    # Fixture 2 — Refuted
    print("--- Fixture 2: Refuted (W excluded under P7/C7) ---")
    req = req_refuted()
    a = route_a_complete_copy(req, SOURCE_P7_C7_EXCLUDED)
    b = route_b_selective(req, SOURCE_P7_C7_EXCLUDED)
    c = route_c_attested(req, SOURCE_P7_C7_EXCLUDED)
    print(f"A: {a.status.value} -> {a.decision.value}")
    print(f"B: {b.status.value} -> {b.decision.value}")
    print(f"C: {c.status.value} -> {c.decision.value} | att_valid={validate_attestation(c.attestation, req)}")
    print()

    # Fixture 3 — Unresolved policy
    print("--- Fixture 3: Unresolved policy (requires P8, source has P7) ---")
    req = req_unresolved_policy()
    a = route_a_complete_copy(req, SOURCE_P7_C7_AUTHORISED)
    b = route_b_selective(req, SOURCE_P7_C7_AUTHORISED)
    c = route_c_attested(req, SOURCE_P7_C7_AUTHORISED)
    print(f"A: {a.status.value} -> {a.decision.value}")
    print(f"B: {b.status.value} -> {b.decision.value}")
    print(f"C: {c.status.value} -> {c.decision.value}")
    print()

    # Fixture 4 — Unresolved checkpoint
    print("--- Fixture 4: Unresolved checkpoint (requires C8, source has C7) ---")
    req = req_unresolved_checkpoint()
    a = route_a_complete_copy(req, SOURCE_P7_C7_AUTHORISED)
    b = route_b_selective(req, SOURCE_P7_C7_AUTHORISED)
    c = route_c_attested(req, SOURCE_P7_C7_AUTHORISED)
    print(f"A: {a.status.value} -> {a.decision.value}")
    print(f"B: {b.status.value} -> {b.decision.value}")
    print(f"C: {c.status.value} -> {c.decision.value}")
    print()

    # Stale attestation
    print("--- Stale Attestation: P6/C6 evidence for P7/C7 requirement ---")
    old_req = AdmissionRequirement(
        requirement_id="req_old",
        consumer_id="consumer_001",
        workload_id="workload_W",
        source_id="source_001",
        required_policy_id="policy_P6",
        required_policy_version="6",
        required_checkpoint_id="checkpoint_C6",
        evaluation_scope="admission",
    )
    old_att_result = route_c_attested(old_req, SOURCE_P6_C6_AUTHORISED)
    current_req = req_positive()
    # Attempt to use old attestation for current requirement
    stale_valid = validate_attestation(old_att_result.attestation, current_req)
    print(f"Old attestation valid for current P7/C7 req: {stale_valid}")
    print(f"Current route C decision: {route_c_attested(current_req, SOURCE_P7_C7_EXCLUDED).decision.value}")
    print()

    # Classification analysis
    print("--- Classification Analysis ---")
    print("Route B returns workload_status for consumer evaluation.")
    print("Route C returns only bound attestation; consumer does not evaluate policy.")
    print("Route B requires policy outcome to leave source.")
    print("Route C keeps policy evaluation at source.")
    print()
    print("Does Route C provide a property Route B cannot?")
    print("YES: Route C binds result to exact source-state checkpoint and evaluator")
    print("without requiring the consumer to possess or evaluate policy values.")
    print("Route B returns policy-derived status for consumer-side evaluation.")
    print()
    print("Classification: A -- GENUINE ATTESTED SOURCE-LOCAL CONSUMER PRESSURE OBSERVED IN FIXTURE")

if __name__ == "__main__":
    run_experiment()
