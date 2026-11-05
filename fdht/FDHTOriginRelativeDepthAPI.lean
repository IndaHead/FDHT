import AggregateFamilyTransform

open KernelExprContext

/-!
# FDHT Origin-Relative Scalar Depth

Candidate semantics: unique age measured from an explicitly specified origin
under an explicitly specified evolution step.

This does NOT redefine ScalarDepthExists.
This does NOT identify age with raw length, traversal count, orbit index, or
folded position except where a theorem proves the identification on a specific
orbit.
-/

variable {X : Sort u}

/-- Current occurs at age `age` along the raw orbit generated from `origin`. -/
def ReachedFromAt
    (step : X → X)
    (origin current : X)
    (age : Nat) : Prop :=
  RawOrbit step origin age = current

def PossibleAgesFrom
    (step : X → X)
    (origin current : X) : Nat → Prop :=
  fun age => ReachedFromAt step origin current age

def HasAgeFrom
    (step : X → X)
    (origin current : X) : Prop :=
  ∃ age, ReachedFromAt step origin current age

def HasUniqueAgeFrom
    (step : X → X)
    (origin current : X) : Prop :=
  ∃ age,
    ReachedFromAt step origin current age
    ∧
    ∀ age',
      ReachedFromAt step origin current age' →
      age' = age

/-- Scalar age only where the trajectory from the chosen origin supplies a unique age. -/
structure OriginRelativeScalarDepthSpec
    (step : X → X)
    (origin current : X) where
  age : Nat
  reached : ReachedFromAt step origin current age
  unique : ∀ age', ReachedFromAt step origin current age' → age' = age

theorem originRelativeSpec_implies_uniqueAge
    (step : X → X)
    (origin current : X)
    (s : OriginRelativeScalarDepthSpec step origin current) :
    HasUniqueAgeFrom step origin current :=
  ⟨s.age, s.reached, s.unique⟩

theorem uniqueAge_implies_originRelativeSpec
    (step : X → X)
    (origin current : X)
    (h : HasUniqueAgeFrom step origin current) :
    Nonempty (OriginRelativeScalarDepthSpec step origin current) := by
  rcases h with ⟨age, hReach, hUniq⟩
  exact ⟨⟨age, hReach, hUniq⟩⟩

theorem origin_reached_at_zero
    (step : X → X)
    (origin : X) :
    ReachedFromAt step origin origin 0 := by
  unfold ReachedFromAt
  rw [RawOrbit_zero]

theorem neverReturns_implies_uniqueZeroAge
    (step : X → X)
    (origin : X)
    (hNever : RawOrbitNeverReturns step origin) :
    HasUniqueAgeFrom step origin origin := by
  refine ⟨0, origin_reached_at_zero step origin, ?_⟩
  intro age' hAge
  cases age' with
  | zero => rfl
  | succ k =>
    unfold ReachedFromAt at hAge
    have hRet : RawOrbitReturnsAt step origin (k + 1) := by
      unfold RawOrbitReturnsAt
      exact hAge
    exact absurd hRet (hNever (k + 1) (Nat.succ_pos k))

/-- Raw-orbit injectivity implies unique age equal to the orbit index. -/
theorem rawOrbitInjective_implies_unique_age
    (step : X → X)
    (origin : X)
    (hInj : RawOrbitInjective step origin)
    (k : Nat) :
    HasUniqueAgeFrom step origin (RawOrbit step origin k) := by
  refine ⟨k, ?_, ?_⟩
  · unfold ReachedFromAt
    rfl
  · intro age' hAge
    unfold ReachedFromAt at hAge
    exact hInj hAge

theorem age_successor
    (step : X → X)
    (origin : X)
    (hInj : RawOrbitInjective step origin)
    (k : Nat) :
    ReachedFromAt step origin (RawOrbit step origin (k + 1)) (k + 1) := by
  unfold ReachedFromAt
  rfl

def OriginRelativeScalarDepthExists
    (step : X → X)
    (origin : X) : Prop :=
  ∀ k, HasUniqueAgeFrom step origin (RawOrbit step origin k)

