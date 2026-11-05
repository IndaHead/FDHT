import AggregateFamilyTransform

open KernelExprContext

/-!
# FDHT Return / Stabiliser / Cancellation Boundary

Dependency calculus only. Does not close OPEN propositions.
Does not assume cancellation.
-/

variable {Store : Sort u} {Location : Sort v}
variable (resolve : KernelExpr → Store → Location)

/-! Algebraic return form. -/

theorem ReturnsTo_iff_right_stabilises
    (xs extension : List KernelExprContext) :
    ReturnsTo resolve xs extension
    ↔
    composeTrajectory resolve
      (trajectoryProjection resolve xs)
      (trajectoryProjection resolve extension)
    =
    trajectoryProjection resolve xs := by
  unfold ReturnsTo
  rw [trajectoryProjection_append]

theorem returnsTo_iff_rightStabilizerMembership
    (xs extension : List KernelExprContext) :
    ReturnsTo resolve xs extension
    ↔
    composeTrajectory resolve
      (trajectoryProjection resolve xs)
      (trajectoryProjection resolve extension)
    =
    trajectoryProjection resolve xs :=
  ReturnsTo_iff_right_stabilises resolve xs extension

/-! ReturnImpliesIdentityClass ↔ AllRightStabilizersTrivial. -/

theorem returnImpliesIdentityClass_implies_allRightStabilizersTrivial
    (hRIC : ReturnImpliesIdentityClass resolve) :
    AllRightStabilizersTrivial resolve := by
  intro q r hStab
  rcases trajectoryProjection_surjective resolve q with ⟨xs, hxs⟩
  rcases trajectoryProjection_surjective resolve r with ⟨ext, hext⟩
  have hRet : ReturnsTo resolve xs ext := by
    unfold ReturnsTo
    rw [trajectoryProjection_append, hxs, hext]
    exact hStab
  have hExt : trajectoryProjection resolve ext = emptyTrajectory resolve :=
    hRIC xs ext hRet
  rw [← hext]
  exact hExt

theorem allRightStabilizersTrivial_implies_returnImpliesIdentityClass
    (hTriv : AllRightStabilizersTrivial resolve) :
    ReturnImpliesIdentityClass resolve := by
  intro xs extension hRet
  have hStab : composeTrajectory resolve
      (trajectoryProjection resolve xs)
      (trajectoryProjection resolve extension)
    = trajectoryProjection resolve xs := by
    rw [← trajectoryProjection_append]
    exact hRet
  exact hTriv _ _ hStab

theorem returnImpliesIdentityClass_iff_allRightStabilizersTrivial :
    ReturnImpliesIdentityClass resolve
    ↔
    AllRightStabilizersTrivial resolve :=
  ⟨returnImpliesIdentityClass_implies_allRightStabilizersTrivial resolve,
   allRightStabilizersTrivial_implies_returnImpliesIdentityClass resolve⟩

/-! NontrivialRightStabilizer ↔ ¬ AllRightStabilizersTrivial. -/

theorem nontrivialRightStabilizer_implies_not_allRightStabilizersTrivial
    (hNon : NontrivialRightStabilizer resolve) :
    ¬ AllRightStabilizersTrivial resolve := by
  rcases hNon with ⟨q, r, hNe, hStab⟩
  intro hTriv
  exact hNe (hTriv q r hStab)

-- Reverse direction requires classical logic to extract an existential
-- witness from a negated universal. Not proved constructively.

-- Full equivalence requires classical extraction. Only the constructive
-- direction is proved: NontrivialRightStabilizer → ¬ AllRightStabilizersTrivial.

/-! Nontrivial stabiliser refutes ReturnImpliesIdentityClass. -/

theorem nontrivialRightStabilizer_refutes_returnImpliesIdentityClass
    (hNon : NontrivialRightStabilizer resolve) :
    ¬ ReturnImpliesIdentityClass resolve := by
  intro hRIC
  have hTriv := returnImpliesIdentityClass_implies_allRightStabilizersTrivial resolve hRIC
  exact nontrivialRightStabilizer_implies_not_allRightStabilizersTrivial resolve hNon hTriv

/-! Cancellation orientation: LeftCancellation is the relevant one.
    LeftCancellation: c ⊙ a = c ⊙ b → a = b
    Stabiliser: q ⊙ r = q = q ⊙ 1 → r = 1
    This is left-factor cancellation. -/

theorem leftCancellation_implies_allRightStabilizersTrivial
    (hL : LeftCancellation resolve) :
    AllRightStabilizersTrivial resolve := by
  intro q r hStab
  have hOne : composeTrajectory resolve q (emptyTrajectory resolve) = q := by
    exact (trajectoryLocalMonoid resolve).mul_one q
  have hEq : composeTrajectory resolve q r = composeTrajectory resolve q (emptyTrajectory resolve) := by
    rw [hStab, hOne]
  exact hL r (emptyTrajectory resolve) q hEq

theorem leftCancellation_implies_returnImpliesIdentityClass
    (hL : LeftCancellation resolve) :
    ReturnImpliesIdentityClass resolve :=
  allRightStabilizersTrivial_implies_returnImpliesIdentityClass resolve
    (leftCancellation_implies_allRightStabilizersTrivial resolve hL)

/-! Countermodel predicates. -/

def _root_.ReturnWithoutIdentityExtension
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ xs extension,
    ReturnsTo resolve xs extension
    ∧
    trajectoryProjection resolve extension ≠ emptyTrajectory resolve

theorem returnWithoutIdentityExtension_refutes_returnImpliesIdentityClass
    (hW : _root_.ReturnWithoutIdentityExtension resolve) :
    ¬ ReturnImpliesIdentityClass resolve := by
  rcases hW with ⟨xs, extension, hRet, hNe⟩
  intro hRIC
  exact hNe (hRIC xs extension hRet)

def _root_.LeftCancellationCollision
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ q r₁ r₂,
    composeTrajectory resolve q r₁ = composeTrajectory resolve q r₂
    ∧
    r₁ ≠ r₂

theorem leftCancellationCollision_refutes_leftCancellation
    (hC : _root_.LeftCancellationCollision resolve) :
    ¬ LeftCancellation resolve := by
  rcases hC with ⟨q, r₁, r₂, hEq, hNe⟩
  intro hL
  exact hNe (hL r₁ r₂ q hEq)

theorem nontrivialRightStabilizer_implies_leftCancellationCollision
    (hNon : NontrivialRightStabilizer resolve) :
    _root_.LeftCancellationCollision resolve := by
  rcases hNon with ⟨q, r, hNe, hStab⟩
  have hOne : composeTrajectory resolve q (emptyTrajectory resolve) = q := by
    exact (trajectoryLocalMonoid resolve).mul_one q
  exact ⟨q, r, emptyTrajectory resolve, by rw [hStab, hOne], hNe⟩

theorem nontrivialRightStabilizer_refutes_leftCancellation
    (hNon : NontrivialRightStabilizer resolve) :
    ¬ LeftCancellation resolve :=
  leftCancellationCollision_refutes_leftCancellation resolve
    (nontrivialRightStabilizer_implies_leftCancellationCollision resolve hNon)

/-! Headline. -/

theorem return_identity_dependency
    (hL : LeftCancellation resolve) :
    ReturnImpliesIdentityClass resolve :=
  leftCancellation_implies_returnImpliesIdentityClass resolve hL


/-! ============================================================
    Left-stabiliser mirror calculus
============================================================ -/

/-- Right-factor cancellation implies every left stabiliser is trivial. -/
theorem rightCancellation_implies_allLeftStabilizersTrivial
    (hR : RightCancellation resolve) :
    AllLeftStabilizersTrivial resolve := by
  intro q l hStab
  have hOne : composeTrajectory resolve (emptyTrajectory resolve) q = q := by
    exact (trajectoryLocalMonoid resolve).one_mul q
  have hEq : composeTrajectory resolve l q = composeTrajectory resolve (emptyTrajectory resolve) q := by
    rw [hStab, hOne]
  exact hR l (emptyTrajectory resolve) q hEq

