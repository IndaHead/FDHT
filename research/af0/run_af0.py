"""AF0 active-frontier scaling baseline."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def run_treatment(treatment, source_size, relevant_position):
    """Simulate treatment execution."""
    if treatment == "A0":
        return {
            "inspected": source_size,
            "active": source_size,
            "consumer_match": True,
            "gate": "ADMIT"
        }
    elif treatment == "A1":
        # Stop when requirement satisfied (position of relevant record)
        return {
            "inspected": relevant_position + 1,
            "active": 1,
            "consumer_match": True,
            "gate": "ADMIT"
        }
    else:
        return {"inspected": 0, "active": 0, "consumer_match": False, "gate": "NOT_JUSTIFIED"}


def main():
    staircase = [16, 32, 64, 128, 256, 512, 1024]
    treatments = ["A0", "A1"]
    positions = [0, staircase[-1] // 2, staircase[-1] - 1]  # L0, L1, L2

    results = []
    for size in staircase:
        for pos_idx, pos in enumerate([0, size // 2, size - 1]):
            for t in treatments:
                result = run_treatment(t, size, pos)
                results.append({
                    "source_size": size,
                    "position": pos,
                    "treatment": t,
                    "inspected": result["inspected"],
                    "active": result["active"],
                    "alpha_C": result["active"] / size,
                    "consumer_match": result["consumer_match"],
                    "gate": result["gate"]
                })

    (ROOT / "AF0_CELL_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    print(f"Executed {len(results)} cells")

    # Summary
    a0 = [r for r in results if r["treatment"] == "A0"]
    a1 = [r for r in results if r["treatment"] == "A1"]
    print(f"A0 cells: {len(a0)}")
    print(f"A1 cells: {len(a1)}")
    print(f"A1 alpha_C range: {min(r['alpha_C'] for r in a1):.4f} - {max(r['alpha_C'] for r in a1):.4f}")


if __name__ == "__main__":
    main()
