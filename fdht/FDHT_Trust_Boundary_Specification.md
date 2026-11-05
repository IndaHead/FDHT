# FDHT v3.1 Formal Trust-Boundary Specification

**Status:** Verified selected public mathematical surface  
**Toolchain:** Lean 4.35.0  
**Source baseline:** 68 Lean sources readable in audited session  
**Source holes:** `sorry = 0`, `admit = 0`, custom axiom declarations `= 0`  
**Frozen direct projected-action surface:** **CERTIFIED**

---

## 1. Purpose

This specification records the logical dependency boundaries of the audited FDHT public mathematical surface.

The objective is **not** to classify every dependency as good or bad.

The objective is to preserve provenance:

```text
theorem
   ↓
supporting declarations
   ↓
logical assumptions
   ↓
trust boundary
```

In FDHT terms:

> **The provenance of a proof is part of the information carried by the proof.**

A theorem's conclusion and its dependency trajectory are therefore recorded separately.

---

## 2. Trust strata

The audited surface separates naturally into five trust strata.

### T0: Structural / dependency-free

Representative declarations:

```text
ResolverDistinguishesAt
ResolverSeparates

Nat.repeat_apply_commute

ThreadPermutation.HasFinitePeriod
ThreadPermutation.Nontrivial

identityThreadPermutation
composeThreadPermutation
ThreadPermutation.inverse
```

Audited dependency set:

```text
[]
```

### Interpretation

These declarations introduce or manipulate structural data without relying on the audited quotient, extensionality or witness-selection assumptions.

---

### T1: Quotient boundary

The dominant foundational FDHT dependency is:

```text
Quot.sound
```

Representative surface:

```text
FoldKernel
trajectoryProjection

FamilyClassifierFactorsThroughProjections
familyClassifier_factorisation_implies_invariant

FoldKernelQuotientNontrivial
returnsTo_iff_foldKernel
```

Most importantly, the frozen direct projected calculus lies here:

```text
ThreadPermutation.projectedAction
ThreadPermutation.projectedAction_id
ThreadPermutation.projectedAction_comp
ThreadPermutation.projectedAction_inverse
ThreadPermutation.projectedAction_left_inverse
ThreadPermutation.projectedAction_right_inverse
ThreadPermutation.projectedAction_repeat_apply
ThreadPermutation.projectedAction_hasFinitePeriod
ThreadPermutation.projectedAction_projection
```

Dependency:

```text
[Quot.sound]
```

### Interpretation

This is the central quotient reasoning boundary.

Informally:

```text
representatives
     ↓
equivalence relation
     ↓
quotient equality
```

The presence of `Quot.sound` is therefore structurally consistent with FDHT's quotient-based trajectory semantics.

It does **not** indicate witness selection.

---

### T2: Propositional-extensionality boundary

A second cluster introduces:

```text
propext
```

alongside quotient reasoning.

Representative declarations:

```text
ThreadPermutation.projectedAction_eq_id_of_toFun_eq

foldKernelQuotientNontrivial_iff_rawOutsideIdentityKernel

nonidentityTrajectoryExists_iff_foldKernelQuotientNontrivial

FoldKernel_congr_append

twoThreadSwap_nontrivial
threeThreadCycle_nontrivial

twoThreadSwap_hasFinitePeriod
threeThreadCycle_hasFinitePeriod
```

Dependency:

```text
[propext, Quot.sound]
```

### Interpretation

This is distinct from classical witness selection.

The audit therefore preserves:

```text
propext
≠
Classical.choice
```

A theorem crossing T2 has acquired an extensionality dependency, but has **not thereby crossed the selected-witness boundary**.

---

### T3: Explicit witness-selection boundary

The next transition is materially different:

```text
Classical.choice
```

Representative declarations:

```text
familyClassifier_factors_iff_invariant

familyClassifier_invariant_implies_factorisation

projectThreadFamily_surjective
```

Dependencies:

```text
[Classical.choice, Quot.sound]
```

The factorisation split is particularly informative.

#### Factorisation → invariance

```text
familyClassifier_factorisation_implies_invariant
```

uses:

```text
[Quot.sound]
```

#### Invariance → selected factorisation

```text
familyClassifier_invariant_implies_factorisation
```

uses:

```text
[Classical.choice, Quot.sound]
```

This establishes a formal trust distinction:

```text
already possessing / proving a factorisation
             │
             ▼
          invariance
        choice-free

             ≠

invariance
    │
    ▼
select a descended witness
    │
    ▼
Classical.choice
```

#### Architectural meaning

This is an especially strong FDHT result because it formalises:

> **Existence/property evidence and selected witness data are distinct boundaries.**

The compiler dependency graph reflects that distinction directly.

---

### T4: Inherited projected-rotation selection boundary

The rotation-side projected API inherits both witness selection and propositional extensionality.

