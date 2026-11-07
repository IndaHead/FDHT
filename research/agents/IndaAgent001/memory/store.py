#!/usr/bin/env python3
"""
IndaAgent001 — Minimal Agent-Local Memory Store

RESEARCH ONLY. Not permanent FDHT mathematics.

Justified by verified I₁–I₅ requirements:

- ObservationMemory: raw observations with provenance (I₂-R, I₃, I₄)
- ClaimMemory: extracted claims separate from sources (I₂-R, I₃)
- EvidenceMemory: evidence status per requirement (A₀, I₃)
- CheckpointMemory: state continuity (I₃, I₄)
- NegativeMemory: rejected/adversarial results (I₄)
- ObjectiveMemory: objective with authoritative origin (I₁, I₄ C3)

Authority boundary: source content may NOT write to ObjectiveMemory,
ProcedureMemory, or any control state.
"""

import hashlib
import json
from dataclasses import dataclass, field, asdict
from typing import List, Optional, Dict, Any
from enum import Enum
from datetime import datetime

# ============================================================
# Evidence Semantics (A₀/S₀ Reuse)
# ============================================================

class EvidenceStatus(Enum):
    ESTABLISHED = "established"
    REFUTED = "refuted"
    UNRESOLVED = "unresolved"

class ConsumerDecision(Enum):
    ADMIT = "admit"
    REJECT = "reject"
    STOP = "stop"

# ============================================================
# Memory Records
# ============================================================

@dataclass
class ProvenanceRecord:
    """Harness-recorded provenance. Not overwritable by source text."""
    source_url: str
    retrieval_timestamp: str
    source_class: str
    raw_content_hash: str
    tool_invoked: str
    harness_recorded: bool = True

@dataclass
class ObservationRecord:
    """Raw observation. Instruction authority fixed to NONE."""
    observation_id: str
    content: str
    provenance: ProvenanceRecord
    stored_at: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    is_adversarial: bool = False
    instruction_authority: str = "NONE"

@dataclass
class ClaimRecord:
    """Extracted claim. Distinct from source statement and interpretation."""
    claim_id: str
    source_statement: str
    interpretation: str
    originating_observation: str
    relation_to_requirement: str
    evidence_status: EvidenceStatus
    provenance: ProvenanceRecord
    superseded_by: Optional[str] = None

@dataclass
class EvidenceRecord:
    """How claims bear on exact requirements."""
    requirement: str
    supporting_claims: List[str]
    contradicting_claims: List[str]
    evidence_status: EvidenceStatus
    decision: ConsumerDecision
    unresolved_reason: Optional[str] = None

@dataclass
class NegativeRecord:
    """Rejected routes, adversarial results, counterevidence."""
    rejection_id: str
    rejected_content: str
    rejection_reason: str
    supporting_evidence: str
    scope: str
    reopening_condition: Optional[str] = None

@dataclass
class ObjectiveRecord:
    """Objective with authoritative origin. Only writable by human boundary."""
    objective_id: str
    content: str
    set_by: str
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())
    active: bool = True
    predecessor: Optional[str] = None

@dataclass
class CheckpointRecord:
    """Exact state resumption point."""
    checkpoint_id: str
    predecessor: Optional[str]
    active_objective: str
    observation_count: int
    claim_count: int
    evidence_status: str
    authority_execution: bool
    timestamp: str = field(default_factory=lambda: datetime.utcnow().isoformat())

# ============================================================
# Memory Store
# ============================================================

