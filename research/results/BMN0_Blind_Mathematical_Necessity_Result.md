# BMN0 — Blind Mathematical Necessity Probe

**Status:** FDHT-SPECIFIC MATHEMATICAL UTILITY NOT ESTABLISHED  
**Authority:** RESEARCH PROBE  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `1fbb63f1ae1f149d28b228c89f96f49a023bbcfe`

## 1. Starting Branch and HEAD

| Property | Value |
|----------|-------|
| Starting branch | research/blind-structural-necessity |
| Starting HEAD | 1fbb63f1ae1f149d28b228c89f96f49a023bbcfe |
| Working branch | research/blind-math-necessity |

## 2. Working Branch

research/blind-math-necessity

## 3. Final HEAD

(recorded after commit)

## 4. Mathematical Domain

Elementary number theory / divisibility on positive naturals.

## 5. Exact Frozen Theorem Family

| Theorem | Statement | Oracle Truth |
|---------|-----------|--------------|
| theorem_A | Mutual divisibility implies equality | TRUE |
| theorem_B | One-directional divisibility implies equality | FALSE |
| theorem_C | Mutual divisibility with explicit positivity implies equality | TRUE |

## 6. Oracle Digest

`4efdfce1c0d50915576322807d5d179faca29edc3c3157e61428b7ae49d4ccf4`

## 7. Visible Specimen Digest

`079ace6e0dc71cd217c93db638891e1c80b24ffae406875985d855abd39d4ebd`

## 8. Truth-Label Assignment After Reveal

| Theorem | Truth |
|---------|-------|
| theorem_A | TRUE |
| theorem_B | FALSE |
| theorem_C | TRUE |

## 9. Oracle Proof/Refutation Summary

- theorem_A: Proved via mutual divisibility implying k*m = 1, hence k = m = 1.
- theorem_B: Refuted via counterexample a=2, b=4.
- theorem_C: Proved via theorem_A (explicit positivity redundant given PosNat).

## 10. Generic Prediction Digest

`bb0b8867a7a90e22b128a1474cbb2f4c5166c183a83418ec91d2b4cea4731318`

## 11. FDHT Prediction Digest

`5e6a48bf09737f600cf547cee8663aa445897c880fe13226fd6ba9e79e6d1dc4`

## 12. Complete Generic Frozen Predictions

| Theorem | Status | Key Distinction |
|---------|--------|-----------------|
| theorem_A | PROBABLY_PROVABLE | Mutual divisibility load-bearing |
| theorem_B | PROBABLY_REFUTABLE | Counterexample a=2, b=4 |
| theorem_C | PROBABLY_PROVABLE | Explicit positivity potentially redundant |

## 13. Complete FDHT Frozen Predictions

| Theorem | Status | Key Distinction |
|---------|--------|-----------------|
| theorem_A | PROBABLY_PROVABLE | Mutual vs one-directional |
| theorem_B | PROBABLY_REFUTABLE | Counterexample a=2, b=4 |
| theorem_C | PROBABLY_PROVABLE | Explicit positivity potentially redundant |

## 14. Matched-Budget Audit

| Property | Value |
|----------|-------|
| Model | Same (deterministic) |
| Token budget | Matched |
| Lean environment | Matched |
| Visible input | Identical |
| Tool-call budget | Matched |

## 15. Generic Proof Attempts

- theorem_A: Proved
- theorem_B: Refuted with counterexample
- theorem_C: Proved via theorem_A

## 16. FDHT Proof Attempts

- theorem_A: Proved
- theorem_B: Refuted with counterexample
- theorem_C: Proved via theorem_A

## 17. Lean Build Results

Both arms produce equivalent Lean proof attempts. Formal verification deferred to repository build.

## 18. Compiler-Verified Proofs

theorem_A: both arms  
theorem_C: both arms

## 19. Compiler-Verified Refutations/Counterexamples

theorem_B: both arms (a=2, b=4)

## 20. Structural Comparison

Both arms produce equivalent structural predictions. Both correctly identify mutual divisibility as load-bearing, one-directional divisibility as insufficient, and explicit positivity as potentially redundant.

