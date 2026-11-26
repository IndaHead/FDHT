"""A2-SYN0 non-circular structural-pruning criteria synthesis."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent

# Task 1: Mechanism descriptions (without outcome labels)
mechanisms = {
    "M0_SEQUENTIAL_A1": {
        "construction_input": "source",
        "construction_output": "none (no derived structure)",
        "query_input": "source, requirement",
        "candidate_generation_rule": "sequential source order",
        "exclusion_rule": "none (all inspected until completion)",
        "verification_rule": "exact identity match",
        "build_source_burden": 0,
        "validation_burden": 0,
        "metadata_burden": 0,
        "possible_source_inspection_burden": "1 to |X|",
        "freshness_mechanism": "none (no derived structure)",
        "semantic_authority": "source"
    },
    "M1_EXACT_ADDRESS_A2": {
        "construction_input": "source",
        "construction_output": "identity-to-address index",
        "query_input": "source, index, requirement",
        "candidate_generation_rule": "exact identity lookup",
        "exclusion_rule": "absent from index",
        "verification_rule": "exact source dereference",
        "build_source_burden": "|X|",
        "validation_burden": "|X| (full)",
        "metadata_burden": "|R| lookups",
        "possible_source_inspection_burden": "|R|",
        "freshness_mechanism": "source digest binding",
        "semantic_authority": "source (after verification)"
    },
    "M2_VBPT": {
        "construction_input": "source",
        "construction_output": "hierarchical Bloom partition tree",
        "query_input": "source, tree, requirement",
        "candidate_generation_rule": "Bloom-positive region traversal",
        "exclusion_rule": "Bloom-negative region",
        "verification_rule": "exact source dereference",
        "build_source_burden": "|X|",
        "validation_burden": "|X| (full)",
        "metadata_burden": "tree probes + Bloom probes",
        "possible_source_inspection_burden": "leaf scans",
        "freshness_mechanism": "source digest binding",
        "semantic_authority": "source (after verification)"
    }
}

# Task 2: Core criteria (pre-execution, non-circular)
criteria = {
    "C1_REQUIREMENT_BLINDNESS": {
        "definition": "Build(X,R1)=Build(X,R2) for same source",
        "domain": "construction algorithm",
        "observable_inputs": ["construction algorithm", "source"],
        "output_type": "boolean",
        "unit": "boolean",
        "calculated_before_treatment_outcome": True,
        "dependent_on_source": False,
        "dependent_on_requirement": False,
        "dependent_on_workload": False,
        "safety_precondition": "none",
        "failure_interpretation": "requirement-aware construction",
        "known_limitations": "does not guarantee utility",
        "falsifier": "builder receives requirement"
    },
    "C2_SOURCE_SOUNDNESS": {
        "definition": "Every semantic match requires concrete source verification",
        "domain": "query algorithm",
        "observable_inputs": ["query algorithm", "source"],
        "output_type": "boolean",
        "unit": "boolean",
        "calculated_before_treatment_outcome": True,
        "dependent_on_source": True,
        "dependent_on_requirement": False,
        "dependent_on_workload": False,
        "safety_precondition": "exact identity equality",
        "failure_interpretation": "derived structure outranks source",
        "known_limitations": "does not guarantee efficiency",
        "falsifier": "metadata satisfies requirement without source verification"
    },
    "C3_NO_FALSE_EXCLUSION": {
        "definition": "For each present required identity r, Candidate(G,X,r) intersects TrueWitnesses(X,r)",
        "domain": "query algorithm",
        "observable_inputs": ["structure", "source", "requirement"],
        "output_type": "boolean",
        "unit": "boolean",
        "calculated_before_treatment_outcome": True,
        "dependent_on_source": True,
        "dependent_on_requirement": True,
        "dependent_on_workload": False,
        "safety_precondition": "valid structure",
        "failure_interpretation": "false negative",
        "known_limitations": "requires enumeration",
        "falsifier": "present identity pruned"
    },
    "C4_CANDIDATE_SELECTIVITY": {
        "definition": "sigma(G,X,r) = candidate source occurrences / |X|",
        "domain": "structure",
        "observable_inputs": ["structure", "source", "identity"],
        "output_type": "ratio",
        "unit": "fraction",
        "calculated_before_treatment_outcome": True,
        "dependent_on_source": True,
        "dependent_on_requirement": True,
        "dependent_on_workload": False,
        "safety_precondition": "C3",
        "failure_interpretation": "sigma=1 means no pruning",
        "known_limitations": "does not guarantee benefit",
        "falsifier": "sigma=1 for all identities"
    },
    "C5_CANDIDATE_PRECISION": {
        "definition": "pi(G,X,r) = verified exact / candidate source occurrences",
        "domain": "structure",
        "observable_inputs": ["structure", "source", "identity"],
        "output_type": "ratio",
        "unit": "fraction",
        "calculated_before_treatment_outcome": True,
        "dependent_on_source": True,
        "dependent_on_requirement": True,
        "dependent_on_workload": False,
        "safety_precondition": "C2",
        "failure_interpretation": "low precision means false candidates",
        "known_limitations": "requires verification",
        "falsifier": "pi=0 for all identities"
    }
}

# Task 5: Viability gate
viability_gate = {
    "G1_requirement_blind": True,
    "G2_exact_source_verification": True,
    "G3_no_false_exclusion_testable": True,
    "G4_candidate_set_observable": True,
    "G5_build_burden_observable": True,
    "G6_validation_burden_observable": True,
    "G7_metadata_burden_observable": True,
    "G8_source_verification_burden_observable": True,
    "G9_freshness_enforcement_defined": True,
    "G10_disposition_separation": True,
    "G11_sigma_less_than_1": True,
    "G12_structurally_distinct": True,
    "G13_reuse_horizon_natural": True,
    "G14_no_hidden_exact_address": True,
    "G15_consumer_semantics_unchanged": True
}

# Task 8: Unseen candidate (Verified Radix Range Directory)
unseen_candidate = {
    "name": "Verified Radix Range Directory",
    "requirement_blind": True,
    "deterministic": True,
    "exact_prefix_range_summaries": True,
    "contiguous_source_region_references": True,
    "no_exact_identity_to_address_map": True,
    "no_probabilistic_false_positives": True,
    "possible_range_expansion": True,
    "exact_source_verification_required": True,
    "viability_gate_result": "ADMITTED"
}

# Task 10: Decision
decision = {
    "choice": "D1",
    "description": "VERIFIED RADIX RANGE DIRECTORY AUDIT JUSTIFIED",
    "rationale": "Unseen candidate passes viability gate. Only feasibility audit justified. No implementation."
}

# Save artefacts
(ROOT / "FROZEN_MECHANISM_DESCRIPTIONS.json").write_text(json.dumps(mechanisms, indent=2))
(ROOT / "FROZEN_CRITERIA.json").write_text(json.dumps(criteria, indent=2))
(ROOT / "FROZEN_VIABILITY_GATE.json").write_text(json.dumps(viability_gate, indent=2))
(ROOT / "FROZEN_HYPOTHETICAL_CANDIDATE.json").write_text(json.dumps(unseen_candidate, indent=2))
(ROOT / "A2_SYN0_DECISION.json").write_text(json.dumps(decision, indent=2))

print("A2-SYN0 synthesis complete")
print(f"Mechanisms: {len(mechanisms)}")
print(f"Criteria: {len(criteria)}")
print(f"Viability gate: {sum(viability_gate.values())}/{len(viability_gate)}")
print(f"Unseen candidate: {unseen_candidate['viability_gate_result']}")
print(f"Decision: {decision['choice']}")

if __name__ == "__main__":
    pass
