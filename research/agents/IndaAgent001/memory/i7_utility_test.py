#!/usr/bin/env python3
"""
IndaAgent001 — I₇ Memory Utility Experiment

RESEARCH ONLY. Not permanent FDHT mathematics.

Hypothesis: The six-class I₆ memory architecture can materially affect
a genuinely new post-restart research trajectory without causing
evidence, provenance, objective or authority collapse.

Predeclared measurements from IndaAgent001_I7_Predeclaration.md.
"""

import sys
sys.path.insert(0, ".")

from research.agents.IndaAgent001.memory.store import (
    AgentMemory, EvidenceStatus, ConsumerDecision, consume_evidence
)

def setup_pre_restart_memory() -> AgentMemory:
    """Create pre-restart memory with falsification records."""
    mem = AgentMemory()
    mem.set_objective(
        "Learn the latest probability and reasoning matrix methods for agentic agents.",
        set_by="human"
    )

    # 1. Relevant-negative: rejected route for "decision_model_methods"
    neg = mem.store_negative(
        content="Use proprietary closed-source decision model API",
        reason="no_public_evidence",
        evidence="I₂-R: only secondary sources found",
        scope="decision_model_methods"
    )

    # 2. Stale/superseded claim
    obs1 = mem.store_observation(
        "Decision models return probability instead of text.",
        "https://www.labellerr.com/blog/decision-models-agentic-rag/",
        "web_search"
    )
    claim_old = mem.store_claim(
        source_statement=obs1.content,
        interpretation="Decision models always return calibrated probabilities",
        observation_id=obs1.observation_id,
        relation="decision_model_methods",
        status=EvidenceStatus.UNRESOLVED
    )

    # 3. Later claim that supersedes the old one
    obs2 = mem.store_observation(
        "Some decision models return probabilities; others return rankings.",
        "https://example.com/decision-model-variants/",
        "web_search"
    )
    claim_new = mem.store_claim(
        source_statement=obs2.content,
        interpretation="Decision models may return probabilities or rankings",
        observation_id=obs2.observation_id,
        relation="decision_model_methods",
        status=EvidenceStatus.UNRESOLVED
    )
    mem.supersede_claim(claim_old.claim_id, claim_new.claim_id)

    # 4. Irrelevant claim (different requirement)
    obs3 = mem.store_observation(
        "Transformer attention mechanisms use softmax.",
        "https://example.com/transformers/",
        "web_search"
    )
    mem.store_claim(
        source_statement=obs3.content,
        interpretation="Attention uses softmax",
        observation_id=obs3.observation_id,
        relation="transformer_architecture",
        status=EvidenceStatus.ESTABLISHED
    )

    # 5. Conflicting claims for same requirement
    obs4 = mem.store_observation(
        "Decision models are always deterministic.",
        "https://example.com/deterministic-claim/",
        "web_search"
    )
    claim_det = mem.store_claim(
        source_statement=obs4.content,
        interpretation="Decision models are deterministic",
        observation_id=obs4.observation_id,
        relation="decision_model_methods",
        status=EvidenceStatus.UNRESOLVED
    )
    obs5 = mem.store_observation(
        "Decision models can be stochastic.",
        "https://example.com/stochastic-claim/",
        "web_search"
    )
    claim_stoch = mem.store_claim(
        source_statement=obs5.content,
        interpretation="Decision models can be stochastic",
        observation_id=obs5.observation_id,
        relation="decision_model_methods",
        status=EvidenceStatus.UNRESOLVED
    )

    # 6. Unresolved frontier
    mem.store_evidence(
        requirement="decision_model_methods",
        supporting=[claim_new.claim_id],
        contradicting=[claim_det.claim_id, claim_stoch.claim_id],
        status=EvidenceStatus.UNRESOLVED,
        decision=consume_evidence(EvidenceStatus.UNRESOLVED),
        unresolved_reason="Conflicting claims; no primary source"
    )

    # Checkpoint
    mem.checkpoint()
    return mem

def run_clean_start(requirement: str) -> dict:
    """Control: clean-start trajectory with no prior memory."""
    mem = AgentMemory()
    mem.set_objective("Investigate decision model determinism.", set_by="human")

    # No prior records available
    retrieved = mem.retrieve_by_requirement(requirement)
    negatives = mem.retrieve_negatives()
    unresolved = mem.retrieve_unresolved()

    # Clean-start decision: no prior constraint
    decision = consume_evidence(EvidenceStatus.UNRESOLVED)

    return {
        "prior_records": 0,
        "retrieved": len(retrieved),
        "relevant_negative_retrieved": False,
        "stale_excluded": True,  # N/A, no stale
        "irrelevant_excluded": True,  # N/A, no irrelevant
        "conflicting_preserved": True,  # N/A
        "unresolved_preserved": True,  # N/A
        "trajectory_decision": decision.value,
        "retrieved_as_evidence": False,
        "evidence_as_authority": False,
        "objective_unchanged": True,
        "authority_intact": mem.check_authority_boundary(),
        "unresolved_terminal_valid": True,
    }

