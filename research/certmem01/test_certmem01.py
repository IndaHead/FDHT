#!/usr/bin/env python3
"""Tests for CERTMEM-01."""
import json
from pathlib import Path

def test_obligations_frozen():
    o = json.loads(Path("research/certmem01/FROZEN_OBLIGATIONS.json").read_text())
    assert o["frozen_before_mapping"] is True
    assert len(o["obligations"]) == 10
    assert o["no_seventh_class"] is True

def test_absorption():
    r = json.loads(Path("research/certmem01/CERTMEM01_RESULTS.json").read_text())
    assert r["primary_disposition"] == "CERTIFIED_VALID"
    assert r["seventh_class_pressure"] is False
    assert r["authority_not_promoted"] is True

if __name__ == "__main__":
    test_obligations_frozen()
    test_absorption()
    print("All CERTMEM-01 tests passed.")
