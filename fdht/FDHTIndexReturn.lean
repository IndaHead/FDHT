import FDHTPermutationRotation
import FDHTFinPigeonhole
open KernelExprContext

/-! ============================================================
    Index positive return for ThreadPermutation
============================================================ -/

/-! Collision → return. -/

theorem Nat_repeat_add_left
    {α : Type _}
    (f : α → α)
    (a c : Nat)
    (x : α) :
    Nat.repeat f (a + c) x = Nat.repeat f a (Nat.repeat f c x) := by
  induction a with
  | zero => simp [Nat.repeat.eq_1]
  | succ a ih =>
    simp only [Nat.repeat.eq_2, Nat.succ_add]
    congr 1

theorem ThreadPermutation.iterate_collision_implies_return
    {n : Nat}
    (π : ThreadPermutation n)
    (i : Fin n)
    (a b : Nat)
    (hab : a ≤ b)
    (h : Nat.repeat π.toFun a i = Nat.repeat π.toFun b i) :
    Nat.repeat π.toFun (b - a) i = i := by
  have hadd : a + (b - a) = b := Nat.add_sub_cancel' hab
  have hcomp := Nat_repeat_add_left π.toFun a (b - a) i
  rw [hadd] at hcomp
  rw [←h] at hcomp
  have hcancel : ∀ (m : Nat) (x y : Fin n),
      Nat.repeat π.toFun m x = Nat.repeat π.toFun m y → x = y := by
    intro m
    induction m with
    | zero => intro x y hxy; exact hxy
    | succ m ih =>
      intro x y hxy
      simp only [Nat.repeat.eq_2] at hxy
      have hinner : Nat.repeat π.toFun m x = Nat.repeat π.toFun m y := by
        have hinv_x : π.invFun (π.toFun (Nat.repeat π.toFun m x)) = Nat.repeat π.toFun m x := π.left_inv _
        have hinv_y : π.invFun (π.toFun (Nat.repeat π.toFun m y)) = Nat.repeat π.toFun m y := π.left_inv _
        rw [←hinv_x, ←hinv_y, hxy]
      exact ih x y hinner
  exact (hcancel a i (Nat.repeat π.toFun (b - a) i) hcomp).symm

/-! Bounded positive return. -/

theorem ThreadPermutation.index_bounded_positive_return_exists
    {n : Nat}
    (π : ThreadPermutation n)
    (i : Fin n) :
    ∃ k : Nat, 0 < k ∧ k ≤ n ∧ Nat.repeat π.toFun k i = i := by
  let seq : Fin (n + 1) → Fin n := fun j => Nat.repeat π.toFun j.val i
  have hpigeon := Fin.pigeonhole_local seq
  rcases hpigeon with ⟨a, b, hab, hseq⟩
  have hab' : a.val ≤ b.val := by omega
  have hreturn := π.iterate_collision_implies_return i a.val b.val hab' hseq
  have hkpos : 0 < b.val - a.val := by
    have : a.val < b.val := hab
    omega
  have hkbnd : b.val - a.val ≤ n := by
    have : b.val < n + 1 := b.isLt
    omega
  exact ⟨b.val - a.val, hkpos, hkbnd, hreturn⟩

/-! Positive return (derived). -/

theorem ThreadPermutation.index_positive_return_exists
    {n : Nat}
    (π : ThreadPermutation n)
    (i : Fin n) :
    ∃ k : Nat, 0 < k ∧ Nat.repeat π.toFun k i = i := by
  obtain ⟨k, hkpos, _, hkret⟩ :=
    π.index_bounded_positive_return_exists i
  exact ⟨k, hkpos, hkret⟩

#print axioms ThreadPermutation.index_bounded_positive_return_exists
#print axioms ThreadPermutation.index_positive_return_exists