/-- Direct countermodel shape for RightCancellation. -/
def _root_.RightCancellationCollision
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ q l₁ l₂,
    composeTrajectory resolve l₁ q = composeTrajectory resolve l₂ q
    ∧ l₁ ≠ l₂

theorem rightCancellationCollision_refutes_rightCancellation
    (hC : _root_.RightCancellationCollision resolve) :
    ¬ RightCancellation resolve := by
  rcases hC with ⟨q, l₁, l₂, hEq, hNe⟩
  intro hR
  exact hNe (hR l₁ l₂ q hEq)

theorem nontrivialLeftStabilizer_implies_not_allLeftStabilizersTrivial
    (hNon : NontrivialLeftStabilizer resolve) :
    ¬ AllLeftStabilizersTrivial resolve := by
  rcases hNon with ⟨q, l, hNe, hStab⟩
  intro hTriv
  exact hNe (hTriv q l hStab)

theorem nontrivialLeftStabilizer_implies_rightCancellationCollision
    (hNon : NontrivialLeftStabilizer resolve) :
    _root_.RightCancellationCollision resolve := by
  rcases hNon with ⟨q, l, hNe, hStab⟩
  have hOne : composeTrajectory resolve (emptyTrajectory resolve) q = q := by
    exact (trajectoryLocalMonoid resolve).one_mul q
  exact ⟨q, l, emptyTrajectory resolve, by rw [hStab, hOne], hNe⟩

theorem nontrivialLeftStabilizer_refutes_rightCancellation
    (hNon : NontrivialLeftStabilizer resolve) :
    ¬ RightCancellation resolve :=
  rightCancellationCollision_refutes_rightCancellation resolve
    (nontrivialLeftStabilizer_implies_rightCancellationCollision resolve hNon)


/-! Non-identity trajectory existence. -/

def NonidentityTrajectoryExists
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ xs : List KernelExprContext,
    trajectoryProjection resolve xs ≠ emptyTrajectory resolve


/-- The empty history is not a nonidentity witness. -/
theorem empty_not_nonidentity
    (resolve : KernelExpr → Store → Location) :
    ¬ (trajectoryProjection resolve [] ≠ emptyTrajectory resolve) := by
  intro h
  exact h (trajectoryProjection_nil resolve)

/-- Nonidentity existence is independent of the empty history. -/
theorem nonidentity_requires_nonempty_history
    (resolve : KernelExpr → Store → Location)
    (h : NonidentityTrajectoryExists resolve) :
    ∃ xs : List KernelExprContext,
      xs ≠ []
      ∧ trajectoryProjection resolve xs ≠ emptyTrajectory resolve := by
  rcases h with ⟨xs, hNe⟩
  cases xs with
  | nil =>
    exact absurd hNe (fun h => h (trajectoryProjection_nil resolve))
  | cons hd tl =>
    exact ⟨hd :: tl, List.cons_ne_nil hd tl, hNe⟩


def NonidentityTrajectoryBoundaryExists
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ q : TrajectoryBoundary resolve,
    q ≠ emptyTrajectory resolve

theorem nonidentityTrajectory_iff_nonidentityBoundary
    (resolve : KernelExpr → Store → Location) :
    NonidentityTrajectoryExists resolve
    ↔
    NonidentityTrajectoryBoundaryExists resolve := by
  constructor
  · intro ⟨xs, hNe⟩
    exact ⟨trajectoryProjection resolve xs, hNe⟩
  · intro ⟨q, hNe⟩
    rcases trajectoryProjection_surjective resolve q with ⟨xs, hxs⟩
    exact ⟨xs, hxs ▸ hNe⟩


theorem nontrivialRightStabilizer_implies_nonidentityTrajectoryExists
    (resolve : KernelExpr → Store → Location)
    (hNon : NontrivialRightStabilizer resolve) :
    NonidentityTrajectoryExists resolve := by
  rcases hNon with ⟨q, r, hNe, hStab⟩
  rcases trajectoryProjection_surjective resolve r with ⟨xs, hxs⟩
  exact ⟨xs, hxs ▸ hNe⟩


theorem nontrivialLeftStabilizer_implies_nonidentityTrajectoryExists
    (resolve : KernelExpr → Store → Location)
    (hNon : NontrivialLeftStabilizer resolve) :
    NonidentityTrajectoryExists resolve := by
  rcases hNon with ⟨q, l, hNe, hStab⟩
  rcases trajectoryProjection_surjective resolve l with ⟨xs, hxs⟩
  exact ⟨xs, hxs ▸ hNe⟩




theorem returnWithoutIdentityExtension_implies_nonidentityTrajectoryExists
    (resolve : KernelExpr → Store → Location)
    (hW : _root_.ReturnWithoutIdentityExtension resolve) :
    NonidentityTrajectoryExists resolve := by
  rcases hW with ⟨xs, extension, hRet, hNe⟩
  exact ⟨extension, hNe⟩


def AllTrajectoriesIdentity
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ q : TrajectoryBoundary resolve,
    q = emptyTrajectory resolve

theorem allTrajectoriesIdentity_implies_not_nonidentityBoundary
    (resolve : KernelExpr → Store → Location)
    (hAll : AllTrajectoriesIdentity resolve) :
    ¬ NonidentityTrajectoryBoundaryExists resolve := by
  intro ⟨q, hNe⟩
  exact hNe (hAll q)

-- Reverse direction requires classical logic to extract a witness
-- from a negated existential. Not proved constructively.


/-! Vacuous consequences of AllTrajectoriesIdentity. -/

theorem allTrajectoriesIdentity_implies_allRightStabilizersTrivial
    (resolve : KernelExpr → Store → Location)
    (hAll : AllTrajectoriesIdentity resolve) :
    AllRightStabilizersTrivial resolve := by
  intro q r hStab
  exact hAll r

theorem allTrajectoriesIdentity_implies_allLeftStabilizersTrivial
    (resolve : KernelExpr → Store → Location)
    (hAll : AllTrajectoriesIdentity resolve) :
    AllLeftStabilizersTrivial resolve := by
  intro q l hStab
  exact hAll l

theorem allTrajectoriesIdentity_implies_returnImpliesIdentityClass
    (resolve : KernelExpr → Store → Location)
    (hAll : AllTrajectoriesIdentity resolve) :
    ReturnImpliesIdentityClass resolve := by
  intro xs extension hRet
  rcases trajectoryProjection_surjective resolve
      (trajectoryProjection resolve extension) with ⟨ys, hys⟩
  rw [← hys]
  exact hAll (trajectoryProjection resolve ys)

theorem allTrajectoriesIdentity_implies_leftCancellation
    (resolve : KernelExpr → Store → Location)
    (hAll : AllTrajectoriesIdentity resolve) :
    LeftCancellation resolve := by
  intro a b c hEq
  rw [hAll a, hAll b]

theorem allTrajectoriesIdentity_implies_rightCancellation
    (resolve : KernelExpr → Store → Location)
    (hAll : AllTrajectoriesIdentity resolve) :
    RightCancellation resolve := by
  intro a b c hEq
  rw [hAll a, hAll b]


/-! ============================================================
    Nonidentity as failure of empty kernel class
============================================================ -/

def RawOutsideIdentityKernelExists
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ xs : List KernelExprContext,
    ¬ FoldKernel resolve xs []

theorem rawOutsideIdentityKernel_iff_nonidentityTrajectory
    (resolve : KernelExpr → Store → Location) :
    RawOutsideIdentityKernelExists resolve
    ↔
    NonidentityTrajectoryExists resolve := by
  constructor
  · intro ⟨xs, hOut⟩
    unfold FoldKernel at hOut
    rw [trajectoryProjection_nil] at hOut
    exact ⟨xs, hOut⟩
  · intro ⟨xs, hNe⟩
    refine ⟨xs, ?_⟩
    unfold FoldKernel
    rw [trajectoryProjection_nil]
    exact hNe

