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

theorem ThreadPairKernel_refl
    (resolve : KernelExpr → Store → Location)
    (p : ThreadPair resolve) :
    ThreadPairKernel resolve p p :=
  rfl

theorem ThreadPairKernel_symm
    (resolve : KernelExpr → Store → Location)
    {p q : ThreadPair resolve}
    (h : ThreadPairKernel resolve p q) :
    ThreadPairKernel resolve q p :=
  h.symm

theorem ThreadPairKernel_trans
    (resolve : KernelExpr → Store → Location)
    {p q r : ThreadPair resolve}
    (hpq : ThreadPairKernel resolve p q)
    (hqr : ThreadPairKernel resolve q r) :
    ThreadPairKernel resolve p r :=
  hpq.trans hqr

def composeThreadPair
    (resolve : KernelExpr → Store → Location)
    (p q : ThreadPair resolve) :
    ThreadPair resolve where
  left  := p.left  ++ q.left
  right := p.right ++ q.right

theorem ThreadPairKernel_congr
    (resolve : KernelExpr → Store → Location)
    {p₁ p₂ q₁ q₂ : ThreadPair resolve}
    (hp : ThreadPairKernel resolve p₁ p₂)
    (hq : ThreadPairKernel resolve q₁ q₂) :
    ThreadPairKernel resolve
      (composeThreadPair resolve p₁ q₁)
      (composeThreadPair resolve p₂ q₂) := by
  unfold ThreadPairKernel projectThreadPair composeThreadPair at *
  simp only [Prod.mk.injEq] at *
  constructor
  · have hL₁ := trajectoryProjection_append resolve p₁.left q₁.left
    have hL₂ := trajectoryProjection_append resolve p₂.left q₂.left
    rw [hL₁, hL₂]
    congr 1
    · exact hp.1
    · exact hq.1
  · have hR₁ := trajectoryProjection_append resolve p₁.right q₁.right
    have hR₂ := trajectoryProjection_append resolve p₂.right q₂.right
    rw [hR₁, hR₂]
    congr 1
    · exact hp.2
    · exact hq.2

def ThreadPairKernelSetoid
    (resolve : KernelExpr → Store → Location) :
    Setoid (ThreadPair resolve) where
  r := ThreadPairKernel resolve
  iseqv :=
  {
    refl  := ThreadPairKernel_refl resolve
    symm  := ThreadPairKernel_symm resolve
    trans := ThreadPairKernel_trans resolve
  }

abbrev ThreadPairQuotient
    (resolve : KernelExpr → Store → Location) :=
  Quotient (ThreadPairKernelSetoid resolve)

/-! Product monoid on TrajectoryBoundary × TrajectoryBoundary -/

def trajectoryProductMonoid
    (resolve : KernelExpr → Store → Location) :
    LocalMonoid
      (TrajectoryBoundary resolve ×
       TrajectoryBoundary resolve) where
  one :=
    (emptyTrajectory resolve, emptyTrajectory resolve)
  mul := fun a b =>
    (composeTrajectory resolve a.1 b.1,
     composeTrajectory resolve a.2 b.2)
  one_mul := by
    intro a
    show
      (composeTrajectory resolve (emptyTrajectory resolve) a.1,
       composeTrajectory resolve (emptyTrajectory resolve) a.2) = a
    congr 1
    · exact (trajectoryLocalMonoid resolve).one_mul a.1
    · exact (trajectoryLocalMonoid resolve).one_mul a.2
  mul_one := by
    intro a
    show
      (composeTrajectory resolve a.1 (emptyTrajectory resolve),
       composeTrajectory resolve a.2 (emptyTrajectory resolve)) = a
    congr 1
    · exact (trajectoryLocalMonoid resolve).mul_one a.1
    · exact (trajectoryLocalMonoid resolve).mul_one a.2
  mul_assoc := by
    intro a b c
    show
      (composeTrajectory resolve
         (composeTrajectory resolve a.1 b.1) c.1,
       composeTrajectory resolve
         (composeTrajectory resolve a.2 b.2) c.2)
      =
      (composeTrajectory resolve a.1
         (composeTrajectory resolve b.1 c.1),
       composeTrajectory resolve a.2
         (composeTrajectory resolve b.2 c.2))
    congr 1
    · exact (trajectoryLocalMonoid resolve).mul_assoc a.1 b.1 c.1
    · exact (trajectoryLocalMonoid resolve).mul_assoc a.2 b.2 c.2

/-! Monoid on ThreadPairQuotient -/

def emptyThreadPair
    (resolve : KernelExpr → Store → Location) :
    ThreadPair resolve where
  left  := []
  right := []

def composeThreadPairQuotient
    (resolve : KernelExpr → Store → Location) :
    ThreadPairQuotient resolve →
    ThreadPairQuotient resolve →
    ThreadPairQuotient resolve :=
  Quotient.lift₂
    (fun p q =>
      Quotient.mk
        (ThreadPairKernelSetoid resolve)
        (composeThreadPair resolve p q))
    (by
      intro p₁ q₁ p₂ q₂ hp hq
      exact Quotient.sound (ThreadPairKernel_congr resolve hp hq))