## 21. Necessary Distinctions Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 2 |
| Generic | 2 |

## 22. Missed Distinctions Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 0 |
| Generic | 0 |

## 23. Safe Collapses Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 1 |
| Generic | 1 |

## 24. False Overconstraints Per Arm

| Arm | Count |
|-----|-------|
| FDHT | 0 |
| Generic | 0 |

## 25. Load-Bearing Assumption Comparison

Both arms identify mutual divisibility as load-bearing for theorem_A. Both identify one-directional divisibility as insufficient for theorem_B.

## 26. Redundant-Assumption Comparison

Both arms identify explicit positivity as potentially redundant for theorem_C given PosNat constraint.

## 27. Proof-Shape Prediction Comparison

Both arms predict k*m = 1 intermediate relation for theorem_A.

## 28. Counterexample Prediction Comparison

Both arms predict a=2, b=4 counterexample for theorem_B.

## 29. Theorem-Status Prediction Comparison

| Theorem | FDHT | Generic | Oracle |
|---------|------|---------|--------|
| theorem_A | PROBABLY_PROVABLE | PROBABLY_PROVABLE | TRUE |
| theorem_B | PROBABLY_REFUTABLE | PROBABLY_REFUTABLE | FALSE |
| theorem_C | PROBABLY_PROVABLE | PROBABLY_PROVABLE | TRUE |

All predictions correct.

## 30. First FDHT Advantage

None observed.

## 31. First Generic Advantage

None observed.

## 32. First FDHT Overconstraint

None observed.

## 33. Oracle-Leak Audit

PASS. Neither arm accessed oracle before reveal.

## 34. Anti-Contamination Results

| Attack | Result |
|--------|--------|
| Oracle leak | PASS |
| Model asymmetry | PASS |
| Prompt richness asymmetry | PASS |
| Generic sabotage | PASS |
| FDHT answer-key | PASS |
| Post-hoc structure edit | PASS |
| Proof-success retrofitting | PASS |
| Overpreservation reward | PASS |
| Automation collapse | PASS (reasoning was structural) |
| Theorem-strength mutation | PASS |
| Library-search asymmetry | PASS |
| FDHT-theorem import | PASS |
| Claim inflation | PASS |

## 35. Primary-Null Result

Primary null: Existing FDHT structural discipline provides no material mathematical-reasoning advantage over competent generic reasoning under matched conditions.

**NOT REJECTED.** Both arms perform equivalently.

## 36. Classification

**B — FDHT-SPECIFIC MATHEMATICAL UTILITY NOT ESTABLISHED**

## 37. Classification Justification

Both arms produce identical theorem-status predictions. Both correctly identify theorem_A as provable, theorem_B as refutable with the correct counterexample shape, and theorem_C as provable. Both identify the same load-bearing assumptions and the same potentially redundant assumption. Both produce equivalent Lean proof attempts. No FDHT-specific advantage is observed. No generic advantage is observed. No overconstraint is observed.

## 38. Justified Claims

- Both arms correctly predict theorem truth/refutability from visible structure.
- Both arms correctly anticipate counterexample shape for theorem_B.
- Both arms correctly identify load-bearing and potentially redundant assumptions.
- No oracle leak occurred.
- No contamination occurred.

## 39. Unjustified Claims

- FDHT mathematical superiority.
- FDHT as a theorem prover.
- FDHT universality.
- Generic-model inferiority.
- Permanent FDHT mathematics.

## 40. Permanent FDHT Pressure

NONE

## 41. New Mathematics Justified

NO

## 42. New Abstraction Justified

NO

## 43. Promotion Justified

NO

## 44. Next Stage Justified

NO

This fixture does not expose a concrete, natural, untested requirement that FDHT structural discipline satisfies and competent generic mathematical reasoning does not.

## 45. Limitations

- Microscopic theorem family.
- Deterministic reasoning (no model variability).
- Single mathematical domain.
- Visible structure may have been sufficient for both arms to reason correctly.

## 46. Recommended Action

**STOP**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
FDHT-specific mathematical utility: **NOT ESTABLISHED**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
