# FDHT CMIM6-BRIDGE-02C Proof-Obstruction Audit

## Classification
D3 — BOTH DIRECTIONS FORMALLY BLOCKED

## Summary
Isolated sidecar from LeanInfoTheory v0.2.0 (953b785, Lean 4.33.1 / mathlib v4.33.1) reproduced the baseline build.

SupportSufficient definition and GlobalSufficient → SupportSufficient recreated and match BRIDGE-02B.

Markov normal form derived from source:

IsMarkovChainOf p id M C
↔
IsCondIndependent (p.map (fun ω => (ω, C ω, M ω)))

which expands to the atomwise cross-product:

q (x, b, a) * thirdMarginal q a = fstThirdMarginal q (x, a) * sndThirdMarginal q (b, a)

where q = p.map (tripleMap M C).

Forward and reverse implications not discharged in Lean.

Immediate obstruction in this run: research files under Research/CMIM6/ did not resolve .olean paths under `lake env lean` after successful library build (object file not found for Markov/Independence). No mathematical source of upstream was modified.

Exact remaining obligations frozen as the cross-product expansions for both directions. No counterexample constructed. No sorry/admit/custom axioms.

## Claim boundary
Obstruction audit only. Does not establish the generic bridge. Does not open CERTMEM-03A.