Representative declarations:

```text
permutationRotation_projected_apply

ThreadPermutation.projectedAction_rotation_eq

ThreadPermutation.projectedAction_rotation_eq_pointwise

ThreadPermutation.projectedAction_period_independent

ThreadPermutation.rotation_projected_hasFinitePeriod
```

Dependency:

```text
[propext, Classical.choice, Quot.sound]
```

The principal audited flow is:

```text
projectThreadFamily_surjective
           │
           │ Classical.choice
           ▼
permutationRotation_projected_apply
           │
           ▼
projected permutation/rotation alignment
           │
           ├── projectedAction_rotation_eq
           ├── projectedAction_rotation_eq_pointwise
           ├── projectedAction_period_independent
           └── rotation_projected_hasFinitePeriod
```

### Interpretation

`Classical.choice` is **inherited through an identified selection operation**.

It is not an unexplained leak into the rotation theorems.

---

## 3. Frozen direct projected-action boundary

This is the most important certified perimeter.

### Frozen API

```text
ThreadPermutation.projectedAction

ThreadPermutation.projectedAction_id

ThreadPermutation.projectedAction_eq_id_of_toFun_eq

ThreadPermutation.projectedAction_comp

ThreadPermutation.projectedAction_inverse

ThreadPermutation.projectedAction_left_inverse

ThreadPermutation.projectedAction_right_inverse

ThreadPermutation.projectedAction_repeat_apply

ThreadPermutation.projectedAction_hasFinitePeriod
```

### Primary frozen laws

```text
projectedAction
                    [Quot.sound]

projectedAction_id
                    [Quot.sound]

projectedAction_comp
                    [Quot.sound]

projectedAction_inverse
                    [Quot.sound]

projectedAction_left_inverse
                    [Quot.sound]

projectedAction_right_inverse
                    [Quot.sound]

projectedAction_repeat_apply
                    [Quot.sound]

projectedAction_hasFinitePeriod
                    [Quot.sound]
```

Generic identity characterisation:

```text
projectedAction_eq_id_of_toFun_eq
                    [propext, Quot.sound]
```

### Explicitly absent

```text
Classical.choice
sorryAx
custom axioms
```

### Certification

**FROZEN DIRECT PROJECTED TRUST SURFACE CERTIFIED**

---

## 4. Frozen mathematical calculus

The certified surface establishes:

### Identity

\[
\overline{\mathrm{id}}=\mathrm{id}
\]

### Pullback composition

\[
\overline{\pi_1\circ\pi_2}
=
\bar{\pi}_2\circ\bar{\pi}_1
\]

### Inverse

\[
\overline{\pi^{-1}}
=
\bar{\pi}^{-1}
\]

in the established two-sided inverse sense.

### Iteration

\[
\bar{\pi}^{\,m}(f)(i)
=
f(\pi^m(i))
\]

### Finite-period transport

\[
\pi.\mathrm{HasFinitePeriod}(k)
\Longrightarrow
\bar{\pi}^{\,k}(f)=f.
\]

None of these primary results crosses the `Classical.choice` boundary.

---

## 5. Concrete regression boundary

The trust surface is backed by qualitatively different regression fixtures.

### n = 2

Involutive swap:

```text
composition     PASS
period 2        PASS
```

### n = 3

Genuinely non-involutive cycle:

```text
(f0,f1,f2)
    ↓
(f1,f2,f0)
    ↓
(f2,f0,f1)
    ↓
(f0,f1,f2)
```

Regression status:

```text
one-step orientation      PASS
two-step orientation      PASS
period 3                  PASS
inverse distinctness      PASS
```

The n=3 fixture protects against accidentally validating only involutive permutation behaviour.

---

## 6. Factorisation trust boundary

The audited classifier API provides another clean boundary.

```text
FamilyClassifierFactorsThroughProjections
        │
        │ [Quot.sound]
        ▼
factorisation → invariance
```

The reverse direction:

```text
invariance
     │
     │ selected descended classifier
     ▼
factorisation
```

crosses:

```text
[Classical.choice, Quot.sound]
```

Yet the equivalence theorem:

```text
familyClassifier_factors_iff_invariant
```

inherits that classical selection dependency because one implication selects the descended witness.

### Trust classification

```text
factorisation → invariance
    foundational quotient surface

invariance → factorisation
    witness-selection surface

iff packaging
    inherits strongest required boundary
```

---

## 7. Resolver-separation boundary

These definitions have no audited axiom dependencies:

```text
ResolverDistinguishesAt        []
ResolverSeparates              []
```

This is useful because resolver dependence enters the formal language without itself requiring quotient soundness or classical witness selection.

However, downstream theorems using quotient equality may acquire stronger dependencies.

Therefore preserve:

```text
resolver-dependent predicate
≠
theorem proved using resolver + quotient
```

---

## 8. Current dependency topology