/-- The FoldKernel quotient has more than one class. -/
def FoldKernelQuotientNontrivial
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ q : FoldKernelQuotient resolve,
    q ≠ Quotient.mk (FoldKernelSetoid resolve) []

theorem foldKernelQuotientNontrivial_iff_rawOutsideIdentityKernel
    (resolve : KernelExpr → Store → Location) :
    FoldKernelQuotientNontrivial resolve
    ↔
    RawOutsideIdentityKernelExists resolve := by
  constructor
  · intro ⟨q, hNe⟩
    rcases Quotient.exists_rep q with ⟨xs, hxs⟩
    refine ⟨xs, ?_⟩
    intro hK
    apply hNe
    rw [← hxs]
    exact Quotient.sound hK
  · intro ⟨xs, hOut⟩
    refine ⟨Quotient.mk (FoldKernelSetoid resolve) xs, ?_⟩
    intro hEq
    have hK : FoldKernel resolve xs [] := Quotient.exact hEq
    exact hOut hK


theorem nonidentityTrajectoryExists_iff_rawOutsideIdentityKernelExists
    (resolve : KernelExpr → Store → Location) :
    NonidentityTrajectoryExists resolve
    ↔
    RawOutsideIdentityKernelExists resolve :=
  (rawOutsideIdentityKernel_iff_nonidentityTrajectory resolve).symm


theorem trajectory_nonidentity_iff_not_foldKernel_empty
    (resolve : KernelExpr → Store → Location)
    (xs : List KernelExprContext) :
    trajectoryProjection resolve xs ≠ emptyTrajectory resolve
    ↔
    ¬ FoldKernel resolve xs [] := by
  unfold FoldKernel
  rw [trajectoryProjection_nil]


theorem nonidentityTrajectoryExists_iff_foldKernelQuotientNontrivial
    (resolve : KernelExpr → Store → Location) :
    NonidentityTrajectoryExists resolve
    ↔
    FoldKernelQuotientNontrivial resolve :=
  (nonidentityTrajectoryExists_iff_rawOutsideIdentityKernelExists resolve).trans
    (foldKernelQuotientNontrivial_iff_rawOutsideIdentityKernel resolve).symm


def FoldKernelHasDistinctClasses
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ xs ys : List KernelExprContext,
    ¬ FoldKernel resolve xs ys

theorem rawOutsideIdentityKernel_implies_distinctClasses
    (resolve : KernelExpr → Store → Location)
    (hOut : RawOutsideIdentityKernelExists resolve) :
    FoldKernelHasDistinctClasses resolve := by
  rcases hOut with ⟨xs, hNe⟩
  exact ⟨xs, [], hNe⟩

-- Reverse direction requires classical logic to extract which of xs, ys
-- fails to be FoldKernel-equivalent to []. Not proved constructively.


def EveryRawHistoryInIdentityKernel
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ xs : List KernelExprContext,
    FoldKernel resolve xs []

theorem everyRawHistoryInIdentityKernel_iff_allTrajectoriesIdentity
    (resolve : KernelExpr → Store → Location) :
    EveryRawHistoryInIdentityKernel resolve
    ↔
    AllTrajectoriesIdentity resolve := by
  constructor
  · intro hAll q
    rcases trajectoryProjection_surjective resolve q with ⟨xs, hxs⟩
    have hK := hAll xs
    unfold FoldKernel at hK
    rw [trajectoryProjection_nil] at hK
    rw [← hxs]
    exact hK
  · intro hAll xs
    unfold FoldKernel
    rw [trajectoryProjection_nil]
    exact hAll (trajectoryProjection resolve xs)


theorem allTrajectoriesIdentity_iff_everyRawHistoryInIdentityKernel
    (resolve : KernelExpr → Store → Location) :
    AllTrajectoriesIdentity resolve
    ↔
    EveryRawHistoryInIdentityKernel resolve :=
  (everyRawHistoryInIdentityKernel_iff_allTrajectoriesIdentity resolve).symm


theorem trajectory_nontrivial_iff_foldKernelQuotient_nontrivial
    (resolve : KernelExpr → Store → Location) :
    NonidentityTrajectoryBoundaryExists resolve
    ↔
    FoldKernelQuotientNontrivial resolve :=
  (nonidentityTrajectory_iff_nonidentityBoundary resolve).symm.trans
    (nonidentityTrajectoryExists_iff_foldKernelQuotientNontrivial resolve)


theorem nontrivialRightStabilizer_implies_rawOutsideIdentityKernel
    (resolve : KernelExpr → Store → Location)
    (hNon : NontrivialRightStabilizer resolve) :
    RawOutsideIdentityKernelExists resolve :=
  (nonidentityTrajectoryExists_iff_rawOutsideIdentityKernelExists resolve).mp
    (nontrivialRightStabilizer_implies_nonidentityTrajectoryExists resolve hNon)


theorem nontrivialLeftStabilizer_implies_rawOutsideIdentityKernel
    (resolve : KernelExpr → Store → Location)
    (hNon : NontrivialLeftStabilizer resolve) :
    RawOutsideIdentityKernelExists resolve :=
  (nonidentityTrajectoryExists_iff_rawOutsideIdentityKernelExists resolve).mp
    (nontrivialLeftStabilizer_implies_nonidentityTrajectoryExists resolve hNon)


theorem returnWithoutIdentityExtension_implies_rawOutsideIdentityKernel
    (resolve : KernelExpr → Store → Location)
    (hW : _root_.ReturnWithoutIdentityExtension resolve) :
    RawOutsideIdentityKernelExists resolve :=
  (nonidentityTrajectoryExists_iff_rawOutsideIdentityKernelExists resolve).mp
    (returnWithoutIdentityExtension_implies_nonidentityTrajectoryExists resolve hW)


def FoldKernelQuotientSingleton
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∀ q : FoldKernelQuotient resolve,
    q = Quotient.mk (FoldKernelSetoid resolve) []

theorem foldKernelQuotientSingleton_iff_allTrajectoriesIdentity
    (resolve : KernelExpr → Store → Location) :
    FoldKernelQuotientSingleton resolve
    ↔
    AllTrajectoriesIdentity resolve := by
  constructor
  · intro hSing q
    rcases trajectoryProjection_surjective resolve q with ⟨xs, hxs⟩
    have hQ : Quotient.mk (FoldKernelSetoid resolve) xs
        = Quotient.mk (FoldKernelSetoid resolve) [] :=
      hSing (Quotient.mk (FoldKernelSetoid resolve) xs)
    have hK : FoldKernel resolve xs [] := Quotient.exact hQ
    unfold FoldKernel at hK
    rw [trajectoryProjection_nil] at hK
    rw [← hxs]
    exact hK
  · intro hAll q
    rcases Quotient.exists_rep q with ⟨xs, hxs⟩
    have hK : FoldKernel resolve xs [] := by
      unfold FoldKernel
      rw [trajectoryProjection_nil]
      exact hAll (trajectoryProjection resolve xs)
    rw [← hxs]
    exact Quotient.sound hK


theorem allTrajectoriesIdentity_iff_foldKernelQuotientSingleton
    (resolve : KernelExpr → Store → Location) :
    AllTrajectoriesIdentity resolve
    ↔
    FoldKernelQuotientSingleton resolve :=
  (foldKernelQuotientSingleton_iff_allTrajectoriesIdentity resolve).symm


theorem nonidentity_trajectory_iff_outside_identity_kernel
    (resolve : KernelExpr → Store → Location) :
    NonidentityTrajectoryExists resolve
    ↔
    ∃ xs, ¬ FoldKernel resolve xs [] :=
  nonidentityTrajectoryExists_iff_rawOutsideIdentityKernelExists resolve


