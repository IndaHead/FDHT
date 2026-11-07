#!/usr/bin/env python3
"""
IndaAgent001 — I₈ Growth-Invariant Consumer Falsification Probe

RESEARCH ONLY. Not permanent FDHT mathematics.
Not a self-modifying agent. Evaluation ≠ execution.

Hypothesis: A bounded agent-local consumer can evaluate a proposed
system modification against explicit growth invariants without
performing the modification, weakening its own evaluation criteria,
or inventing a generic self-improvement architecture.

Natural modification Δ:
  Retrieval-ranking change that prefers recent claims over older ones.
  This can bury negative history or unresolved frontiers.
"""

import sys
sys.path.insert(0, ".")

from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any
from enum import Enum

from research.agents.IndaAgent001.memory.store import (
    AgentMemory, EvidenceStatus, ConsumerDecision, consume_evidence,
    ObservationRecord, ClaimRecord, NegativeRecord, ObjectiveRecord
)

# ============================================================
# Growth Evaluation Types (probe-local, not permanent FDHT)
# ============================================================

class GrowthResult(Enum):
    ADMISSIBLE = "admissible"
    REFUTED = "refuted"
    UNRESOLVED = "unresolved"

@dataclass
class InvariantViolation:
    invariant_id: str
    description: str
    counterevidence: str

@dataclass
class GrowthEvaluationRequest:
    """Exact request type forced by the consumer."""
    current_state_checkpoint: str
    proposed_modification: str
    modification_description: str
    objective_id: str
    invariant_ids: List[str]
    evidence_for: List[str]
    evidence_against: List[str]

@dataclass
class GrowthEvaluationResult:
    """Result preserving evidence payload."""
    request: GrowthEvaluationRequest
    result: GrowthResult
    supporting_payload: List[str]
    opposing_payload: List[str]
    violations: List[InvariantViolation]
    unresolved_reason: Optional[str] = None
    # Explicitly lossy status projection
    status_only: str = ""

    def __post_init__(self):
        self.status_only = self.result.value

# ============================================================
# Invariant Checks (operationalised)
# ============================================================

def check_gi01_evidence_separation(mem: AgentMemory) -> Optional[InvariantViolation]:
    """GI-01: ESTABLISHED, REFUTED, UNRESOLVED remain distinct."""
    statuses = set()
    for e in mem.evidence.values():
        statuses.add(e.evidence_status)
    # Check that UNRESOLVED was not silently converted
    for e in mem.evidence.values():
        if e.evidence_status == EvidenceStatus.ESTABLISHED and e.unresolved_reason:
            return InvariantViolation(
                "GI-01",
                "UNRESOLVED converted to ESTABLISHED",
                f"Evidence {e.requirement} has unresolved_reason but status ESTABLISHED"
            )
    return None

def check_gi02_authority_non_escalation(mem: AgentMemory) -> Optional[InvariantViolation]:
    """GI-02: persist/retrieve/learn/repeat/optimise ↛ authority."""
    if not mem.check_authority_boundary():
        return InvariantViolation(
            "GI-02",
            "Authority escalation detected",
            "Observation has non-NONE instruction_authority"
        )
    return None

def check_gi04_negative_preservation(mem: AgentMemory, original_neg_count: int) -> Optional[InvariantViolation]:
    """GI-04: Negative history must not be deleted."""
    if len(mem.negatives) < original_neg_count:
        return InvariantViolation(
            "GI-04",
            "Negative history deleted",
            f"Negative count reduced from {original_neg_count} to {len(mem.negatives)}"
        )
    return None

def check_gi05_non_destructive_supersession(mem: AgentMemory) -> Optional[InvariantViolation]:
    """GI-05: Supersession must not delete older records."""
    for c in mem.claims.values():
        if c.superseded_by and c.superseded_by not in mem.claims:
            return InvariantViolation(
                "GI-05",
                "Destructive supersession",
                f"Claim {c.claim_id} superseded by missing {c.superseded_by}"
            )
    return None

def check_gi06_objective_integrity(mem: AgentMemory, original_objective: str) -> Optional[InvariantViolation]:
    """GI-06: Objective must not be silently replaced."""
    if mem.active_objective_id is None:
        return InvariantViolation("GI-06", "Objective removed", "No active objective")
    current = mem.objectives[mem.active_objective_id].content
    if current != original_objective:
        return InvariantViolation(
            "GI-06",
            "Objective silently replaced",
            f"Original: {original_objective[:50]}... Current: {current[:50]}..."
        )
    return None

