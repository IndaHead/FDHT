# FDHT CMIM6-INFRA-02A-R1 Corrected LeanInfoTheory v0.2.0 Baseline and 4.35 Compatibility

## Classification
D — LEAN 4.35 COMPATIBILITY REMAINS BLOCKED

## Summary
Correct upstream located and frozen: https://github.com/serhatemrecoban/LeanInfoTheory tag v0.2.0 resolves to 953b785fbdbcc9bffe22834124d5e1cbd14a4835.

Baseline under declared Lean 4.33.1 / mathlib v4.33.1:
- Full lake build succeeded.
- Load-bearing API confirmed:
  IsMarkovChainOf p X Y Z := IsCondIndependentOf p X Z Y
  condMutualInfoOf p X Z Y = 0 ↔ IsMarkovChainOf p X Y Z
- Axiom footprint: propext, Classical.choice, Quot.sound.

Minimal metadata port (lean-toolchain and lakefile.toml mathlib rev changed to v4.35.0) failed at dependency resolution:

error: mathlib/lakefile.lean:53:48: expected token
error: mathlib/lakefile.lean: package configuration has errors

First-failure class: DEPENDENCY_RESOLUTION / PARSER_OR_SYNTAX_CHANGE.

No mathematical source edited. No sorry/admit/custom axioms introduced. REENTRY_ELIGIBLE = NO.

## Claim boundary
Infrastructure only. Does not establish the SufficientForP ↔ Markov ↔ CMI bridge.
