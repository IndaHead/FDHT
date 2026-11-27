# FDHT CMIM6-BRIDGE-02G-R2 Matching-Fibre Mass Equality

## Classification
A — MATCHING-FIBRE MASS EQUALITY VERIFIED GENERICALLY

## Summary
Reused verified LeanInfoTheory 953b785 / Lean 4.33.1 dependency tree.

Proved:
- consumerRepresentation_preimage_iff_on_support
- consumerRepresentation_mass_eq_representation_mass_of_supportSufficient
- sndThirdMarginal_eq_thirdMarginal_of_supportSufficient

The matching consumer/representation marginal carries exactly the representation-fibre mass under SupportSufficient for supported x.

Used PMF.map_apply + tsum_congr with support-relative preimage equivalence.
No Fintype/DecidableEq/Nonempty assumptions added.
No sorry/admit/custom axioms.
Cold recompile succeeded.
Axiom footprint: propext, Classical.choice, Quot.sound (inherited).

## Claim boundary
Does not establish SupportSufficient → conditional independence or Markov.
