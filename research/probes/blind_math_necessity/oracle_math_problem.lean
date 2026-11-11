/-
Oracle mathematical specimen for BMN0.

Domain: elementary number theory / divisibility on positive naturals.

This file contains theorem identities, oracle proofs, and oracle counterexamples.
Treatment and control arms must NOT import this file until after prediction freeze
and proof attempts are complete.
-/

import Mathlib.Data.Nat.Basic
import Mathlib.Tactic

namespace BMN0Oracle

/-- Positive natural numbers. -/
def PosNat := { n : Nat // n > 0 }

/-- Divisibility on positive naturals. -/
def divides (a b : PosNat) : Prop := ∃ k : Nat, b.val = k * a.val

/-- theorem_A: Mutual divisibility implies equality. -/
theorem theorem_A (a b : PosNat) (h1 : divides a b) (h2 : divides b a) : a.val = b.val := by
  obtain ⟨k, hk⟩ := h1
  obtain ⟨m, hm⟩ := h2
  have : a.val = m * (k * a.val) := by rw [← hk]; exact hm
  have : a.val = (m * k) * a.val := by rw [Nat.mul_assoc] at this; exact this
  have ha : a.val > 0 := a.property
  have : m * k = 1 := by
    have h := Nat.eq_one_of_mul_eq_self_right ha this
    exact h
  have hm1 : m = 1 := by
    have : m * k = 1 := this
    exact Nat.eq_one_of_mul_eq_one_left this
  rw [hm1, Nat.one_mul] at hm
  exact hm.symm

/-- theorem_B: Divisibility implies equality. (FALSE) -/
theorem theorem_B (a b : PosNat) (h : divides a b) : a.val = b.val := by
  sorry -- This is false. Counterexample below.

/-- Counterexample for theorem_B. -/
def counterexample_B : ¬ ∀ (a b : PosNat), divides a b → a.val = b.val := by
  intro h
  let a : PosNat := ⟨2, by omega⟩
  let b : PosNat := ⟨4, by omega⟩
  have hdiv : divides a b := ⟨2, by omega⟩
  have heq := h a b hdiv
  omega

/-- theorem_C: Mutual divisibility with explicit positivity implies equality. -/
theorem theorem_C (a b : PosNat) (h1 : divides a b) (h2 : divides b a)
    (ha : a.val > 0) (hb : b.val > 0) : a.val = b.val := by
  exact theorem_A a b h1 h2

end BMN0Oracle
