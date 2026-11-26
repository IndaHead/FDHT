/-
MRT-04: Factorisation Boundary

TL17: Sufficiency-to-factorisation boundary audit.
-/

import Mathlib.Logic.Function.Basic

/-! ## TL17: Global factorisation requires choice or coverage -/

-- The converse:
-- SufficientFor T C → ∃ Ĉ : Y → R, C = Ĉ ∘ T
-- is NOT constructively provable in general.
--
-- Reasons:
-- 1. Requires defining Ĉ on the image of T.
-- 2. Requires choice or explicit coverage to extend beyond the image.
-- 3. For non-surjective T, Ĉ is underdetermined off the image.
--
-- Image-local factorisation is constructive:
-- C factors through Set.range T.

theorem image_local_factorisation
    {X Y R : Type}
    (T : X → Y) (C : X → R)
    (hSuff : SufficientFor T C) :
    ∀ x₁ x₂, T x₁ = T x₂ → C x₁ = C x₂ :=
  hSuff

-- The image-local statement is exactly SufficientFor.
-- A constructive factorisation through Set.range requires
-- defining a function on the subtype { y // ∃ x, T x = y }.
-- This is possible but requires explicit construction.
--
-- Classification: CLASSICAL_BOUNDARY for global factorisation.
-- Image-local factorisation is definitionally SufficientFor.
