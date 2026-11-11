/-
Frozen conjecture for OC0.

Source: google-deepmind/formal-conjectures @ da703a5f239f
File: FormalConjectures/OEIS/232174.lean
Status: research open

This file contains only the conjecture statement.
No proofs. No FDHT imports. No arm-specific lemmas.
-/

import Mathlib.Data.Nat.Prime.Basic

namespace OC0Frozen

/-- The predicate that n can be written as x + y with x, y > 0 such that
both x + n*y and x^2 + n*y^2 are prime. -/
def A (n : ℕ) : Prop :=
  ∃ x y : ℕ, 0 < x ∧ 0 < y ∧ n = x + y ∧ (x + n * y).Prime ∧ (x ^ 2 + n * y ^ 2).Prime

/--
Zhi-Wei Sun's Conjecture (A232174): Any integer n > 1 can be written as x + y
with x, y > 0 such that both x + n*y and x^2 + n*y^2 are prime.
-/
theorem conjecture (n : ℕ) (hn : 1 < n) : A n := by
  sorry

end OC0Frozen
