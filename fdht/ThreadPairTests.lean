import FDHT_Audit_ArbitraryCollision

open KernelExprContext

variable
    {Store : Sort u}
    {Location : Sort v}

structure ThreadPair
    (resolve : KernelExpr → Store → Location) where
  left  : List KernelExprContext
  right : List KernelExprContext

def projectThreadPair
    (resolve : KernelExpr → Store → Location) :
    ThreadPair resolve →
    TrajectoryBoundary resolve ×
      TrajectoryBoundary resolve
  | p =>
      (trajectoryProjection resolve p.left,
       trajectoryProjection resolve p.right)

def ThreadPairKernel
    (resolve : KernelExpr → Store → Location)
    (p q : ThreadPair resolve) : Prop :=
  projectThreadPair resolve p =
  projectThreadPair resolve q

def FactorsThroughProjections
    (resolve : KernelExpr → Store → Location)
    (R : ThreadPair resolve → Prop) : Prop :=
  ∀ p q : ThreadPair resolve,
    ThreadPairKernel resolve p q →
    R p = R q

theorem factorsThroughProjections_iff_kernel_invariant
    (resolve : KernelExpr → Store → Location)
    (R : ThreadPair resolve → Prop) :
    FactorsThroughProjections resolve R
    ↔
    ∀ p q : ThreadPair resolve,
      ThreadPairKernel resolve p q →
      R p = R q := by
  rfl

theorem rawRelation_independent_of_witness
    (resolve : KernelExpr → Store → Location)
    (R : ThreadPair resolve → Prop)
    (p q : ThreadPair resolve)
    (hWitness :
      ThreadPairKernel resolve p q ∧
      R p ≠ R q) :
    ¬ FactorsThroughProjections resolve R := by
  intro hFactor
  have hInvariant :=
    (factorsThroughProjections_iff_kernel_invariant
      resolve R).mp hFactor
  have hEq : R p = R q :=
    hInvariant p q hWitness.1
  exact hWitness.2 hEq

#check rawRelation_independent_of_witness