theorem rawOrbitInjective_implies_originRelativeScalarDepthExists
    (step : X → X)
    (origin : X)
    (hInj : RawOrbitInjective step origin) :
    OriginRelativeScalarDepthExists step origin :=
  fun k => rawOrbitInjective_implies_unique_age step origin hInj k

/-- Collision of distinct indices refutes unique age. -/
theorem rawOrbit_collision_refutes_unique_age
    (step : X → X)
    (origin : X)
    (k m : Nat)
    (hkm : k ≠ m)
    (hCollision : RawOrbit step origin k = RawOrbit step origin m) :
    ¬ HasUniqueAgeFrom step origin (RawOrbit step origin k) := by
  intro hUniq
  rcases hUniq with ⟨age, hReach, hUniqAge⟩
  have hReachK : ReachedFromAt step origin (RawOrbit step origin k) k := by
    unfold ReachedFromAt
    rfl
  have hReachM : ReachedFromAt step origin (RawOrbit step origin k) m := by
    unfold ReachedFromAt
    exact hCollision.symm
  have hMk : m = k := (hUniqAge m hReachM).trans (hUniqAge k hReachK).symm
  exact hkm hMk.symm

theorem positiveReturn_refutes_uniqueZeroAge
    (step : X → X)
    (origin : X)
    (hRet : PositiveRawReturnExists step origin) :
    ¬ HasUniqueAgeFrom step origin origin := by
  rcases hRet with ⟨k, hkPos, hRetAt⟩
  intro hUniq
  rcases hUniq with ⟨age, hReach, hUniqAge⟩
  have hK : ReachedFromAt step origin origin k := by
    unfold ReachedFromAt
    unfold RawOrbitReturnsAt at hRetAt
    exact hRetAt
  have hZero : ReachedFromAt step origin origin 0 := origin_reached_at_zero step origin
  have hEq : k = 0 := (hUniqAge k hK).trans (hUniqAge 0 hZero).symm
  exact Nat.not_succ_le_zero k (hEq ▸ hkPos)

def SameAgeFromDifferentOrigins
    (step : X → X)
    (origin₁ origin₂ current : X)
    (age : Nat) : Prop :=
  ReachedFromAt step origin₁ current age
  ∧
  ReachedFromAt step origin₂ current age

def DistinctOriginsSameCurrent
    (step : X → X)
    (current : X) : Prop :=
  ∃ origin₁ origin₂ age₁ age₂,
    origin₁ ≠ origin₂
    ∧
    ReachedFromAt step origin₁ current age₁
    ∧
    ReachedFromAt step origin₂ current age₂

/-- Candidate FDHT scalar-depth semantics. A proposition, not a total Nat-valued function. -/
def ScalarDepthAsOriginAge
    (step : X → X)
    (origin current : X) : Prop :=
  HasUniqueAgeFrom step origin current

/-! ============================================================
    n=2 familyUnequal instantiation
============================================================ -/

variable {Store : Sort v} {Location : Sort w}
variable (resolve : KernelExpr → Store → Location)
variable (h : 1 < 2)

theorem familyUnequal_originRelativeScalarDepthExists_n2 :
    OriginRelativeScalarDepthExists
      (asAggregateFun resolve (neighbourComposeTransform resolve h))
      (familyUnequal resolve 2 h) :=
  rawOrbitInjective_implies_originRelativeScalarDepthExists
    _
    _
    (familyUnequal_rawOrbit_injective_n2 resolve h)

theorem familyUnequal_unique_age_n2
    (k : Nat) :
    HasUniqueAgeFrom
      (asAggregateFun resolve (neighbourComposeTransform resolve h))
      (familyUnequal resolve 2 h)
      (RawOrbit
        (asAggregateFun resolve (neighbourComposeTransform resolve h))
        (familyUnequal resolve 2 h)
        k) :=
  rawOrbitInjective_implies_unique_age
    _
    _
    (familyUnequal_rawOrbit_injective_n2 resolve h)
    k

