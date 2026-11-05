# FDHT Stage 4 Concrete First-Collapse Localisation

## Status

STAGE 4 CONCRETE FIRST-COLLAPSE LOCALISATION PROVED AT k=1

## Frozen concrete histories

```lean
xs := [exposingContext, identityContext]
ys := [identityContext, exposingContext]
```

## Indexed event

```lean
def CollapseTransitionAt
    (xs ys : List KernelExprContext)
    (k : Nat) : Prop :=
  trajectoryProjection distinguishingResolve (List.take k xs)
    ≠
  trajectoryProjection distinguishingResolve (List.take k ys)
  ∧
  trajectoryProjection distinguishingResolve (List.take (k + 1) xs)
    =
  trajectoryProjection distinguishingResolve (List.take (k + 1) ys)
```

## Concrete results

- Event at k=1: PROVED
  (from `distinguishingResolve_synchronous_distinction_to_collapse`)

- Event at k=0: REFUTED
  (`List.take 0 _ = []`, projections identical, inequality fails)

- Concrete minimality at k=1: PROVED

```lean
theorem concrete_first_collapse_at_one :
    CollapseTransitionAt
      [exposingContext, identityContext]
      [identityContext, exposingContext]
      1
    ∧
    ∀ j < 1,
      ¬ CollapseTransitionAt
        [exposingContext, identityContext]
        [identityContext, exposingContext]
        j
```

Proof uses only direct expansion of `j < 1` to `j = 0` and the refutation at zero. No general Nat well-ordering or `Nat.find` is invoked.

## Trust footprint

```text
concrete_first_collapse_at_one depends on axioms: [propext, Quot.sound]
```

No `Classical.choice`, no `sorryAx`, no custom axioms.

## Generic least-event existence

NOT ESTABLISHED

Ordinary Nat minimality for an arbitrary Prop-valued predicate requires either decidability of the predicate or classical principles. Neither is currently available for `CollapseTransitionAt` in general. Concrete proof does not establish a generic API.

## Computability

NOT ESTABLISHED

Existence of a least index is not a computable first-event function.

## New definitions

NONE (CollapseTransitionAt used only as local probe proposition)

## New theorems

```lean
theorem concrete_first_collapse_at_one
```

(proved in probe; not committed to source modules)

## Downstream impact

```text
Stage 5: UNAFFECTED
Stage 6: UNAFFECTED
Stage 7: UNAFFECTED
Stage 8: UNAFFECTED
Stage 9: UNAFFECTED
```

## Firewall

```text
event exists ≠ least-event theorem encoded
least event exists ≠ computable first-event function
concrete minimal index ≠ generic localisation theorem
minimal index ≠ FirstCollapse datatype
Nat well-ordering ≠ search algorithm
proof of k=1 minimal ≠ post-collapse behaviour
```

## Governing rule

Concrete first-collapse localisation is proved at k=1 for the frozen pair and the current event predicate. Generic first-collapse localisation remains OPEN. No new ontology is introduced.

Trust the maths.
