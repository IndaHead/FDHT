import FDHTIndexReturn
open KernelExprContext

/-! ============================================================
    Global positive period for ThreadPermutation
============================================================ -/

/-! Local common-multiple bound. -/

def Nat.fdhtCommonPeriodBound : Nat → Nat
  | 0 => 1
  | n + 1 => (n + 1) * Nat.fdhtCommonPeriodBound n

theorem Nat.fdhtCommonPeriodBound_pos (n : Nat) :
    0 < Nat.fdhtCommonPeriodBound n := by
  induction n with
  | zero => simp [Nat.fdhtCommonPeriodBound]
  | succ n ih =>
    simp only [Nat.fdhtCommonPeriodBound]
    exact Nat.mul_pos (Nat.succ_pos n) ih

theorem Nat.dvd_commonPeriodBound_of_pos_le
    {k n : Nat}
    (hkpos : 0 < k)
    (hkn : k ≤ n) :
    k ∣ Nat.fdhtCommonPeriodBound n := by
  induction n with
  | zero =>
    omega
  | succ n ih =>
    simp only [Nat.fdhtCommonPeriodBound]
    by_cases hk : k = n + 1
    · rw [hk]
      exact Nat.dvd_mul_right _ _
    · have hkn' : k ≤ n := by omega
      have hdiv := ih hkn'
      exact Nat.dvd_trans hdiv (Nat.dvd_mul_left _ _)

/-! Multiple of a return period is a return period. -/

theorem Nat_repeat_period_of_dvd
    {α : Type _}
    (f : α → α)
    (x : α)
    (r K : Nat)
    (hr : Nat.repeat f r x = x)
    (hdiv : r ∣ K) :
    Nat.repeat f K x = x := by
  obtain ⟨m, hm⟩ := hdiv
  rw [hm]
  clear hm
  induction m with
  | zero =>
    simp [Nat.repeat.eq_1]
  | succ m ih =>
    simp only [Nat.mul_succ]
    rw [Nat_repeat_add_left]
    rw [hr]
    exact ih

/-! Global positive period. -/

theorem ThreadPermutation.positivePeriod_exists
    {n : Nat}
    (π : ThreadPermutation n) :
    ∃ K : Nat, 0 < K ∧ ∀ i : Fin n, Nat.repeat π.toFun K i = i := by
  let K := Nat.fdhtCommonPeriodBound n
  have hKpos := Nat.fdhtCommonPeriodBound_pos n
  refine ⟨K, hKpos, ?_⟩
  intro i
  obtain ⟨k, hkpos, hkn, hkret⟩ := π.index_bounded_positive_return_exists i
  have hdiv : k ∣ K := Nat.dvd_commonPeriodBound_of_pos_le hkpos hkn
  exact Nat_repeat_period_of_dvd π.toFun i k K hkret hdiv

#print axioms ThreadPermutation.positivePeriod_exists
