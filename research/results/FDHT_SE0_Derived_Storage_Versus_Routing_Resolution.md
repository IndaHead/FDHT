# FDHT SE₀: Derived-Structure Storage Versus Routing Resolution

## Classification

C — EXACT ADDRESS USES LESS OR EQUAL MEASURED STORAGE; SHARPER ROUTING RESOLUTION

## Summary

Within one frozen 64-occurrence source and one canonical serialisation scheme, the exact-address structure uses less measured storage and has sharper routing resolution than the depth-2 VRRD structure. Zero live requests were issued.

## Storage comparison

| Metric | Exact Address | VRRD (depth-2) | Ratio |
|---|---|---|---|
| Canonical serialised bytes | 3071 | 5120 | 1.667× |
| Bytes per source occurrence | 47.98 | 80.00 | 1.667× |
| Candidate fraction | 0.015625 | 0.125 | 8× coarser |
| Query source inspections | 1 | 6 | 6× more |

## Logical structure

| Component | Exact Address | VRRD |
|---|---|---|
| Identity keys | 64 | 0 |
| Prefix keys | 0 | 8 |
| Address references | 64 | 0 |
| Range descriptors | 0 | 8 |
| Derived references | 0 | 64 |
| Structure nodes | 64 | 8 |

## Build and validation

| Metric | Exact Address | VRRD |
|---|---|---|
| Build source inspections | 64 | 64 |
| Full validation source inspections | 64 | 64 |

## Core result

Exact Address is smaller and has finer routing resolution than VRRD for this fixture. VRRD pays storage overhead for derived-order references and range descriptors.

## Integrity

- Network/API requests: 0
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Claims explicitly NOT established

- Asymptotic storage complexity
- In-memory footprint
- Runtime reduction
- Compute reduction
- Scaling with source size
- Scaling with prefix depth
- Repeated-query amortisation
- Generic superiority
- Trajectory-projection compression
- Permanent FDHT pressure
- New mathematics
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
