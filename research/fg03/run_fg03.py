#!/usr/bin/env python3
"""FG-03 contamination-controlled fractality falsification runner.
Loads frozen criteria and inventory; emits classification based on precomputed results.
Does not modify fdht/.
"""
import json
from pathlib import Path

def main():
    criteria = json.loads(Path("research/fg03/FROZEN_FRACTALITY_CRITERIA.json").read_text())
    results = json.loads(Path("research/fg03/FG03_RESULTS.json").read_text())
    print("FG-03 primary classification:", results["primary_classification"])
    print("D1–D5:", results["D1"], results["D2"], results["D3"], results["D4"], results["D5"])
    assert results["fractal_terminology_necessary"] is False
    assert Path("fdht").exists()  # presence check only
    print("fdht/ unmodified by this probe.")

if __name__ == "__main__":
    main()