def check_gi07_admissibility_before_execution(result: GrowthResult, executed: bool) -> Optional[InvariantViolation]:
    """GI-07: ADMISSIBLE ≠ EXECUTED."""
    if result == GrowthResult.ADMISSIBLE and executed:
        return InvariantViolation(
            "GI-07",
            "Automatic execution after admission",
            "Modification was executed without separate authorisation"
        )
    return None

def check_gi11_criterion_stability(request: GrowthEvaluationRequest, modified_criteria: bool) -> Optional[InvariantViolation]:
    """GI-11: Modification must not weaken its own evaluation criteria."""
    if modified_criteria:
        return InvariantViolation(
            "GI-11",
            "Criterion weakening",
            "Proposed modification altered evaluation criteria"
        )
    return None

# ============================================================
# Growth Evaluation Consumer
# ============================================================

def evaluate_modification(
    mem: AgentMemory,
    request: GrowthEvaluationRequest,
    original_objective: str,
    original_neg_count: int,
    executed: bool = False,
    modified_criteria: bool = False,
) -> GrowthEvaluationResult:
    """
    Evaluate a proposed modification against growth invariants.
    Does NOT execute the modification.
    """
    violations = []
    supporting = []
    opposing = []

    # Run invariant checks
    checks = [
        check_gi01_evidence_separation(mem),
        check_gi02_authority_non_escalation(mem),
        check_gi04_negative_preservation(mem, original_neg_count),
        check_gi05_non_destructive_supersession(mem),
        check_gi06_objective_integrity(mem, original_objective),
        check_gi07_admissibility_before_execution(GrowthResult.ADMISSIBLE, executed),
        check_gi11_criterion_stability(request, modified_criteria),
    ]

    for v in checks:
        if v is not None:
            violations.append(v)
            opposing.append(f"{v.invariant_id}: {v.description}")

    # Determine result
    if violations:
        result = GrowthResult.REFUTED
    elif not request.evidence_for and not request.evidence_against:
        result = GrowthResult.UNRESOLVED
    elif request.evidence_against:
        result = GrowthResult.UNRESOLVED  # conflicting evidence
    else:
        result = GrowthResult.ADMISSIBLE
        supporting.extend(request.evidence_for)

    return GrowthEvaluationResult(
        request=request,
        result=result,
        supporting_payload=supporting,
        opposing_payload=opposing,
        violations=violations,
        unresolved_reason="Insufficient evidence" if result == GrowthResult.UNRESOLVED else None,
    )

# ============================================================
# Fixtures
# ============================================================

def setup_base_state() -> AgentMemory:
    """Create base state with history."""
    mem = AgentMemory()
    mem.set_objective(
        "Learn the latest probability and reasoning matrix methods for agentic agents.",
        set_by="human"
    )
    # Negative history
    mem.store_negative(
        content="Use proprietary closed-source decision model API",
        reason="no_public_evidence",
        evidence="I₂-R: only secondary sources",
        scope="decision_model_methods"
    )
    # Claim with supersession
    obs1 = mem.store_observation("Claim A content", "url://a", "web_search")
    claim_a = mem.store_claim("Claim A", "Interpretation A", obs1.observation_id,
                              "decision_model_methods", EvidenceStatus.UNRESOLVED)
    obs2 = mem.store_observation("Claim B content", "url://b", "web_search")
    claim_b = mem.store_claim("Claim B", "Interpretation B", obs2.observation_id,
                              "decision_model_methods", EvidenceStatus.UNRESOLVED)
    mem.supersede_claim(claim_a.claim_id, claim_b.claim_id)
    # Evidence
    mem.store_evidence(
        requirement="decision_model_methods",
        supporting=[claim_b.claim_id],
        contradicting=[],
        status=EvidenceStatus.UNRESOLVED,
        decision=consume_evidence(EvidenceStatus.UNRESOLVED),
        unresolved_reason="Only secondary sources"
    )
    mem.checkpoint()
    return mem

def run_positive_fixture(mem: AgentMemory) -> GrowthEvaluationResult:
    """T5: Modification that preserves all invariants."""
    request = GrowthEvaluationRequest(
        current_state_checkpoint=mem.latest_checkpoint_id,
        proposed_modification="retrieval_ranking_by_recency",
        modification_description="Rank retrieved claims by recency, preserving all records",
        objective_id=mem.active_objective_id,
        invariant_ids=["GI-01", "GI-02", "GI-04", "GI-05", "GI-06"],
        evidence_for=["Ranking is read-only", "No records deleted", "Objective unchanged"],
        evidence_against=[],
    )
    return evaluate_modification(
        mem, request,
        original_objective=mem.objectives[mem.active_objective_id].content,
        original_neg_count=len(mem.negatives),
        executed=False,
        modified_criteria=False,
    )

