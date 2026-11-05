# FDHT Stage 4 Generic Least-Event Audit

## Status

GENERIC LEAST-EVENT PRINCIPLE AVAILABLE FROM EXISTING LIBRARY

## Question

For an arbitrary predicate

```lean
P : Nat → Prop
```

given

```lean
h : ∃ k, P k
```

does the current Lean/Mathlib environment already provide a theorem or principle sufficient to prove

```lean
∃ k,
  P k ∧
  ∀ j < k, ¬ P j
```

without requiring decidability of P?

## Existing principle

```lean
theorem WellFounded.has_min {α} {r : α → α → Prop} (H : WellFounded r) (s : Set α) :
    s.Nonempty → ∃ a ∈ s, ∀ x ∈ s, ¬r x a
```

On `Nat` with `r := (· < ·)` and `s := {k | P k}`, this is exactly the least-witness principle from a nonempty existential.

The derived noncomputable `WellFounded.min` packages the same fact via `Classical.choose`.

(The constructive `Nat.find` / `Nat.findX` also exists, but requires `[DecidablePred p]` and is therefore excluded.)

## Assumptions

- Decidability required: NO
- Classical.choice required: YES
- Other classical assumptions: classical logic (`not_imp_not` in the proof of `has_min`)

## Generic least-witness result

AVAILABLE FROM EXISTING LIBRARY

## Application to CollapseTransitionAt

YES

If `∃ k, CollapseTransitionAt xs ys k`, then the set  
`{k | CollapseTransitionAt xs ys k}` is nonempty.  
`WellFounded.has_min` (or `WellFounded.min`) applied to it immediately yields

```lean
∃ k,
  CollapseTransitionAt xs ys k
  ∧
  ∀ j < k, ¬ CollapseTransitionAt xs ys j
```

No permanent FDHT definition is required; the principle is applied directly to the local proposition.

## What remains OPEN

- Generic event existence for arbitrary histories (the premise `∃ k, CollapseTransitionAt xs ys k` is not established in general)
- Computability of a first-event function
- Generic first-collapse localisation as a permanent FDHT theorem

## New definitions

NONE

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
event existence ⇒ least-event existence (classically)
least-event existence ≠ computable first-event function
library principle ≠ permanent FDHT API
generic minimality ≠ concrete k=1 result
standard-library theorem ≠ new FDHT mathematics
Classical.choice ≠ constructive search
OPEN ≠ FALSE
```

## Governing rule

Event existence implies least-event existence via Nat well-foundedness and `WellFounded.has_min`. Generic event existence and computability remain OPEN. No new ontology is introduced.

Trust the maths.
