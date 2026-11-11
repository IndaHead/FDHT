"""
Falsification fixtures for EOP0.
"""

from evidence_obligations import *

def test_f1_status_only():
    """F1: Status-only collapse must not qualify as evidence sufficient."""
    obligations = [
        EvidenceObligation("omega_pos", "req", EvidenceStatus.ESTABLISHED, "claim", "scope", "prov", "v", True)
    ]
    payload = []
    result = judge(payload, obligations)
    assert result == EvidenceStatus.UNRESOLVED, f"Expected UNRESOLVED, got {result}"
    print("F1 PASS")

def test_f2_missing_evidence():
    """F2: Missing evidence must return UNRESOLVED, not REFUTED."""
    obligations = [
        EvidenceObligation("omega_pos", "req", EvidenceStatus.ESTABLISHED, "claim", "scope", "prov", "v", True),
        EvidenceObligation("omega_neg", "req", EvidenceStatus.REFUTED, "claim", "scope", "prov", "v", True)
    ]
    payload = []
    result = judge(payload, obligations)
    assert result == EvidenceStatus.UNRESOLVED, f"Expected UNRESOLVED, got {result}"
    print("F2 PASS")

def test_f3_scope_collapse():
    """F3: Evidence from S1 must not discharge obligation requiring S2."""
    omega = EvidenceObligation("omega", "req", EvidenceStatus.ESTABLISHED, "claim", "S2", "prov", "v", True)
    item = EvidenceItem("item", "claim", True, "src", "prov", "S1", [], "v", True)
    assert not discharges_at(item, omega), "Stale scope must not discharge"
    print("F3 PASS")

def test_f4_provenance_collapse():
    """F4: Matching claim with unacceptable provenance must not discharge."""
    omega = EvidenceObligation("omega", "req", EvidenceStatus.ESTABLISHED, "claim", "scope", "correct_prov", "v", True)
    item = EvidenceItem("item", "claim", True, "src", "wrong_prov", "scope", [], "v", True)
    assert not discharges_at(item, omega), "Wrong provenance must not discharge"
    print("F4 PASS")

def test_f7_conflict_completion():
    """F7: Positive and negative evidence must not choose arbitrary polarity."""
    obligations = [
        EvidenceObligation("omega_pos", "req", EvidenceStatus.ESTABLISHED, "claim", "scope", "prov", "v", True),
        EvidenceObligation("omega_neg", "req", EvidenceStatus.REFUTED, "claim", "scope", "prov", "v", True)
    ]
    payload = [
        EvidenceItem("pos", "claim", True, "src", "prov", "scope", [], "v", True),
        EvidenceItem("neg", "claim", False, "src", "prov", "scope", [], "v", True)
    ]
    result = judge(payload, obligations)
    assert result == EvidenceStatus.UNRESOLVED, f"Expected UNRESOLVED, got {result}"
    print("F7 PASS")

if __name__ == "__main__":
    test_f1_status_only()
    test_f2_missing_evidence()
    test_f3_scope_collapse()
    test_f4_provenance_collapse()
    test_f7_conflict_completion()
    print("All fixture tests passed")
