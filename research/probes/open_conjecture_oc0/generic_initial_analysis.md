# Generic Mathematical Analysis — OC0

Visible input only. No oracle. Predictions before proof attempts.

## Conjecture

Any integer n > 1 can be written as x + y with x, y > 0 such that both x + n*y and x² + n*y² are prime.

## Expected Terminal State

EXPECT_OPEN

## Load-Bearing Assumptions

- n > 1
- x, y > 0
- Both x + n*y and x² + n*y² must be prime simultaneously

## Candidate Special Cases

- Small n already verified in source (n=2,3,4,5,6,8)
- n=7 may be checkable by bounded search

## Candidate Conditionals

- If Dirichlet's theorem applies to certain arithmetic progressions, partial progress may be possible

## Candidate Reductions

- None identified that are strictly weaker than the original

## Candidate Obstructions

- Simultaneous primality of two related expressions is a hard condition
- No obvious algebraic factorization that would force compositeness

## Likely False Intermediate Claims

- Claiming all such pairs are prime for small bounds (likely false for large enough search)

## Counterexample Search Space

- Bounded search over x, y for fixed n
- For n=7: x + y = 7, x, y > 0, check primality

## Proof Strategy

- Direct proof appears difficult
- Bounded verification of small cases is feasible
- General proof likely requires deep number-theoretic machinery

## Unresolved Points

- Whether the conjecture is true for all n > 1
- Whether a counterexample exists for large n
