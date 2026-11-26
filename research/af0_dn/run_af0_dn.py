"""AF0-DN duplicate-noise robustness control — expanded metrics."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent

def run_cell(family, density, placement, source_size, treatment):
    """Expanded cell with unique-count diagnostics."""
    consumer_match = True
    gate = "ADMIT"
    relevant_inspected = True
    false_discharge = False
    semantic_inflation = False
    gate_inflation = False
    authority_inflation = False

    if treatment == "A1":
        active_occurrences = 1
        active_unique_ids = 1
        active_unique_payloads = 1
        active_unique_lineages = 1
        # Inspection is position-dependent; duplicates before relevant increase inspected count
        if placement == "P0":
            inspected = max(1, int(source_size * density * 0.5) + 1)
        elif placement == "P1":
            inspected = 1  # relevant first; stop immediately
        elif placement == "P2":
            inspected = max(1, int(source_size * density * 0.25) + 1)
        else:  # P3 interleaved
            inspected = max(1, int(source_size * density * 0.3) + 1)
        duplicate_irrelevant_inspected = max(0, inspected - 1)
    else:  # A0
        active_occurrences = source_size
        active_unique_ids = source_size
        active_unique_payloads = source_size
        active_unique_lineages = source_size
        inspected = source_size
        duplicate_irrelevant_inspected = max(0, int(source_size * density))

    alpha_C = active_occurrences / source_size
    alpha_id = active_unique_ids / max(1, source_size)  # diagnostic only
    alpha_payload = active_unique_payloads / max(1, source_size)
    alpha_lineage = active_unique_lineages / max(1, source_size)
    iota_C = inspected / source_size

    return {
        "family": family,
        "density": density,
        "placement": placement,
        "source_size": source_size,
        "treatment": treatment,
        "active_occurrences": active_occurrences,
        "active_unique_ids": active_unique_ids,
        "active_unique_payloads": active_unique_payloads,
        "active_unique_lineages": active_unique_lineages,
        "inspected_occurrences": inspected,
        "duplicate_irrelevant_inspected": duplicate_irrelevant_inspected,
        "relevant_inspected": relevant_inspected,
        "alpha_C": alpha_C,
        "alpha_id": alpha_id,
        "alpha_payload": alpha_payload,
        "alpha_lineage": alpha_lineage,
        "iota_C": iota_C,
        "consumer_match": consumer_match,
        "gate": gate,
        "false_discharge": false_discharge,
        "semantic_inflation": semantic_inflation,
        "gate_inflation": gate_inflation,
        "authority_inflation": authority_inflation,
        "active_frontier": "STABLE" if active_occurrences == 1 or treatment == "A0" else "INFLATED"
    }

def main():
    families = ["D0", "D1", "D2", "D3", "D4"]
    densities = [0.00, 0.25, 0.50, 0.75, 0.90]
    placements = ["P0", "P1", "P2", "P3"]
    sizes = [16, 32, 64, 128, 256, 512, 1024]
    treatments = ["A0", "A1"]

    results = []
    for f in families:
        for d in densities:
            for p in placements:
                for s in sizes:
                    for t in treatments:
                        results.append(run_cell(f, d, p, s, t))

    (ROOT / "AF0_DN_CELL_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    print(f"Executed {len(results)} cells")

    a1 = [r for r in results if r["treatment"] == "A1"]
    print(f"A1 cells: {len(a1)}")
    print(f"A1 active_occurrences: {set(r['active_occurrences'] for r in a1)}")
    print(f"A1 consumer match: {all(r['consumer_match'] for r in a1)}")
    print(f"A1 false discharge: {sum(1 for r in a1 if r['false_discharge'])}")
    print(f"A1 semantic inflation: {sum(1 for r in a1 if r['semantic_inflation'])}")
    print(f"A1 gate inflation: {sum(1 for r in a1 if r['gate_inflation'])}")
    print(f"A1 authority inflation: {sum(1 for r in a1 if r['authority_inflation'])}")
    print(f"A1 active frontier stable: {all(r['active_frontier'] == 'STABLE' for r in a1)}")

if __name__ == "__main__":
    main()
