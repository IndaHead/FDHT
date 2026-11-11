/-
Visible mathematical specimen for BMN0.

Domain: elementary number theory / divisibility on positive naturals.

This file contains only definitions, assumptions, and theorem statements.
Treatment and control arms reason only from this file until predictions
and proof strategies are frozen.
-/

import Mathlib.Data.Nat.Basic

namespace BMN0Visible

/-- Positive natural numbers. -/
def PosNat := { n : Nat // n > 0 }

/-- Divisibility on positive naturals. -/
def divides (a b : PosNat) : Prop := ∃ k : Nat, b.val = k * a.val

/-- theorem_A: Mutual divisibility implies equality. -/
theorem theorem_A (a b : PosNat) (h1 : divides a b) (h2 : divides b a) : a.val = b.val := by
  sorry

/-- theorem_B: Divisibility implies equality. -/
theorem theorem_B (a b : PosNat) (h : divides a b) : a.val = b.val := by
  sorry

/-- theorem_C: Mutual divisibility with explicit positivity implies equality. -/
theorem theorem_C (a b : PosNat) (h1 : divides a b) (h2 : divides b a)
    (ha : a.val > 0) (hb : b.val > 0) : a.val = b.val := by
  sorry

end BMN0Visible
