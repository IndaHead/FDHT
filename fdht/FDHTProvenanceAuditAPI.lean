import FDHTReturnStabilizerBoundaryAPI

open KernelExprContext

namespace KernelExprContext
namespace ProvenanceAudit

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# FDHT Provenance Audit Consumer API

Evidence-bearing consumer surface only.

This module does not provide a total classifier over histories.
Certificates are constructed only when the required evidence is supplied.
-/

/-! ============================================================
    Primary provenance relation
============================================================ -/

inductive ProvenanceRelation
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) : Type where

  /-- The raw histories are equal. -/
  | sameRaw
      (rawEqual : xs = ys) :
      ProvenanceRelation resolve xs ys

  /-- The projected trajectories are distinct under this resolver. -/
  | projectedDistinct
      (projectedDistinct :
        trajectoryProjection resolve xs ≠
        trajectoryProjection resolve ys) :
      ProvenanceRelation resolve xs ys

  /--
  The raw histories are distinct but occupy the same projected
  trajectory position under this resolver.
  -/
  | collapsed
      (rawDistinct : xs ≠ ys)
      (projectedEqual :
        trajectoryProjection resolve xs =
        trajectoryProjection resolve ys) :
      ProvenanceRelation resolve xs ys


/-! ============================================================
    Collapse certificate
============================================================ -/

structure CollapseCertificate
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) : Prop where

  rawDistinct :
    xs ≠ ys

  projectedEqual :
    trajectoryProjection resolve xs =
    trajectoryProjection resolve ys

  commonRecoveryBlocked :
    ¬ ∃ recover :
        TrajectoryBoundary resolve →
        List KernelExprContext,
      recover (trajectoryProjection resolve xs) = xs ∧
      recover (trajectoryProjection resolve ys) = ys


/--
Construct a collapse certificate directly from distinctness and
projected equality.

No additional mathematical assumption is introduced.
-/
def collapseCertificate
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (hRaw : xs ≠ ys)
    (hProjected :
      trajectoryProjection resolve xs =
      trajectoryProjection resolve ys) :
    CollapseCertificate resolve xs ys where

  rawDistinct := hRaw

  projectedEqual := hProjected

  commonRecoveryBlocked :=
    collapsed_pair_blocks_common_reconstruction
      resolve xs ys hRaw hProjected


/-! ============================================================
    Projected distinction certificate
============================================================ -/

structure ProjectedDistinctionCertificate
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) : Prop where

  projectedDistinct :
    trajectoryProjection resolve xs ≠
    trajectoryProjection resolve ys


def projectedDistinctionCertificate
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (h :
      trajectoryProjection resolve xs ≠
      trajectoryProjection resolve ys) :
    ProjectedDistinctionCertificate resolve xs ys :=
  ⟨h⟩


/-! ============================================================
    Observable factorisation certificate
============================================================ -/

structure ObservableFactorisationCertificate
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O) : Prop where

  existsBoundary :
    ∃ boundaryObservable : TrajectoryBoundary resolve → O,
      ∀ xs : List KernelExprContext,
        boundaryObservable (trajectoryProjection resolve xs) = obs xs


/--
An invariant observable admits a trajectory-boundary factorisation.

This constructor requires invariance explicitly.
The certificate remains in Prop and does not extract a choice witness.
-/
def observableFactorisationCertificate
    {O : Type}
    (resolve : KernelExpr → Store → Location)
    (obs : List KernelExprContext → O)
    (hInv : HistoryObservableInvariant resolve obs) :
    ObservableFactorisationCertificate resolve obs where
  existsBoundary :=
    (history_observable_invariant_iff_factor resolve obs).mp hInv


/-! ============================================================
    distinguishingResolve-specialised certificate
============================================================ -/

/--
Closed cancellation/stabiliser facts for distinguishingResolve only.

Nothing in this structure generalises these results to arbitrary
resolvers.
-/
structure DistinguishingResolveCertificate : Prop where

  nontrivialRightStabilizer :
    NontrivialRightStabilizer distinguishingResolve

  nontrivialLeftStabilizer :
    NontrivialLeftStabilizer distinguishingResolve

  notReturnImpliesIdentityClass :
    ¬ ReturnImpliesIdentityClass distinguishingResolve

  notLeftCancellation :
    ¬ LeftCancellation distinguishingResolve

  notRightCancellation :
    ¬ RightCancellation distinguishingResolve

  rightCancellationCollision :
    RightCancellationCollision distinguishingResolve


def distinguishingResolveCertificate :
    DistinguishingResolveCertificate := by

  rcases distinguishingResolve_cancellation_frontier with
    ⟨hRight, hLeft, hReturn, hLCancel, hRCancel, hCollision⟩

  exact
    {
      nontrivialRightStabilizer := hRight
      nontrivialLeftStabilizer := hLeft
      notReturnImpliesIdentityClass := hReturn
      notLeftCancellation := hLCancel
      notRightCancellation := hRCancel
      rightCancellationCollision := hCollision
    }


/-! ============================================================
    Evidence-driven relation constructors
============================================================ -/

def sameRaw
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (h : xs = ys) :
    ProvenanceRelation resolve xs ys :=
  .sameRaw h


def projectedDistinct
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (h :
      trajectoryProjection resolve xs ≠
      trajectoryProjection resolve ys) :
    ProvenanceRelation resolve xs ys :=
  .projectedDistinct h


def collapsed
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (hRaw : xs ≠ ys)
    (hProjected :
      trajectoryProjection resolve xs =
      trajectoryProjection resolve ys) :
    ProvenanceRelation resolve xs ys :=
  .collapsed hRaw hProjected


/-! ============================================================
    Structural incompatibility lemmas
============================================================ -/

theorem sameRaw_not_collapsed
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (hEq : xs = ys)
    (hNe : xs ≠ ys) :
    False :=
  hNe hEq


theorem projectedEqual_not_projectedDistinct
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (hEq :
      trajectoryProjection resolve xs =
      trajectoryProjection resolve ys)
    (hNe :
      trajectoryProjection resolve xs ≠
      trajectoryProjection resolve ys) :
    False :=
  hNe hEq


theorem rawEqual_implies_projectedEqual
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (h : xs = ys) :
    trajectoryProjection resolve xs =
    trajectoryProjection resolve ys := by
  rw [h]


/-! ============================================================
    No total classifier
============================================================ -/

/-
Intentionally NOT defined:

def audit
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext) :
    ProvenanceRelation resolve xs ys := ...

The frozen substrate does not currently provide the projected-equality
decidability required for a constructive total classifier.

Absence of a certificate means NOT CERTIFIED.
It does not mean FALSE.
-/


/-! ============================================================
    Compile-time surface checks
============================================================ -/

#check ProvenanceRelation
#check CollapseCertificate
#check collapseCertificate
#check ProjectedDistinctionCertificate
#check projectedDistinctionCertificate
#check ObservableFactorisationCertificate
#check observableFactorisationCertificate
#check DistinguishingResolveCertificate
#check distinguishingResolveCertificate

end ProvenanceAudit
end KernelExprContext
