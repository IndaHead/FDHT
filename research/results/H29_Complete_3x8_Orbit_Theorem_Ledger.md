# H29 — Complete 3×8 Orbit Theorem Ledger

## A. Classification

H29 — VERIFIED FINITE 3×8 ORBIT SYNTHESIS

## B. Evidence class

Lean-verified probe-local research.
NOT permanent mathematics.

## C. Repository baseline

- Branch: main
- HEAD: `0e378c044edacd6adec1e40fc426abb5d5680a65`

## D. Exact frozen carrier

`Fin 3 × Fin 8`

## E. Component first-return results

- `threeThreadCycle`: first positive return 3 from every Fin-3 state
- `eightThreadCycle`: first positive return 8 from every Fin-8 state

## F. Exact component coherence

- One-step projection equality for Fin 3
- One-step projection equality for Fin 8
- Iterated projection equality for Fin 3
- Iterated projection equality for Fin 8

## G. Exact product reconstruction

`step3x8 = existingCycleProduct`

## H. Full trajectory reconstruction

`Nat.repeat step3x8 k p = (Nat.repeat threeThreadCycle.toFun k p.1, Nat.repeat eightThreadCycle.toFun k p.2)`

## I. Joint first-return result

First positive return 24 from every JointState origin.

## J. Joint orbit result

- Injective first-24 map from every origin
- Surjective first-24 map from every origin
- Therefore bijective first-24 map from every origin

## K. Trust summary

- Direct probe compile: EXIT 0
- lake build: EXIT 0 (49 jobs)
- Strict audit: PASS
- sorryAx: ABSENT
- Classical.choice: ABSENT
- Custom axioms: ABSENT

Relevant H29-E/E7 theorem footprints: `[propext, Quot.sound]`

## L. Probe SHA-256 inventory

- H29-E (component coherence): `a6d8f7ac4a8362c18dda83017884ce4c64023895aad5832f6f958e968c6e71d7`
- H29-E7 (component first-return): `35c474cad6ec0df9060453c6f7b61f50c9a7080ac0af6f81964f889ca8f9a2bb`
- H29-DI-F (all-origin injectivity): `707f2e538e73d39ac0db288c6f03ce0d02e2101461d4892119433201588914ca`
- H29-DS-R (all-origin surjectivity): `e147cbb0222ceefc64407ce9b2779807c17069836ccc6f541873fdb1e3262179`

## M. New mathematics required

NO

## N. New foundational abstraction required

NO

## O. Permanent FDHT pressure

NO

## P. Promotion justified

NO

## Finite synthesis

Within the frozen H29 probe-local Fin 3 × Fin 8 specimen, the synchronized joint action is extensionally the product of the independently pre-existing FDHT threeThreadCycle and eightThreadCycle actions.

The component actions have first positive returns 3 and 8 respectively from every component state.

The joint action has first positive return 24 from every joint origin.

From every joint origin, the first 24 positions are pairwise distinct and cover the complete Fin 3 × Fin 8 carrier, hence form a bijective complete 24-state orbit.

## Explicit non-claims

H29 does NOT establish:

- Generic coprime-product theorem
- Generic LCM/joint-period theorem
- Mechanism: 3 and 8 imply 24
- CRT as required FDHT machinery
- Universal privilege of 3
- Universal privilege of 8
- Universal privilege of 24
- Relation to H27's eight-world fixture
- Spiral geometry
- Staircase geometry
- Geometric necessity
- n = 360
- Physical interpretation
- Universal FDHT orbit mathematics
- Permanent FDHT architectural necessity

## Provenance

Archived at repository HEAD `0e378c044edacd6adec1e40fc426abb5d5680a65`.
Probe-local only. Permanent FDHT source unchanged.
