#!/usr/bin/env python3
"""Tests for FSB-01 frozen protocol and result invariants."""
import json
from pathlib import Path

def test_protocol_frozen():
    p = json.loads(Path("research/fsb01/FROZEN_PROTOCOL.json").read_text())
    assert p["frozen_before_execution"] is True
    assert p["no_fractality"] is True
    assert 16384 in p["scale_family"]

def test_semantic_equivalence():
    primary = json.loads(Path("research/fsb01/PRIMARY_RESULTS.json").read_text())
    assert all(c["semantic_equivalence"] for c in primary)

def test_r1_active_fixed():
    primary = json.loads(Path("research/fsb01/PRIMARY_RESULTS.json").read_text())
    r1 = [c for c in primary if c["ident"] == "id_r1"]
    assert all(c["active_count"] == 1 and c["candidate_count"] == 1 for c in r1)

def test_absent_empty():
    primary = json.loads(Path("research/fsb01/PRIMARY_RESULTS.json").read_text())
    absent = [c for c in primary if c["ident"] == "id_absent"]
    assert all(c["candidate_count"] == 0 and c["active_count"] == 0 for c in absent)

def test_fate_regression():
    fate = json.loads(Path("research/fsb01/FATE_REGRESSION.json").read_text())
    assert all(f["membership_ok"] and f["multiplicity_ok"] and f["absent_ok"] for f in fate)

if __name__ == "__main__":
    test_protocol_frozen()
    test_semantic_equivalence()
    test_r1_active_fixed()
    test_absent_empty()
    test_fate_regression()
    print("All FSB-01 tests passed.")
