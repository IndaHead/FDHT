import FDHT_Audit_ArbitraryCollision
import ThreadFamilyWitness
import ChiralitySpec
import UniformRealisation
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Equality-partition refinement
============================================================ -/

def SameRawAt
    {n : Nat}
    (p : ThreadFamily resolve n)
    (i j : Fin n) : Prop :=
  p i = p j

def EqualityPartitionRefines
    {n : Nat}
    (p q : ThreadFamily resolve n) : Prop :=
  ∀ i j : Fin n,
    SameRawAt p i j →
    SameRawAt q i j

theorem uniformActionCompatible_iff_partitionRefines
    {n : Nat}
    (p q : ThreadFamily resolve n) :
    UniformActionCompatible p q
    ↔
    EqualityPartitionRefines p q := by
  rfl

/-! ============================================================
    Uniform-compatible relational witness
============================================================ -/

def UniformCompatibleRelationalWitness
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  ∃ (R : ThreadFamily resolve n → Prop)
    (p q : ThreadFamily resolve n),
      ThreadFamilyKernel resolve p q
      ∧
      UniformActionCompatible p q
      ∧
      R p ≠ R q

/-! ============================================================
    RawAllEqual limitation on compatible pairs
============================================================ -/

theorem rawAllEqual_invariant_on_compatible_from_allEqual
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {p q : ThreadFamily resolve n}
    (hComp : UniformActionCompatible p q)
    (hP : RawAllEqual resolve p) :
    RawAllEqual resolve q := by
  intro i j
  exact hComp i j (hP i j)

/-! ============================================================
    Explicit n=2 candidates using existing raw histories
============================================================ -/

def familyDistinctRaw
    (resolve : KernelExpr → Store → Location) :
    ThreadFamily resolve 2 :=
  fun i => if i.val = 0 then [] else [identityContext]

def familyDistinctRawSwapped
    (resolve : KernelExpr → Store → Location) :
    ThreadFamily resolve 2 :=
  fun i => if i.val = 0 then [identityContext] else []

theorem familyDistinctRaw_notAllEqual
    (resolve : KernelExpr → Store → Location) :
    ¬ RawAllEqual resolve (familyDistinctRaw resolve) := by
  intro h
  have h0 : familyDistinctRaw resolve ⟨0, by decide⟩ = [] := by
    simp [familyDistinctRaw]
  have h1 : familyDistinctRaw resolve ⟨1, by decide⟩ = [identityContext] := by
    simp [familyDistinctRaw]
  have := h ⟨0, by decide⟩ ⟨1, by decide⟩
  rw [h0, h1] at this
  exact empty_ne_identity this

theorem familyDistinctRaw_kernel_self
    (resolve : KernelExpr → Store → Location) :
    ThreadFamilyKernel resolve
      (familyDistinctRaw resolve)
      (familyDistinctRaw resolve) := by
  unfold ThreadFamilyKernel projectThreadFamily
  funext i
  rfl

theorem familyDistinctRaw_compatible_self
    (resolve : KernelExpr → Store → Location) :
    UniformActionCompatible
      (familyDistinctRaw resolve)
      (familyDistinctRaw resolve) := by
  intro i j hij
  exact hij

/-! ============================================================
    Folded-trivial rotation witness implies uniform-compatible
============================================================ -/

theorem foldedTrivialRotationWitness_implies_uniformCompatibleWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : FoldedTrivialRotationClassifierWitness resolve C) :
    UniformCompatibleRelationalWitness resolve n := by
  rcases h with ⟨r, p, hKernel, hDifferent⟩
  let R : ThreadFamily resolve n → Prop :=
    fun q => C.classify q = C.classify p
  have hComp : UniformActionCompatible p (rotateThreadFamily resolve r p) := by
    intro i j hij
    simp only [rotateThreadFamily]
    rw [hij]
  have hNe : R p ≠ R (rotateThreadFamily resolve r p) := by
    intro hEq
    have hRp : R p := rfl
    rw [hEq] at hRp
    exact hDifferent hRp
  exact ⟨R, p, rotateThreadFamily resolve r p,
    ThreadFamilyKernel_symm resolve hKernel, hComp, hNe⟩

/-! ============================================================
    Local realisation vs global FoldKernel
============================================================ -/

def LocallyRealisesWitness
    (r : List KernelExprContext → List KernelExprContext)
    {n : Nat}
    (p q : ThreadFamily resolve n) : Prop :=
  UniformlyRealises r p q

def FoldCompatibleExtensionExists
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p q : ThreadFamily resolve n) : Prop :=
  ∃ r : List KernelExprContext → List KernelExprContext,
    UniformlyRealises r p q
    ∧
    RotationRespectsFoldKernel resolve r

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check uniformActionCompatible_iff_partitionRefines
#check UniformCompatibleRelationalWitness
#check rawAllEqual_invariant_on_compatible_from_allEqual
#check foldedTrivialRotationWitness_implies_uniformCompatibleWitness
#check FoldCompatibleExtensionExists

#print axioms uniformActionCompatible_iff_partitionRefines
#print axioms rawAllEqual_invariant_on_compatible_from_allEqual
#print axioms foldedTrivialRotationWitness_implies_uniformCompatibleWitness
