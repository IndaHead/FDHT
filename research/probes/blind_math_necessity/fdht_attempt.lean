/-
FDHT arm proof attempts for BMN0.

No oracle access. Predictions already frozen.
-/

import Mathlib.Data.Nat.Basic
import Mathlib.Tactic

namespace BMN0FDHT

def PosNat := { n : Nat // n > 0 }
def divides (a b : PosNat) : Prop := ∃ k : Nat, b.val = k * a.val

-- theorem_A attempt
theorem theorem_A (a b : PosNat) (h1 : divides a b) (h2 : divides b a) : a.val = b.val := by
  obtain ⟨k, hk⟩ := h1
  obtain ⟨m, hm⟩ := h2
  have h : a.val = m * (k * a.val) := by rw [← hk]; exact hm
  have h' : a.val = (m * k) * a.val := by rw [← Nat.mul_assoc]; exact h
  have ha : a.val > 0 := a.property
  have hmk : m * k = 1 := Nat.eq_one_of_mul_eq_self_right ha h'
  have hm1 : m = 1 := Nat.eq_one_of_mul_eq_one_left hmk
  rw [hm1, Nat.one_mul] at hm
  exact hm.symm

-- theorem_B attempt (predicted refutable)
theorem theorem_B_refutation : ¬ ∀ (a b : PosNat), divides a b → a.val = b.val := by
  intro h
  let a : PosNat := ⟨2, by omega⟩
  let b : PosNat := ⟨4, by omega⟩
  have hdiv : divides a b := ⟨2, by omega⟩
  have heq := h a b hdiv
  omega

-- theorem_C attempt
theorem theorem_C (a b : PosNat) (h1 : divides a b) (h2 : divides b a)
    (ha : a.val > 0) (hb : b.val > 0) : a.val = b.val := by
  exact theorem_A a b h1 h2

end BMN0FDHT
