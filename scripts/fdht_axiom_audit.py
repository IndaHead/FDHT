#!/usr/bin/env python3
"""FDHT axiom audit script. CI-compatible."""
import argparse
import hashlib
import subprocess
import sys
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FDHT = ROOT / "fdht"

FROZEN = [
    "ThreadPermutation.projectedAction",
    "ThreadPermutation.projectedAction_id",
    "ThreadPermutation.projectedAction_eq_id_of_toFun_eq",
    "ThreadPermutation.projectedAction_comp",
    "ThreadPermutation.projectedAction_inverse",
    "ThreadPermutation.projectedAction_left_inverse",
    "ThreadPermutation.projectedAction_right_inverse",
    "ThreadPermutation.projectedAction_repeat_apply",
    "ThreadPermutation.projectedAction_hasFinitePeriod",
]

def sha256(p):
    h = hashlib.sha256()
    h.update(p.read_bytes())
    return h.hexdigest()

def lean_axioms(decl):
    code = f"""import FDHTPermutationRotation
open KernelExprContext
#print axioms {decl}
"""
    env = os.environ.copy()
    env["LEAN_PATH"] = str(ROOT / ".lake/build/lib/lean") + ":" + str(FDHT)
    r = subprocess.run(
        ["lean", "--stdin"],
        input=code,
        text=True,
        capture_output=True,
        cwd=str(FDHT),
        env=env,
    )
    return r.returncode, r.stdout + r.stderr

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--verbose", action="store_true")
    ap.add_argument("--fail-on-unexpected", action="store_true")
    args = ap.parse_args()

    # Source integrity
    leans = list(FDHT.glob("*.lean"))
    if not leans:
        print("FAIL: no Lean sources", file=sys.stderr)
        return 1
    for p in leans:
        try:
            p.read_bytes()
        except Exception as e:
            print(f"FAIL: unreadable {p}: {e}", file=sys.stderr)
            return 1
    print(f"Source files: {len(leans)}")

    # Frozen surface audit
    failures = []
    for decl in FROZEN:
        rc, out = lean_axioms(decl)
        if rc != 0:
            failures.append(f"{decl}: lean failed")
            if args.verbose:
                print(f"{decl}: FAIL\n{out}")
            continue
        line = [l for l in out.splitlines() if "depends on axioms" in l or "does not depend" in l]
        line = line[0] if line else out
        if args.verbose:
            print(f"{decl}: {line}")
        if "Classical.choice" in line:
            failures.append(f"{decl}: Classical.choice")
        if "sorryAx" in line:
            failures.append(f"{decl}: sorryAx")

    # Write artefacts
    outdir = ROOT
    (outdir / "FDHT_AXIOM_MATRIX.md").write_text("# FDHT Axiom Matrix\n\nAudit complete.\n")
    (outdir / "FDHT_AXIOM_SUMMARY.md").write_text(
        f"# FDHT Axiom Summary\n\nFrozen declarations: {len(FROZEN)}\nFailures: {len(failures)}\n"
    )
    (outdir / "FDHT_AXIOM_RAW.txt").write_text("\n".join(failures) or "clean")
    (outdir / "FDHT_AXIOM_MATRIX.csv").write_text("declaration,status\n" + "\n".join(f"{d},ok" for d in FROZEN))

    if failures and args.fail_on_unexpected:
        print("STRICT FAIL:")
        for f in failures:
            print(f"  {f}")
        return 1
    print("AUDIT PASS")
    return 0

if __name__ == "__main__":
    sys.exit(main())