/-! ============================================================
    Resolver observability contract for exposingContext
============================================================ -/

/-- Weakest condition: resolve distinguishes exposedLeft from left
    under some context and store. -/
def ResolveDistinguishesExposedLeft
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ (ctx : KernelExprContext) (store : Store),
    resolve (ctx.plug KernelExpr.exposedLeft) store
    ≠
    resolve (ctx.plug KernelExpr.left) store

/-- If resolve distinguishes exposedLeft from left, then they are
    not PersistentEquivalent. -/
theorem resolveDistinguishes_implies_not_persistentEquivalent
    (resolve : KernelExpr → Store → Location)
    (hDist : ResolveDistinguishesExposedLeft resolve) :
    ¬ PersistentEquivalent resolve KernelExpr.exposedLeft KernelExpr.left := by
  rcases hDist with ⟨ctx, store, hNe⟩
  intro hEq
  exact hNe (hEq ctx store)

/-- If resolve distinguishes exposedLeft from left, then [exposingContext]
    is outside the FoldKernel identity class. -/
theorem resolveDistinguishes_implies_exposingContext_outside_identity
    (resolve : KernelExpr → Store → Location)
    (hDist : ResolveDistinguishesExposedLeft resolve) :
    ¬ FoldKernel resolve [exposingContext] [] := by
  intro hK
  have hDist' := resolveDistinguishes_implies_not_persistentEquivalent resolve hDist
  unfold FoldKernel at hK
  rw [trajectoryProjection_nil] at hK
  -- trajectoryProjection [exposingContext] = emptyTrajectory
  -- = toTrajectoryBoundary [] = Quotient.mk trajectorySetoid []
  -- trajectoryProjection [exposingContext] = toTrajectoryBoundary [exposingContext]
  -- So Quotient.mk trajectorySetoid [exposingContext] = Quotient.mk trajectorySetoid []
  -- means TrajectoryEquivalent [exposingContext] []
  have hTE : TrajectoryEquivalent resolve [exposingContext] [] :=
    Quotient.exact hK
  -- Take q = toPersistentBoundary resolve KernelExpr.left
  let q := toPersistentBoundary resolve KernelExpr.left
  have hEv := hTE q
  -- evolvePersistent [exposingContext] q = plugPersistent resolve exposingContext q
  -- = toPersistentBoundary resolve (exposingContext.plug left)
  -- = toPersistentBoundary resolve exposedLeft
  have hLeft : evolvePersistent resolve [exposingContext] q
      = toPersistentBoundary resolve KernelExpr.exposedLeft := by
    show plugPersistent resolve exposingContext q = _
    rw [plugPersistent_mk]
    rfl
  -- evolvePersistent [] q = q
  have hRight : evolvePersistent resolve [] q = q :=
    evolvePersistent_nil resolve q
  rw [hLeft, hRight] at hEv
  -- So toPersistentBoundary resolve exposedLeft = toPersistentBoundary resolve left
  have hPE : PersistentEquivalent resolve KernelExpr.exposedLeft KernelExpr.left :=
    Quotient.exact hEv
  exact hDist' hPE


/-- Under the resolver contract, NonidentityTrajectoryExists holds. -/
theorem resolveDistinguishes_implies_nonidentityTrajectoryExists
    (resolve : KernelExpr → Store → Location)
    (hDist : ResolveDistinguishesExposedLeft resolve) :
    NonidentityTrajectoryExists resolve :=
  ⟨[exposingContext],
   (trajectory_nonidentity_iff_not_foldKernel_empty resolve [exposingContext]).mpr
     (resolveDistinguishes_implies_exposingContext_outside_identity resolve hDist)⟩


def ResolverDistinguishesAt
    (resolve : KernelExpr → Store → Location)
    (e₁ e₂ : KernelExpr)
    (store : Store) : Prop :=
  resolve e₁ store ≠ resolve e₂ store

/-- If resolve distinguishes exposedLeft from left at some store,
    then ResolveDistinguishesExposedLeft holds (using identityContext). -/
theorem resolverDistinguishesAt_implies_resolveDistinguishes
    (resolve : KernelExpr → Store → Location)
    (store : Store)
    (hDist : ResolverDistinguishesAt resolve
      KernelExpr.exposedLeft KernelExpr.left store) :
    ResolveDistinguishesExposedLeft resolve :=
  ⟨identityContext, store, by
    show resolve (identityContext.plug KernelExpr.exposedLeft) store
        ≠ resolve (identityContext.plug KernelExpr.left) store
    simp [identityContext]
    exact hDist⟩


def ResolverContextDistinguishesAt
    (resolve : KernelExpr → Store → Location)
    (ctx : KernelExprContext)
    (e₁ e₂ : KernelExpr)
    (store : Store) : Prop :=
  resolve (ctx.plug e₁) store ≠ resolve (ctx.plug e₂) store

/-- If some context and store distinguish exposedLeft from left,
    then ResolveDistinguishesExposedLeft holds. -/
theorem resolverContextDistinguishesAt_implies_resolveDistinguishes
    (resolve : KernelExpr → Store → Location)
    (ctx : KernelExprContext)
    (store : Store)
    (hDist : ResolverContextDistinguishesAt resolve ctx
      KernelExpr.exposedLeft KernelExpr.left store) :
    ResolveDistinguishesExposedLeft resolve :=
  ⟨ctx, store, hDist⟩


def ResolverSeparates
    (resolve : KernelExpr → Store → Location)
    (e₁ e₂ : KernelExpr) : Prop :=
  ∃ ctx store,
    ResolverContextDistinguishesAt resolve ctx e₁ e₂ store

/-- ResolverSeparates exposedLeft left is exactly
    ResolveDistinguishesExposedLeft. -/
theorem resolverSeparates_exposedLeft_iff_resolveDistinguishes
    (resolve : KernelExpr → Store → Location) :
    ResolverSeparates resolve KernelExpr.exposedLeft KernelExpr.left
    ↔
    ResolveDistinguishesExposedLeft resolve := by
  constructor
  · intro ⟨ctx, store, hDist⟩
    exact ⟨ctx, store, hDist⟩
  · intro ⟨ctx, store, hDist⟩
    exact ⟨ctx, store, hDist⟩


/-! Aliases and direct separation. -/

def ResolvesExposedLeftDifferently
    (resolve : KernelExpr → Store → Location) : Prop :=
  ResolverSeparates resolve KernelExpr.exposedLeft KernelExpr.left

def ResolvesExposedRightDifferently
    (resolve : KernelExpr → Store → Location) : Prop :=
  ResolverSeparates resolve KernelExpr.exposedRight KernelExpr.right

def ResolverDirectlySeparatesExposedLeft
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ store : Store,
    resolve KernelExpr.exposedLeft store ≠ resolve KernelExpr.left store

theorem resolverDirectlySeparates_implies_resolvesExposedLeftDifferently
    (resolve : KernelExpr → Store → Location)
    (hDirect : ResolverDirectlySeparatesExposedLeft resolve) :
    ResolvesExposedLeftDifferently resolve := by
  rcases hDirect with ⟨store, hNe⟩
  exact ⟨identityContext, store, by
    show resolve (identityContext.plug KernelExpr.exposedLeft) store
        ≠ resolve (identityContext.plug KernelExpr.left) store
    simp [identityContext]
    exact hNe⟩

theorem resolvesExposedLeftDifferently_implies_nonidentityTrajectoryExists
    (resolve : KernelExpr → Store → Location)
    (hSep : ResolvesExposedLeftDifferently resolve) :
    NonidentityTrajectoryExists resolve :=
  resolveDistinguishes_implies_nonidentityTrajectoryExists resolve
    ((resolverSeparates_exposedLeft_iff_resolveDistinguishes resolve).mp hSep)

