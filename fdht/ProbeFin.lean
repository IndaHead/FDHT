import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

def familyUnequal (n : Nat) (h : 1 < n) : Fin n → List KernelExprContext :=
  fun i => if i.val = 0 then [] else [identityContext]

theorem empty_ne_identity :
    ([] : List KernelExprContext) ≠ [identityContext] := by
  intro h
  cases h

theorem test (n : Nat) (h : 1 < n) :
    ¬ ∀ i j : Fin n, familyUnequal n h i = familyUnequal n h j := by
  intro hAll
  have h0 : familyUnequal n h ⟨0, Nat.zero_lt_of_lt h⟩ = [] := by
    simp [familyUnequal]
  have h1 : familyUnequal n h ⟨1, h⟩ = [identityContext] := by
    simp [familyUnequal]
  have hEq := hAll ⟨0, Nat.zero_lt_of_lt h⟩ ⟨1, h⟩
  rw [h0, h1] at hEq
  exact empty_ne_identity hEq

#check test
