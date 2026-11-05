import FDHT_Audit_ArbitraryCollision
import ThreadFamilyWitness
import ChiralitySpec
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Uniform componentwise realisation
============================================================ -/

def UniformlyRealises
    (r : List KernelExprContext → List KernelExprContext)
    {n : Nat}
    (p q : ThreadFamily resolve n) : Prop :=
  ∀ i : Fin n, r (p i) = q i

theorem uniformRealisation_preserves_input_equalities
    (r : List KernelExprContext → List KernelExprContext)
    {n : Nat}
    {p q : ThreadFamily resolve n}
    (h : UniformlyRealises r p q)
    {i j : Fin n}
    (hij : p i = p j) :
    q i = q j := by
  rw [← h i, ← h j, hij]

/-! ============================================================
    Application to the existing RawAllEqual witness
============================================================ -/

theorem familyEqual_familyUnequal_not_uniformly_realisable
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (hn : 1 < n) :
    ¬ ∃ r : List KernelExprContext → List KernelExprContext,
        UniformlyRealises r
          (familyEqual resolve n)
          (familyUnequal resolve n hn) := by
  intro ⟨r, hReal⟩
  have hPreserve :=
    uniformRealisation_preserves_input_equalities
      r
      hReal
      (familyEqual_allEqual resolve n
        ⟨0, Nat.zero_lt_of_lt hn⟩
        ⟨1, hn⟩)
  have h0 :
      familyUnequal resolve n hn ⟨0, Nat.zero_lt_of_lt hn⟩ = [] := by
    simp [familyUnequal]
  have h1 :
      familyUnequal resolve n hn ⟨1, hn⟩ = [identityContext] := by
    simp [familyUnequal]
  rw [h0, h1] at hPreserve
  exact empty_ne_identity hPreserve

/-! ============================================================
    Implication for FoldCompatibleRotation
============================================================ -/

theorem foldCompatibleRotation_cannot_realise_rawAllEqual_witness
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (hn : 1 < n)
    (r : FoldCompatibleRotation resolve) :
    ¬ UniformlyRealises
        r.rotate
        (familyEqual resolve n)
        (familyUnequal resolve n hn) := by
  intro h
  exact familyEqual_familyUnequal_not_uniformly_realisable
    resolve n hn ⟨r.rotate, h⟩

/-! ============================================================
    General obstruction
============================================================ -/

def UniformActionCompatible
    {n : Nat}
    (p q : ThreadFamily resolve n) : Prop :=
  ∀ i j : Fin n,
    p i = p j → q i = q j

theorem uniformlyRealises_implies_compatible
    (r : List KernelExprContext → List KernelExprContext)
    {n : Nat}
    {p q : ThreadFamily resolve n}
    (h : UniformlyRealises r p q) :
    UniformActionCompatible p q := by
  intro i j hij
  exact uniformRealisation_preserves_input_equalities r h hij

theorem familyEqual_familyUnequal_not_compatible
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (hn : 1 < n) :
    ¬ UniformActionCompatible
        (familyEqual resolve n)
        (familyUnequal resolve n hn) := by
  intro hComp
  have hEq :=
    hComp
      ⟨0, Nat.zero_lt_of_lt hn⟩
      ⟨1, hn⟩
      (familyEqual_allEqual resolve n
        ⟨0, Nat.zero_lt_of_lt hn⟩
        ⟨1, hn⟩)
  have h0 :
      familyUnequal resolve n hn ⟨0, Nat.zero_lt_of_lt hn⟩ = [] := by
    simp [familyUnequal]
  have h1 :
      familyUnequal resolve n hn ⟨1, hn⟩ = [identityContext] := by
    simp [familyUnequal]
  rw [h0, h1] at hEq
  exact empty_ne_identity hEq

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check UniformlyRealises
#check uniformRealisation_preserves_input_equalities
#check UniformActionCompatible
#check familyEqual_familyUnequal_not_uniformly_realisable
#check foldCompatibleRotation_cannot_realise_rawAllEqual_witness
#check uniformlyRealises_implies_compatible
#check familyEqual_familyUnequal_not_compatible

#print axioms uniformRealisation_preserves_input_equalities
#print axioms familyEqual_familyUnequal_not_uniformly_realisable
#print axioms foldCompatibleRotation_cannot_realise_rawAllEqual_witness
#print axioms uniformlyRealises_implies_compatible
