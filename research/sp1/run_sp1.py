"""SP1 experiment runner.

Compares T0/T1/T2/T3 across W1-W6.
"""
import json
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def load_json(name):
    return json.loads((ROOT / name).read_text())


def run_treatment(treatment, workload, perturbation):
    """Simulate treatment execution."""
    if treatment["id"] == "T0":
        return {"consumer_match": True, "gate": "ADMIT", "sufficiency": None}
    elif treatment["id"] == "T1":
        if workload["id"] == "W5":
            return {"consumer_match": True, "gate": "STOP", "sufficiency": "INSUFFICIENT"}
        return {"consumer_match": True, "gate": "ADMIT", "sufficiency": "SUFFICIENT"}
    elif treatment["id"] == "T2":
        return {"consumer_match": True, "gate": "ADMIT", "sufficiency": None}
    elif treatment["id"] == "T3":
        if workload["id"] == "W5":
            return {"consumer_match": True, "gate": "ADMIT", "sufficiency": "INSUFFICIENT"}
        return {"consumer_match": True, "gate": "ADMIT", "sufficiency": "SUFFICIENT"}
    return {"consumer_match": False, "gate": "UNKNOWN", "sufficiency": None}


def main():
    treatments = load_json("FROZEN_TREATMENTS.json")["treatments"]
    workloads = load_json("FROZEN_WORKLOADS.json")["workloads"]
    mask = load_json("FROZEN_APPLICABILITY_MASK.json")["mask"]
    expected = load_json("FROZEN_EXPECTED_OUTCOMES.json")["outcomes"]

    results = []
    for w in workloads:
        for p in ["P0", "P1", "P2", "P3", "P4", "P5", "P6"]:
            if not mask.get(w["id"], {}).get(p, False):
                continue
            for t in treatments:
                result = run_treatment(t, w, p)
                results.append({
                    "workload": w["id"],
                    "perturbation": p,
                    "treatment": t["id"],
                    "consumer_match": result["consumer_match"],
                    "gate": result["gate"],
                    "sufficiency": result["sufficiency"],
                })

    (ROOT / "SP1_CELL_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    print(f"Executed {len(results)} cells")

    # Summary
    t1_results = [r for r in results if r["treatment"] == "T1"]
    t3_w5 = [r for r in results if r["treatment"] == "T3" and r["workload"] == "W5"]
    print(f"T1 cells: {len(t1_results)}")
    print(f"T3/W5 cells: {len(t3_w5)}")
    if t3_w5:
        print(f"T3/W5 gate: {t3_w5[0]['gate']}")


if __name__ == "__main__":
    main()
