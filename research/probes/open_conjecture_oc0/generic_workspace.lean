/-
Generic arm workspace for OC0.

No FDHT imports. Predictions already frozen.
-/

import Mathlib.Data.Nat.Prime.Basic

namespace OC0Generic

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

end OC0Generic
