#!/usr/bin/env python3
"""Oracle external system for BSN0.

COMPLETE. Contains all invariants, visible fixtures, and hidden fixtures.
This module must not be imported by treatment or control arms.

External system: Versioned Accumulator with Path-Sensitive Audit.

State: (accumulator_value, path_tag, merge_count)
Projection: accumulator_value only
Merge: max(value), concatenate path_tags, increment merge_count
Audit: path-sensitive operation that the visible spec does not reveal
"""

from dataclasses import dataclass, field
from typing import List, Optional, Tuple
from enum import Enum
import hashlib
import json

class OracleResult(Enum):
    VALID = "VALID"
    INVALID = "INVALID"
    AUDIT_REQUIRED = "AUDIT_REQUIRED"

@dataclass
class AccumulatorState:
    value: int
    path_tag: str
    merge_count: int

    def project(self) -> int:
        """Consumer-visible projection. Does not reveal path_tag or merge_count."""
        return self.value

    def to_dict(self):
        return {"value": self.value, "path_tag": self.path_tag, "merge_count": self.merge_count}

def initial(tag: str) -> AccumulatorState:
    return AccumulatorState(value=0, path_tag=tag, merge_count=0)

def increment(state: AccumulatorState, amount: int, tag: str) -> AccumulatorState:
    return AccumulatorState(
        value=state.value + amount,
        path_tag=f"{state.path_tag}+{tag}",
        merge_count=state.merge_count,
    )

def merge(a: AccumulatorState, b: AccumulatorState) -> AccumulatorState:
    """Merge takes max value. Path tags are concatenated. Merge count increments."""
    return AccumulatorState(
        value=max(a.value, b.value),
        path_tag=f"M({a.path_tag}|{b.path_tag})",
        merge_count=a.merge_count + b.merge_count + 1,
    )

def audit(state: AccumulatorState) -> OracleResult:
    """Hidden path-sensitive audit. Not visible in the public specification.
    
    Returns INVALID if path_tag contains a forbidden pattern.
    Returns AUDIT_REQUIRED if merge_count exceeds threshold.
    Returns VALID otherwise.
    """
    if "FORBIDDEN" in state.path_tag:
        return OracleResult.INVALID
    if state.merge_count > 5:
        return OracleResult.AUDIT_REQUIRED
    return OracleResult.VALID

# ============================================================
# Hidden invariants (not exposed to treatment/control)
# ============================================================

HIDDEN_INVARIANTS = {
    "H1_unsafe_collapse": "Equal projected value does not imply equal audit result when path_tag differs",
    "H2_safe_collapse": "Different path_tags with same value and no forbidden pattern are consumer-equivalent",
    "H3_temporary_difference": "Intermediate states with different values are valid during partition",
    "H4_path_dependent": "Same final value via different paths may differ under audit",
    "H5_history_irrelevant": "Merge order does not affect final value when no forbidden tags present",
    "H6_projection_trap": "Equal projection does not imply equal path_tag",
    "H7_redundant_detail": "merge_count below threshold has no consumer consequence",
    "H8_missing_distinction": "path_tag content is required for audit but not obvious from value/merge vocabulary",
}

# ============================================================
# Visible fixtures (exposed to treatment/control)
# ============================================================

def visible_fixtures():
    """Fixtures that treatment and control may see."""
    a = initial("A")
    a = increment(a, 5, "inc1")
    b = initial("B")
    b = increment(b, 3, "inc1")
    merged = merge(a, b)
    return {
        "v1_increment": {"state": a.to_dict(), "projection": a.project()},
        "v2_partition": {"a": a.to_dict(), "b": b.to_dict(), "a_proj": a.project(), "b_proj": b.project()},
        "v3_merge": {"result": merged.to_dict(), "projection": merged.project()},
        "v4_equal_projection": {
            "x": AccumulatorState(10, "X", 0).to_dict(),
            "y": AccumulatorState(10, "Y", 0).to_dict(),
            "x_proj": 10, "y_proj": 10,
        },
    }

# ============================================================
# Hidden fixtures (NOT exposed until after prediction freeze)
# ============================================================

def hidden_fixtures():
    """Hidden fixtures. Must not be accessed by treatment/control before reveal."""
    results = {}

    # H1: Unsafe collapse — equal projection, different audit
    s1 = AccumulatorState(10, "SAFE", 0)
    s2 = AccumulatorState(10, "FORBIDDEN_PATH", 0)
    results["H1"] = {
        "s1_proj": s1.project(), "s2_proj": s2.project(),
        "s1_audit": audit(s1).value, "s2_audit": audit(s2).value,
        "distinction_required": True,
    }

    # H2: Safe collapse — different paths, same consumer outcome
    s3 = AccumulatorState(10, "PATH_A", 0)
    s4 = AccumulatorState(10, "PATH_B", 0)
    results["H2"] = {
        "s3_audit": audit(s3).value, "s4_audit": audit(s4).value,
        "distinction_required": False,
    }

    # H3: Temporary difference — partition is valid
    a = initial("A"); a = increment(a, 5, "x")
    b = initial("B"); b = increment(b, 3, "y")
    results["H3"] = {
        "a_proj": a.project(), "b_proj": b.project(),
        "both_valid": audit(a) == OracleResult.VALID and audit(b) == OracleResult.VALID,
        "distinction_required": False,
    }

    # H4: Path-dependent — same value, different paths, audit differs
    p1 = increment(initial("A"), 10, "SAFE")
    p2 = increment(initial("A"), 10, "FORBIDDEN")
    results["H4"] = {
        "p1_proj": p1.project(), "p2_proj": p2.project(),
        "p1_audit": audit(p1).value, "p2_audit": audit(p2).value,
        "distinction_required": True,
    }

    # H5: History-irrelevant — merge order doesn't matter for value
    x = increment(initial("A"), 5, "a")
    y = increment(initial("B"), 3, "b")
    m1 = merge(x, y)
    m2 = merge(y, x)
    results["H5"] = {
        "m1_proj": m1.project(), "m2_proj": m2.project(),
        "equal_proj": m1.project() == m2.project(),
        "distinction_required": False,
    }

    # H6: Projection trap — equal projection, different underlying state
    t1 = AccumulatorState(10, "ALPHA", 0)
    t2 = AccumulatorState(10, "BETA", 1)
    results["H6"] = {
        "t1_proj": t1.project(), "t2_proj": t2.project(),
        "t1_audit": audit(t1).value, "t2_audit": audit(t2).value,
        "distinction_required": False,
    }

    # H7: Redundant detail — merge_count below threshold is irrelevant
    r1 = AccumulatorState(10, "R", 0)
    r2 = AccumulatorState(10, "R", 3)
    results["H7"] = {
        "r1_audit": audit(r1).value, "r2_audit": audit(r2).value,
        "distinction_required": False,
    }

    # H8: Missing distinction — path_tag content required but not in value/merge vocabulary
    m1 = AccumulatorState(10, "NORMAL", 0)
    m2 = AccumulatorState(10, "FORBIDDEN_X", 0)
    results["H8"] = {
        "m1_audit": audit(m1).value, "m2_audit": audit(m2).value,
        "distinction_required": True,
    }

    return results

def oracle_digest() -> str:
    """Canonical digest of the complete oracle."""
    content = json.dumps({
        "invariants": HIDDEN_INVARIANTS,
        "visible": visible_fixtures(),
        "hidden": hidden_fixtures(),
    }, sort_keys=True, default=str)
    return hashlib.sha256(content.encode()).hexdigest()