/-! exposingContext plug theorems. -/

theorem exposingContext_plug_left :
    exposingContext.plug KernelExpr.left = KernelExpr.exposedLeft := rfl

theorem exposingContext_plug_right :
    exposingContext.plug KernelExpr.right = KernelExpr.exposedRight := rfl


/-! Constant resolver countermodel.
    A constant resolver collapses all KernelExpr distinctions. -/

theorem constant_resolver_not_separating
    (location : Location) :
    ¬ ResolvesExposedLeftDifferently (fun (_ : KernelExpr) (_ : Store) => location) := by
  intro ⟨ctx, store, hNe⟩
  exact hNe rfl


/-! Constant resolver collapse.
    Under a constant resolver, all KernelExprs are PersistentEquivalent. -/

theorem constant_resolver_persistentEquivalent
    (location : Location)
    (e₁ e₂ : KernelExpr) :
    PersistentEquivalent (fun (_ : KernelExpr) (_ : Store) => location) e₁ e₂ := by
  intro ctx store
  rfl

theorem constant_resolver_all_persistentBoundary_eq
    (location : Location)
    (q₁ q₂ : PersistentBoundary (fun (_ : KernelExpr) (_ : Store) => location)) :
    q₁ = q₂ := by
  rcases Quotient.exists_rep q₁ with ⟨e₁, h₁⟩
  rcases Quotient.exists_rep q₂ with ⟨e₂, h₂⟩
  rw [← h₁, ← h₂]
  exact Quotient.sound (constant_resolver_persistentEquivalent location e₁ e₂)


theorem constant_resolver_trajectoryEquivalent
    (location : Location)
    (xs ys : List KernelExprContext) :
    TrajectoryEquivalent (fun (_ : KernelExpr) (_ : Store) => location) xs ys := by
  intro q
  exact constant_resolver_all_persistentBoundary_eq location _ _

theorem constant_resolver_allTrajectoriesIdentity
    (location : Location) :
    AllTrajectoriesIdentity (fun (_ : KernelExpr) (_ : Store) => location) := by
  intro q
  rcases trajectoryProjection_surjective
      (fun (_ : KernelExpr) (_ : Store) => location) q with ⟨xs, hxs⟩
  rw [← hxs]
  show trajectoryProjection (fun (_ : KernelExpr) (_ : Store) => location) xs
      = trajectoryProjection (fun (_ : KernelExpr) (_ : Store) => location) []
  exact Quotient.sound (constant_resolver_trajectoryEquivalent location xs [])


/-! Concrete separating resolver. -/

inductive ConcreteLocation where
  | ordinary
  | exposed
  deriving DecidableEq

def ConcreteStore := Unit

def concreteSeparatingResolve :
    KernelExpr → ConcreteStore → ConcreteLocation
  | KernelExpr.exposedLeft, _ => .exposed
  | _, _ => .ordinary

theorem concreteSeparatingResolve_separates :
    ResolvesExposedLeftDifferently concreteSeparatingResolve :=
  ⟨identityContext, (), by
    show concreteSeparatingResolve KernelExpr.exposedLeft ()
        ≠ concreteSeparatingResolve KernelExpr.left ()
    simp [concreteSeparatingResolve]⟩

theorem concreteSeparatingResolve_nonidentity :
    NonidentityTrajectoryExists concreteSeparatingResolve :=
  resolvesExposedLeftDifferently_implies_nonidentityTrajectoryExists
    concreteSeparatingResolve
    concreteSeparatingResolve_separates


theorem concreteSeparatingResolve_distinguishes :
    ResolverDirectlySeparatesExposedLeft concreteSeparatingResolve := by
  refine ⟨(), ?_⟩
  show concreteSeparatingResolve KernelExpr.exposedLeft ()
      ≠ concreteSeparatingResolve KernelExpr.left ()
  simp [concreteSeparatingResolve]


theorem concreteSeparatingResolve_nonidentityTrajectory :
    NonidentityTrajectoryExists concreteSeparatingResolve :=
  resolvesExposedLeftDifferently_implies_nonidentityTrajectoryExists
    concreteSeparatingResolve
    (resolverDirectlySeparates_implies_resolvesExposedLeftDifferently
      concreteSeparatingResolve
      concreteSeparatingResolve_distinguishes)


/-! Cleaner resolver separation witness. -/

abbrev ResolverSeparationStore := Unit

abbrev ResolverSeparationLocation := Bool

def resolverSeparationWitness :
    KernelExpr → ResolverSeparationStore → ResolverSeparationLocation
  | .exposedLeft, _ => true
  | _, _ => false

@[simp]
theorem resolverSeparationWitness_exposedLeft :
    resolverSeparationWitness KernelExpr.exposedLeft () = true := rfl

@[simp]
theorem resolverSeparationWitness_left :
    resolverSeparationWitness KernelExpr.left () = false := rfl

theorem resolverSeparationWitness_distinguishes :
    resolverSeparationWitness KernelExpr.exposedLeft () ≠
      resolverSeparationWitness KernelExpr.left () := by
  decide

theorem resolverSeparationWitness_directlySeparates :
    ResolverDirectlySeparatesExposedLeft resolverSeparationWitness :=
  ⟨(), resolverSeparationWitness_distinguishes⟩

theorem resolverSeparationWitness_nonidentity :
    NonidentityTrajectoryExists resolverSeparationWitness :=
  resolvesExposedLeftDifferently_implies_nonidentityTrajectoryExists
    resolverSeparationWitness
    (resolverDirectlySeparates_implies_resolvesExposedLeftDifferently
      resolverSeparationWitness
      resolverSeparationWitness_directlySeparates)


def ExposedLeftSeparated
    {Store : Sort u}
    {Location : Sort v}
    (resolve : KernelExpr → Store → Location) : Prop :=
  ∃ store,
    resolve KernelExpr.exposedLeft store ≠ resolve KernelExpr.left store

theorem exposedLeftSeparated_iff_directlySeparates
    (resolve : KernelExpr → Store → Location) :
    ExposedLeftSeparated resolve
    ↔
    ResolverDirectlySeparatesExposedLeft resolve := Iff.rfl

theorem resolverSeparationWitness_separates :
    ExposedLeftSeparated resolverSeparationWitness := by
  refine ⟨(), ?_⟩
  exact resolverSeparationWitness_distinguishes


theorem resolverSeparationWitness_separates_all :
    ∀ store : ResolverSeparationStore,
      resolverSeparationWitness KernelExpr.exposedLeft store ≠
        resolverSeparationWitness KernelExpr.left store := by
  intro store
  cases store
  decide


theorem exposingContext_nonidentity_of_exposedLeftSeparated
    (resolve : KernelExpr → Store → Location)
    (hSep : ExposedLeftSeparated resolve) :
    trajectoryProjection resolve [exposingContext] ≠
      emptyTrajectory resolve := by
  have hDirect : ResolverDirectlySeparatesExposedLeft resolve :=
    (exposedLeftSeparated_iff_directlySeparates resolve).mp hSep
  have hContextual : ResolvesExposedLeftDifferently resolve :=
    resolverDirectlySeparates_implies_resolvesExposedLeftDifferently resolve hDirect
  have hDist : ResolveDistinguishesExposedLeft resolve :=
    (resolverSeparates_exposedLeft_iff_resolveDistinguishes resolve).mp hContextual
  have hK : ¬ FoldKernel resolve [exposingContext] [] :=
    resolveDistinguishes_implies_exposingContext_outside_identity resolve hDist
  exact (trajectory_nonidentity_iff_not_foldKernel_empty resolve [exposingContext]).mpr hK

theorem exposingContext_nonidentity_witness :
    trajectoryProjection resolverSeparationWitness [exposingContext] ≠
      emptyTrajectory resolverSeparationWitness :=
  exposingContext_nonidentity_of_exposedLeftSeparated
    resolverSeparationWitness
    resolverSeparationWitness_separates


