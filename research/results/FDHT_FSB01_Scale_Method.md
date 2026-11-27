# FDHT FSB-01 Scale Method

## Method
1. Freeze protocol, scales, requirements, generator, metrics and falsifiers before any execution.
2. Generate deterministic prefix family X_N (fixed placements for R1/R2 at positions 0–4; sequential thereafter).
3. For each N and each requirement, execute T0–T4 mirroring frozen A2 semantics (ExactIndex via position lists, candidateT, verifiedQueryT via find?, consumers).
4. Record independent channels: available, candidate, inspected, verified, active.
5. Check semantic equivalence and fate-profile regression witnesses.
6. Emit descriptives only; no Big-O, no fractal dimension.

## Controls
Nulls N0–N3 documented; primary family not mixed with multiplicity-growth control.
