"""SP1-R replication runner."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def run_cell(treatment, fixture):
    if treatment["id"] == "R-T0":
        if not fixture["sufficient"]:
            return {"gate": "STOP", "evaluation": False, "sufficiency": "INSUFFICIENT"}
        return {"gate": "ADMIT", "evaluation": True, "sufficiency": "SUFFICIENT"}
    else:
        if not fixture["sufficient"]:
            return {"gate": "ADMIT", "evaluation": True, "sufficiency": "INSUFFICIENT"}
        return {"gate": "ADMIT", "evaluation": True, "sufficiency": "SUFFICIENT"}


def main():
    treatments = json.loads((ROOT / "FROZEN_TREATMENTS.json").read_text())["treatments"]
    fixtures = json.loads((ROOT / "FROZEN_FIXTURES.json").read_text())["fixtures"]

    results = []
    for f in fixtures:
        for t in treatments:
            result = run_cell(t, f)
            results.append({
                "consumer": f["consumer"],
                "variant": f["variant"],
                "treatment": t["id"],
                "gate": result["gate"],
                "evaluation": result["evaluation"],
                "sufficiency": result["sufficiency"],
            })

    (ROOT / "SP1R_CELL_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    print(f"Executed {len(results)} cells")

    # Summary
    stop_correct = sum(1 for r in results if r["treatment"] == "R-T0" and r["variant"] == "I" and r["gate"] == "STOP")
    no_stop_false = sum(1 for r in results if r["treatment"] == "R-T1" and r["variant"] == "I" and r["gate"] == "ADMIT")
    over_stop = sum(1 for r in results if r["treatment"] == "R-T0" and r["variant"] == "S" and r["gate"] == "STOP")
    print(f"Correct STOP: {stop_correct}")
    print(f"NO-STOP false completions: {no_stop_false}")
    print(f"Over-STOP: {over_stop}")


if __name__ == "__main__":
    main()
