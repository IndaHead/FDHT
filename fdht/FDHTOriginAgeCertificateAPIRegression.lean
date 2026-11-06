import FDHTOriginAgeCertificateAPI

open KernelExprContext
open KernelExprContext.OriginAgeCertificate

namespace KernelExprContext
namespace OriginAgeRegression

/-!
# FDHT Origin-Relative Age Consumer Regressions

These regressions certify only the public consumer contract.

They do not extract an age witness.
They do not introduce Classical.choice.
They do not identify origin-relative age with folded position,
ScalarDepthExists, physical time, or geometric distance.
-/

universe u

/-! ============================================================
    Fixture A — generic injective raw orbit
============================================================ -/

section GenericInjectiveOrbit

variable {X : Type u}
variable (step : X → X)
variable (origin : X)
variable (hInj : RawOrbitInjective step origin)
variable (k : Nat)

/--
An injective raw orbit certifies unique origin-relative age
for every state explicitly reached at index `k`.
-/
example :
    OriginAgeCertificate
      step
      origin
      (RawOrbit step origin k) :=
  originAgeCertificateOfInjective
    step origin hInj k

end GenericInjectiveOrbit


/-! ============================================================
    Fixture B — familyUnequal n = 2
============================================================ -/

#check familyUnequal_originRelativeScalarDepthExists_n2
#check familyUnequal_age_eq_orbit_index_n2
#check foldedPosition_does_not_determine_originRelativeAge_n2
#check distinct_age_same_folded_position_n2


/-! ============================================================
    Fixture C — explicit raw-orbit collision
============================================================ -/

section Collision

variable {X : Type u}
variable (step : X → X)
variable (origin : X)
variable (k m : Nat)

variable (hDistinct : k ≠ m)

variable (hCollision :
  RawOrbit step origin k =
  RawOrbit step origin m)

/--
The collision hypotheses can be packaged without claiming
that the collided state has no age.
-/
example :
    AgeCollisionCertificate step origin k m :=
  {
    distinctAges := hDistinct
    sameState := hCollision
  }

/--
The packaged collision refutes UNIQUE age at the collided state.

It does not refute reachability.
-/
example
    (hCert : AgeCollisionCertificate step origin k m) :
    ¬ HasUniqueAgeFrom
        step
        origin
        (RawOrbit step origin k) :=
  ageCollision_refutes_uniqueAge
    step origin k m hCert

end Collision


/-! ============================================================
    Public-surface checks
============================================================ -/

#check OriginAgeCertificate
#check originAgeCertificateOfInjective
#check AgeCollisionCertificate
#check ageCollision_refutes_uniqueAge


/-! ============================================================
    Existing mathematical dependencies
============================================================ -/

#check rawOrbitInjective_implies_unique_age
#check rawOrbit_collision_refutes_unique_age


/-! ============================================================
    Trust audit targets
============================================================ -/

#print axioms originAgeCertificateOfInjective
#print axioms ageCollision_refutes_uniqueAge

end OriginAgeRegression
end KernelExprContext
