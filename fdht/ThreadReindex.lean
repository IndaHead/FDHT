import FDHT_Audit_ArbitraryCollision
import ThreadFamilyWitness
import ClassifierReconciliation
import ClassifierFactorisation
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Finite thread reindexing
============================================================ -/

def ThreadReindex (n : Nat) :=
  Fin n → Fin n

def reindexThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (σ : ThreadReindex n)
    (p : ThreadFamily resolve n) :
    ThreadFamily resolve n :=
  fun i => p (σ i)

theorem reindexThreadFamily_apply
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (σ : ThreadReindex n)
    (p : ThreadFamily resolve n)
    (i : Fin n) :
    reindexThreadFamily resolve σ p i = p (σ i) := by
  rfl

def identityThreadReindex (n : Nat) : ThreadReindex n :=
  fun i => i

theorem reindexThreadFamily_identity
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) :
    reindexThreadFamily resolve (identityThreadReindex n) p = p := by
  funext i
  rfl

def composeThreadReindex
    {n : Nat}
    (σ τ : ThreadReindex n) :
    ThreadReindex n :=
  fun i => σ (τ i)

theorem reindexThreadFamily_compose
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (σ τ : ThreadReindex n)
    (p : ThreadFamily resolve n) :
    reindexThreadFamily resolve (composeThreadReindex σ τ) p
    =
    reindexThreadFamily resolve τ (reindexThreadFamily resolve σ p) := by
  funext i
  rfl

/-! ============================================================
    Projection commuting
============================================================ -/

def reindexProjectedFamily
    {n : Nat}
    (σ : ThreadReindex n)
    (q : Fin n → TrajectoryBoundary resolve) :
    Fin n → TrajectoryBoundary resolve :=
  fun i => q (σ i)

theorem project_reindexThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (σ : ThreadReindex n)
    (p : ThreadFamily resolve n) :
    projectThreadFamily resolve (reindexThreadFamily resolve σ p)
    =
    reindexProjectedFamily σ (projectThreadFamily resolve p) := by
  funext i
  rfl

/-! ============================================================
    Kernel preservation
============================================================ -/

theorem reindexThreadFamily_respects_kernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (σ : ThreadReindex n)
    {p q : ThreadFamily resolve n}
    (h : ThreadFamilyKernel resolve p q) :
    ThreadFamilyKernel resolve
      (reindexThreadFamily resolve σ p)
      (reindexThreadFamily resolve σ q) := by
  unfold ThreadFamilyKernel projectThreadFamily reindexThreadFamily
  funext i
  exact congrArg (fun f => f (σ i)) h

/-! ============================================================
    Bijective reindexing
============================================================ -/

structure ThreadPermutation (n : Nat) where
  toFun : Fin n → Fin n
  invFun : Fin n → Fin n
  left_inv : ∀ i, invFun (toFun i) = i
  right_inv : ∀ i, toFun (invFun i) = i

def permuteThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p : ThreadFamily resolve n) :
    ThreadFamily resolve n :=
  reindexThreadFamily resolve π.toFun p

def identityThreadPermutation (n : Nat) : ThreadPermutation n where
  toFun := fun i => i
  invFun := fun i => i
  left_inv := fun _ => rfl
  right_inv := fun _ => rfl

def composeThreadPermutation
    {n : Nat}
    (π₁ π₂ : ThreadPermutation n) :
    ThreadPermutation n where
  toFun := fun i => π₁.toFun (π₂.toFun i)
  invFun := fun i => π₂.invFun (π₁.invFun i)
  left_inv := fun i => by
    rw [π₁.left_inv, π₂.left_inv]
  right_inv := fun i => by
    rw [π₂.right_inv, π₁.right_inv]

def inverseThreadPermutation
    {n : Nat}
    (π : ThreadPermutation n) :
    ThreadPermutation n where
  toFun := π.invFun
  invFun := π.toFun
  left_inv := π.right_inv
  right_inv := π.left_inv

theorem permuteThreadFamily_identity
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) :
    permuteThreadFamily resolve (identityThreadPermutation n) p = p := by
  funext i
  rfl

