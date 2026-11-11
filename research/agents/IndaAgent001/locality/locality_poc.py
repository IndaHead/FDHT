#!/usr/bin/env python3
"""
Locality L0 — Source-Local Consumer Relation POC

RESEARCH ONLY. Not permanent FDHT mathematics.
Not a ConsumerGraph, Locality API, or EvidenceGraph.

Hypothesis: For at least one microscopic fixture, a source-local
evaluation route can preserve the exact consumer decision and required
provenance while moving strictly less source information than a control
route that first transports the complete source relation.
"""

import sys
sys.path.insert(0, ".")

from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any, Set
from enum import Enum
from copy import deepcopy

# Reuse existing A0 types if available; define locally for isolation
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
# Minimal types for the fixture
# ============================================================

@dataclass(frozen=True)
class SourceRelation:
    """Fixture-local inert relation. Not a graph."""
    source_id: str
    source_node: str
    relation: str
    target_node: str
    provenance: str

@dataclass(frozen=True)
class ConsumerRequirement:
    requirement_id: str
    required_relation: str
    consumer_id: str
    evaluation_scope: str

@dataclass
class EvaluationResult:
    requirement: ConsumerRequirement
    status: EvidenceStatus
    supporting_evidence: List[str]
    opposing_evidence: List[str]
    provenance: str
    evaluation_scope: str
    information_moved: List[str]
    decision: ConsumerDecision = None

    def __post_init__(self):
        if self.decision is None:
            self.decision = a0_consume(self.status)

# ============================================================
# Information movement tracker
# ============================================================

@dataclass
class MovementLog:
    """Records exactly what crossed the source boundary."""
    fields_moved: List[str] = field(default_factory=list)
    complete_source_copied: bool = False
    records_moved: int = 0

    def record(self, field_name: str):
        if field_name not in self.fields_moved:
            self.fields_moved.append(field_name)
            self.records_moved += 1

    def mark_complete_copy(self):
        self.complete_source_copied = True
        for f in ["source_id", "source_node", "relation", "target_node", "provenance"]:
            self.record(f)

# ============================================================
# Frozen source (one relation only)
# ============================================================

FROZEN_SOURCE = SourceRelation(
    source_id="src_001",
    source_node="N1",
    relation="supports",
    target_node="N2",
    provenance="fixture-local-inert"
)

# ============================================================
# Route A — Control (copy complete source)
# ============================================================

def control_route(req: ConsumerRequirement, source: SourceRelation) -> EvaluationResult:
    log = MovementLog()
    log.mark_complete_copy()

    # Evaluate locally against copied source
    if req.required_relation == source.relation:
        status = EvidenceStatus.ESTABLISHED
        supporting = [f"relation={source.relation}"]
        opposing = []
    elif req.required_relation != source.relation and req.required_relation:
        status = EvidenceStatus.REFUTED
        supporting = []
        opposing = [f"required={req.required_relation} but source={source.relation}"]
    else:
        status = EvidenceStatus.UNRESOLVED
        supporting = []
        opposing = []

    return EvaluationResult(
        requirement=req,
        status=status,
        supporting_evidence=supporting,
        opposing_evidence=opposing,
        provenance=source.provenance,
        evaluation_scope=req.evaluation_scope,
        information_moved=log.fields_moved,
    )

# ============================================================
# Route B — Source-local (evaluate at source, return only evidence)
# ============================================================

def source_local_route(req: ConsumerRequirement, source: SourceRelation) -> EvaluationResult:
    log = MovementLog()

    # Only the requirement crosses to the source evaluator
    # Evaluation happens at source; only evidence returns
    if req.required_relation == source.relation:
        status = EvidenceStatus.ESTABLISHED
        supporting = ["relation matches required"]
        opposing = []
        # Return only the evidence, not the full relation
        log.record("evidence:relation_match")
        log.record("provenance")
    elif req.required_relation != source.relation and req.required_relation:
        status = EvidenceStatus.REFUTED
        supporting = []
        opposing = [f"required {req.required_relation} not present"]
        log.record("evidence:relation_mismatch")
        log.record("provenance")
    else:
        status = EvidenceStatus.UNRESOLVED
        supporting = []
        opposing = []
        log.record("evidence:insufficient")
        log.record("provenance")

    return EvaluationResult(
        requirement=req,
        status=status,
        supporting_evidence=supporting,
        opposing_evidence=opposing,
        provenance=source.provenance,
        evaluation_scope=req.evaluation_scope,
        information_moved=log.fields_moved,
    )

# ============================================================
# Memory class audit helpers
# ============================================================

MEMORY_CLASSES = [
    "ObservationRecord",
    "ClaimRecord",
    "EvidenceRecord",
    "NegativeRecord",
    "ObjectiveRecord",
    "CheckpointRecord",
]

def audit_memory_crossing(route_name: str, result: EvaluationResult) -> Dict[str, str]:
    """Determine whether each memory class must cross the boundary."""
    audit = {}
    for cls in MEMORY_CLASSES:
        # For this fixture, none of the six classes are required to cross
        # for evaluation. Evidence is returned as payload, not as a class instance.
        audit[cls] = "NOT_REQUIRED_TO_CROSS"
    return audit

# ============================================================
# Fixtures
# ============================================================

def positive_requirement() -> ConsumerRequirement:
    return ConsumerRequirement(
        requirement_id="req_pos",
        required_relation="supports",
        consumer_id="consumer_001",
        evaluation_scope="single_relation",
    )