theorem familyUnequal_age_eq_orbit_index_n2
    (k : Nat)
    {age : Nat}
    (hAge :
      ReachedFromAt
        (asAggregateFun resolve (neighbourComposeTransform resolve h))
        (familyUnequal resolve 2 h)
        (RawOrbit
          (asAggregateFun resolve (neighbourComposeTransform resolve h))
          (familyUnequal resolve 2 h)
          k)
        age) :
    age = k := by
  have hUniq := familyUnequal_unique_age_n2 resolve h k
  rcases hUniq with ⟨age', hReach', hUniqAge⟩
  have hReachK : ReachedFromAt
      (asAggregateFun resolve (neighbourComposeTransform resolve h))
      (familyUnequal resolve 2 h)
      (RawOrbit
        (asAggregateFun resolve (neighbourComposeTransform resolve h))
        (familyUnequal resolve 2 h)
        k)
      k := by
    unfold ReachedFromAt
    rfl
  have hAge' : k = age' := hUniqAge k hReachK
  have hAge'' : age = age' := hUniqAge age hAge
  exact hAge''.trans hAge'.symm

theorem distinct_age_same_folded_position_n2
    (k m : Nat)
    (hkm : k ≠ m) :
    k ≠ m
    ∧
    FoldedOrbit resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      k
    =
    FoldedOrbit resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      m :=
  ⟨hkm, (familyUnequal_hidden_dynamic_split_n2 resolve h k m hkm).2⟩

theorem foldedPosition_does_not_determine_originRelativeAge_n2 :
    ¬ ∃ decode :
      (Fin 2 → TrajectoryBoundary resolve) → Nat,
      ∀ k,
        decode
          (projectThreadFamily resolve
            (RawOrbit
              (asAggregateFun resolve
                ((neighbourComposeAggregate resolve h).transform))
              (familyUnequal resolve 2 h)
              k))
        =
        k :=
  hiddenDynamicOrbit_folded_does_not_recover_index
    resolve
    (neighbourComposeAggregate resolve h)
    (familyUnequal resolve 2 h)
    (familyUnequal_hiddenDynamicOrbit_n2 resolve h)

theorem familyUnequal_chirality_by_originAge_n2 :
    ChiralityValueAlongOrbit resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      0
      .separated
    ∧
    ∀ age,
      0 < age →
      ChiralityValueAlongOrbit resolve
        (neighbourComposeTransform resolve h)
        (familyUnequal resolve 2 h)
        age
        .aligned :=
  familyUnequal_chiralityValue_orbit_n2 resolve h

/-! ============================================================
    Generic HiddenDynamicOrbit connection
============================================================ -/

theorem hiddenDynamicOrbit_has_originRelativeScalarDepth
    {n : Nat}
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n)
    (H : HiddenDynamicOrbit resolve n A p) :
    OriginRelativeScalarDepthExists
      (asAggregateFun resolve A.transform)
      p :=
  rawOrbitInjective_implies_originRelativeScalarDepthExists
    _
    _
    H.rawInjective

structure OriginAgeHiddenDynamicsCertificate
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (A : FoldCompatibleAggregateTransform resolve n)
    (p : ThreadFamily resolve n) where
  hidden : HiddenDynamicOrbit resolve n A p
  scalarAge : OriginRelativeScalarDepthExists (asAggregateFun resolve A.transform) p

def familyUnequal_originAgeCertificate_n2 :
    OriginAgeHiddenDynamicsCertificate
      resolve
      2
      (neighbourComposeAggregate resolve h)
      (familyUnequal resolve 2 h) where
  hidden := familyUnequal_hiddenDynamicOrbit_n2 resolve h
  scalarAge := familyUnequal_originRelativeScalarDepthExists_n2 resolve h


/-! Headline convenience conjunction. Reuses existing theorems only. -/

theorem familyUnequal_origin_age_hidden_by_fold_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    OriginRelativeScalarDepthExists
      (asAggregateFun resolve (neighbourComposeTransform resolve h))
      (familyUnequal resolve 2 h)
    ∧
    ¬ ∃ decode :
      (Fin 2 → TrajectoryBoundary resolve) → Nat,
      ∀ k,
        decode
          (projectThreadFamily resolve
            (RawOrbit
              (asAggregateFun resolve
                ((neighbourComposeAggregate resolve h).transform))
              (familyUnequal resolve 2 h)
              k))
        =
        k :=
  ⟨
    familyUnequal_originRelativeScalarDepthExists_n2 resolve h,
    foldedPosition_does_not_determine_originRelativeAge_n2 resolve h
  ⟩
