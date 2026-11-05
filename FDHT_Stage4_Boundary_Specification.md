# FDHT Stage 4 Boundary Specification

## Survival, Collapse and Reconstruction

## Section 1 — Status

STAGE 4 FIRST MATHEMATICAL BOUNDARY: VERIFIED

This boundary establishes a precise implication from:

- distinct raw histories

- equal trajectory projection

to:

- impossibility of one exact recovery function reconstructing both histories from that common projected observation.

The result is about exact reconstruction from projected state. It is not a theorem of deletion or non-existence.

## Section 2 — Existing Substrate

The Stage 4 probe found substantial existing information-boundary machinery.

`HistoryInvariant` and `HistoryObservableInvariant` already capture invariance/survival-style semantics for Prop-valued and Type-valued properties respectively.

`RawHistoryRecoverable` and `raw_history_not_recoverable` already provide the global reconstruction boundary.

Therefore Stage 4 did NOT introduce:

- `Determines`
- `PairCollapses`
- `InformationLoss`
- `InformationFate`

This is deliberate.

## Section 3 — First Missing Boundary

The missing joint was a local quantifier-explicit reconstruction obstruction for arbitrary distinct raw histories in one trajectory projection fibre.

```lean
theorem collapsed_pair_blocks_common_reconstruction
    (resolve : KernelExpr → Store → Location)
    (xs ys : List KernelExprContext)
    (hxy : xs ≠ ys)
    (hcollapse : toTrajectoryBoundary resolve xs = toTrajectoryBoundary resolve ys) :
    ¬ ∃ recover : TrajectoryBoundary resolve → List KernelExprContext,
      recover (toTrajectoryBoundary resolve xs) = xs ∧
      recover (toTrajectoryBoundary resolve ys) = ys
```

Proof structure: if `π(xs) = π(ys)`, then `recover(π(xs)) = recover(π(ys))`. Exact reconstruction would require `recover(π(xs)) = xs` and `recover(π(ys)) = ys`, hence `xs = ys`, contradicting `xs ≠ ys`.

This is not deletion.

## Section 4 — Concrete Swap Collision

```lean
theorem swap_pair_equals_empty_trajectory
    (resolve : KernelExpr → Store → Location) :
    toTrajectoryBoundary resolve [swapContext, swapContext] = emptyTrajectory resolve
```

Under the theorem's resolver parameter, `[swapContext, swapContext]` and `[]` have matching projected trajectories. Also `[] ≠ [swapContext, swapContext]`. Therefore a genuine raw-history distinction lies inside one projected trajectory fibre.

## Section 5 — Concrete Reconstruction Obstruction

```lean
theorem swap_pair_blocks_common_reconstruction
    (resolve : KernelExpr → Store → Location) :
    ¬ ∃ recover : TrajectoryBoundary resolve → List KernelExprContext,
      recover (toTrajectoryBoundary resolve []) = [] ∧
      recover (toTrajectoryBoundary resolve [swapContext, swapContext]) =
        [swapContext, swapContext]
```

No one recovery function of type `TrajectoryBoundary resolve → List KernelExprContext` can map the common projected observation simultaneously back to `[]` and `[swapContext, swapContext]`.

This is a concrete certified witness of exact reconstruction obstruction.

## Section 6 — Verified Implication Chain

```text
DISTINCT RAW HISTORIES
[] ≠ [swapContext, swapContext]
              │
              ▼
PROJECTED COLLISION
π([]) = π([swapContext, swapContext])
              │
              ▼
LOCAL RECONSTRUCTION OBSTRUCTION
no single decoder reconstructs both exactly
              │
              ▼
EXISTING GLOBAL RECONSTRUCTION RESULTS
RawHistoryRecoverable fails at the established global boundary.
```

Local and global results remain distinct.

## Section 7 — Definition of Collapse Used by This Document

"Collapse" describes only:

- `xs ≠ ys`
- together with `π(xs) = π(ys)`.

Explicitly:

- collapse ≠ deletion
- collapse ≠ non-existence
- collapse ≠ destruction
- collapse ≠ automatic absolute information loss
- collapse ≠ proof that every property is unrecoverable.

The proved implication is: projection collision → common exact reconstruction obstruction for the colliding pair.

## Section 8 — Survival

Observable survival concerns properties/observables invariant across the relevant historical/projection equivalence classes.

Pairwise distinction survival concerns whether two distinct raw inputs remain distinguishable after projection.

For the two-swap witness:

- raw histories: DISTINCT
- projected trajectories: EQUAL.

Therefore that particular raw distinction does not survive as a projected distinction. The histories do not cease to exist.

## Section 9 — Reconstruction Levels

Three separate reconstruction questions:

1. PAIRWISE: Can one recovery function reconstruct both members of a particular collision?
2. GLOBAL: Can one left inverse reconstruct every raw history?
3. RESTRICTED DOMAIN: Can exact reconstruction exist on some smaller domain where projection is injective?

Stage 4 establishes the pairwise obstruction. Existing FDHT results establish the global raw-history reconstruction boundary. Stage 4 does not establish failure for every possible restricted subdomain.

## Section 10 — Resolver Quantification

The swap-pair theorem is parameterised by `resolve : KernelExpr → Store → Location`. The theorem's explicit quantifiers are authoritative. This documentation does not translate the result into a broader undefined notion of absolute loss.

