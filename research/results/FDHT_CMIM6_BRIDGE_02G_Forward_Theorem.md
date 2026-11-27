# FDHT CMIM6-BRIDGE-02G Forward Theorem

## Classification
D1 — SUPPORT-AWARE CONSUMER-MARGINAL ZERO BLOCKED

## Summary
Fresh external sidecar /tmp/CMIM6_BRIDGE_02G_FORWARD created under Lean 4.33.1 against LeanInfoTheory 953b785.

02E atom package and 02F reverse theorems reproduced and compiled as registered local modules.

Forward skeleton written with:
- supportSufficient_fibre_unique_consumer (trivial, compiles)
- exists_supported_source_of_representation_supported (compiles)
- supportSufficient_consumer_constant_on_representation_fibre (compiles)
- fstThirdMarginal_eq_zero_of_representation_ne (compiles)

The load-bearing support-aware lemma:

sndThirdMarginal_eq_zero_of_supported_fibre_consumer_ne

was not completed. The range-based approach (PMF.map_apply_eq_zero_of_notMem_range) is insufficient because a zero-support preimage may exist; the required argument must use support membership and SupportSufficient to derive contradiction on positive-support fibres. This distinction was frozen as the exact obstruction.

No sorry/admit/custom axioms remain in the committed result. No upstream source modified. No CMI composition. No CERTMEM-02.

## Claim boundary
Forward direction not established. Reverse direction remains verified from 02F. Generic iff not obtained.
