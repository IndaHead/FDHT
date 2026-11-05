import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

def ThreadFamily
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :=
  Fin n → List KernelExprContext

def projectThreadFamily
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) :
    Fin n → TrajectoryBoundary resolve :=
  fun i => trajectoryProjection resolve (p i)

def ThreadFamilyKernel
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p q : ThreadFamily resolve n) : Prop :=
  projectThreadFamily resolve p =
  projectThreadFamily resolve q

theorem ThreadFamilyKernel_refl
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) :
    ThreadFamilyKernel resolve p p := rfl

theorem ThreadFamilyKernel_symm
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {p q : ThreadFamily resolve n}
    (h : ThreadFamilyKernel resolve p q) :
    ThreadFamilyKernel resolve q p := h.symm

theorem ThreadFamilyKernel_trans
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    {p q r : ThreadFamily resolve n}
    (hpq : ThreadFamilyKernel resolve p q)
    (hqr : ThreadFamilyKernel resolve q r) :
    ThreadFamilyKernel resolve p r := hpq.trans hqr

def RawAllEqual
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (p : ThreadFamily resolve n) : Prop :=
  ∀ i j : Fin n, p i = p j

theorem empty_identity_equivalent
    (resolve : KernelExpr → Store → Location) :
    TrajectoryEquivalent resolve [] [identityContext] := by
  intro q
  simp [evolvePersistent, plugPersistent, identityContext, toPersistentBoundary]
  induction q using Quotient.ind with
  | _ e => rfl

theorem empty_identity_same_projection
    (resolve : KernelExpr → Store → Location) :
    trajectoryProjection resolve [] =
    trajectoryProjection resolve [identityContext] := by
  unfold trajectoryProjection toTrajectoryBoundary
  exact Quotient.sound (empty_identity_equivalent resolve)

def familyEqual
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    ThreadFamily resolve n :=
  fun _ => []

def familyUnequal
    (resolve : KernelExpr → Store → Location)
    (n : Nat) (h : 1 < n) :
    ThreadFamily resolve n :=
  fun i => if i.val = 0 then [] else [identityContext]

theorem familyEqual_kernel_familyUnequal
    (resolve : KernelExpr → Store → Location)
    (n : Nat) (h : 1 < n) :
    ThreadFamilyKernel resolve (familyEqual resolve n) (familyUnequal resolve n h) := by
  unfold ThreadFamilyKernel projectThreadFamily familyEqual familyUnequal
  funext i
  by_cases hi : i.val = 0
  · simp [hi, empty_identity_same_projection]
  · simp [hi, empty_identity_same_projection]

theorem familyEqual_allEqual
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    RawAllEqual resolve (familyEqual resolve n) := by
  unfold RawAllEqual familyEqual
  intro i j
  rfl

theorem empty_ne_identity :
    ([] : List KernelExprContext) ≠ [identityContext] := by
  intro h
  cases h

theorem familyUnequal_notAllEqual
    (resolve : KernelExpr → Store → Location)
    (n : Nat) (h : 1 < n) :
    ¬ RawAllEqual resolve (familyUnequal resolve n h) := by
  intro hAll
  have h0 : familyUnequal resolve n h ⟨0, Nat.zero_lt_of_lt h⟩ = [] := by
    simp [familyUnequal]
  have h1 : familyUnequal resolve n h ⟨1, h⟩ = [identityContext] := by
    simp [familyUnequal]
  have hEq := hAll ⟨0, Nat.zero_lt_of_lt h⟩ ⟨1, h⟩
  rw [h0, h1] at hEq
  exact empty_ne_identity hEq

def FamilyFactorsThroughProjections
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : ThreadFamily resolve n → Prop) : Prop :=
  ∀ p q : ThreadFamily resolve n,
    ThreadFamilyKernel resolve p q → R p = R q

theorem family_factors_iff_kernel_invariant
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : ThreadFamily resolve n → Prop) :
    FamilyFactorsThroughProjections resolve R
    ↔
    ∀ p q : ThreadFamily resolve n,
      ThreadFamilyKernel resolve p q → R p = R q := by
  rfl

theorem familyRelation_independent_of_witness
    (resolve : KernelExpr → Store → Location)
    {n : Nat}
    (R : ThreadFamily resolve n → Prop)
    {p q : ThreadFamily resolve n}
    (hKernel : ThreadFamilyKernel resolve p q)
    (hRel : R p ≠ R q) :
    ¬ FamilyFactorsThroughProjections resolve R := by
  intro hFactor
  have hInvariant :=
    (family_factors_iff_kernel_invariant resolve R).mp hFactor
  exact hRel (hInvariant p q hKernel)

theorem rawAllEqual_independence_witness
    (resolve : KernelExpr → Store → Location)
    (n : Nat) (h : 1 < n) :
    ∃ p q : ThreadFamily resolve n,
      ThreadFamilyKernel resolve p q ∧
      RawAllEqual resolve p ≠ RawAllEqual resolve q := by
  refine ⟨familyEqual resolve n, familyUnequal resolve n h, ?_, ?_⟩
  · exact familyEqual_kernel_familyUnequal resolve n h
  · intro hEq
    have hNot : ¬ RawAllEqual resolve (familyUnequal resolve n h) :=
      familyUnequal_notAllEqual resolve n h
    exact hNot (hEq ▸ familyEqual_allEqual resolve n)

theorem rawAllEqual_does_not_factor
    (resolve : KernelExpr → Store → Location)
    (n : Nat) (h : 1 < n) :
    ¬ FamilyFactorsThroughProjections (resolve := resolve) (n := n)
        (RawAllEqual (resolve := resolve) (n := n)) := by
  rcases rawAllEqual_independence_witness resolve n h with
    ⟨p, q, hKernel, hRelation⟩
  exact familyRelation_independent_of_witness (resolve := resolve) (n := n)
    (RawAllEqual (resolve := resolve) (n := n)) hKernel hRelation

def FamilyRelationalDegreeOfFreedomExists
    (resolve : KernelExpr → Store → Location)
    (n : Nat) : Prop :=
  ∃ (R : ThreadFamily resolve n → Prop)
    (p q : ThreadFamily resolve n),
      ThreadFamilyKernel resolve p q ∧ R p ≠ R q

theorem family_relational_degree_of_freedom_exists
    (resolve : KernelExpr → Store → Location)
    (n : Nat) (h : 1 < n) :
    FamilyRelationalDegreeOfFreedomExists resolve n := by
  exact ⟨RawAllEqual (resolve := resolve) (n := n),
         familyEqual resolve n,
         familyUnequal resolve n h,
         familyEqual_kernel_familyUnequal resolve n h,
         fun hEq => familyUnequal_notAllEqual resolve n h (hEq ▸ familyEqual_allEqual resolve n)⟩

#check rawAllEqual_independence_witness
#check rawAllEqual_does_not_factor
#check family_relational_degree_of_freedom_exists

#print axioms rawAllEqual_independence_witness
#print axioms rawAllEqual_does_not_factor
#print axioms family_relational_degree_of_freedom_exists
