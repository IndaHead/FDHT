# FDHT Research Provenance Index

## Notice

- Research artefacts are not permanent FDHT mathematics.
- Passing probes do not imply promotion.
- Failed probes remain evidence.
- Historical artefacts may be superseded without being deleted.
- Result documents are interpretative summaries.
- Frozen fixtures and machine-readable outputs remain experimental evidence.
- Permanent mathematics lives under `fdht/`.

## Evidence and Authority

- Lean theorem files provide formal mathematical evidence within their exact assumptions and trust footprint.
- Deterministic runners provide bounded executable evidence.
- Live-model logs provide bounded treatment evidence.
- Frozen fixtures specify experimental inputs.
- Expected-result files specify oracles.
- Machine-readable results record executions.
- Human-readable result documents interpret those artefacts.
- Git history supplies repository provenance.
- No single evidence class automatically grants architectural or promotion authority.

## Programme Index

| Programme | Status | Classification | Predecessor | Successor | Result |
|---|---|---|---|---|---|
| AF₀ | CLOSED | BOUNDED_DETERMINISTIC_EXECUTION | — | AF₀-DN | research/results/ |
| AF₀-DN | CLOSED | BOUNDED_DETERMINISTIC_EXECUTION | AF₀ | AF₁-RS | research/results/ |
| AF₁-RS | CLOSED | BOUNDED_DETERMINISTIC_EXECUTION | AF₀-DN | AF₁-ADV | research/results/ |
| AF₁-ADV | CLAIM_REDUCED | BOUNDED_DETERMINISTIC_EXECUTION | AF₁-RS | AF₁-ADV2 | research/results/FDHT_AF1_ADV_Adversarial_Requirement_Scaling.md |
| AF₁-ADV2 | CLOSED | REPLICATION | AF₁-ADV | AF₁-CTRL | research/results/FDHT_AF1_ADV2_Concrete_Adversarial_Fixture_Execution.md |
| AF₁-CTRL | CLOSED | ADVERSARIAL_CONTROL | AF₁-ADV2 | AF₁-M5 | research/results/FDHT_AF1_CTRL_Label_Invariance_Control.md |
| AF₁-M5 | CLOSED | ADVERSARIAL_CONTROL | AF₁-CTRL | — | research/results/FDHT_AF1_M5_Requirement_Representation_Invariance.md |
| RSA₀ | CLOSED | REPOSITORY_AUDIT | — | RSA₁ | research/results/FDHT_RSA0_Repository_Structure_Audit.md |

## AF₁ Lineage

```
AF₀ → AF₀-DN → AF₁-RS → AF₁-ADV → AF₁-ADV2 → AF₁-CTRL → AF₁-M5
```

### AF₁-ADV

STATUS: CLAIM_REDUCED / HISTORICAL

REASON: The committed runner enumerated labelled geometry and duplicate-shadow dimensions but did not operationalise those dimensions as concrete source differences.

### AF₁-ADV2

STATUS: CLOSED / REPLICATION

RELATION: Repairs and concretely replicates the bounded adversarial claim using concrete fixtures, independent oracle calculation and source/requirement-only treatment inputs.

### AF₁-CTRL

STATUS: CLOSED

RELATION: Tests label invariance, source responsiveness and requirement-identity responsiveness against the AF₁-ADV2 boundary.

### AF₁-M5

STATUS: CLOSED WITH EXPLICIT SCOPE

ESTABLISHED: Canonical representation invariance within tested schemas.

OPEN: Downstream Oracle/A0/A1 behavioural representation invariance was not executed in that run.

## Supersession

See `research/af1_adv/STATUS.md` for the AF₁-ADV → AF₁-ADV2 claim reduction.

| TG₀ | CLOSED | REPOSITORY_AUDIT | ECD₀ | — | research/results/FDHT_TG0_Temporal_Graph_Information_Fate_Survey.md |

| IS₀ | CLOSED | INSPECTION_SCALING | TGAT₀-F | — | research/results/FDHT_IS0_Inspection_Scaling_Experiment.md |

| A2₀ | CLOSED | ADDRESS_STRUCTURE | IS₀ | — | research/results/FDHT_A2_0_Address_Structure_Experiment.md |

| A2₀-C | CLOSED | ACCOUNTING_CORRECTION | A2₀ | — | research/results/FDHT_A2_0C_Address_Structure_Accounting_Correction.md |

| A2₀-S | CLOSED | SAFETY_PROBE | A2₀-C | — | research/results/FDHT_A2_0S_Address_Index_Safety_Probe.md |

| A2₁ | CLOSED | INDEPENDENT_REPLICATION | A2₀-S | — | research/results/FDHT_A2_1_Independent_Address_Pruning_Replication.md |

| A2₂ | CLOSED | STRUCTURAL_PRUNING | A2₁ | — | research/results/FDHT_A2_2_Verified_Bloom_Partition_Tree.md |

| A2-SYN₀ | CLOSED | CRITERIA_SYNTHESIS | A2₂ | — | research/results/FDHT_A2_SYN0_Non_Circular_Pruning_Criteria.md |

| A2-SYN₀-M | CLOSED | MAPPING_AUDIT | A2-SYN₀ | — | research/results/FDHT_A2_SYN0M_Criteria_Coverage_Mapping.md |

| A2-SYN₁ | CLOSED | OPERATIONALISATION | A2-SYN₀-M | — | research/results/FDHT_A2_SYN1_Operationalised_Criteria.md |

| VRRD₀-F | CLOSED | FEASIBILITY_AUDIT | A2-SYN₁ | — | research/results/FDHT_VRRD0F_Feasibility_Audit.md |

| VRRD₀ | CLOSED | MICROSCOPIC_PROBE | VRRD₀-F | — | research/results/FDHT_VRRD0_Microscopic_Radix_Range_Pruning.md |

| VRRD₀-C | CLOSED | A0_CORRECTION | VRRD₀ | — | research/results/FDHT_VRRD0C_A0_Exhaustive_Trace_Correction.md |

| SE₀ | CLOSED | STORAGE_PROBE | VRRD₀-C | — | research/results/FDHT_SE0_Derived_Storage_Versus_Routing_Resolution.md |
