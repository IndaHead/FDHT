# FDHT Provenance Audit API — Composition Boundary Audit

## Classification

FDHT PROVENANCE CERTIFICATES HAVE MIXED COMPOSITION BEHAVIOUR;
KEEP COMPOSITION EXPLICIT

## Established boundary

- `sameRaw`: equality transports normally.
- `projectedDistinct`: NOT preserved under arbitrary continuation.
- `collapsed`: projected equality may transport by congruence, but raw
  distinctness does not automatically transport.
- `CollapseCertificate`: reconstruction obstruction is pair-specific and
  is not automatically transported.
- `ObservableFactorisationCertificate`: factorisation through projection
  does not imply invariance under an additional transformation.
- `DistinguishingResolveCertificate`: remains resolver-specific and does
  not generalise under composition.

## Counterexample leverage

The concrete nonidentity idempotent trajectory under
`distinguishingResolve` refutes the universal claim that projected
distinction survives arbitrary continuation.

Preserve:

current distinction ≠ future distinction
current collapse ≠ permanent collapse
factorisation ≠ transformation invariance
resolver-specific ≠ universal

## Reversible projected actions

Existing `ThreadPermutation.projectedAction` inverse laws make
injectivity / inequality preservation derivable for reversible projected
actions.

This is classified as packaging-level leverage only.

No new foundational mathematics is required.

No composition helper is currently required.

## API decision

**KEEP COMPOSITION EXPLICIT**

Do not add a generic certificate-transport API.

Optional future ergonomic theorem:

`ThreadPermutation.projectedAction_injective`

may be packaged if a concrete downstream consumer requires it.

It is not currently required.

## Trust / verification

- `lake build`: EXIT 0
- strict FDHT axiom audit: PASS
- source modified during audit: NO
- new foundational mathematics: NO
- missing mathematical bridge: NONE

## Governing rule

A certificate proves exactly what its evidence establishes at its
current boundary.

Transformation does not automatically preserve that certificate.

**What survives the transformation must itself be proved.**

Trust the maths.

STOP.