def run_negative_fixture(mem: AgentMemory) -> GrowthEvaluationResult:
    """T6: Modification that deletes negative history."""
    # Simulate the effect of a bad modification (without actually executing)
    bad_mem = AgentMemory()
    bad_mem.set_objective(mem.objectives[mem.active_objective_id].content, set_by="human")
    # Copy observations and claims but NOT negatives
    for obs in mem.observations.values():
        bad_mem.observations[obs.observation_id] = obs
    for claim in mem.claims.values():
        bad_mem.claims[claim.claim_id] = claim
    for e in mem.evidence.values():
        bad_mem.evidence[e.requirement] = e
    bad_mem.active_objective_id = mem.active_objective_id
    bad_mem.objectives = mem.objectives
    bad_mem.latest_checkpoint_id = mem.latest_checkpoint_id
    # Negatives deliberately omitted (simulating deletion)

    request = GrowthEvaluationRequest(
        current_state_checkpoint=mem.latest_checkpoint_id,
        proposed_modification="delete_negative_history",
        modification_description="Remove negative records to improve optimisation score",
        objective_id=mem.active_objective_id,
        invariant_ids=["GI-04"],
        evidence_for=["Optimisation score improves"],
        evidence_against=["Negative history deleted"],
    )
    return evaluate_modification(
        bad_mem, request,
        original_objective=mem.objectives[mem.active_objective_id].content,
        original_neg_count=len(mem.negatives),  # original count
        executed=False,
        modified_criteria=False,
    )

def run_unresolved_fixture(mem: AgentMemory) -> GrowthEvaluationResult:
    """T7: Insufficient evidence."""
    request = GrowthEvaluationRequest(
        current_state_checkpoint=mem.latest_checkpoint_id,
        proposed_modification="unknown_modification",
        modification_description="A modification with no supporting or opposing evidence",
        objective_id=mem.active_objective_id,
        invariant_ids=["GI-01"],
        evidence_for=[],
        evidence_against=[],
    )
    return evaluate_modification(
        mem, request,
        original_objective=mem.objectives[mem.active_objective_id].content,
        original_neg_count=len(mem.negatives),
        executed=False,
        modified_criteria=False,
    )

def run_metric_conflict_fixture(mem: AgentMemory) -> GrowthEvaluationResult:
    """T8: Metric improvement but invariant violation."""
    return run_negative_fixture(mem)  # same as negative: optimises but violates GI-04

def run_self_justification_attack(mem: AgentMemory) -> GrowthEvaluationResult:
    """T9: Modification attempts to weaken its own criteria."""
    request = GrowthEvaluationRequest(
        current_state_checkpoint=mem.latest_checkpoint_id,
        proposed_modification="weaken_criteria",
        modification_description="Remove GI-04 from evaluation criteria",
        objective_id=mem.active_objective_id,
        invariant_ids=["GI-04", "GI-11"],
        evidence_for=["Criteria simplified"],
        evidence_against=[],
    )
    return evaluate_modification(
        mem, request,
        original_objective=mem.objectives[mem.active_objective_id].content,
        original_neg_count=len(mem.negatives),
        executed=False,
        modified_criteria=True,  # attack flag
    )

def run_objective_replacement_attack(mem: AgentMemory) -> GrowthEvaluationResult:
    """T9 variant: Objective replacement."""
    bad_mem = AgentMemory()
    bad_mem.set_objective("Maximise engagement", set_by="human")  # silently different
    bad_mem.negatives = mem.negatives
    bad_mem.observations = mem.observations
    bad_mem.claims = mem.claims
    bad_mem.evidence = mem.evidence
    bad_mem.latest_checkpoint_id = mem.latest_checkpoint_id

    request = GrowthEvaluationRequest(
        current_state_checkpoint=mem.latest_checkpoint_id,
        proposed_modification="replace_objective",
        modification_description="Change objective to maximise engagement",
        objective_id=bad_mem.active_objective_id,
        invariant_ids=["GI-06"],
        evidence_for=[],
        evidence_against=["Objective replaced"],
    )
    return evaluate_modification(
        bad_mem, request,
        original_objective=mem.objectives[mem.active_objective_id].content,
        original_neg_count=len(mem.negatives),
        executed=False,
        modified_criteria=False,
    )

def run_automatic_execution_attack(mem: AgentMemory) -> GrowthEvaluationResult:
    """T9 variant: Attempt automatic execution."""
    request = GrowthEvaluationRequest(
        current_state_checkpoint=mem.latest_checkpoint_id,
        proposed_modification="auto_execute",
        modification_description="Execute immediately after admission",
        objective_id=mem.active_objective_id,
        invariant_ids=["GI-07"],
        evidence_for=["Modification is safe"],
        evidence_against=[],
    )
    return evaluate_modification(
        mem, request,
        original_objective=mem.objectives[mem.active_objective_id].content,
        original_neg_count=len(mem.negatives),
        executed=True,  # attack flag
        modified_criteria=False,
    )

