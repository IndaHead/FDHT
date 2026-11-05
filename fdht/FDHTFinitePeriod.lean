import FDHTGlobalPeriod
open KernelExprContext

/-! ============================================================
    Automatic HasFinitePeriod for ThreadPermutation
============================================================ -/

theorem ThreadPermutation.finitePeriod_exists
    {n : Nat}
    (π : ThreadPermutation n) :
    ∃ K : Nat, π.HasFinitePeriod K := by
  obtain ⟨k, hkpos, hkperiod⟩ := π.positivePeriod_exists
  refine ⟨2 * k, ?_, ?_⟩
  · -- 1 < 2 * k
    omega
  · -- ∀ i, Nat.repeat π.toFun (2 * k) i = i
    intro i
    have hret := hkperiod i
    -- use Nat_repeat_period_of_dvd
    have hdiv : k ∣ 2 * k := Nat.dvd_mul_left _ _
    exact Nat_repeat_period_of_dvd π.toFun i k (2 * k) hret hdiv

#print axioms ThreadPermutation.finitePeriod_exists
