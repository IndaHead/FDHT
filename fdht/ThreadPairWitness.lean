import FDHT_Audit_ArbitraryCollision
open KernelExprContext

variable {Store : Sort u} {Location : Sort v}

structure ThreadPair
    (resolve : KernelExpr → Store → Location) where
  left  : List KernelExprContext
  right : List KernelExprContext

def projectThreadPair
    (resolve : KernelExpr → Store → Location) :
    ThreadPair resolve →
    TrajectoryBoundary resolve × TrajectoryBoundary resolve
  | p =>
      (trajectoryProjection resolve p.left,
       trajectoryProjection resolve p.right)

def ThreadPairKernel
    (resolve : KernelExpr → Store → Location)
    (p q : ThreadPair resolve) : Prop :=
  projectThreadPair resolve p = projectThreadPair resolve q

def FactorsThroughProjections
    (resolve : KernelExpr → Store → Location)
    (R : ThreadPair resolve → Prop) : Prop :=
  ∀ p q : ThreadPair resolve,
    ThreadPairKernel resolve p q → R p = R q

def RawThreadsEqual
    (resolve : KernelExpr → Store → Location)
    (p : ThreadPair resolve) : Prop :=
  p.left = p.right

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

def pairEqual
    (resolve : KernelExpr → Store → Location) :
    ThreadPair resolve where
  left  := []
  right := []

def pairUnequal
    (resolve : KernelExpr → Store → Location) :
    ThreadPair resolve where
  left  := []
  right := [identityContext]

theorem pairEqual_kernel_pairUnequal
    (resolve : KernelExpr → Store → Location) :
    ThreadPairKernel resolve (pairEqual resolve) (pairUnequal resolve) := by
  unfold ThreadPairKernel projectThreadPair pairEqual pairUnequal
  simp [empty_identity_same_projection]

theorem pairEqual_rawEqual
    (resolve : KernelExpr → Store → Location) :
    RawThreadsEqual resolve (pairEqual resolve) := by
  unfold RawThreadsEqual pairEqual
  rfl

theorem empty_ne_identity :
    ([] : List KernelExprContext) ≠ [identityContext] := by
  intro h
  cases h

theorem pairUnequal_rawNotEqual
    (resolve : KernelExpr → Store → Location) :
    ¬ RawThreadsEqual resolve (pairUnequal resolve) := by
  unfold RawThreadsEqual pairUnequal
  exact empty_ne_identity

theorem rawThreadsEqual_independence_witness
    (resolve : KernelExpr → Store → Location) :
    ∃ p q : ThreadPair resolve,
      ThreadPairKernel resolve p q ∧
      RawThreadsEqual resolve p ≠ RawThreadsEqual resolve q := by
  refine ⟨pairEqual resolve, pairUnequal resolve, ?_, ?_⟩
  · exact pairEqual_kernel_pairUnequal resolve
  · intro h
    have hNot : ¬ RawThreadsEqual resolve (pairUnequal resolve) :=
      pairUnequal_rawNotEqual resolve
    exact hNot (h ▸ pairEqual_rawEqual resolve)

theorem factorsThroughProjections_iff_kernel_invariant
    (resolve : KernelExpr → Store → Location)
    (R : ThreadPair resolve → Prop) :
    FactorsThroughProjections resolve R
    ↔
    ∀ p q : ThreadPair resolve,
      ThreadPairKernel resolve p q → R p = R q := by
  rfl

theorem rawRelation_independent_of_witness
    (resolve : KernelExpr → Store → Location)
    (R : ThreadPair resolve → Prop)
    (p q : ThreadPair resolve)
    (hWitness : ThreadPairKernel resolve p q ∧ R p ≠ R q) :
    ¬ FactorsThroughProjections resolve R := by
  intro hFactor
  have hInvariant :=
    (factorsThroughProjections_iff_kernel_invariant resolve R).mp hFactor
  exact hWitness.2 (hInvariant p q hWitness.1)

theorem rawThreadsEqual_does_not_factor
    (resolve : KernelExpr → Store → Location) :
    ¬ FactorsThroughProjections resolve (RawThreadsEqual resolve) := by
  rcases rawThreadsEqual_independence_witness resolve with
    ⟨p, q, hKernel, hRelation⟩
  exact rawRelation_independent_of_witness resolve
    (RawThreadsEqual resolve) p q ⟨hKernel, hRelation⟩

def RelationalDegreeOfFreedomExists
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ (R : ThreadPair resolve → Prop)
    (p q : ThreadPair resolve),
      ThreadPairKernel resolve p q ∧ R p ≠ R q

theorem relational_degree_of_freedom_exists
    (resolve : KernelExpr → Store → Location) :
    RelationalDegreeOfFreedomExists resolve := by
  exact ⟨RawThreadsEqual resolve,
         pairEqual resolve,
         pairUnequal resolve,
         pairEqual_kernel_pairUnequal resolve,
         fun h => pairUnequal_rawNotEqual resolve (h ▸ pairEqual_rawEqual resolve)⟩

theorem relational_degree_of_freedom_blocks_universal_factorisation
    (resolve : KernelExpr → Store → Location)
    (h : RelationalDegreeOfFreedomExists resolve) :
    ∃ R : ThreadPair resolve → Prop,
      ¬ FactorsThroughProjections resolve R := by
  rcases h with ⟨R, p, q, hKernel, hDifferent⟩
  exact ⟨R, rawRelation_independent_of_witness resolve R p q ⟨hKernel, hDifferent⟩⟩

#check rawThreadsEqual_independence_witness
#check rawThreadsEqual_does_not_factor
#check relational_degree_of_freedom_exists
#check relational_degree_of_freedom_blocks_universal_factorisation

#print axioms rawThreadsEqual_independence_witness
#print axioms rawThreadsEqual_does_not_factor
#print axioms relational_degree_of_freedom_exists
#print axioms relational_degree_of_freedom_blocks_universal_factorisation