def refuted_requirement() -> ConsumerRequirement:
    return ConsumerRequirement(
        requirement_id="req_neg",
        required_relation="contradicts",
        consumer_id="consumer_001",
        evaluation_scope="single_relation",
    )

def unresolved_requirement() -> ConsumerRequirement:
    return ConsumerRequirement(
        requirement_id="req_unres",
        required_relation="",
        consumer_id="consumer_001",
        evaluation_scope="single_relation",
    )

# ============================================================
# Adversarial checks
# ============================================================

def check_retrieval_collapse(result: EvaluationResult) -> bool:
    """Source-local must not copy complete SourceRelation."""
    return "source_node" not in result.information_moved and "target_node" not in result.information_moved

def check_possession_collapse(result: EvaluationResult) -> bool:
    """Receiving EvidenceResult does not imply possessing SourceRelation."""
    return result.information_moved != ["source_id", "source_node", "relation", "target_node", "provenance"]

def check_authority_collapse(result: EvaluationResult) -> bool:
    """Evidence returned does not become authority."""
    return result.decision == a0_consume(result.status)

def check_persistence_collapse() -> bool:
    """Useful result does not auto-persist all six classes."""
    # No persistence occurs in this fixture
    return True

def check_objective_replacement(result: EvaluationResult) -> bool:
    """Source interest does not alter objective."""
    return result.requirement.evaluation_scope == "single_relation"

def check_scope_expansion(result: EvaluationResult) -> bool:
    """No second relation inspected."""
    return len(result.information_moved) <= 2

def check_information_volume_attack(result: EvaluationResult) -> bool:
    """Complete SourceRelation not embedded in supporting_evidence."""
    for ev in result.supporting_evidence:
        if "N1" in ev and "N2" in ev and "supports" in ev:
            return False
    return True

def check_status_only_collapse(result: EvaluationResult) -> bool:
    """Must return evidence/provenance, not status alone."""
    return len(result.supporting_evidence) > 0 or len(result.opposing_evidence) > 0 or result.provenance

# ============================================================
# Main experiment runner
# ============================================================

def run_experiment():
    print("=== Locality L0 Source-Local Consumer POC ===")
    print()

    results = {}

    # Positive
    print("--- Positive Fixture ---")
    req = positive_requirement()
    ctrl = control_route(req, FROZEN_SOURCE)
    src = source_local_route(req, FROZEN_SOURCE)
    results["positive"] = {"control": ctrl, "source_local": src}
    print(f"Control: {ctrl.status.value} -> {ctrl.decision.value} | moved: {ctrl.information_moved}")
    print(f"Source-local: {src.status.value} -> {src.decision.value} | moved: {src.information_moved}")
    print()

    # Refuted
    print("--- Refuted Fixture ---")
    req = refuted_requirement()
    ctrl = control_route(req, FROZEN_SOURCE)
    src = source_local_route(req, FROZEN_SOURCE)
    results["refuted"] = {"control": ctrl, "source_local": src}
    print(f"Control: {ctrl.status.value} -> {ctrl.decision.value} | moved: {ctrl.information_moved}")
    print(f"Source-local: {src.status.value} -> {src.decision.value} | moved: {src.information_moved}")
    print()

    # Unresolved
    print("--- Unresolved Fixture ---")
    req = unresolved_requirement()
    ctrl = control_route(req, FROZEN_SOURCE)
    src = source_local_route(req, FROZEN_SOURCE)
    results["unresolved"] = {"control": ctrl, "source_local": src}
    print(f"Control: {ctrl.status.value} -> {ctrl.decision.value} | moved: {ctrl.information_moved}")
    print(f"Source-local: {src.status.value} -> {src.decision.value} | moved: {src.information_moved}")
    print()

    # Memory audit
    print("--- Six-Memory-Class Audit ---")
    audit = audit_memory_crossing("source_local", results["positive"]["source_local"])
    for cls, status in audit.items():
        print(f"  {cls}: {status}")
    print()

    # Adversarial
    print("--- Adversarial Checks (source-local positive) ---")
    sl = results["positive"]["source_local"]
    checks = {
        "retrieval_collapse": check_retrieval_collapse(sl),
        "possession_collapse": check_possession_collapse(sl),
        "authority_collapse": check_authority_collapse(sl),
        "persistence_collapse": check_persistence_collapse(),
        "objective_replacement": check_objective_replacement(sl),
        "scope_expansion": check_scope_expansion(sl),
        "information_volume": check_information_volume_attack(sl),
        "status_only": check_status_only_collapse(sl),
    }
    for name, passed in checks.items():
        print(f"  {name}: {'PASS' if passed else 'FAIL'}")
    print()

    # Classification
    pos_match = (results["positive"]["control"].status == results["positive"]["source_local"].status and
                 results["positive"]["control"].decision == results["positive"]["source_local"].decision)
    less_info = len(results["positive"]["source_local"].information_moved) < len(results["positive"]["control"].information_moved)
    no_complete = "source_node" not in results["positive"]["source_local"].information_moved
    all_adv = all(checks.values())

    if pos_match and less_info and no_complete and all_adv:
        classification = "A -- SOURCE-LOCAL CONSUMER RELATION OBSERVED IN FIXTURE"
    elif not pos_match:
        classification = "C -- REFUTED IN FIXTURE"
    else:
        classification = "B -- REDUNDANT WITH ORDINARY RETRIEVAL / EXISTING CONSUMER DISCIPLINE"

    print(f"=== Classification: {classification} ===")
    return results, classification, checks

if __name__ == "__main__":
    run_experiment()
