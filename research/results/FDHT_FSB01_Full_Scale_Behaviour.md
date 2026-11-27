# FDHT FSB-01 First Full-Scale Behaviour Probe

## Classification
A — REQUIREMENT-RELATIVE ACTIVE AND QUERY BEHAVIOUR OBSERVED ACROSS FULL TESTED SCALE

## Summary
Across the frozen deterministic source family N = 64 … 16384, with fixed requirements R1 (single identity, multiplicity 1), R2 (four identities), and R_absent:

- Active count for R1 remained exactly 1 at every scale (ACTIVE_FIXED).
- Candidate count for R1 remained exactly 1 (CANDIDATE_FIXED).
- Exact-index query inspections tracked presence/absence (1 for present identities; full scan for absent).
- Semantic equivalence between oracle, sequential, exact-index + source-threaded verification held for all cells.
- Fate-profile regression (membership/multiplicity sufficient; absent empty) passed at N = 64, 1024, 16384.
- Index storage grew approximately linearly with N over the tested range (descriptive only).

No fractality tested. No asymptotic claims. No fdht/ modification. A2 semantics preserved.

## Claim boundary
Finite-range observation only. Does not establish asymptotic complexity, runtime complexity, fractality, or promotion.
