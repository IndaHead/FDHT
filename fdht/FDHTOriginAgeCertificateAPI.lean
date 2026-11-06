import FDHTOriginRelativeDepthAPI

open KernelExprContext

namespace KernelExprContext
namespace OriginAgeCertificate

/-!
# FDHT Origin-Relative Age Certificate API

Evidence-bearing consumer surface only.

This module does not extract an age witness.
It does not introduce Classical.choice.
It does not identify origin-relative age with folded position,
ScalarDepthExists, physical time, or geometric distance.
-/

universe u

variable {X : Type u}

/--
Certificate that `current` has a unique origin-relative age
along the raw orbit generated from `origin` by `step`.
-/
structure OriginAgeCertificate
    (step : X → X)
    (origin current : X) : Prop where
  uniqueAge : HasUniqueAgeFrom step origin current

/--
An injective raw orbit certifies unique age for every state
explicitly reached at index `k`.
-/
def originAgeCertificateOfInjective
    (step : X → X)
    (origin : X)
    (hInj : RawOrbitInjective step origin)
    (k : Nat) :
    OriginAgeCertificate step origin (RawOrbit step origin k) where
  uniqueAge := rawOrbitInjective_implies_unique_age step origin hInj k

/--
Certificate that distinct raw-orbit indices collide at the same state.
-/
structure AgeCollisionCertificate
    (step : X → X)
    (origin : X)
    (k m : Nat) : Prop where
  distinctAges : k ≠ m
  sameState : RawOrbit step origin k = RawOrbit step origin m

/--
A collision refutes unique age at the collided state.
It does not refute reachability.
-/
theorem ageCollision_refutes_uniqueAge
    (step : X → X)
    (origin : X)
    (k m : Nat)
    (hCert : AgeCollisionCertificate step origin k m) :
    ¬ HasUniqueAgeFrom step origin (RawOrbit step origin k) :=
  rawOrbit_collision_refutes_unique_age
    step origin k m hCert.distinctAges hCert.sameState

end OriginAgeCertificate
end KernelExprContext
