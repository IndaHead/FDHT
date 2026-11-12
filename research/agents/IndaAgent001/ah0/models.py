"""Frozen AH0 types."""
from enum import Enum
from pydantic import BaseModel, Field
from typing import List, Optional, Dict

class EvidenceStatus(str, Enum):
    ESTABLISHED = "ESTABLISHED"
    REFUTED = "REFUTED"
    UNRESOLVED = "UNRESOLVED"

class ConsumerDecision(str, Enum):
    ADMIT = "ADMIT"
    REJECT = "REJECT"
    STOP = "STOP"

class MemoryClass(str, Enum):
    OBSERVATION = "OBSERVATION"
    CLAIM = "CLAIM"
    EVIDENCE = "EVIDENCE"
    NEGATIVE = "NEGATIVE"
    OBJECTIVE = "OBJECTIVE"
    CHECKPOINT = "CHECKPOINT"

class Operation(str, Enum):
    QUERY_INDEX = "QUERY_INDEX"
    INSPECT_RECORD = "INSPECT_RECORD"
    SUBMIT_EVIDENCE = "SUBMIT_EVIDENCE"
    DECLARE_STATUS = "DECLARE_STATUS"
    STOP = "STOP"

class ProposalDecision(str, Enum):
    ADMITTED = "ADMITTED"
    REJECTED = "REJECTED"

class ObligationDischargeStatus(str, Enum):
    DISCHARGED = "DISCHARGED"
    FAILED = "FAILED"
    UNVERIFIABLE = "UNVERIFIABLE"
    NOT_APPLICABLE = "NOT_APPLICABLE"

class AgentRequirement(BaseModel):
    requirement_id: str
    objective_id: str
    proposition: str
    required_scope: str
    accepted_provenance: List[str]
    accepted_verifiers: List[str]
    evidence_standard: str
    retrieval_budget: int
    terminal_conditions: List[str]

class MemoryRecord(BaseModel):
    record_id: str
    record_class: MemoryClass
    requirement_tags: List[str]
    content: str
    claim: Optional[str] = None
    polarity: Optional[bool] = None
    scope: str
    provenance: str
    verifier_id: Optional[str] = None
    verification_status: str
    supersession_status: str
    source_id: str
    created_checkpoint: str
    superseded_by: Optional[str] = None

class EvidenceObligation(BaseModel):
    obligation_id: str
    requirement_id: str
    candidate_status: EvidenceStatus
    proposition: str
    required_scope: str
    provenance_requirement: str
    verifier_requirement: str
    mandatory: bool
    dependency_ids: List[str] = []

class AgentProposal(BaseModel):
    proposal_id: str
    operation: Operation
    target_record_id: Optional[str] = None
    target_obligation_id: Optional[str] = None
    proposed_status: Optional[EvidenceStatus] = None
    justification: str
    expected_information_gain: str

class AH0State(BaseModel):
    run_id: str
    fixture_id: str
    frozen_requirement: AgentRequirement
    current_objective_id: str
    obligation_profiles: Dict[str, ObligationDischargeStatus]
    visible_memory_index: List[Dict]
    inspected_record_ids: List[str] = []
    admitted_evidence_ids: List[str] = []
    opposing_evidence_ids: List[str] = []
    rejected_proposals: List[str] = []
    remaining_retrieval_budget: int
    current_status: Optional[EvidenceStatus] = None
    terminal: bool = False
    step_number: int = 0
    state_digest: str = ""
    previous_observation: Optional[str] = None

class AH0Event(BaseModel):
    run_id: str
    sequence_number: int
    state_digest_before: str
    proposal: AgentProposal
    admission_result: ProposalDecision
    admission_reason: str
    executed_operation: Optional[str] = None
    operation_result_summary: Optional[str] = None
    obligation_profile_after: Dict[str, ObligationDischargeStatus]
    current_status_after: Optional[EvidenceStatus] = None
    state_digest_after: str
    terminal: bool
    timestamp: str
