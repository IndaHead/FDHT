# FDHT Research Backlog #3
## Scalar Depth / Origin-Relative Age Reconciliation Audit

### Status

**CLOSED — DISTINCT DEPTH NOTIONS CONFIRMED**

No new mathematics required.

---

## ScalarDepthExists

`ScalarDepthExists` remains a separate proposition concerning the
existence of an injective scalar assignment on `TrajectoryBoundary`.

It does not encode:

- an explicit origin;
- an explicit evolution step;
- origin-relative age;
- uniqueness of age.

It remains independent of the origin-relative depth semantics audited
here.

---

## Origin-relative scalar depth

`FDHTOriginRelativeDepthAPI.lean` already formalises candidate scalar
depth as unique age measured from an explicitly specified origin under an
explicitly specified evolution step.

The existing machinery includes:

- `ReachedFromAt`
- `PossibleAgesFrom`
- `HasAgeFrom`
- `HasUniqueAgeFrom`
- `OriginRelativeScalarDepthSpec`
- `OriginRelativeScalarDepthExists`
- `ScalarDepthAsOriginAge`

This machinery does not redefine `ScalarDepthExists`.

---

## Positive boundary

Raw-orbit injectivity supplies unique origin-relative age.

Existing results include:

- `rawOrbitInjective_implies_unique_age`
- `rawOrbitInjective_implies_originRelativeScalarDepthExists`
- `hiddenDynamicOrbit_has_originRelativeScalarDepth`

Thus a `HiddenDynamicOrbit` supplies origin-relative scalar depth through
its raw-injectivity property.

---

## Negative boundary

Distinct raw-orbit indices that collide at the same raw state obstruct
unique age.

Existing results include:

- `rawOrbit_collision_refutes_unique_age`
- `positiveReturn_refutes_uniqueZeroAge`

Therefore:

```text
raw-orbit injectivity
        → unique origin-relative age

distinct-index raw collision
        → unique age fails
```

---

## n=2 concrete instantiation

On the `familyUnequal` n=2 orbit:

- origin-relative scalar depth exists;
- the unique age equals the raw orbit index;
- folded/projected position does not determine that age.

Existing results:

- `familyUnequal_originRelativeScalarDepthExists_n2`
- `familyUnequal_age_eq_orbit_index_n2`
- `foldedPosition_does_not_determine_originRelativeAge_n2`
- `distinct_age_same_folded_position_n2`

---

## Relationship

The two notions are **distinct**.

No existing theorem proves either direction:

```text
ScalarDepthExists → OriginRelativeScalarDepthExists
OriginRelativeScalarDepthExists → ScalarDepthExists
```

No bridge is required by current downstream mathematics.

---

## Trust footprint

Generic origin-relative theorems depend on no axioms.

Concrete n=2 and HiddenDynamicOrbit results depend only on:

```text
[propext, Quot.sound]
```

No Classical.choice, no sorryAx, no custom axioms.

---

## Classification

**THE TWO DEPTH NOTIONS ARE DISTINCT AND NO BRIDGE IS CURRENTLY REQUIRED**

Repository HEAD at time of audit:

`d334fa60ece2fecdd0e7953fb408619aa68c8993`
