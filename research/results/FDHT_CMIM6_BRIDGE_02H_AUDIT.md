# FDHT CMIM6-BRIDGE-02H-AUDIT

## Classification
A — EXACT ZERO-CMI ↔ MARKOV API AUDITED; 02H PROOF GATE OPEN

## Summary
Exact upstream theorem recovered under Lean 4.33.1:

condMutualInfoOf_eq_zero_iff_isMarkovChainOf
  {omega} {alpha} {beta} {gamma}
  [Fintype alpha] [Fintype beta] [Fintype gamma]
  (p : PMF omega) (X : omega → alpha) (Y : omega → beta) (Z : omega → gamma) :
  condMutualInfoOf p X Z Y = 0 ↔ IsMarkovChainOf p X Y Z

Codomain of condMutualInfoOf: ℝ

Required Fintype: alpha (id range = Ω), beta (M range = A), gamma (C range = B)

No explicit DecidableEq. No Nonempty. No explicit classical.

Orientation confirmed: condMutualInfoOf p id C M = 0 ↔ IsMarkovChainOf p id M C

Wrong order rejected by type mismatch.

Axiom footprint: propext, Classical.choice, Quot.sound (inherited).

## Claim boundary
Does not yet prove SupportSufficient ↔ zero CMI.
