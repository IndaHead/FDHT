import FDHT_Audit_ArbitraryCollision
import ThreadFamilyWitness
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

/-! ============================================================
    Verified layers
============================================================ -/

structure RelationalClassifier (X : Type) where
  Value : Type
  classify : X → Value

def ClassifierInvariant
    {X : Type}
    (C : RelationalClassifier X)
    (E : X → X → Prop) : Prop :=
  ∀ x y, E x y → C.classify x = C.classify y

def FamilyClassifierInvariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ClassifierInvariant C (ThreadFamilyKernel resolve)

def FamilyClassifierIndependentWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n)) : Prop :=
  ∃ p q,
    ThreadFamilyKernel resolve p q ∧
    C.classify p ≠ C.classify q

theorem familyClassifierIndependentWitness_refutes_invariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (C : RelationalClassifier (ThreadFamily resolve n))
    (h : FamilyClassifierIndependentWitness resolve C) :
    ¬ FamilyClassifierInvariant resolve C := by
  intro hInv
  rcases h with ⟨p, q, hKernel, hNe⟩
  exact hNe (hInv p q hKernel)

/-! ============================================================
    Relation as classifier
============================================================ -/

def relationClassifier
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : ThreadFamily resolve n → Prop) :
    RelationalClassifier (ThreadFamily resolve n) :=
{
  Value := Prop
  classify := R
}

theorem relationClassifier_apply
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : ThreadFamily resolve n → Prop)
    (p : ThreadFamily resolve n) :
    (relationClassifier resolve R).classify p = R p := by
  rfl

/-! ============================================================
    Lift existing relational witness
============================================================ -/

theorem relationWitness_to_classifierWitness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : ThreadFamily resolve n → Prop)
    {p q : ThreadFamily resolve n}
    (hKernel : ThreadFamilyKernel resolve p q)
    (hRel : R p ≠ R q) :
    FamilyClassifierIndependentWitness
      resolve
      (relationClassifier resolve R) := by
  exact ⟨p, q, hKernel, by simpa [relationClassifier] using hRel⟩

/-! ============================================================
    Finite family classifier independence
============================================================ -/

theorem finite_family_classifier_independence
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (hn : 1 < n) :
    ∃ C : RelationalClassifier (ThreadFamily resolve n),
      FamilyClassifierIndependentWitness resolve C := by
  rcases rawAllEqual_independence_witness resolve n hn with
    ⟨p, q, hKernel, hRel⟩
  exact ⟨relationClassifier resolve (RawAllEqual (resolve := resolve) (n := n)),
         relationWitness_to_classifierWitness resolve
           (RawAllEqual (resolve := resolve) (n := n))
           hKernel hRel⟩

theorem finite_family_noninvariant_classifier_exists
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (hn : 1 < n) :
    ∃ C : RelationalClassifier (ThreadFamily resolve n),
      ¬ FamilyClassifierInvariant resolve C := by
  rcases finite_family_classifier_independence resolve n hn with
    ⟨C, hWitness⟩
  exact ⟨C, familyClassifierIndependentWitness_refutes_invariant resolve C hWitness⟩

/-! ============================================================
    Compiler-facing checks
============================================================ -/

#check relationClassifier
#check relationClassifier_apply
#check relationWitness_to_classifierWitness
#check finite_family_classifier_independence
#check finite_family_noninvariant_classifier_exists

#print axioms relationClassifier_apply
#print axioms relationWitness_to_classifierWitness
#print axioms finite_family_classifier_independence
#print axioms finite_family_noninvariant_classifier_exists
