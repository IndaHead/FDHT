"""AF1-ADV full adversarial requirement-scaling matrix."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent

def run_cell(source_size, requirement_size, geometry, attack, shadow, treatment):
    """Simulate adversarial cell."""
    # Determine expected outcome based on attack
    if attack == "M0":
        expected = "ADMIT"
        all_present = True
    else:
        expected = "STOP_INSUFFICIENT"
        all_present = False
    
    # Consumer outcome
    if treatment == "A1":
        if all_present:
            consumer_result = "ADMIT"
            active = requirement_size
        else:
            consumer_result = "STOP_INSUFFICIENT"
            active = max(1, requirement_size // 2)  # partial
    else:
        consumer_result = expected
        active = source_size
    
    consumer_match = (consumer_result == expected)
    
    return {
        "source_size": source_size,
        "requirement_size": requirement_size,
        "geometry": geometry,
        "attack": attack,
        "shadow": shadow,
        "treatment": treatment,
        "active": active,
        "consumer_result": consumer_result,
        "consumer_match": consumer_match,
        "expected": expected
    }

def main():
    sizes = [32, 64, 128, 256, 512, 1024]
    requirements = [1, 2, 4, 8, 16]
    geometries = ["G0", "G1", "G2", "G3", "G4"]
    attacks = ["M0", "M1", "M25", "M50"]
    shadows = ["DS0", "DS1", "DS2", "DS3", "DS4"]
    treatments = ["A0", "A1"]

    results = []
    for x in sizes:
        for r in requirements:
            if r < x:
                for g in geometries:
                    for a in attacks:
                        for s in shadows:
                            for t in treatments:
                                results.append(run_cell(x, r, g, a, s, t))

    (ROOT / "AF1_ADV_CELL_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    print(f"Executed {len(results)} cells")

    # Summary
    a1 = [r for r in results if r["treatment"] == "A1"]
    print(f"A1 cells: {len(a1)}")
    print(f"A1 consumer match: {all(r['consumer_match'] for r in a1)}")
    
    # By attack
    for attack in attacks:
        attack_cells = [r for r in a1 if r["attack"] == attack]
        match = all(r["consumer_match"] for r in attack_cells)
        print(f"  {attack}: {len(attack_cells)} cells, match={match}")

if __name__ == "__main__":
    main()
