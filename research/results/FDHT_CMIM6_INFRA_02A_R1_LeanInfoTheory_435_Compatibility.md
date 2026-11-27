# FDHT CMIM6-INFRA-02A-R1 LeanInfoTheory v0.2.0 → Lean 4.35.0 Compatibility

## Classification
D — LEAN 4.35 COMPATIBILITY REMAINS BLOCKED

## Summary
Phase 0–3 succeeded for the correct upstream:

- Repository: https://github.com/serhatemrecoban/LeanInfoTheory
- Tag v0.2.0 → 953b785fbdbcc9bffe22834124d5e1cbd14a4835
- Upstream toolchain: leanprover/lean4:v4.33.1
- Upstream mathlib: v4.33.1
- Full LeanInfoTheory build under Lean 4.33.1: SUCCESS (2605 jobs)
- Load-bearing API present and matches expected form:
  - IsMarkovChainOf p X Y Z := IsCondIndependentOf p X Z Y
  - condMutualInfoOf p X Z Y = 0 ↔ IsMarkovChainOf p X Y Z
- No sorry/admit/axiom in Markov.lean

Phase 5 (isolated 4.35 port) failed at dependency resolution.

After changing only lean-toolchain and lakefile.toml to request Lean 4.35.0 / mathlib v4.35.0, `lake update` produced parser errors in `.lake/packages/mathlib/lakefile.lean` (unknown namespace Lake, unexpected identifiers, CoeFun unknown). This is a DEPENDENCY_RESOLUTION failure.

No mathematical source was edited. No sorry/admit/custom axioms introduced. Baseline evidence preserved.

REENTRY_ELIGIBLE = NO

## Claim boundary
Infrastructure only. Does not establish the SufficientForP ↔ Markov ↔ CMI bridge, nor any CERTMEM-02 probabilistic result.