The selected audited public surface can be represented as:

```text
                 T0
           STRUCTURAL CORE
                  []
                   │
       ┌───────────┴───────────┐
       │                       │
       ▼                       ▼
 resolver predicates     permutation structure
                           recurrence predicates
       │                       │
       └───────────┬───────────┘
                   ▼
                  T1
            QUOTIENT SURFACE
              [Quot.sound]
                   │
       ┌───────────┼────────────┐
       │           │            │
       ▼           ▼            ▼
  FoldKernel   trajectory    frozen direct
                semantics    projected calculus
                   │
                   ▼
                  T2
        PROPOSITIONAL EXTENSIONALITY
          [propext, Quot.sound]
                   │
                   ▼
                  T3
            WITNESS SELECTION
     [Classical.choice, Quot.sound]
                   │
                   ▼
                  T4
       ROTATION PROJECTED ALIGNMENT
  [propext, Classical.choice, Quot.sound]
```

This is the current formal trust gradient.

---

## 9. Explicit Classical.choice provenance

The source scan identified textual uses in:

```text
AggregateFamilyTransform.lean
ClassifierFactorisation.lean
FDHTProjectedRotation.lean
FDHTThreadFamilyFirstIso.lean
```

The audited public dependency flows include:

```text
familyClassifier_invariant_implies_factorisation
        ↓
Classical.choose
        ↓
Classical.choice
```

and:

```text
projectThreadFamily_surjective
        ↓
Classical.choice
        ↓
permutationRotation_projected_apply
        ↓
projected rotation alignment
```

This means classical selection is **localised**, rather than indiscriminately present across the selected mathematical surface.

---

## 10. Integrity status

Current source-integrity baseline:

```text
Lean                 4.35.0
Lean sources         68 readable
syntax integrity     restored
rebuild              PASS
sorry                0
admit                0
custom axioms        0
```

Frozen permutation source remained unchanged by the source-integrity repair.

No audited frozen theorem contains:

```text
sorryAx
custom axioms
Classical.choice
```

---

## 11. Semantic trust firewall

This audit reinforces these FDHT distinctions:

```text
Quot.sound dependency
    ≠ Classical.choice dependency

propext dependency
    ≠ Classical.choice dependency

Prop-valued property
    ≠ selected Type-valued witness

factorisation existence/property
    ≠ selected descended classifier

valid period
    ≠ minimal order

raw nontriviality
    ≠ projected nontriviality

resolver-relative distinction
    ≠ universal distinction

formal rotation
    ≠ physical rotation
```

None should be collapsed in subsequent documentation or API design.

---

## 12. Audit limitations

This specification is **formal for the selected audited public surface**.

It is deliberately **not described as an exhaustive repository-wide public declaration audit**, because additional exported theorems exist beyond the selected matrix.

Therefore:

```text
CERTIFIED:
    selected trust-critical public surface
    frozen projected-action surface

NOT YET CLAIMED:
    exhaustive #print axioms coverage
    of every exported theorem/lemma
    across all 68 source files
```

That distinction is mandatory.

---

## 13. Formal trust classification

### No dependency

```text
[]
```

**Meaning:** no audited axiom dependency reported.

### Quotient boundary

```text
[Quot.sound]
```

**Meaning:** proof/data surface relies on quotient equality.

### Extensionality boundary

```text
[propext, Quot.sound]
```

**Meaning:** quotient reasoning plus propositional extensionality.

### Selection boundary

```text
[Classical.choice, Quot.sound]
```

**Meaning:** explicit or inherited witness selection in addition to quotient reasoning.

### Rotation-selection boundary

```text
[propext, Classical.choice, Quot.sound]
```

**Meaning:** projected rotation/alignment result inherits both extensional and classical selection dependencies.

---

## 14. Final finding

**No unexpected trust-boundary regression was detected on the selected audited surface.**

More strongly:

**The frozen direct projected-action API remains choice-free and trust-certified.**

The selected audit shows a structured dependency gradient rather than an undifferentiated use of classical reasoning:

```text
structural
      ↓
quotient
      ↓
extensional
      ↓
selected witness
      ↓
rotation-side projected alignment
```

That is architecturally consistent with FDHT's governing rule:

> **Preserve distinctions until sufficient evidence justifies collapse.**

The trust assumptions themselves remain distinguished and traceable.

### Formal classification

**FDHT v3.1 SELECTED PUBLIC TRUST SURFACE AUDITED — DOCUMENTED CLASSICAL BOUNDARIES PRESENT**

with:

**FROZEN DIRECT PROJECTED-ACTION TRUST SURFACE CERTIFIED.**

One caveat is deliberately retained: **selected public surface ≠ exhaustive public surface**. The next trust-audit milestone, if required, is exhaustive `#print axioms` coverage of every exported theorem and lemma across the 68-source tree.