theorem permuteThreadFamily_compose
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π₁ π₂ : ThreadPermutation n)
    (p : ThreadFamily resolve n) :
    permuteThreadFamily resolve (composeThreadPermutation π₁ π₂) p
    =
    permuteThreadFamily resolve π₂ (permuteThreadFamily resolve π₁ p) := by
  funext i
  rfl

theorem permuteThreadFamily_inverse
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p : ThreadFamily resolve n) :
    permuteThreadFamily resolve (inverseThreadPermutation π)
      (permuteThreadFamily resolve π p) = p := by
  funext i
  simp only [permuteThreadFamily, reindexThreadFamily, inverseThreadPermutation]
  rw [π.right_inv]

/-! ============================================================
    RawAllEqual under permutation
============================================================ -/

theorem rawAllEqual_permutation_invariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p : ThreadFamily resolve n) :
    RawAllEqual resolve (permuteThreadFamily resolve π p)
    ↔
    RawAllEqual resolve p := by
  unfold RawAllEqual permuteThreadFamily reindexThreadFamily
  constructor
  · intro h i j
    have h' := h (π.invFun i) (π.invFun j)
    simp only [π.right_inv] at h'
    exact h'
  · intro h i j
    exact h (π.toFun i) (π.toFun j)

/-! ============================================================
    Two-thread swap
============================================================ -/

def swapTwo : ThreadPermutation 2 where
  toFun
    | ⟨0, _⟩ => ⟨1, by decide⟩
    | ⟨1, _⟩ => ⟨0, by decide⟩
  invFun
    | ⟨0, _⟩ => ⟨1, by decide⟩
    | ⟨1, _⟩ => ⟨0, by decide⟩
  left_inv
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl
  right_inv
    | ⟨0, _⟩ => rfl
    | ⟨1, _⟩ => rfl

theorem swapTwo_nonidentity :
    swapTwo.toFun ≠ (identityThreadPermutation 2).toFun := by
  intro h
  have := congrFun h ⟨0, by decide⟩
  simp [swapTwo, identityThreadPermutation] at this

theorem swapTwo_square
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 2) :
    permuteThreadFamily resolve (composeThreadPermutation swapTwo swapTwo) p = p := by
  funext i
  match i with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl

/-! ============================================================
    Folded-trivial permutation
============================================================ -/

def FoldedTrivialPermutationStep
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (π : ThreadPermutation n)
    (p : ThreadFamily resolve n) : Prop :=
  ThreadFamilyKernel resolve
    (permuteThreadFamily resolve π p)
    p

def PermutationSensitiveClassifierWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ∃ (π : ThreadPermutation n)
    (p : ThreadFamily resolve n),
      C.classify (permuteThreadFamily resolve π p)
      ≠
      C.classify p

def FoldedTrivialPermutationClassifierWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ∃ (π : ThreadPermutation n)
    (p : ThreadFamily resolve n),
      FoldedTrivialPermutationStep resolve π p
      ∧
      C.classify (permuteThreadFamily resolve π p)
      ≠
      C.classify p

theorem foldedTrivialPermutationWitness_implies_independent
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : FoldedTrivialPermutationClassifierWitness resolve C) :
    FamilyClassifierIndependentWitness resolve C := by
  rcases h with ⟨π, p, hKernel, hDifferent⟩
  exact ⟨permuteThreadFamily resolve π p, p, hKernel, hDifferent⟩

theorem foldedTrivialPermutationWitness_blocks_factorisation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : FoldedTrivialPermutationClassifierWitness resolve C) :
    ¬ FamilyClassifierFactorsThroughProjections resolve C := by
  exact familyClassifierIndependentWitness_blocks_factorisation
    resolve C
    (foldedTrivialPermutationWitness_implies_independent resolve C h)

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check reindexThreadFamily_respects_kernel
#check permuteThreadFamily_identity
#check permuteThreadFamily_compose
#check permuteThreadFamily_inverse
#check rawAllEqual_permutation_invariant
#check swapTwo_nonidentity
#check swapTwo_square
#check foldedTrivialPermutationWitness_blocks_factorisation

#print axioms reindexThreadFamily_respects_kernel
#print axioms rawAllEqual_permutation_invariant
#print axioms swapTwo_nonidentity
#print axioms foldedTrivialPermutationWitness_blocks_factorisation
