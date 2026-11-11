# FDHT Observation Inventory — DFT0

## Existing Permanent Observation Surfaces

### 1. trajectoryProjection

| Property | Value |
|----------|-------|
| Qualified name | KernelExprContext.trajectoryProjection |
| Type | (KernelExpr → Store → Location) → List KernelExprContext → TrajectoryBoundary resolve |
| Source | fdht/FDHT_Audit_ArbitraryCollision.lean (via FDHTTrajectoryAPI) |
| Assumptions | resolve : KernelExpr → Store → Location |
| Resolver dependence | YES |
| Quotient | FoldKernel setoid |
| Codomain | TrajectoryBoundary resolve |
| Finite fixture | YES (for finite histories) |

### 2. ThreadPermutation.projectedAction

| Property | Value |
|----------|-------|
| Qualified name | ThreadPermutation.projectedAction |
| Type | ThreadPermutation n → ThreadFamily resolve n → ThreadFamily resolve n |
| Source | fdht/FDHTPermutationRotation.lean |
| Assumptions | n : Nat, resolve |
| Resolver dependence | YES |
| Quotient | ThreadFamilyKernel |
| Codomain | ThreadFamily resolve n |
| Finite fixture | YES |

## Selected Observation Surface

**trajectoryProjection**

Rationale: Most fundamental FDHT observation. Deterministic under frozen resolver. Applicable to finite histories. Does not include external consumer result.

Observation tuple: O(xs) = trajectoryProjection resolve xs
Observational equivalence: ObsEq xs ys := O(xs) = O(ys)
