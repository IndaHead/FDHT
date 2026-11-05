import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

structure ThreadQuad
    (resolve : KernelExpr → Store → Location) where
  first  : List KernelExprContext
  second : List KernelExprContext
  third  : List KernelExprContext
  fourth : List KernelExprContext

def projectThreadQuad
    (resolve : KernelExpr → Store → Location)
    (p : ThreadQuad resolve) :
    TrajectoryBoundary resolve ×
      TrajectoryBoundary resolve ×
      TrajectoryBoundary resolve ×
      TrajectoryBoundary resolve :=
  (trajectoryProjection resolve p.first,
   trajectoryProjection resolve p.second,
   trajectoryProjection resolve p.third,
   trajectoryProjection resolve p.fourth)

def ThreadQuadKernel
    (resolve : KernelExpr → Store → Location)
    (p q : ThreadQuad resolve) : Prop :=
  projectThreadQuad resolve p =
  projectThreadQuad resolve q

theorem ThreadQuadKernel_refl
    (resolve : KernelExpr → Store → Location)
    (p : ThreadQuad resolve) :
    ThreadQuadKernel resolve p p := rfl

theorem ThreadQuadKernel_symm
    (resolve : KernelExpr → Store → Location)
    {p q : ThreadQuad resolve}
    (h : ThreadQuadKernel resolve p q) :
    ThreadQuadKernel resolve q p := h.symm

theorem ThreadQuadKernel_trans
    (resolve : KernelExpr → Store → Location)
    {p q r : ThreadQuad resolve}
    (hpq : ThreadQuadKernel resolve p q)
    (hqr : ThreadQuadKernel resolve q r) :
    ThreadQuadKernel resolve p r := hpq.trans hqr

def RawFourWayAgreement
    (resolve : KernelExpr → Store → Location)
    (p : ThreadQuad resolve) : Prop :=
  p.first = p.second ∧
  p.second = p.third ∧
  p.third = p.fourth

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

def quadEqual
    (resolve : KernelExpr → Store → Location) :
    ThreadQuad resolve where
  first  := []
  second := []
  third  := []
  fourth := []

def quadUnequal
    (resolve : KernelExpr → Store → Location) :
    ThreadQuad resolve where
  first  := []
  second := []
  third  := []
  fourth := [identityContext]

theorem quadEqual_kernel_quadUnequal
    (resolve : KernelExpr → Store → Location) :
    ThreadQuadKernel resolve (quadEqual resolve) (quadUnequal resolve) := by
  unfold ThreadQuadKernel projectThreadQuad quadEqual quadUnequal
  simp [empty_identity_same_projection]

theorem empty_ne_identity :
    ([] : List KernelExprContext) ≠ [identityContext] := by
  intro h
  cases h

theorem quadEqual_agrees
    (resolve : KernelExpr → Store → Location) :
    RawFourWayAgreement resolve (quadEqual resolve) := by
  unfold RawFourWayAgreement quadEqual
  exact ⟨rfl, rfl, rfl⟩

theorem quadUnequal_disagrees
    (resolve : KernelExpr → Store → Location) :
    ¬ RawFourWayAgreement resolve (quadUnequal resolve) := by
  unfold RawFourWayAgreement quadUnequal
  intro ⟨_, _, h⟩
  exact empty_ne_identity h

def QuadFactorsThroughProjections
    (resolve : KernelExpr → Store → Location)
    (R : ThreadQuad resolve → Prop) : Prop :=
  ∀ p q : ThreadQuad resolve,
    ThreadQuadKernel resolve p q → R p = R q

theorem quad_factors_iff_kernel_invariant
    (resolve : KernelExpr → Store → Location)
    (R : ThreadQuad resolve → Prop) :
    QuadFactorsThroughProjections resolve R
    ↔
    ∀ p q : ThreadQuad resolve,
      ThreadQuadKernel resolve p q → R p = R q := by
  rfl

theorem quadRelation_independent_of_witness
    (resolve : KernelExpr → Store → Location)
    (R : ThreadQuad resolve → Prop)
    {p q : ThreadQuad resolve}
    (hKernel : ThreadQuadKernel resolve p q)
    (hRel : R p ≠ R q) :
    ¬ QuadFactorsThroughProjections resolve R := by
  intro hFactor
  have hInvariant :=
    (quad_factors_iff_kernel_invariant resolve R).mp hFactor
  exact hRel (hInvariant p q hKernel)

theorem rawFourWayAgreement_independence_witness
    (resolve : KernelExpr → Store → Location) :
    ∃ p q : ThreadQuad resolve,
      ThreadQuadKernel resolve p q ∧
      RawFourWayAgreement resolve p ≠
        RawFourWayAgreement resolve q := by
  refine ⟨quadEqual resolve, quadUnequal resolve, ?_, ?_⟩
  · exact quadEqual_kernel_quadUnequal resolve
  · intro h
    have hNot : ¬ RawFourWayAgreement resolve (quadUnequal resolve) :=
      quadUnequal_disagrees resolve
    exact hNot (h ▸ quadEqual_agrees resolve)

theorem rawFourWayAgreement_does_not_factor
    (resolve : KernelExpr → Store → Location) :
    ¬ QuadFactorsThroughProjections
        resolve (RawFourWayAgreement resolve) := by
  rcases rawFourWayAgreement_independence_witness resolve with
    ⟨p, q, hKernel, hRelation⟩
  exact quadRelation_independent_of_witness resolve
    (RawFourWayAgreement resolve) hKernel hRelation

def QuadRelationalDegreeOfFreedomExists
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ (R : ThreadQuad resolve → Prop)
    (p q : ThreadQuad resolve),
      ThreadQuadKernel resolve p q ∧ R p ≠ R q

theorem quad_relational_degree_of_freedom_exists
    (resolve : KernelExpr → Store → Location) :
    QuadRelationalDegreeOfFreedomExists resolve := by
  exact ⟨RawFourWayAgreement resolve,
         quadEqual resolve,
         quadUnequal resolve,
         quadEqual_kernel_quadUnequal resolve,
         fun h => quadUnequal_disagrees resolve (h ▸ quadEqual_agrees resolve)⟩

#check rawFourWayAgreement_independence_witness
#check rawFourWayAgreement_does_not_factor
#check quad_relational_degree_of_freedom_exists

#print axioms rawFourWayAgreement_independence_witness
#print axioms rawFourWayAgreement_does_not_factor
#print axioms quad_relational_degree_of_freedom_exists
#print axioms ThreadQuadKernel_refl
#print axioms quad_factors_iff_kernel_invariant
#print axioms quadRelation_independent_of_witness
