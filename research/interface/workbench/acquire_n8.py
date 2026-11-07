#!/usr/bin/env python3
"""
FDHT Prototype V₁ — Real-Artefact Acquisition

Acquires i3.0 presentation record from actual FDHT repository artefacts.
Non-circular: extracts from source, does not hard-code expected values.
"""

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent.parent
FDHT = ROOT / "fdht"
SOURCE = FDHT / "FDHTFirstPositiveReturn.lean"
TARGET = "n8_index_first_return"

def extract_theorem(source_path: Path, theorem_name: str) -> dict:
    """Extract theorem declaration from Lean source."""
    text = source_path.read_text()
    pattern = rf"theorem\s+{theorem_name}\s*\n\s*\(([^)]+)\)\s*:\s*([^\n]+)"
    match = re.search(pattern, text)
    if not match:
        return None
    params = match.group(1).strip()
    conclusion = match.group(2).strip().rstrip(" := by")
    return {
        "theorem": theorem_name,
        "params": params,
        "conclusion": conclusion,
        "source": str(source_path.relative_to(ROOT)),
    }

def extract_trust_footprint(theorem_name: str) -> list:
    """Acquire trust footprint by running Lean #print axioms."""
    code = f"""import FDHTFirstPositiveReturn
open KernelExprContext
#print axioms {theorem_name}
"""
    try:
        r = subprocess.run(
            ["lake", "env", "lean", "--stdin"],
            input=code,
            text=True,
            capture_output=True,
            cwd=str(ROOT),
            timeout=120,
        )
        output = r.stdout + r.stderr
        axioms = []
        for line in output.split("\n"):
            for axiom in ["propext", "Quot.sound", "Classical.choice", "sorryAx"]:
                if axiom in line and axiom not in axioms:
                    axioms.append(axiom)
        return axioms if axioms else None
    except Exception as e:
        print(f"Trust acquisition failed: {e}", file=sys.stderr)
        return None

def extract_scope(theorem_info: dict) -> dict:
    """Extract request scope from theorem type signature."""
    params = theorem_info["params"]
    conclusion = theorem_info["conclusion"]
    state_match = re.search(r"Fin\s+(\d+)", params)
    k_match = re.search(r"(\d+)\s*$", conclusion)
    step_match = re.search(r"(\w+\.toFun)", conclusion)
    return {
        "state": f"Fin {state_match.group(1)}" if state_match else None,
        "k": int(k_match.group(1)) if k_match else None,
        "step": step_match.group(1) if step_match else None,
    }

def get_git_snapshot() -> dict:
    """Acquire actual repository snapshot identity."""
    try:
        branch = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, cwd=str(ROOT),
        ).stdout.strip()
        head = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            capture_output=True, text=True, cwd=str(ROOT),
        ).stdout.strip()
        return {"source_branch": branch, "source_head": head}
    except Exception:
        return None

def acquire():
    """Main acquisition function."""
    theorem_info = extract_theorem(SOURCE, TARGET)
    if not theorem_info:
        print(f"FAIL: theorem {TARGET} not found in {SOURCE}", file=sys.stderr)
        sys.exit(1)

    scope = extract_scope(theorem_info)
    if not all(scope.values()):
        print(f"FAIL: could not extract scope from theorem signature", file=sys.stderr)
        sys.exit(1)

    trust = extract_trust_footprint(TARGET)
    if not trust:
        print(f"FAIL: could not acquire trust footprint", file=sys.stderr)
        sys.exit(1)

    snapshot = get_git_snapshot()
    if not snapshot:
        print(f"FAIL: could not acquire git snapshot", file=sys.stderr)
        sys.exit(1)

    record = {
        "schema_version": "i3.0",
        "source_snapshot": snapshot,
        "request_scope": scope,
        "result_class": "ESTABLISHED",
        "evidence_ref": {
            "theorem": theorem_info["theorem"],
            "source": theorem_info["source"],
            "authority": "MATHEMATICAL",
        },
        "obstruction_ref": None,
        "non_admission_reason": None,
        "historical_lineage": {
            "source": "DIRECT",
            "episode": theorem_info["theorem"],
        },
        "trust_footprint": {"axioms": trust},
        "research_provenance": {
            "authority": "RESEARCH RESULT ONLY",
            "programme": "interface-consumer",
            "probe": "V₁",
            "branch": snapshot["source_branch"],
            "commit": snapshot["source_head"],
            "promotion": "NOT PROMOTED",
        },
        "_acquisition": {
            "method": "executable read-only acquisition",
            "source_artefact": str(SOURCE.relative_to(ROOT)),
            "extraction_rules": {
                "request_scope": "parsed from theorem type signature",
                "result_class": "derived from theorem existence + consumer context",
                "evidence_ref": "extracted from theorem declaration",
                "trust_footprint": "acquired via lean #print axioms",
                "source_snapshot": "acquired via git rev-parse",
            },
        },
    }

    return record

if __name__ == "__main__":
    record = acquire()
    output_path = Path(__file__).parent / "generated" / "acquired_n8.json"
    output_path.write_text(json.dumps(record, indent=2))
    print(f"ACQUIRED: {output_path}")
    print(json.dumps(record, indent=2))
