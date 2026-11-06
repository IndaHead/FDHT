# FDHT Backlog #16 — Projected Nonidentity Closure

**Status:** CLOSED  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Base HEAD:** df8921671b386b0b935ffbf290c4f32a4457c68f

## Classification

COMPILER-VERIFIED RESEARCH RESULT  
NOT PERMANENT API

## Mathematical Summary

A nonidentity ThreadPermutation induces a nonidentity direct projectedAction
whenever the projected TrajectoryBoundary carrier contains two distinct elements.

### Minimal Verified Chain

```
π ≠ identityThreadPermutation n
    ↓
∃ i : Fin n, π.toFun i ≠ i
    +
∃ a b : TrajectoryBoundary resolve, a ≠ b
    ↓
explicit indicator family
    ↓
∃ f, π.projectedAction resolve f ≠ f
    ↓
π.projectedAction resolve ≠ id
```

### Resolver-Specific Summary

For `resolverSeparationWitness`:

```
resolverSeparationWitness_nonidentity
    ↓
TrajectoryBoundary resolverSeparationWitness contains distinct values
    ↓
n=4 projected half-power action ≠ id
n=6 projected half-power action ≠ id
n=8 projected half-power action ≠ id
```

## Archived Probes

| Probe | Path | SHA256 |
|-------|------|--------|
| constructive_moved_coordinate | research/probes/backlog_16/constructive_moved_coordinate_probe.lean | d26f88379a2c4b73f07bc1be79e9f4eb1ba36d96fa9e117640e31c9f759849d1 |
| projectedAction_moved | research/probes/backlog_16/projectedAction_moved_probe.lean | 61e0d42d83a5b80541b33d2c8542b3cd121cd40346dd3b0ae4848e48fa75d84e |
| end_to_end | research/probes/backlog_16/end_to_end_projected_nonidentity_probe.lean | 601c54dab7daa313734a78def28e99f1721ea1bb8a8b2f2f4d2d54ea29ec1950 |
| shared_carrier_witness | research/probes/backlog_16/shared_carrier_witness_n4_n6_n8_probe.lean | 77e28745b5839f9faa02b20ae8deef43e8e19df43684868c2ec517f3faa893d1 |

## Trust Footprint

All preferred theorems: `[propext, Quot.sound]`

- Classical.choice: ABSENT
- sorryAx: ABSENT
- custom axioms: ABSENT

## Verification

- lake build: EXIT 0 (48 jobs)
- strict axiom audit: PASS

## Firewalls

- raw permutation nonidentity ≠ arbitrary-resolver projected nonidentity
- projected involution ≠ projected nonidentity
- resolver-specific closure ≠ arbitrary-resolver closure
- carrier nontriviality ≠ global ResolverSeparates
- mathematical consumer ≠ permanent API consumer
- passing probe ≠ promoted theorem
- historical OPEN ≠ historical error
- example ≠ arbitrary-n theorem

## #14P Historical Compatibility

#14P was correct at its historical boundary. Projected nonidentity was OPEN
and non-blocking. #16D verified the missing generic conditional bridge.
#16E connected an existing resolver-level trajectory distinction to that
bridge. Projected nonidentity is now probe-closed for `resolverSeparationWitness`
at n=4/6/8. Arbitrary-resolver projected nonidentity remains conditional.

## Remaining OPEN Boundaries

- Arbitrary-resolver projected nonidentity
- Permanent API promotion decision

## Disposition

RETAIN AS RESEARCH PROBE. Do not promote.
