# OC0 — Open Conjecture Pilot

**Status:** NO VERIFIED PROGRESS; CONJECTURE REMAINS OPEN  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `0d02fd8609893bc705f9378d1273d3936012471f`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/blind-math-necessity |
| Starting HEAD | 0d02fd8609893bc705f9378d1273d3936012471f |
| Working branch | research/open-conjecture-pilot |

## 2. Working Branch

research/open-conjecture-pilot

## 3. Final HEAD

(recorded after commit)

## 4. External Source

| Property | Value |
|----------|-------|
| Repository | google-deepmind/formal-conjectures |
| Commit | da703a5f239f |
| File | FormalConjectures/OEIS/232174.lean |
| Identifier | OeisA232174.conjecture |
| Category | OEIS |
| OEIS | A232174 |

## 5. Open-Status Audit

**OPEN_STATUS_CONFIRMED**

Source marks the conjecture as `research open`. No accepted proof or disproof documented in source metadata.

## 6. Semantic Correspondence

**SUFFICIENTLY_FAITHFUL_FOR_FIXTURE**

Formal statement matches informal conjecture on domain, quantifiers, decomposition, and both prime conditions.

## 7. Digests

| Item | Digest |
|------|--------|
| Source manifest | `d0c2e5b2823cdac3...` |
| Frozen conjecture | `e5a6f0fd7729299f...` |
| Semantic audit | `f1d22b6617c5bef3...` |
| Known boundary | `d9681f2af68e9455...` |
| Generic analysis | `993cac6cd3b4b5e5...` |
| FDHT analysis | `ef41ba0c6669082f...` |

## 8. Conjecture Statement

Any integer n > 1 can be written as x + y with x, y > 0 such that both x + n*y and x² + n*y² are prime.

## 9. Known Results Boundary

Source-verified special cases: n=2,3,4,5,6,8. No general proof documented.

## 10. Pre-Attempt Predictions

| Arm | Expected Terminal State |
|-----|------------------------|
| Generic | EXPECT_OPEN |
| FDHT | EXPECT_OPEN |

## 11. Matched-Budget Audit

| Property | Value |
|----------|-------|
| Model | Same (deterministic) |
| Visible input | Identical |
| Known-results boundary | Identical |
| Tool budget | Matched |

## 12. Generic Arm Results

| Metric | Value |
|--------|-------|
| Verified special cases | a_7 |
| Full proof | NO |
| Counterexample | NO |
| Progress category | NO_VERIFIED_PROGRESS |
| Terminal state | OPEN |

## 13. FDHT Arm Results

| Metric | Value |
|--------|-------|
| Verified special cases | a_7 |
| Full proof | NO |
| Counterexample | NO |
| Progress category | NO_VERIFIED_PROGRESS |
| Terminal state | OPEN |

## 14. Comparative Measurements

| Metric | Generic | FDHT |
|--------|---------|------|
| Successful Lean proofs | 1 (special case) | 1 (special case) |
| Counterexamples | 0 | 0 |
| Full proofs | 0 | 0 |
| Verified special cases | 1 | 1 |
| Terminal state | OPEN | OPEN |

## 15. Primary FDHT Utility Test

No FDHT-specific utility observed. Both arms produce equivalent results: one verified special case (n=7) and no general progress.

## 16. Anti-Contamination Audit

| Attack | Result |
|--------|--------|
| Source-status error | PASS |
| Formalisation mismatch | PASS |
| Oracle fiction | PASS |
| Generic sabotage | PASS |
| FDHT answer-key | PASS |
| Budget drift | PASS |
| Post-hoc prediction | PASS |
| Trivial-special-case inflation | PASS |
| Assumption inflation | PASS |
| Circular reduction | PASS |
| Numerical-evidence promotion | PASS |
| Compiler-error promotion | PASS |
| Natural-language proof promotion | PASS |
| Known-result novelty | PASS |
| FDHT-branding promotion | PASS |
| Open-to-failure collapse | PASS |
| Open-to-continue collapse | PASS |

## 17. Classification

**D — NO VERIFIED PROGRESS; CONJECTURE REMAINS OPEN**

## 18. Classification Justification

Neither arm produces a full proof, counterexample, strict reduction, non-vacuous conditional result, or formal obstruction beyond known results. Both arms verify one additional special case (n=7) not in the source test cases, but this does not constitute verified progress on the general conjecture. The conjecture remains open.

## 19. Justified Claims

- Open status confirmed from source.
- Semantic correspondence sufficient.
- Both arms produce equivalent results.
- Conjecture remains open.
- No contamination occurred.

## 20. Unjustified Claims

- FDHT mathematical superiority.
- FDHT as a theorem prover.
- Solution to the conjecture.
- Permanent FDHT mathematics.

## 21. Permanent FDHT Pressure

NONE

## 22. New Mathematics Justified

NO

## 23. New Abstraction Justified

NO

## 24. Promotion Justified

NO

## 25. Next Stage Justified

NO

## 26. Limitations

- Single conjecture.
- Bounded exploration.
- Deterministic reasoning.
- Special case verification is not general progress.

## 27. Recommended Action

**STOP**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Conjecture status: **OPEN**  
FDHT-specific utility: **NOT ESTABLISHED**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
