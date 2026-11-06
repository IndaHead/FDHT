import FDHTProvenanceAuditAPI

open KernelExprContext
open KernelExprContext.ProvenanceAudit

namespace KernelExprContext
namespace ProvenanceAuditRegression

universe u v

variable {Store : Type u}
variable {Location : Type v}

/-!
# FDHT Provenance Audit Consumer API — Regression Certification

Consumes existing theorems only. No new foundational mathematics.
-/

/-! ============================================================
    Fixture A — same raw
============================================================ -/

def fixtureA_sameRaw
    (resolve : KernelExpr → Store → Location) :
    ProvenanceRelation resolve ([] : List KernelExprContext) [] :=
  sameRaw resolve [] [] rfl

/-! ============================================================
    Fixture B — identity collapse
============================================================ -/

def fixtureB_rawDistinct :
    ([] : List KernelExprContext) ≠ [identityContext] := by
  intro h
  cases h

def fixtureB_projectedEqual
    (resolve : KernelExpr → Store → Location) :
    trajectoryProjection resolve ([] : List KernelExprContext)
    =
    trajectoryProjection resolve [identityContext] := by
  rw [trajectoryProjection_nil]
  exact (identity_singleton_equals_empty_trajectory resolve).symm

def fixtureB_collapsed
    (resolve : KernelExpr → Store → Location) :
    ProvenanceRelation resolve ([] : List KernelExprContext) [identityContext] :=
  collapsed resolve [] [identityContext]
    fixtureB_rawDistinct
    (fixtureB_projectedEqual resolve)

def fixtureB_certificate
    (resolve : KernelExpr → Store → Location) :
    CollapseCertificate resolve ([] : List KernelExprContext) [identityContext] :=
  collapseCertificate resolve [] [identityContext]
    fixtureB_rawDistinct
    (fixtureB_projectedEqual resolve)

/-! ============================================================
    Fixture C — projected distinction
============================================================ -/

def fixtureC_projectedDistinct :
    ProvenanceRelation distinguishingResolve [exposingContext] [identityContext] :=
  projectedDistinct distinguishingResolve [exposingContext] [identityContext]
    (distinguishingResolve_synchronous_distinction_to_collapse).1

def fixtureC_certificate :
    ProjectedDistinctionCertificate distinguishingResolve [exposingContext] [identityContext] :=
  projectedDistinctionCertificate distinguishingResolve [exposingContext] [identityContext]
    (distinguishingResolve_synchronous_distinction_to_collapse).1

/-! ============================================================
    Fixture D — Stage 4 collapse
============================================================ -/

def fixtureD_rawDistinct :
    [exposingContext, identityContext] ≠ ([identityContext, exposingContext] : List KernelExprContext) := by
  intro h
  have hHead : exposingContext = identityContext := by
    injection h
  have : (exposingContext.plug .left) = (identityContext.plug .left) := by
    rw [hHead]
  simp [exposingContext, identityContext] at this

def fixtureD_projectedEqual :
    trajectoryProjection distinguishingResolve [exposingContext, identityContext]
    =
    trajectoryProjection distinguishingResolve [identityContext, exposingContext] :=
  (distinguishingResolve_synchronous_distinction_to_collapse).2

def fixtureD_collapsed :
    ProvenanceRelation distinguishingResolve
      [exposingContext, identityContext]
      [identityContext, exposingContext] :=
  collapsed distinguishingResolve
    [exposingContext, identityContext]
    [identityContext, exposingContext]
    fixtureD_rawDistinct
    fixtureD_projectedEqual

def fixtureD_certificate :
    CollapseCertificate distinguishingResolve
      [exposingContext, identityContext]
      [identityContext, exposingContext] :=
  collapseCertificate distinguishingResolve
    [exposingContext, identityContext]
    [identityContext, exposingContext]
    fixtureD_rawDistinct
    fixtureD_projectedEqual

/-! ============================================================
    Fixture E — distinguishingResolve certificate
============================================================ -/

def fixtureE_certificate :
    DistinguishingResolveCertificate :=
  distinguishingResolveCertificate

/-! ============================================================
    Fixture F — observable factorisation (Prop)
============================================================ -/

def constantObservable
    (resolve : KernelExpr → Store → Location)
    (_xs : List KernelExprContext) : Nat :=
  0

theorem constantObservable_invariant
    (resolve : KernelExpr → Store → Location) :
    HistoryObservableInvariant resolve (constantObservable resolve) := by
  intro xs ys _
  rfl

def fixtureF_certificate
    (resolve : KernelExpr → Store → Location) :
    ObservableFactorisationCertificate resolve (constantObservable resolve) :=
  observableFactorisationCertificate resolve
    (constantObservable resolve)
    (constantObservable_invariant resolve)

/-! ============================================================
    Invalid-state checks
============================================================ -/

theorem invalid_raw_contradiction
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (hEq : xs = ys)
    (hNe : xs ≠ ys) :
    False :=
  sameRaw_not_collapsed resolve xs ys hEq hNe

theorem invalid_projected_contradiction
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (hEq : trajectoryProjection resolve xs = trajectoryProjection resolve ys)
    (hNe : trajectoryProjection resolve xs ≠ trajectoryProjection resolve ys) :
    False :=
  projectedEqual_not_projectedDistinct resolve xs ys hEq hNe

/-! ============================================================
    Compile-time surface checks
============================================================ -/

#check fixtureA_sameRaw
#check fixtureB_collapsed
#check fixtureB_certificate
#check fixtureC_projectedDistinct
#check fixtureC_certificate
#check fixtureD_collapsed
#check fixtureD_certificate
#check fixtureE_certificate
#check fixtureF_certificate

end ProvenanceAuditRegression
end KernelExprContext