def threadPairQuotientMonoid
    (resolve : KernelExpr → Store → Location) :
    LocalMonoid (ThreadPairQuotient resolve) where
  one :=
    Quotient.mk
      (ThreadPairKernelSetoid resolve)
      (emptyThreadPair resolve)
  mul := composeThreadPairQuotient resolve
  one_mul := by
    intro a
    induction a using Quotient.ind with
    | _ p =>
      apply Quotient.sound
      show ThreadPairKernel resolve
        (composeThreadPair resolve (emptyThreadPair resolve) p) p
      unfold ThreadPairKernel projectThreadPair
      simp [emptyThreadPair, composeThreadPair]
  mul_one := by
    intro a
    induction a using Quotient.ind with
    | _ p =>
      apply Quotient.sound
      show ThreadPairKernel resolve
        (composeThreadPair resolve p (emptyThreadPair resolve)) p
      unfold ThreadPairKernel projectThreadPair
      simp [emptyThreadPair, composeThreadPair]
  mul_assoc := by
    intro a b c
    induction a using Quotient.ind with
    | _ p =>
      induction b using Quotient.ind with
      | _ q =>
        induction c using Quotient.ind with
        | _ r =>
          apply Quotient.sound
          show ThreadPairKernel resolve
            (composeThreadPair resolve
              (composeThreadPair resolve p q) r)
            (composeThreadPair resolve p
              (composeThreadPair resolve q r))
          unfold ThreadPairKernel projectThreadPair
          simp [composeThreadPair, List.append_assoc]

/-! Projection factors through quotient -/

def threadPairToProduct
    (resolve : KernelExpr → Store → Location) :
    ThreadPairQuotient resolve →
    TrajectoryBoundary resolve ×
      TrajectoryBoundary resolve :=
  Quotient.lift
    (projectThreadPair resolve)
    (by
      intro p q h
      exact h)

def productToThreadPair
    (resolve : KernelExpr → Store → Location) :
    TrajectoryBoundary resolve ×
      TrajectoryBoundary resolve →
    ThreadPairQuotient resolve
  | (tx, ty) =>
    Quotient.liftOn₂ tx ty
      (fun xs ys =>
        Quotient.mk
          (ThreadPairKernelSetoid resolve)
          { left := xs, right := ys })
      (by
        intro xs₁ ys₁ xs₂ ys₂ hx hy
        apply Quotient.sound
        show ThreadPairKernel resolve
          { left := xs₁, right := ys₁ }
          { left := xs₂, right := ys₂ }
        unfold ThreadPairKernel projectThreadPair
        simp [trajectoryProjection]
        exact ⟨Quotient.sound hx, Quotient.sound hy⟩)

/-! Equivalence -/

theorem threadPairToProduct_left_inv
    (resolve : KernelExpr → Store → Location)
    (a : ThreadPairQuotient resolve) :
    productToThreadPair resolve
      (threadPairToProduct resolve a) = a := by
  induction a using Quotient.ind with
  | _ p =>
    simp only [threadPairToProduct, productToThreadPair,
               projectThreadPair, trajectoryProjection]
    apply Quotient.sound
    show ThreadPairKernel resolve
      { left := p.left, right := p.right } p
    unfold ThreadPairKernel projectThreadPair
    rfl

theorem threadPairToProduct_right_inv
    (resolve : KernelExpr → Store → Location)
    (b : TrajectoryBoundary resolve ×
         TrajectoryBoundary resolve) :
    threadPairToProduct resolve
      (productToThreadPair resolve b) = b := by
  rcases b with ⟨tx, ty⟩
  induction tx using Quotient.ind with
  | _ xs =>
    induction ty using Quotient.ind with
    | _ ys =>
      simp only [threadPairToProduct, productToThreadPair,
                 projectThreadPair, trajectoryProjection]
      rfl

def ThreadPairQuotient_equiv_Product
    (resolve : KernelExpr → Store → Location) :
    LocalEquiv
      (ThreadPairQuotient resolve)
      (TrajectoryBoundary resolve ×
       TrajectoryBoundary resolve) where
  toFun     := threadPairToProduct resolve
  invFun    := productToThreadPair resolve
  left_inv  := threadPairToProduct_left_inv resolve
  right_inv := threadPairToProduct_right_inv resolve

/-! Monoid equivalence -/

theorem threadPairToProduct_map_one
    (resolve : KernelExpr → Store → Location) :
    threadPairToProduct resolve
      (threadPairQuotientMonoid resolve).one
    =
    (trajectoryProductMonoid resolve).one := by
  simp only [threadPairToProduct, projectThreadPair,
             trajectoryProjection]
  rfl

theorem threadPairToProduct_map_mul
    (resolve : KernelExpr → Store → Location)
    (a b : ThreadPairQuotient resolve) :
    threadPairToProduct resolve
      ((threadPairQuotientMonoid resolve).mul a b)
    =
    (trajectoryProductMonoid resolve).mul
      (threadPairToProduct resolve a)
      (threadPairToProduct resolve b) := by
  induction a using Quotient.ind with
  | _ p =>
    induction b using Quotient.ind with
    | _ q =>
      simp only [threadPairToProduct, projectThreadPair,
                 composeThreadPairQuotient,
                 trajectoryProjection,
                 trajectoryProjection_append]
      rfl

def ThreadPairQuotient_monoidEquiv_Product
    (resolve : KernelExpr → Store → Location) :
    LocalMonoidEquiv
      (ThreadPairQuotient resolve)
      (TrajectoryBoundary resolve ×
       TrajectoryBoundary resolve)
      (threadPairQuotientMonoid resolve)
      (trajectoryProductMonoid resolve) where
  equiv    := ThreadPairQuotient_equiv_Product resolve
  map_one  := threadPairToProduct_map_one resolve
  map_mul  := threadPairToProduct_map_mul resolve

#check ThreadPairQuotient_monoidEquiv_Product
#check ThreadPairQuotient_equiv_Product
