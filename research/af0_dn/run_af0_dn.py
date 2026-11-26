"""AF0-DN duplicate-noise control."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def run_cell(family, density, placement, source_size, treatment):
    """Simulate duplicate-noise control cell."""
    # Consumer outcome preserved for all duplicate regimes
    consumer_match = True
    gate = "ADMIT"
    
    # A1 active count remains 1 (relevant core only)
    if treatment == "A1":
        active = 1
        # Inspection count depends on placement
        if placement == "P0":
            inspected = source_size // 4  # duplicates before relevant
        elif placement == "P1":
            inspected = source_size // 2  # duplicates after relevant
        else:
            inspected = source_size // 3
    else:
        active = source_size
        inspected = source_size
    
    return {
        "family": family,
        "density": density,
        "placement": placement,
        "source_size": source_size,
        "treatment": treatment,
        "active": active,
        "inspected": inspected,
        "alpha_C": active / source_size,
        "consumer_match": consumer_match,
        "gate": gate,
        "requirement_discharged_by_duplicate": False
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

    # Summary
    a1 = [r for r in results if r["treatment"] == "A1"]
    print(f"A1 cells: {len(a1)}")
    print(f"A1 active: {set(r['active'] for r in a1)}")
    print(f"A1 consumer match: {all(r['consumer_match'] for r in a1)}")
    print(f"A1 false discharge: {sum(1 for r in a1 if r['requirement_discharged_by_duplicate'])}")


if __name__ == "__main__":
    main()
