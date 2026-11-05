import FDHTFinitePeriod
open KernelExprContext

/-! ============================================================
    Automatic ThreadFamilyRotation from Nontrivial
============================================================ -/

theorem ThreadPermutation.rotation_exists
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (hnon : π.Nontrivial) :
    ∃ rot : ThreadFamilyRotation resolve n,
      rot.rotate = permuteThreadFamily resolve π := by
  obtain ⟨K, hperiod⟩ := π.finitePeriod_exists
  exact ⟨π.toThreadFamilyRotation resolve hnon K hperiod, rfl⟩

#print axioms ThreadPermutation.rotation_exists
