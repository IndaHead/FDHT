#!/usr/bin/env python3
"""Minimal tests for FG-03 frozen artefacts and negative fractality results."""
import json
from pathlib import Path

def test_criteria_frozen_first():
    c = json.loads(Path("research/fg03/FROZEN_FRACTALITY_CRITERIA.json").read_text())
    assert c["frozen_before_graph_inspection"] is True
    assert "D1_exact_self_similarity" in c["notions"]

def test_no_exact_self_similarity():
    r = json.loads(Path("research/fg03/EXACT_SELF_SIMILARITY.json").read_text())
    assert r["exact_typed_isomorphisms_found"] == 0
    assert r["result"] == "NO_EXACT_SELF_SIMILARITY"

def test_insufficient_scale():
    r = json.loads(Path("research/fg03/BOX_COVER_RESULTS.json").read_text())
    assert r["result"] == "INSUFFICIENT_SCALE_RANGE"
    assert r["usable_scale_count"] < r["scale_range_requirement"]

def test_no_natural_family():
    r = json.loads(Path("research/fg03/STATISTICAL_SCALING_RESULTS.json").read_text())
    assert r["natural_graph_family_found"] is False
    assert r["result"] == "NO_NATURAL_GRAPH_FAMILY"

def test_fractal_not_necessary():
    r = json.loads(Path("research/fg03/FRACTAL_NECESSITY_AUDIT.json").read_text())
    assert r["result"] == "FRACTAL_INTERPRETATION_NOT_NECESSARY"

if __name__ == "__main__":
    test_criteria_frozen_first()
    test_no_exact_self_similarity()
    test_insufficient_scale()
    test_no_natural_family()
    test_fractal_not_necessary()
    print("All FG-03 tests passed.")