## Section 11 — Explicitly Unproved Claims

| Claim | Status |
|-------|--------|
| Raw information is deleted | NOT PROVED |
| Collapsed histories cease to exist | NOT PROVED |
| All semantic information is lost | NOT PROVED |
| Every raw property is unrecoverable | NOT PROVED |
| Every restricted subdomain is non-recoverable | NOT PROVED |
| Projection physically destroys information | NOT PROVED |
| Collapse proves thermodynamic irreversibility | NOT PROVED |
| Projection creates information | NOT PROVED |
| Absolute information loss has been formalised | NOT PROVED |

## Section 12 — Information Addition

STATUS: UNPROBED

New structure ≠ added information.

Future distinctions an addition probe would need to preserve:

- derived structure
- external parameter
- selected witness
- unmodelled state
- genuinely non-derivable observable.

None of these are defined in Lean during this pass.

## Section 13 — First-Collapse Localisation

STATUS: OPEN

Unresolved questions:

- Does collision persist under common extension?
- Can distinctions collapse and later reappear?
- Can the earliest collapsing prefix be proved to exist?
- What minimality principle would define first collapse?
- Does `FoldKernel_congr_append` already provide sufficient persistence?

These are not answered without new proofs.

## Section 14 — InformationFate Decision

InformationFate: NOT CREATED

Reason: current propositions already preserve the verified distinctions. No new datatype is mathematically required at this boundary.

Governing rule: preserve distinctions until sufficient evidence proves collapse is lossless.

## Section 15 — Trust Boundary

| Theorem | Axioms |
|---------|--------|
| `collapsed_pair_blocks_common_reconstruction` | [Quot.sound] |
| `swap_pair_equals_empty_trajectory` | [propext, Quot.sound] |
| `swap_pair_blocks_common_reconstruction` | [propext, Quot.sound] |

Classical.choice: ABSENT from these Stage 4 results.  
sorryAx: ABSENT.  
Custom axioms: ABSENT.

## Section 16 — Build Regression

```text
FDHT_Audit_ArbitraryCollision.lean  EXIT 0
AggregateFamilyTransform.lean       EXIT 0
FDHTPermutationRotation.lean        EXIT 0
```

Frozen trust regression: PASS.

## Section 17 — Frozen Classification

| Concept | Status |
|---------|--------|
| Observable survival | ESTABLISHED |
| Pairwise raw distinction | EXPRESSIBLE |
| Concrete projected collapse | PROVED |
| Generic local reconstruction obstruction | PROVED |
| Concrete swap-pair reconstruction obstruction | PROVED |
| Global raw-history non-recoverability | ESTABLISHED |
| Deletion | NOT PROVED |
| Non-existence | NOT PROVED |
| Absolute information loss | NOT PROVED |
| Failure on every restricted domain | NOT PROVED |
| First-collapse localisation | OPEN |
| Information-addition semantics | UNPROBED |
| InformationFate | NOT REQUIRED |

## Section 18 — Frozen Boundary Statement

Distinct raw histories may occupy the same trajectory projection fibre. When they do, no single recovery function from that common projected observation can exactly reconstruct both histories. FDHT establishes this obstruction generically and instantiates it concretely for the empty history and the two-swap history. This establishes projection collision and exact reconstruction failure, not deletion, non-existence, or an unrestricted notion of absolute information loss.

STAGE 4 FIRST SURVIVAL/COLLAPSE/RECONSTRUCTION BOUNDARY VERIFIED

## Synchronous Distinction→Collapse Event

### Verified theorem

```lean
theorem distinguishingResolve_synchronous_distinction_to_collapse :
    trajectoryProjection distinguishingResolve [exposingContext]
    ≠
    trajectoryProjection distinguishingResolve [identityContext]
    ∧
    trajectoryProjection distinguishingResolve [exposingContext, identityContext]
    =
    trajectoryProjection distinguishingResolve [identityContext, exposingContext]
```

### Frozen mathematical statement

A genuine synchronous projected distinction→collapse transition exists for `distinguishingResolve`.

```text
BEFORE:
  π([exposingContext]) ≠ π([identityContext])

AFTER INDEPENDENT NEXT STEPS:
  π([exposingContext, identityContext])
  =
  π([identityContext, exposingContext])
```

### Distinctions preserved

- projected collapse ≠ deletion
- projected collapse ≠ non-existence
- projected collapse ≠ absolute information loss
- independent continuations ≠ common continuation
- this result does NOT contradict common-extension persistence
- existence of an event ≠ first-event localisation
- existence ≠ computability
- this theorem does NOT define FirstCollapse

### Trust footprint

```text
[propext, Quot.sound]
Classical.choice: ABSENT
sorryAx: ABSENT
custom axioms: ABSENT
```

### Stage 4 status map

| Boundary | Status |
|----------|--------|
| collision/reconstruction obstruction | PROVED |
| common-continuation persistence | PROVED |
| naive first-prefix equality | DEGENERATE |
| concrete projected nonidentity | PROVED |
| projected distinction seed | PROVED |
| synchronous distinction→collapse event | PROVED |
| first-collapse localisation | OPEN |
| information addition | UNPROBED |
| InformationFate | NOT CREATED |