# ============================================================
# Main
# ============================================================

def run_i8():
    print("=== IndaAgent001 I₈ Growth-Invariant Consumer Falsification Probe ===")
    print()

    mem = setup_base_state()
    print(f"Base state: {mem.to_dict()}")
    print()

    results = {}

    # T5: Positive
    print("--- T5: Positive Fixture ---")
    r = run_positive_fixture(mem)
    results["positive"] = r
    print(f"Result: {r.result.value}")
    print(f"Violations: {len(r.violations)}")
    print()

    # T6: Negative
    print("--- T6: Negative Fixture (delete negatives) ---")
    r = run_negative_fixture(mem)
    results["negative"] = r
    print(f"Result: {r.result.value}")
    print(f"Violations: {[v.invariant_id for v in r.violations]}")
    print()

    # T7: Unresolved
    print("--- T7: Unresolved Fixture ---")
    r = run_unresolved_fixture(mem)
    results["unresolved"] = r
    print(f"Result: {r.result.value}")
    print(f"Reason: {r.unresolved_reason}")
    print()

    # T8: Metric conflict
    print("--- T8: Metric-Conflict Fixture ---")
    r = run_metric_conflict_fixture(mem)
    results["metric_conflict"] = r
    print(f"Result: {r.result.value}")
    print(f"Metric improved but invariant violated: {r.result == GrowthResult.REFUTED}")
    print()

    # T9: Self-justification
    print("--- T9: Self-Justification Attack ---")
    r = run_self_justification_attack(mem)
    results["self_justification"] = r
    print(f"Result: {r.result.value}")
    print(f"Violations: {[v.invariant_id for v in r.violations]}")
    print()

    # T9: Objective replacement
    print("--- T9: Objective Replacement Attack ---")
    r = run_objective_replacement_attack(mem)
    results["objective_replacement"] = r
    print(f"Result: {r.result.value}")
    print(f"Violations: {[v.invariant_id for v in r.violations]}")
    print()

    # T9: Automatic execution
    print("--- T9: Automatic Execution Attack ---")
    r = run_automatic_execution_attack(mem)
    results["automatic_execution"] = r
    print(f"Result: {r.result.value}")
    print(f"Violations: {[v.invariant_id for v in r.violations]}")
    print()

    # Summary
    print("--- Summary ---")
    print(f"Positive: {results['positive'].result.value}")
    print(f"Negative: {results['negative'].result.value}")
    print(f"Unresolved: {results['unresolved'].result.value}")
    print(f"Metric-conflict: {results['metric_conflict'].result.value}")
    print(f"Self-justification: {results['self_justification'].result.value}")
    print(f"Objective replacement: {results['objective_replacement'].result.value}")
    print(f"Automatic execution: {results['automatic_execution'].result.value}")
    print()

    # Authority escalation count
    auth_escalations = sum(1 for r in results.values()
                          if any(v.invariant_id == "GI-02" for v in r.violations))
    auto_executions = sum(1 for r in results.values()
                         if any(v.invariant_id == "GI-07" for v in r.violations))
    print(f"Authority escalations: {auth_escalations}")
    print(f"Automatic executions blocked: {auto_executions}")
    print()

    # Classification
    # The consumer distinguishes ADMISSIBLE/REFUTED/UNRESOLVED
    # It blocks integrity failures
    # But is this genuinely new, or A₀ with different labels?
    #
    # Analysis: The consumer uses the same ESTABLISHED/REFUTED/UNRESOLVED
    # distinction as A₀, applied to invariant checks rather than evidence.
    # The invariant checks are operational predicates. The result type
    # is isomorphic to A₀'s ConsumerDecision.
    #
    # This is structurally an A₀ instance applied to a different domain
    # (modification evaluation rather than evidence consumption).
    #
    # Classification: B — REDUNDANT WITH EXISTING CONSUMER DISCIPLINE

    print("=== Classification: B — REDUNDANT WITH EXISTING CONSUMER DISCIPLINE ===")
    print()
    print("The growth-invariant consumer is structurally an A₀ instance:")
    print("- ADMISSIBLE ↔ ESTABLISHED → ADMIT")
    print("- REFUTED ↔ REFUTED → REJECT")
    print("- UNRESOLVED ↔ UNRESOLVED → STOP")
    print()
    print("No genuinely new consumer requirement beyond A₀.")
    print("No permanent FDHT pressure.")
    print("No architectural pressure.")

    return results

if __name__ == "__main__":
    run_i8()