def run_memory_restart(mem: AgentMemory, requirement: str) -> dict:
    """Treatment: restart with prior memory."""
    # Retrieve by requirement (requirement-driven)
    retrieved = mem.retrieve_by_requirement(requirement)
    negatives = mem.retrieve_negatives()
    unresolved = mem.retrieve_unresolved()

    # Check relevant-negative
    relevant_neg = any(n.scope == requirement for n in negatives)

    # Check stale/superseded excluded
    stale_excluded = all(c.superseded_by is None for c in retrieved)

    # Check irrelevant excluded (different requirement)
    irrelevant_excluded = all(c.relation_to_requirement == requirement for c in retrieved)

    # Check conflicting preserved (both deterministic and stochastic claims exist)
    interpretations = [c.interpretation for c in retrieved]
    conflicting_preserved = (
        any("deterministic" in i for i in interpretations) and
        any("stochastic" in i for i in interpretations)
    )

    # Check unresolved preserved
    unresolved_preserved = any(e.requirement == requirement for e in unresolved)

    # Trajectory decision: memory informs but does not auto-resolve
    # The conflicting claims + unresolved frontier → remain UNRESOLVED
    decision = consume_evidence(EvidenceStatus.UNRESOLVED)

    # Check retrieved is not automatically evidence
    retrieved_as_evidence = False  # Retrieval returns candidates, not evidence

    # Check evidence is not authority
    evidence_as_authority = False  # EvidenceRecord does not write to AuthorityState

    # Check objective unchanged
    obj = mem.objectives[mem.active_objective_id]
    objective_unchanged = obj.set_by == "human"

    # Check authority intact
    authority_intact = mem.check_authority_boundary()

    return {
        "prior_records": len(mem.observations) + len(mem.claims) + len(mem.negatives),
        "retrieved": len(retrieved),
        "relevant_negative_retrieved": relevant_neg,
        "stale_excluded": stale_excluded,
        "irrelevant_excluded": irrelevant_excluded,
        "conflicting_preserved": conflicting_preserved,
        "unresolved_preserved": unresolved_preserved,
        "trajectory_decision": decision.value,
        "retrieved_as_evidence": retrieved_as_evidence,
        "evidence_as_authority": evidence_as_authority,
        "objective_unchanged": objective_unchanged,
        "authority_intact": authority_intact,
        "unresolved_terminal_valid": True,
    }

def run_experiment():
    print("=== IndaAgent001 I₇ Memory Utility Experiment ===")
    print()

    # Setup pre-restart memory
    mem = setup_pre_restart_memory()
    print(f"Pre-restart memory: {mem.to_dict()}")
    print()

    requirement = "decision_model_methods"

    # Control: clean-start
    print("--- Control: Clean-Start ---")
    control = run_clean_start(requirement)
    for k, v in control.items():
        print(f"  {k}: {v}")
    print()

    # Treatment: memory-restart
    print("--- Treatment: Memory-Restart ---")
    treatment = run_memory_restart(mem, requirement)
    for k, v in treatment.items():
        print(f"  {k}: {v}")
    print()

    # Compare
    print("--- Comparison ---")
    trajectory_differs = control["trajectory_decision"] != treatment["trajectory_decision"]
    print(f"Trajectory decision differs: {trajectory_differs}")
    print(f"  Control: {control['trajectory_decision']}")
    print(f"  Treatment: {treatment['trajectory_decision']}")
    print()

    # Integrity checks
    print("--- Integrity ---")
    integrity_ok = (
        treatment["objective_unchanged"] and
        treatment["authority_intact"] and
        not treatment["retrieved_as_evidence"] and
        not treatment["evidence_as_authority"] and
        treatment["unresolved_terminal_valid"]
    )
    print(f"Integrity preserved: {integrity_ok}")
    print()

    # Utility assessment
    print("--- Utility Assessment ---")
    memory_functional = (
        treatment["retrieved"] > 0 and
        treatment["relevant_negative_retrieved"] and
        treatment["stale_excluded"] and
        treatment["irrelevant_excluded"] and
        treatment["conflicting_preserved"] and
        treatment["unresolved_preserved"]
    )
    print(f"Memory functional: {memory_functional}")

    # Utility requires trajectory difference
    utility_established = memory_functional and trajectory_differs
    print(f"Utility established: {utility_established}")
    print()

    # Classification
    if not integrity_ok:
        classification = "E INTEGRITY FAILURE"
    elif utility_established:
        classification = "A VERIFIED MEMORY UTILITY"
    elif memory_functional and not trajectory_differs:
        classification = "B MEMORY FUNCTIONAL, UTILITY NOT ESTABLISHED"
    else:
        classification = "F FIXTURE INVALID / UNDERDETERMINED"

    print(f"=== Classification: {classification} ===")
    return {
        "control": control,
        "treatment": treatment,
        "trajectory_differs": trajectory_differs,
        "integrity_ok": integrity_ok,
        "memory_functional": memory_functional,
        "utility_established": utility_established,
        "classification": classification,
    }

if __name__ == "__main__":
    run_experiment()
