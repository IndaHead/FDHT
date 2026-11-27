#!/usr/bin/env python3
"""Tests for CIDX-01."""
import json
from pathlib import Path

def test_protocol_frozen():
    p = json.loads(Path("research/cidx01/FROZEN_PROTOCOL.json").read_text())
    assert p["frozen_before_execution"] is True

def test_semantic_and_t2():
    primary = json.loads(Path("research/cidx01/PRIMARY_RESULTS.json").read_text())
    assert all(p["semantic_eq"] for p in primary)
    assert all(p["t2"] == "STOP_INSUFFICIENT_EVIDENCE" for p in primary)

def test_certified_absence_local():
    primary = json.loads(Path("research/cidx01/PRIMARY_RESULTS.json").read_text())
    absent = [p for p in primary if p["req"] == "R_absent"]
    assert all(p["t3"] == "verifiedAbsent" and p["t3_source_inspections"] == 0 for p in absent)

def test_attacks_rejected():
    attacks = json.loads(Path("research/cidx01/ATTACK_RESULTS.json").read_text())
    assert all(a["rejected"] for a in attacks)

if __name__ == "__main__":
    test_protocol_frozen()
    test_semantic_and_t2()
    test_certified_absence_local()
    test_attacks_rejected()
    print("All CIDX-01 tests passed.")
