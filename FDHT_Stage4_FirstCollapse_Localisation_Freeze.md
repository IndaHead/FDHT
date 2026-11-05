# FDHT Stage 4 First-Collapse Localisation — Freeze

## Status

STAGE 4 FIRST-COLLAPSE LOCALISATION AUDIT FROZEN

## Concrete result

**PROVED AT k=1**

```lean
xs := [exposingContext, identityContext]
ys := [identityContext, exposingContext]
```

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

Proof uses only direct expansion (`j < 1` forces `j = 0`) and the refutation at zero. No general Nat well-ordering or `Nat.find` is invoked.

Trust footprint: `[propext, Quot.sound]`. No `Classical.choice`, no `sorryAx`.

## Generic least-event principle

**AVAILABLE FROM EXISTING LIBRARY**

```lean
theorem WellFounded.has_min {α} {r : α → α → Prop} (H : WellFounded r) (s : Set α) :
    s.Nonempty → ∃ a ∈ s, ∀ x ∈ s, ¬r x a
```

On `Nat` with `r := (· < ·)`, event existence implies least-event existence. The derived noncomputable `WellFounded.min` packages the same fact via `Classical.choose`.

- Decidability required: NO
- Classical.choice required: YES
- Other classical assumptions: classical logic

Application to `CollapseTransitionAt`: YES (classically, without permanent FDHT definition).

## What remains OPEN

- Generic event existence for arbitrary histories  
  (the premise `∃ k, CollapseTransitionAt xs ys k` is not established in general)
- Computability of a first-event function
- Generic first-collapse localisation as a permanent FDHT theorem
- Post-collapse branch separation

## New definitions

NONE

## New theorems

NONE committed to source modules  
(`concrete_first_collapse_at_one` proved in probe only)

## Source modified

NO

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
concrete minimal index ≠ generic localisation theorem
event existence ⇒ least-event existence (classically)
least-event existence ≠ computable first-event function
library principle ≠ permanent FDHT API
generic minimality ≠ concrete k=1 result
standard-library theorem ≠ new FDHT mathematics
Classical.choice ≠ constructive search
proof of k=1 minimal ≠ post-collapse behaviour
OPEN ≠ FALSE
NOT FOUND ≠ NON-EXISTENT
```

## Governing rule

Concrete first-collapse localisation is proved at k=1 for the frozen pair. Event existence implies least-event existence via Nat well-foundedness. Generic event existence and computability remain OPEN. No new FDHT mathematics is introduced.

Trust the maths.
