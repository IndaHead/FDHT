# Known Results Boundary — OC0

## Source-Documented Partial Results

The source file FormalConjectures/OEIS/232174.lean contains verified test cases:
- a_2: A 2 (witness: x=1, y=1)
- a_3: A 3 (witness: x=2, y=1)
- a_4: A 4 (witness: x=1, y=3)
- a_5: A 5 (witness: x=3, y=2)
- a_6: A 6 (witness: x=5, y=1)
- a_8: A 8 (witness: x=5, y=3)

These are finite verified instances, not a general proof.

## Known Solved Special Cases

None documented in the source beyond the finite test cases above.

## Known Computational Bounds

None documented in the source.

## Existing Mathlib Lemmas Likely Relevant

- Nat.Prime
- Basic arithmetic on ℕ
- Existence of primes in arithmetic progressions (Dirichlet) — not directly applicable

## Candidate Statements That Would Merely Rediscover Known Material

- Proving A n for specific small n already verified in the source.

## Novelty Limitations

Any result proving A n for a specific n not already in the source test cases would be a verified special case, but the general conjecture remains open. A full proof or counterexample would be new.
