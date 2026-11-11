# FDHT Structural Analysis — BMN0

Visible input only. No oracle access.

## theorem_A

**Predicted status:** PROBABLY_PROVABLE

**Load-bearing assumptions:**
- Mutual divisibility (both h1 and h2)
- Positive naturals (PosNat constraint)

**Redundant assumption candidates:**
- None identified from visible statement

**Necessary distinctions:**
- Divisibility vs equality (must remain distinct; one-directional divisibility does not imply equality)
- Mutual vs one-directional (both directions required)

**Safe collapse candidates:**
- None identified

**Predicted intermediate relations:**
- From a|b and b|a, derive a = k*b and b = m*a, then a = (k*m)*a, then k*m = 1, then k = m = 1

**Predicted counterexample structure:**
- N/A (predicted provable)

**Unresolved points:**
- Exact proof structure for k*m = 1 implication

## theorem_B

**Predicted status:** PROBABLY_REFUTABLE

**Load-bearing assumptions:**
- One-directional divisibility only

**Redundant assumption candidates:**
- N/A

**Necessary distinctions:**
- One-directional divisibility vs equality (must remain distinct)

**Safe collapse candidates:**
- None

**Predicted intermediate relations:**
- None (predicted refutable)

**Predicted counterexample structure:**
- Small positive naturals where a divides b but a ≠ b. Example: a=2, b=4.

**Unresolved points:**
- None

## theorem_C

**Predicted status:** PROBABLY_PROVABLE

**Load-bearing assumptions:**
- Mutual divisibility
- Explicit positivity (ha, hb)

**Redundant assumption candidates:**
- Explicit positivity (ha, hb) may be redundant given PosNat constraint

**Necessary distinctions:**
- Mutual divisibility vs equality

**Safe collapse candidates:**
- Explicit positivity may collapse into PosNat constraint

**Predicted intermediate relations:**
- Same as theorem_A

**Predicted counterexample structure:**
- N/A

**Unresolved points:**
- Whether explicit positivity is genuinely redundant
