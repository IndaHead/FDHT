import FDHT_Audit_ArbitraryCollision
import ThreadFamilyWitness
import ClassifierReconciliation
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Classifier factorisation
============================================================ -/

def FamilyClassifierFactorsThroughProjections
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ∃ classifyProjected :
      (Fin n → TrajectoryBoundary resolve) → C.Value,
    ∀ p,
      classifyProjected (projectThreadFamily resolve p)
      =
      C.classify p

theorem familyClassifier_factorisation_implies_invariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    FamilyClassifierFactorsThroughProjections resolve C →
    FamilyClassifierInvariant resolve C := by
  intro ⟨classifyProjected, hFactor⟩ p q hKernel
  rw [← hFactor p, ← hFactor q]
  rw [hKernel]

/-! ============================================================
    Invariance implies factorisation
============================================================ -/

theorem familyClassifier_invariant_implies_factorisation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    FamilyClassifierInvariant resolve C →
    FamilyClassifierFactorsThroughProjections resolve C := by
  intro hInv
  refine ⟨fun q =>
    C.classify (fun i =>
      Classical.choose (KernelExprContext.trajectoryProjection_surjective
        resolve (q i))),
    ?_⟩
  intro p
  have hChoice :
      ∀ i,
        trajectoryProjection resolve
          (Classical.choose
            (KernelExprContext.trajectoryProjection_surjective
              resolve (projectThreadFamily resolve p i)))
        =
        projectThreadFamily resolve p i :=
    fun i => Classical.choose_spec
      (KernelExprContext.trajectoryProjection_surjective
        resolve (projectThreadFamily resolve p i))
  have hKernel :
      ThreadFamilyKernel resolve
        (fun i =>
          Classical.choose
            (KernelExprContext.trajectoryProjection_surjective
              resolve (projectThreadFamily resolve p i)))
        p := by
    unfold ThreadFamilyKernel projectThreadFamily
    funext i
    exact hChoice i
  exact hInv _ p hKernel

/-! ============================================================
    Exact iff
============================================================ -/

theorem familyClassifier_factors_iff_invariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    FamilyClassifierFactorsThroughProjections resolve C
    ↔
    FamilyClassifierInvariant resolve C := by
  constructor
  · exact familyClassifier_factorisation_implies_invariant resolve C
  · exact familyClassifier_invariant_implies_factorisation resolve C

/-! ============================================================
    Independence blocks factorisation
============================================================ -/

theorem familyClassifierIndependentWitness_blocks_factorisation
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    FamilyClassifierIndependentWitness resolve C →
    ¬ FamilyClassifierFactorsThroughProjections resolve C := by
  intro hWitness hFactor
  have hInv :=
    familyClassifier_factorisation_implies_invariant resolve C hFactor
  exact familyClassifierIndependentWitness_refutes_invariant
    resolve C hWitness hInv

/-! ============================================================
    Finite family non-factorisation
============================================================ -/

theorem finite_family_nonfactorising_classifier_exists
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (hn : 1 < n) :
    ∃ C : RelationalClassifier (ThreadFamily resolve n),
      ¬ FamilyClassifierFactorsThroughProjections resolve C := by
  rcases finite_family_classifier_independence resolve n hn with
    ⟨C, hWitness⟩
  exact ⟨C,
    familyClassifierIndependentWitness_blocks_factorisation
      resolve C hWitness⟩

/-! ============================================================
    RawAllEqual specialisation
============================================================ -/

def rawAllEqualClassifier
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    RelationalClassifier (ThreadFamily resolve n) :=
  relationClassifier resolve (RawAllEqual (resolve := resolve) (n := n))

theorem rawAllEqualClassifier_apply
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (p : ThreadFamily resolve n) :
    (rawAllEqualClassifier resolve n).classify p
    =
    RawAllEqual (resolve := resolve) (n := n) p := by
  rfl

theorem rawAllEqualClassifier_does_not_factor
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (hn : 1 < n) :
    ¬ FamilyClassifierFactorsThroughProjections
      resolve
      (rawAllEqualClassifier resolve n) := by
  rcases rawAllEqual_independence_witness resolve n hn with
    ⟨p, q, hKernel, hRel⟩
  have hWitness :
      FamilyClassifierIndependentWitness resolve
        (rawAllEqualClassifier resolve n) :=
    ⟨p, q, hKernel, by simpa [rawAllEqualClassifier, relationClassifier] using hRel⟩
  exact familyClassifierIndependentWitness_blocks_factorisation
    resolve _ hWitness

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check familyClassifier_factorisation_implies_invariant
#check familyClassifier_invariant_implies_factorisation
#check familyClassifier_factors_iff_invariant
#check familyClassifierIndependentWitness_blocks_factorisation
#check finite_family_nonfactorising_classifier_exists
#check rawAllEqualClassifier_does_not_factor

#print axioms familyClassifier_factorisation_implies_invariant
#print axioms familyClassifier_invariant_implies_factorisation
#print axioms familyClassifier_factors_iff_invariant
#print axioms familyClassifierIndependentWitness_blocks_factorisation
#print axioms finite_family_nonfactorising_classifier_exists
#print axioms rawAllEqualClassifier_does_not_factor