theorem foldKernelQuotient_nontrivial_witness :
    Quotient.mk (FoldKernelSetoid resolverSeparationWitness) [exposingContext] ≠
      Quotient.mk (FoldKernelSetoid resolverSeparationWitness) [] := by
  intro h
  have hK : FoldKernel resolverSeparationWitness [exposingContext] [] :=
    Quotient.exact h
  have hNe : ¬ FoldKernel resolverSeparationWitness [exposingContext] [] :=
    (trajectory_nonidentity_iff_not_foldKernel_empty
      resolverSeparationWitness [exposingContext]).mp
      exposingContext_nonidentity_witness
  exact hNe hK


/-! Nontrivial right stabiliser from exposingContext idempotence. -/

theorem exposingContext_plug_idempotent
    (e : KernelExpr) :
    exposingContext.plug (exposingContext.plug e) = exposingContext.plug e := by
  cases e <;> simp [exposingContext]

theorem plugPersistent_exposingContext_idempotent
    (resolve : KernelExpr → Store → Location)
    (e : KernelExpr) :
    plugPersistent resolve exposingContext
      (plugPersistent resolve exposingContext (toPersistentBoundary resolve e))
    =
    plugPersistent resolve exposingContext (toPersistentBoundary resolve e) := by
  rw [plugPersistent_mk, plugPersistent_mk]
  rw [exposingContext_plug_idempotent]

theorem evolvePersistent_exposingContext_idempotent
    (resolve : KernelExpr → Store → Location)
    (e : KernelExpr) :
    evolvePersistent resolve [exposingContext, exposingContext]
      (toPersistentBoundary resolve e)
    =
    evolvePersistent resolve [exposingContext]
      (toPersistentBoundary resolve e) := by
  show plugPersistent resolve exposingContext
      (plugPersistent resolve exposingContext (toPersistentBoundary resolve e))
    = plugPersistent resolve exposingContext (toPersistentBoundary resolve e)
  exact plugPersistent_exposingContext_idempotent resolve e

theorem exposingContext_history_idempotent
    (resolve : KernelExpr → Store → Location) :
    TrajectoryEquivalent resolve
      [exposingContext, exposingContext]
      [exposingContext] := by
  intro q
  rcases Quotient.exists_rep q with ⟨e, he⟩
  rw [← he]
  exact evolvePersistent_exposingContext_idempotent resolve e

theorem exposingContext_stabilises_itself
    (resolve : KernelExpr → Store → Location) :
    composeTrajectory resolve
      (trajectoryProjection resolve [exposingContext])
      (trajectoryProjection resolve [exposingContext])
    =
    trajectoryProjection resolve [exposingContext] := by
  show trajectoryProjection resolve ([exposingContext] ++ [exposingContext])
      = trajectoryProjection resolve [exposingContext]
  rw [trajectoryProjection_append]
  exact Quotient.sound (exposingContext_history_idempotent resolve)

theorem resolverSeparationWitness_nontrivialRightStabilizer :
    NontrivialRightStabilizer resolverSeparationWitness := by
  refine ⟨
    trajectoryProjection resolverSeparationWitness [exposingContext],
    trajectoryProjection resolverSeparationWitness [exposingContext],
    ?_,
    exposingContext_stabilises_itself resolverSeparationWitness⟩
  exact exposingContext_nonidentity_witness


/-! Consequences of the nontrivial right stabiliser. -/

theorem resolverSeparationWitness_not_allRightStabilizersTrivial :
    ¬ AllRightStabilizersTrivial resolverSeparationWitness :=
  nontrivialRightStabilizer_implies_not_allRightStabilizersTrivial
    resolverSeparationWitness
    resolverSeparationWitness_nontrivialRightStabilizer

theorem resolverSeparationWitness_not_returnImpliesIdentityClass :
    ¬ ReturnImpliesIdentityClass resolverSeparationWitness :=
  nontrivialRightStabilizer_refutes_returnImpliesIdentityClass
    resolverSeparationWitness
    resolverSeparationWitness_nontrivialRightStabilizer

theorem resolverSeparationWitness_leftCancellationCollision :
    _root_.LeftCancellationCollision resolverSeparationWitness :=
  nontrivialRightStabilizer_implies_leftCancellationCollision
    resolverSeparationWitness
    resolverSeparationWitness_nontrivialRightStabilizer

theorem resolverSeparationWitness_not_leftCancellation :
    ¬ LeftCancellation resolverSeparationWitness :=
  nontrivialRightStabilizer_refutes_leftCancellation
    resolverSeparationWitness
    resolverSeparationWitness_nontrivialRightStabilizer


/-! ReturnWithoutIdentityExtension from the stabiliser witness. -/

theorem resolverSeparationWitness_returnWithoutIdentityExtension :
    _root_.ReturnWithoutIdentityExtension resolverSeparationWitness := by
  refine ⟨[exposingContext], [exposingContext], ?_, exposingContext_nonidentity_witness⟩
  -- ReturnsTo: trajectoryProjection ([exposingContext] ++ [exposingContext]) = trajectoryProjection [exposingContext]
  show trajectoryProjection resolverSeparationWitness ([exposingContext] ++ [exposingContext])
      = trajectoryProjection resolverSeparationWitness [exposingContext]
  rw [trajectoryProjection_append]
  exact exposingContext_stabilises_itself resolverSeparationWitness


/-! Right cancellation collision from idempotent nonidentity. -/

theorem resolverSeparationWitness_rightCancellationCollision :
    _root_.RightCancellationCollision resolverSeparationWitness := by
  let r := trajectoryProjection resolverSeparationWitness [exposingContext]
  let one := emptyTrajectory resolverSeparationWitness
  -- r ⊙ r = r (from stabiliser)
  have hIdem : composeTrajectory resolverSeparationWitness r r = r :=
    exposingContext_stabilises_itself resolverSeparationWitness
  -- 1 ⊙ r = r (from monoid identity)
  have hOne : composeTrajectory resolverSeparationWitness one r = r :=
    (trajectoryLocalMonoid resolverSeparationWitness).one_mul r
  -- So r ⊙ r = 1 ⊙ r with r ≠ 1
  have hNe : r ≠ one := exposingContext_nonidentity_witness
  exact ⟨r, r, one, by rw [hIdem, hOne], hNe⟩


theorem resolverSeparationWitness_not_rightCancellation :
    ¬ RightCancellation resolverSeparationWitness := by
  intro hR
  rcases resolverSeparationWitness_rightCancellationCollision with ⟨q, l₁, l₂, hEq, hNe⟩
  -- hEq : composeTrajectory resolve l₁ q = composeTrajectory resolve l₂ q
  -- RightCancellation: composeTrajectory resolve a c = composeTrajectory resolve b c → a = b
  -- So a = l₁, b = l₂, c = q
  exact hNe (hR l₁ l₂ q hEq)


/-! ============================================================
    Two-thread swap rotation candidate
============================================================ -/

def twoThreadSwapFun : Fin 2 → Fin 2
  | ⟨0, _⟩ => ⟨1, by omega⟩
  | ⟨1, _⟩ => ⟨0, by omega⟩

def twoThreadSwap : ThreadPermutation 2 where
  toFun := twoThreadSwapFun
  invFun := twoThreadSwapFun
  left_inv := fun i => by
    cases i using Fin.cases with
    | zero => rfl
    | succ j =>
      cases j using Fin.cases with
      | zero => rfl
      | succ k => exact absurd k.isLt (by omega)
  right_inv := fun i => by
    cases i using Fin.cases with
    | zero => rfl
    | succ j =>
      cases j using Fin.cases with
      | zero => rfl
      | succ k => exact absurd k.isLt (by omega)

