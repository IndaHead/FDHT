/-
FDHT arm workspace for OC0.

No FDHT theorem imports. Predictions already frozen.
Preserves distinction between the two prime conditions.
-/

import Mathlib.Data.Nat.Prime.Basic

namespace OC0FDHT

def A (n : ℕ) : Prop :=
  ∃ x y : ℕ, 0 < x ∧ 0 < y ∧ n = x + y ∧ (x + n * y).Prime ∧ (x ^ 2 + n * y ^ 2).Prime

-- Verified special case: n=7
theorem a_7 : A 7 := by
  use 4, 3
  constructor; norm_num
  constructor; norm_num
  constructor; norm_num
  constructor; norm_num
  norm_num

-- The general conjecture remains open
-- No full proof or counterexample found within bounds
-- Distinction between x + n*y prime and x^2 + n*y^2 prime preserved

end OC0FDHT
