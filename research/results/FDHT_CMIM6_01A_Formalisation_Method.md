# FDHT CMIM6-01A Method Record

## Method
1. Confirmed starting HEAD 90dd0adfdc084fdcc8085524fbc191a44a28888d, clean worktree (except pre-existing untracked RSA0), Lean 4.35.0, empty fdht/ diff.
2. Inspected CERTMEM-02 source (research/certmem02/CERTMEM02_SixClassCertification.lean) — present and unchanged.
3. Searched for LeanInfoTheory / SemanticBridge / IsMarkovChainOf / condMutualInfoOf.
4. No compatible checked package found for Lean 4.35.0.
5. Classified D and STOP. No sorry, no custom axioms, no fabricated bridge.

## Dependencies considered
- mathlib probability (Markov kernels, conditional independence) — does not provide the exact named SemanticBridge API.
- PFR / other entropy formalisations — different signatures, not the required module path.
- No leanprover-community/LeanInfoTheory repository located.