def twoThreadSwapTransform
    (resolve : KernelExpr → Store → Location) :
    ThreadFamily resolve 2 → ThreadFamily resolve 2 :=
  permuteThreadFamily resolve twoThreadSwap

theorem twoThreadSwap_involutive :
    ∀ i : Fin 2, twoThreadSwap.toFun (twoThreadSwap.toFun i) = i := by
  intro i
  cases i using Fin.cases with
  | zero => rfl
  | succ j =>
    cases j using Fin.cases with
    | zero => rfl
    | succ k => exact absurd k.isLt (by omega)

theorem twoThreadSwapTransform_involutive
    (resolve : KernelExpr → Store → Location) :
    ∀ p : ThreadFamily resolve 2,
      twoThreadSwapTransform resolve (twoThreadSwapTransform resolve p) = p := by
  intro p
  funext i
  unfold twoThreadSwapTransform permuteThreadFamily reindexThreadFamily
  congr 1
  exact twoThreadSwap_involutive i

theorem twoThreadSwapTransform_preserves_kernel
    (resolve : KernelExpr → Store → Location)
    {p q : ThreadFamily resolve 2}
    (h : ThreadFamilyKernel resolve p q) :
    ThreadFamilyKernel resolve
      (twoThreadSwapTransform resolve p)
      (twoThreadSwapTransform resolve q) :=
  permuteThreadFamily_respects_kernel resolve twoThreadSwap h

theorem twoThreadSwapTransform_reflects_kernel
    (resolve : KernelExpr → Store → Location)
    {p q : ThreadFamily resolve 2}
    (h : ThreadFamilyKernel resolve
      (twoThreadSwapTransform resolve p)
      (twoThreadSwapTransform resolve q)) :
    ThreadFamilyKernel resolve p q := by
  have h' := twoThreadSwapTransform_preserves_kernel resolve h
  rw [twoThreadSwapTransform_involutive resolve p,
      twoThreadSwapTransform_involutive resolve q] at h'
  exact h'

theorem twoThreadSwapTransform_kernel_iff
    (resolve : KernelExpr → Store → Location)
    (p q : ThreadFamily resolve 2) :
    ThreadFamilyKernel resolve
      (twoThreadSwapTransform resolve p)
      (twoThreadSwapTransform resolve q)
    ↔
    ThreadFamilyKernel resolve p q :=
  ⟨twoThreadSwapTransform_reflects_kernel resolve,
   twoThreadSwapTransform_preserves_kernel resolve⟩


/-! Raw nonidentity of two-thread swap. -/

theorem twoThreadSwapTransform_familyUnequal_ne
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    twoThreadSwapTransform resolve (familyUnequal resolve 2 h) ≠
      familyUnequal resolve 2 h := by
  intro heq
  have h0 := congrFun heq ⟨0, by omega⟩
  unfold twoThreadSwapTransform permuteThreadFamily reindexThreadFamily familyUnequal at h0
  simp [twoThreadSwap, twoThreadSwapFun] at h0

theorem twoThreadSwapTransform_nonidentity
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∃ p : ThreadFamily resolve 2,
      twoThreadSwapTransform resolve p ≠ p :=
  ⟨familyUnequal resolve 2 h,
   twoThreadSwapTransform_familyUnequal_ne resolve h⟩


/-! ============================================================
    Abstract ThreadFamily rotation contract
============================================================ -/

structure ThreadFamilyRotation
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where

  rotate :
    ThreadFamily resolve n → ThreadFamily resolve n

  inverse :
    ThreadFamily resolve n → ThreadFamily resolve n

  inverse_rotate :
    ∀ p, inverse (rotate p) = p

  rotate_inverse :
    ∀ p, rotate (inverse p) = p

  kernel_iff :
    ∀ p q,
      ThreadFamilyKernel resolve (rotate p) (rotate q) ↔
        ThreadFamilyKernel resolve p q

  nonidentity :
    ∃ p, rotate p ≠ p

  finiteOrder :
    ∃ k : Nat,
      1 < k ∧
      ∀ p, Nat.repeat rotate k p = p

namespace ThreadFamilyRotation

variable {resolve : KernelExpr → Store → Location} {n : Nat}
variable (R : ThreadFamilyRotation resolve n)

theorem rotate_injective :
    Function.Injective R.rotate := by
  intro p q h
  have h' := congrArg R.inverse h
  rw [R.inverse_rotate p, R.inverse_rotate q] at h'
  exact h'

theorem rotate_surjective :
    Function.Surjective R.rotate := by
  intro p
  exact ⟨R.inverse p, R.rotate_inverse p⟩

theorem preserves_kernel :
    ∀ p q,
      ThreadFamilyKernel resolve p q →
        ThreadFamilyKernel resolve (R.rotate p) (R.rotate q) :=
  fun p q h => (R.kernel_iff p q).mpr h

theorem reflects_kernel :
    ∀ p q,
      ThreadFamilyKernel resolve (R.rotate p) (R.rotate q) →
        ThreadFamilyKernel resolve p q :=
  fun p q h => (R.kernel_iff p q).mp h

end ThreadFamilyRotation


/-! Two-thread swap as ThreadFamilyRotation inhabitant. -/

theorem twoThreadSwap_finiteOrder
    (resolve : KernelExpr → Store → Location) :
    ∃ k : Nat,
      1 < k ∧
      ∀ p : ThreadFamily resolve 2,
        Nat.repeat (twoThreadSwapTransform resolve) k p = p := by
  refine ⟨2, by omega, ?_⟩
  intro p
  show twoThreadSwapTransform resolve (twoThreadSwapTransform resolve p) = p
  exact twoThreadSwapTransform_involutive resolve p

def twoThreadSwapRotation
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ThreadFamilyRotation resolve 2 where
  rotate := twoThreadSwapTransform resolve
  inverse := twoThreadSwapTransform resolve
  inverse_rotate := twoThreadSwapTransform_involutive resolve
  rotate_inverse := twoThreadSwapTransform_involutive resolve
  kernel_iff := twoThreadSwapTransform_kernel_iff resolve
  nonidentity := twoThreadSwapTransform_nonidentity resolve h
  finiteOrder := twoThreadSwap_finiteOrder resolve


/-! Folded-trivial witness for two-thread swap. -/

def ThreadFamilyRotation.HasFoldedTrivialWitness
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (R : ThreadFamilyRotation resolve n) : Prop :=
  ∃ p,
    R.rotate p ≠ p ∧
    projectThreadFamily resolve (R.rotate p) =
      projectThreadFamily resolve p

theorem twoThreadSwap_familyUnequal_folded_trivial
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    projectThreadFamily resolve
      (twoThreadSwapTransform resolve (familyUnequal resolve 2 h))
    =
    projectThreadFamily resolve (familyUnequal resolve 2 h) := by
  funext i
  cases i using Fin.cases with
  | zero =>
    show trajectoryProjection resolve [identityContext] =
         trajectoryProjection resolve []
    exact (empty_identity_same_projection resolve).symm
  | succ j =>
    cases j using Fin.cases with
    | zero =>
      show trajectoryProjection resolve [] =
           trajectoryProjection resolve [identityContext]
      exact empty_identity_same_projection resolve
    | succ k =>
      exact absurd k.isLt (by omega)

theorem twoThreadSwapRotation_has_folded_trivial_witness
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ThreadFamilyRotation.HasFoldedTrivialWitness
      (twoThreadSwapRotation resolve h) := by
  refine ⟨familyUnequal resolve 2 h, ?_, ?_⟩
  · exact twoThreadSwapTransform_familyUnequal_ne resolve h
  · exact twoThreadSwap_familyUnequal_folded_trivial resolve h


/-! ============================================================
    ThreadFamily quotient by ThreadFamilyKernel
============================================================ -/

