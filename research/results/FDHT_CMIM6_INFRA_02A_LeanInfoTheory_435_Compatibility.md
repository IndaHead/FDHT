# FDHT CMIM6-INFRA-02A LeanInfoTheory v0.2.0 → Lean 4.35.0 Compatibility Falsification

## Classification
E — UPSTREAM v0.2.0 BASELINE COULD NOT BE REPRODUCED

## Summary
Phase 0 (FDHT provenance) succeeded: HEAD b6d4c82c3abb04959cc7ba93b82a1fc1048201ce, clean worktree (except pre-existing untracked RSA0), Lean 4.35.0, empty fdht/ diff.

Phase 1 failed: the exact upstream repository and tag LeanInfoTheory v0.2.0 (with LeanInfoTheory/Shannon/SemanticBridge/Markov.lean containing IsMarkovChainOf and condMutualInfoOf_eq_zero_iff_isMarkovChainOf) could not be acquired from public sources.

Clone attempts against leanprover-community/LeanInfoTheory and remydegenne/LeanInfoTheory returned "repository not found". Broader search did not locate a matching public package pinned to Lean 4.33.1 / mathlib v4.33.1 exposing the required API surface.

Without a reproducible frozen baseline, no port to Lean 4.35.0 was attempted.

No FDHT source was modified. No compatibility library was committed into FDHT. No sorry, admit, or custom axioms introduced.

A clean E result is valid evidence.

## Claim boundary
Infrastructure acquisition blocked. Does not establish or refute mathematical compatibility of any information-theory substrate with Lean 4.35.0.
