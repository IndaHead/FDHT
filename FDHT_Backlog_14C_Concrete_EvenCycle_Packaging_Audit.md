# FDHT Backlog #14C — Concrete Even-Cycle → Inline No-Early-Return Packaging Audit

## Status

**#14C AUDIT RECORDED.**

## Base commit

`d505c33b513579cf3d5072873e1020f8730151c2`

## Temporary probe

`/tmp/n2_no_early_return.lean`

## Summary

The existing FDHT primitives can express the inline pointwise
no-early-return contract without a new `PointwiseExactPeriod` predicate.

The committed n=2 fixture remains incomplete at the no-early-return proof
level and therefore is NOT accepted as a new theorem.

The temporary n=2 proof carries `sorryAx`.

Under the governing FDHT rule:

**if it doesn't pass Lean, it dies.**

Therefore the incomplete theorem is rejected and must not enter committed
source.

The previously verified n=4, n=6 and n=8 permutations remain probe-local
historical results and are not part of the committed dependency surface.

Accordingly, the higher-dimensional packaging gap is classified as:

**REPOSITORY / PROVENANCE GAP**

not:

**MATHEMATICAL BRIDGE**

No new foundational mathematics is required.

No new predicate is justified.

No permanent API is justified by this audit.

## Exact status

| Item | Status |
|------|--------|
| n=2 committed permutation | PRESENT |
| n=2 inline no-early-return theorem | NOT ACCEPTED |
| Reason | temporary proof incomplete / sorryAx |
| n=4 committed permutation | ABSENT |
| n=6 committed permutation | ABSENT |
| n=8 committed permutation | ABSENT |
| PointwiseExactPeriod definition | NOT REQUIRED |
| New foundational mathematics | NONE |
| Missing mathematical bridge | NONE |
| Packaging classification | REGRESSION-ONLY JUSTIFIED |

## Verification record

Temporary probe command:

```
LEAN_PATH=".lake/build/lib/lean:fdht" \
lean /tmp/n2_no_early_return.lean
```

Temporary probe EXIT: **1**

Failure classification: **LOCAL PROOF GAP**

The incomplete temporary theorem reported:

```
[propext, sorryAx, Quot.sound]
```

This theorem is REJECTED.

Repository verification:

- `lake build`: EXIT 0
- strict axiom audit: PASS
- Tracked source modified during audit: NO
- Documentation modified during audit: NO
- git status: GENERATED ARTEFACTS ONLY

## Provenance firewall

```
verified temporary probe ≠ committed reusable fixture
historical probe result ≠ current dependency
local proof gap ≠ mathematical impossibility
absence from committed source ≠ false theorem
sorryAx ≠ accepted FDHT proof
packaging gap ≠ foundational mathematics gap
```

## Hard mathematical boundary

The successful #14B result is preserved:

The inline no-early-return hypothesis is sufficient for the generic
half-power fixed-point-free theorem.

No `PointwiseExactPeriod` predicate is required.

However, the current committed source does not yet provide the complete
fixture-level evidence required to instantiate that generic contract
across n=2,4,6,8.

Therefore:

**THE GENERAL CONTRACT SURVIVES.**

**THE PERMANENT REGRESSION PACKAGING DOES NOT YET EXIST.**

## Final classification

**CONCRETE n=2,4,6,8 PACKAGING GAP IS A REPOSITORY / PROVENANCE BOUNDARY; NO NEW PREDICATE OR FOUNDATIONAL MATHEMATICS JUSTIFIED**

STOP.
