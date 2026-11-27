# FDHT SCF-03B: Typed Graph Method

## Method

1. Freeze artefact inventory before extraction
2. Recover carriers from exact type definitions
3. Recover transformations from exact function signatures
4. Recover consumers from exact consumer definitions
5. Compute connected components mechanically
6. Classify topology from edges
7. Audit cycles independently
8. Audit authority changes

## Carrier admission

A carrier is admitted only if:
- exact type exists
- authority is explicit
- at least one transformation or consumer uses it

## Transformation admission

A transformation is admitted only if:
- exact source type exists
- exact target type exists
- exact function exists
- direction is explicit

## Consumer admission

A consumer is admitted only if:
- exact domain carrier exists
- exact codomain exists
- exact function exists

## Graph construction

The graph is constructed from recovered artefacts only. No edges are invented. No carriers are collapsed. No cross-carrier adapters are created.

## Conclusion

The graph has two connected components. No cross-carrier adapter exists.
