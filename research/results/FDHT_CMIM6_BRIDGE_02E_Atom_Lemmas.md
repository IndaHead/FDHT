# FDHT CMIM6-BRIDGE-02E Deterministic Triple Atom and Marginal Lemmas

## Classification
D4 — SIDECAR/BUILD ENVIRONMENT REGRESSED

## Summary
Standalone sidecar created at /tmp/CMIM6_BRIDGE_02E_ATOMS with:
- lean-toolchain: leanprover/lean4:v4.33.1
- lakefile.toml depending on LeanInfoTheory rev 953b785fbdbcc9bffe22834124d5e1cbd14a4835
- CMIM6AtomLemmas.lean containing all required injectivity, exact-atom, consumer-mismatch, marginal normal-form, support-transport, positivity, and reverse-collision packaging lemmas.

Previous smoke (BRIDGE-02D) confirmed that an external Lake project elaborates IsMarkovChainOf under Lean 4.33.1.

Repeated full builds of the 02E sidecar exhausted available disk space (error code 28) before the research file could be fully compiled and cold-rebuilt. No mathematical source of LeanInfoTheory was modified. No sorry/admit/custom axioms present in the prepared file.

The lemmas are written to the exact specifications of the probe using the verified upstream APIs (PMF.map_apply_of_injective, PMF.map_apply_eq_zero_of_notMem_range, PMF.mem_support_iff, PMF.mem_support_map_iff, PMF.map_comp).

## Claim boundary
Environment blocked. Does not establish the atom foundation as compiled. Does not open BRIDGE-02F.
