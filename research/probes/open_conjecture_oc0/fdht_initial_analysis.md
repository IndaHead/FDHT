# FDHT Structural Analysis — OC0

Visible input only. No oracle. Predictions before proof attempts.

## Conjecture

Any integer n > 1 can be written as x + y with x, y > 0 such that both x + n*y and x² + n*y² are prime.

## Expected Terminal State

EXPECT_OPEN

## Load-Bearing Assumptions

- n > 1 (strict inequality; n=1 is excluded)
- x, y > 0 (strict positivity)
- Simultaneous primality of two distinct expressions

## Candidate Special Cases

- Source-verified: n=2,3,4,5,6,8
- n=7: bounded search feasible

## Candidate Conditionals

- Conditional on Dirichlet or similar arithmetic-progression results

## Candidate Reductions

- None identified that are strictly weaker

## Candidate Obstructions

- Simultaneous primality is a strong condition
- No obvious collapse of the two prime conditions into one

## Likely False Intermediate Claims

- Claiming the two prime conditions are equivalent (they are not)
- Claiming all decompositions work (likely false)

## Counterexample Search Space

- Bounded x, y for fixed n
- Distinguish: no counterexample found ≠ conjecture true

## Proof Strategy

- Preserve the distinction between the two prime conditions
- Do not collapse x + n*y prime into x² + n*y² prime
- Bounded verification of small cases
- Retain OPEN if neither proof nor counterexample found

## Unresolved Points

- Whether the conjecture holds for all n > 1
- Whether a counterexample exists
- Whether the two prime conditions can be related algebraically