def ThreadFamilyKernelSetoid
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :
    Setoid (ThreadFamily resolve n) where
  r := ThreadFamilyKernel resolve
  iseqv := ⟨
    ThreadFamilyKernel_refl resolve,
    fun h => ThreadFamilyKernel_symm resolve h,
    fun h1 h2 => ThreadFamilyKernel_trans resolve h1 h2
  ⟩

abbrev ThreadFamilyQuotient
    (resolve : KernelExpr → Store → Location)
    (n : Nat) :=
  Quotient (ThreadFamilyKernelSetoid resolve n)


/-! Quotient descent of ThreadFamilyRotation. -/

namespace ThreadFamilyRotation

variable {resolve : KernelExpr → Store → Location} {n : Nat}
variable (R : ThreadFamilyRotation resolve n)

def quotientRotate :
    ThreadFamilyQuotient resolve n → ThreadFamilyQuotient resolve n :=
  Quotient.lift
    (fun p => Quotient.mk (ThreadFamilyKernelSetoid resolve n) (R.rotate p))
    (fun p q h => by
      apply Quotient.sound
      exact R.preserves_kernel p q h)

theorem quotientRotate_mk
    (p : ThreadFamily resolve n) :
    R.quotientRotate (Quotient.mk _ p) =
      Quotient.mk _ (R.rotate p) := rfl

def quotientInverse :
    ThreadFamilyQuotient resolve n → ThreadFamilyQuotient resolve n :=
  Quotient.lift
    (fun p => Quotient.mk (ThreadFamilyKernelSetoid resolve n) (R.inverse p))
    (fun p q h => by
      apply Quotient.sound
      -- inverse preserves kernel via kernel_iff and inverse laws
      have h' : ThreadFamilyKernel resolve (R.rotate (R.inverse p)) (R.rotate (R.inverse q)) := by
        rw [R.rotate_inverse p, R.rotate_inverse q]
        exact h
      exact (R.kernel_iff (R.inverse p) (R.inverse q)).mp h')

theorem quotient_inverse_rotate
    (p : ThreadFamily resolve n) :
    R.quotientInverse (R.quotientRotate (Quotient.mk _ p)) = Quotient.mk _ p := by
  show R.quotientInverse (Quotient.mk _ (R.rotate p)) = Quotient.mk _ p
  rw [show R.quotientInverse (Quotient.mk _ (R.rotate p)) =
        Quotient.mk _ (R.inverse (R.rotate p)) from rfl]
  rw [R.inverse_rotate p]

theorem quotient_rotate_inverse
    (p : ThreadFamily resolve n) :
    R.quotientRotate (R.quotientInverse (Quotient.mk _ p)) = Quotient.mk _ p := by
  show R.quotientRotate (Quotient.mk _ (R.inverse p)) = Quotient.mk _ p
  rw [show R.quotientRotate (Quotient.mk _ (R.inverse p)) =
        Quotient.mk _ (R.rotate (R.inverse p)) from rfl]
  rw [R.rotate_inverse p]

theorem quotient_finiteOrder_two
    (hOrder : ∀ p, R.rotate (R.rotate p) = p)
    (p : ThreadFamily resolve n) :
    R.quotientRotate (R.quotientRotate (Quotient.mk _ p)) = Quotient.mk _ p := by
  rw [R.quotientRotate_mk, R.quotientRotate_mk]
  rw [hOrder p]

end ThreadFamilyRotation


/-! Quotient nontriviality for ThreadFamilyRotation. -/

namespace ThreadFamilyRotation

variable {resolve : KernelExpr → Store → Location} {n : Nat}
variable (R : ThreadFamilyRotation resolve n)

def QuotientNontrivial : Prop :=
  ∃ x : ThreadFamilyQuotient resolve n,
    R.quotientRotate x ≠ x

def QuotientTrivial : Prop :=
  ∀ x : ThreadFamilyQuotient resolve n,
    R.quotientRotate x = x

end ThreadFamilyRotation


/-! Two-thread swap quotient action. -/

theorem twoThreadSwapRotation_quotient_finiteOrder
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (p : ThreadFamily resolve 2) :
    (twoThreadSwapRotation resolve h).quotientRotate
      ((twoThreadSwapRotation resolve h).quotientRotate
        (Quotient.mk _ p))
    =
    Quotient.mk _ p :=
  (twoThreadSwapRotation resolve h).quotient_finiteOrder_two
    (twoThreadSwapTransform_involutive resolve) p

/-! Resolver-separation family for quotient nontriviality. -/

def exposingFamily
    (resolve : KernelExpr → Store → Location) :
    ThreadFamily resolve 2 :=
  fun i => if i.val = 0 then [] else [exposingContext]

theorem exposingFamily_swap_kernel_ne
    (h : 1 < 2) :
    ¬ ThreadFamilyKernel resolverSeparationWitness
        (twoThreadSwapTransform resolverSeparationWitness
          (exposingFamily resolverSeparationWitness))
        (exposingFamily resolverSeparationWitness) := by
  intro hK
  have h0 := congrFun hK ⟨0, by omega⟩
  unfold ThreadFamilyKernel projectThreadFamily twoThreadSwapTransform
    permuteThreadFamily reindexThreadFamily exposingFamily at h0
  simp [twoThreadSwap, twoThreadSwapFun] at h0
  -- h0 : trajectoryProjection [exposingContext] = trajectoryProjection []
  exact exposingContext_nonidentity_witness h0

theorem twoThreadSwapRotation_quotient_nontrivial
    (h : 1 < 2) :
    ThreadFamilyRotation.QuotientNontrivial
      (twoThreadSwapRotation resolverSeparationWitness h) := by
  refine ⟨Quotient.mk _ (exposingFamily resolverSeparationWitness), ?_⟩
  intro heq
  have hK := Quotient.exact heq
  exact exposingFamily_swap_kernel_ne h hK

/-! Concrete instance of ResolveDistinguishesExposedLeft -/

def distinguishingResolve : KernelExpr → Unit → KernelExpr :=
  fun e _ => e

theorem distinguishingResolve_instance :
    ResolveDistinguishesExposedLeft distinguishingResolve := by
  refine ⟨identityContext, (), ?_⟩
  simp [distinguishingResolve, identityContext]

theorem distinguishingResolve_exposingContext_nonidentity :
    toTrajectoryBoundary distinguishingResolve [exposingContext]
    ≠
    emptyTrajectory distinguishingResolve := by
  intro h
  have hK : FoldKernel distinguishingResolve [exposingContext] [] := by
    show Quotient.mk _ [exposingContext] = Quotient.mk _ []
    exact h
  exact resolveDistinguishes_implies_exposingContext_outside_identity
    distinguishingResolve distinguishingResolve_instance hK

theorem distinguishingResolve_synchronous_distinction_to_collapse :
    trajectoryProjection distinguishingResolve [exposingContext]
    ≠
    trajectoryProjection distinguishingResolve [identityContext]
    ∧
    trajectoryProjection distinguishingResolve [exposingContext, identityContext]
    =
    trajectoryProjection distinguishingResolve [identityContext, exposingContext] := by
  constructor
  · intro h
    have hId : trajectoryProjection distinguishingResolve [identityContext]
        = emptyTrajectory distinguishingResolve :=
      identity_singleton_equals_empty_trajectory distinguishingResolve
    rw [hId] at h
    exact distinguishingResolve_exposingContext_nonidentity h
  · show trajectoryProjection distinguishingResolve ([exposingContext] ++ [identityContext])
        = trajectoryProjection distinguishingResolve ([identityContext] ++ [exposingContext])
    rw [trajectoryProjection_append, trajectoryProjection_append]
    have hId : trajectoryProjection distinguishingResolve [identityContext]
        = emptyTrajectory distinguishingResolve :=
      identity_singleton_equals_empty_trajectory distinguishingResolve
    rw [hId]
    rw [composeTrajectory_id_right, composeTrajectory_id_left]
