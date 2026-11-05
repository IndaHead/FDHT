/-! ============================================================
    Local Fin pigeonhole theorem
============================================================ -/

/-! Codomain deletion helper. -/

def Fin.compress
    {n : Nat}
    (y : Fin (n + 1))
    (z : Fin (n + 1))
    (hz : z ≠ y) :
    Fin n :=
  if h : z.val < y.val then
    ⟨z.val, by omega⟩
  else
    ⟨z.val - 1, by
      have hle : y.val ≤ z.val := Nat.le_of_not_lt h
      have hne : z.val ≠ y.val := by
        intro heq
        exact hz (Fin.ext heq)
      omega⟩

theorem Fin.compress_injective
    {n : Nat}
    (y : Fin (n + 1))
    {z₁ z₂ : Fin (n + 1)}
    (hz₁ : z₁ ≠ y)
    (hz₂ : z₂ ≠ y)
    (h : Fin.compress y z₁ hz₁ = Fin.compress y z₂ hz₂) :
    z₁ = z₂ := by
  unfold Fin.compress at h
  by_cases h₁ : z₁.val < y.val
  · by_cases h₂ : z₂.val < y.val
    · simp [h₁, h₂] at h
      exact Fin.ext (by omega)
    · simp [h₁, h₂] at h
      -- z₁.val = z₂.val - 1, but z₁.val < y.val ≤ z₂.val
      have hle : y.val ≤ z₂.val := Nat.le_of_not_lt h₂
      omega
  · by_cases h₂ : z₂.val < y.val
    · simp [h₁, h₂] at h
      have hle : y.val ≤ z₁.val := Nat.le_of_not_lt h₁
      omega
    · simp [h₁, h₂] at h
      -- z₁.val - 1 = z₂.val - 1
      have hne₁ : z₁.val ≠ y.val := by
        intro heq
        exact hz₁ (Fin.ext heq)
      have hne₂ : z₂.val ≠ y.val := by
        intro heq
        exact hz₂ (Fin.ext heq)
      have hle₁ : y.val ≤ z₁.val := Nat.le_of_not_lt h₁
      have hle₂ : y.val ≤ z₂.val := Nat.le_of_not_lt h₂
      omega

/-! Main pigeonhole theorem. -/

theorem Fin.pigeonhole_local
    {n : Nat}
    (f : Fin (n + 1) → Fin n) :
    ∃ a b : Fin (n + 1), a < b ∧ f a = f b := by
  induction n with
  | zero =>
    -- Fin 1 → Fin 0 is impossible
    exact Fin.elim0 (f 0)
  | succ n ih =>
    -- f : Fin (n + 2) → Fin (n + 1)
    let y := f 0
    -- decide whether some later input maps to y
    classical
    by_cases hcase : ∃ j : Fin (n + 1), f j.succ = y
    · -- Case A: collision with f 0
      rcases hcase with ⟨j, hj⟩
      refine ⟨0, j.succ, Fin.succ_pos j, hj.symm⟩
    · -- Case B: no later input maps to y
      have hnone : ∀ j : Fin (n + 1), f j.succ ≠ y := by
        intro j hj
        exact hcase ⟨j, hj⟩
      -- compress the codomain
      let g : Fin (n + 1) → Fin n := fun j =>
        Fin.compress y (f j.succ) (hnone j)
      -- apply IH
      rcases ih g with ⟨a, b, hab, hgab⟩
      -- lift witnesses
      refine ⟨a.succ, b.succ, by show a.val + 1 < b.val + 1; omega, ?_⟩
      -- f a.succ = f b.succ from g a = g b
      exact Fin.compress_injective y (hnone a) (hnone b) hgab

#print axioms Fin.pigeonhole_local
#print axioms Fin.compress_injective