class AgentMemory:
    """
    Minimal agent-local memory.

    Write authority:
    - ObservationRecord: harness (from retrieval)
    - ClaimRecord: harness (from extraction)
    - EvidenceRecord: harness (from evaluation)
    - NegativeRecord: harness (from rejection)
    - ObjectiveRecord: human boundary only
    - CheckpointRecord: harness

    Source content may NOT write to ObjectiveRecord or any control state.
    """

    def __init__(self):
        self.observations: Dict[str, ObservationRecord] = {}
        self.claims: Dict[str, ClaimRecord] = {}
        self.evidence: Dict[str, EvidenceRecord] = {}
        self.negatives: Dict[str, NegativeRecord] = {}
        self.objectives: Dict[str, ObjectiveRecord] = {}
        self.checkpoints: Dict[str, CheckpointRecord] = {}
        self.active_objective_id: Optional[str] = None
        self.latest_checkpoint_id: Optional[str] = None
        self._seq = 0

    def _next_id(self, prefix: str) -> str:
        self._seq += 1
        return f"{prefix}_{self._seq:04d}"

    # --- Observation ---

    def store_observation(self, content: str, url: str, tool: str,
                          adversarial: bool = False) -> ObservationRecord:
        oid = self._next_id("obs")
        prov = ProvenanceRecord(
            source_url=url,
            retrieval_timestamp=datetime.utcnow().isoformat(),
            source_class="fixture" if adversarial else "web",
            raw_content_hash=hashlib.sha256(content.encode()).hexdigest()[:16],
            tool_invoked=tool,
            harness_recorded=True,
        )
        rec = ObservationRecord(
            observation_id=oid,
            content=content,
            provenance=prov,
            is_adversarial=adversarial,
            instruction_authority="NONE",
        )
        self.observations[oid] = rec
        return rec

    # --- Claim ---

    def store_claim(self, source_statement: str, interpretation: str,
                    observation_id: str, relation: str,
                    status: EvidenceStatus) -> ClaimRecord:
        cid = self._next_id("claim")
        obs = self.observations[observation_id]
        rec = ClaimRecord(
            claim_id=cid,
            source_statement=source_statement,
            interpretation=interpretation,
            originating_observation=observation_id,
            relation_to_requirement=relation,
            evidence_status=status,
            provenance=obs.provenance,
        )
        self.claims[cid] = rec
        return rec

    def supersede_claim(self, old_id: str, new_id: str):
        """Supersession without deletion."""
        if old_id in self.claims:
            self.claims[old_id].superseded_by = new_id

    # --- Evidence ---

    def store_evidence(self, requirement: str, supporting: List[str],
                       contradicting: List[str], status: EvidenceStatus,
                       decision: ConsumerDecision,
                       unresolved_reason: Optional[str] = None) -> EvidenceRecord:
        rec = EvidenceRecord(
            requirement=requirement,
            supporting_claims=supporting,
            contradicting_claims=contradicting,
            evidence_status=status,
            decision=decision,
            unresolved_reason=unresolved_reason,
        )
        self.evidence[requirement] = rec
        return rec

    # --- Negative ---

    def store_negative(self, content: str, reason: str,
                       evidence: str, scope: str) -> NegativeRecord:
        nid = self._next_id("neg")
        rec = NegativeRecord(
            rejection_id=nid,
            rejected_content=content,
            rejection_reason=reason,
            supporting_evidence=evidence,
            scope=scope,
        )
        self.negatives[nid] = rec
        return rec

    # --- Objective (human boundary only) ---

    def set_objective(self, content: str, set_by: str) -> ObjectiveRecord:
        if set_by != "human":
            raise PermissionError("Objective may only be set by human boundary")
        oid = self._next_id("obj")
        predecessor = self.active_objective_id
        if predecessor and predecessor in self.objectives:
            self.objectives[predecessor].active = False
        rec = ObjectiveRecord(
            objective_id=oid,
            content=content,
            set_by=set_by,
            predecessor=predecessor,
        )
        self.objectives[oid] = rec
        self.active_objective_id = oid
        return rec

    # --- Checkpoint ---

    def checkpoint(self) -> CheckpointRecord:
        cid = self._next_id("ckpt")
        obj_id = self.active_objective_id or ""
        ev_status = "unresolved"
        if self.evidence:
            ev_status = list(self.evidence.values())[-1].evidence_status.value
        rec = CheckpointRecord(
            checkpoint_id=cid,
            predecessor=self.latest_checkpoint_id,
            active_objective=obj_id,
            observation_count=len(self.observations),
            claim_count=len(self.claims),
            evidence_status=ev_status,
            authority_execution=False,
        )
        self.checkpoints[cid] = rec
        self.latest_checkpoint_id = cid
        return rec

    def restore_from_checkpoint(self, checkpoint_id: str) -> bool:
        """Restore reference to checkpoint. State is already in memory."""
        if checkpoint_id not in self.checkpoints:
            return False
        self.latest_checkpoint_id = checkpoint_id
        return True

    # --- Retrieval ---

    def retrieve_by_requirement(self, requirement: str) -> List[ClaimRecord]:
        """Retrieve claims related to a requirement. Does not establish truth."""
        return [c for c in self.claims.values()
                if c.relation_to_requirement == requirement and c.superseded_by is None]

    def retrieve_unresolved(self) -> List[EvidenceRecord]:
        return [e for e in self.evidence.values()
                if e.evidence_status == EvidenceStatus.UNRESOLVED]

    def retrieve_negatives(self) -> List[NegativeRecord]:
        return list(self.negatives.values())

    # --- Authority check ---

    def check_authority_boundary(self) -> bool:
        """Verify no observation has acquired instruction authority."""
        for obs in self.observations.values():
            if obs.instruction_authority != "NONE":
                return False
        return True

    # --- Serialisation ---

    def to_dict(self) -> Dict[str, Any]:
        return {
            "observations": len(self.observations),
            "claims": len(self.claims),
            "evidence": len(self.evidence),
            "negatives": len(self.negatives),
            "objectives": len(self.objectives),
            "checkpoints": len(self.checkpoints),
            "active_objective": self.active_objective_id,
            "latest_checkpoint": self.latest_checkpoint_id,
            "authority_intact": self.check_authority_boundary(),
        }

# ============================================================
# A₀/S₀ Reuse
# ============================================================

def consume_evidence(status: EvidenceStatus) -> ConsumerDecision:
    if status == EvidenceStatus.ESTABLISHED:
        return ConsumerDecision.ADMIT
    elif status == EvidenceStatus.REFUTED:
        return ConsumerDecision.REJECT
    return ConsumerDecision.STOP
