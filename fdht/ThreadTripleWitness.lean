import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

structure ThreadTriple
    (resolve : KernelExpr → Store → Location) where
  first  : List KernelExprContext
  second : List KernelExprContext
  third  : List KernelExprContext

def projectThreadTriple
    (resolve : KernelExpr → Store → Location)
    (p : ThreadTriple resolve) :
    TrajectoryBoundary resolve ×
      TrajectoryBoundary resolve ×
      TrajectoryBoundary resolve :=
  (trajectoryProjection resolve p.first,
   trajectoryProjection resolve p.second,
   trajectoryProjection resolve p.third)

def ThreadTripleKernel
    (resolve : KernelExpr → Store → Location)
    (p q : ThreadTriple resolve) : Prop :=
  projectThreadTriple resolve p =
  projectThreadTriple resolve q

theorem ThreadTripleKernel_refl
    (resolve : KernelExpr → Store → Location)
    (p : ThreadTriple resolve) :
    ThreadTripleKernel resolve p p := rfl

theorem ThreadTripleKernel_symm
    (resolve : KernelExpr → Store → Location)
    {p q : ThreadTriple resolve}
    (h : ThreadTripleKernel resolve p q) :
    ThreadTripleKernel resolve q p := h.symm

theorem ThreadTripleKernel_trans
    (resolve : KernelExpr → Store → Location)
    {p q r : ThreadTriple resolve}
    (hpq : ThreadTripleKernel resolve p q)
    (hqr : ThreadTripleKernel resolve q r) :
    ThreadTripleKernel resolve p r := hpq.trans hqr

def RawThreeWayAgreement
    (resolve : KernelExpr → Store → Location)
    (p : ThreadTriple resolve) : Prop :=
  p.first = p.second ∧ p.second = p.third

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

def tripleEqual
    (resolve : KernelExpr → Store → Location) :
    ThreadTriple resolve where
  first  := []
  second := []
  third  := []

def tripleUnequal
    (resolve : KernelExpr → Store → Location) :
    ThreadTriple resolve where
  first  := []
  second := []
  third  := [identityContext]

theorem tripleEqual_kernel_tripleUnequal
    (resolve : KernelExpr → Store → Location) :
    ThreadTripleKernel resolve (tripleEqual resolve) (tripleUnequal resolve) := by
  unfold ThreadTripleKernel projectThreadTriple tripleEqual tripleUnequal
  simp [empty_identity_same_projection]

theorem empty_ne_identity :
    ([] : List KernelExprContext) ≠ [identityContext] := by
  intro h
  cases h

theorem tripleEqual_agrees
    (resolve : KernelExpr → Store → Location) :
    RawThreeWayAgreement resolve (tripleEqual resolve) := by
  unfold RawThreeWayAgreement tripleEqual
  exact ⟨rfl, rfl⟩

theorem tripleUnequal_disagrees
    (resolve : KernelExpr → Store → Location) :
    ¬ RawThreeWayAgreement resolve (tripleUnequal resolve) := by
  unfold RawThreeWayAgreement tripleUnequal
  intro ⟨_, h⟩
  exact empty_ne_identity h

def TripleFactorsThroughProjections
    (resolve : KernelExpr → Store → Location)
    (R : ThreadTriple resolve → Prop) : Prop :=
  ∀ p q : ThreadTriple resolve,
    ThreadTripleKernel resolve p q → R p = R q

theorem triple_factors_iff_kernel_invariant
    (resolve : KernelExpr → Store → Location)
    (R : ThreadTriple resolve → Prop) :
    TripleFactorsThroughProjections resolve R
    ↔
    ∀ p q : ThreadTriple resolve,
      ThreadTripleKernel resolve p q → R p = R q := by
  rfl

theorem tripleRelation_independent_of_witness
    (resolve : KernelExpr → Store → Location)
    (R : ThreadTriple resolve → Prop)
    {p q : ThreadTriple resolve}
    (hKernel : ThreadTripleKernel resolve p q)
    (hRel : R p ≠ R q) :
    ¬ TripleFactorsThroughProjections resolve R := by
  intro hFactor
  have hInvariant :=
    (triple_factors_iff_kernel_invariant resolve R).mp hFactor
  exact hRel (hInvariant p q hKernel)

theorem rawThreeWayAgreement_independence_witness
    (resolve : KernelExpr → Store → Location) :
    ∃ p q : ThreadTriple resolve,
      ThreadTripleKernel resolve p q ∧
      RawThreeWayAgreement resolve p ≠
        RawThreeWayAgreement resolve q := by
  refine ⟨tripleEqual resolve, tripleUnequal resolve, ?_, ?_⟩
  · exact tripleEqual_kernel_tripleUnequal resolve
  · intro h
    have hNot : ¬ RawThreeWayAgreement resolve (tripleUnequal resolve) :=
      tripleUnequal_disagrees resolve
    exact hNot (h ▸ tripleEqual_agrees resolve)

theorem rawThreeWayAgreement_does_not_factor
    (resolve : KernelExpr → Store → Location) :
    ¬ TripleFactorsThroughProjections
        resolve (RawThreeWayAgreement resolve) := by
  rcases rawThreeWayAgreement_independence_witness resolve with
    ⟨p, q, hKernel, hRelation⟩
  exact tripleRelation_independent_of_witness resolve
    (RawThreeWayAgreement resolve) hKernel hRelation

def TripleRelationalDegreeOfFreedomExists
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ (R : ThreadTriple resolve → Prop)
    (p q : ThreadTriple resolve),
      ThreadTripleKernel resolve p q ∧ R p ≠ R q

theorem triple_relational_degree_of_freedom_exists
    (resolve : KernelExpr → Store → Location) :
    TripleRelationalDegreeOfFreedomExists resolve := by
  exact ⟨RawThreeWayAgreement resolve,
         tripleEqual resolve,
         tripleUnequal resolve,
         tripleEqual_kernel_tripleUnequal resolve,
         fun h => tripleUnequal_disagrees resolve (h ▸ tripleEqual_agrees resolve)⟩

#check rawThreeWayAgreement_independence_witness
#check rawThreeWayAgreement_does_not_factor
#check triple_relational_degree_of_freedom_exists

#print axioms rawThreeWayAgreement_independence_witness
#print axioms rawThreeWayAgreement_does_not_factor
#print axioms triple_relational_degree_of_freedom_exists
#print axioms ThreadTripleKernel_refl
#print axioms triple_factors_iff_kernel_invariant
#print axioms tripleRelation_independent_of_witness
