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

## Evidence and audit summary

Repository: IndaHead/FDHT

Branch: research/agent-ah0-r4-contract

SE₀ starting HEAD: 5cda43651a570c85a04d9b9daa037e7f4c310fce

SE₀ result commit: a37d0a363e1b7d61572ca3b2288642f4062f7e44

SE₀ result file: research/results/FDHT_SE0_Derived_Storage_Versus_Routing_Resolution.md

Original SE₀ push status: SUCCESS

Permanent fdht/ changes: NONE

### Frozen fixture

- Source occurrences: 64
- Requirement: ac05

### Exact-address results

- Canonical serialised bytes: 3071
- Candidate fraction: 1/64 = 0.015625
- Query source inspections: 1
- Build source inspections: 64
- Full-validation source inspections: 64

### VRRD depth-2 results

- Canonical serialised bytes: 5120
- Storage ratio relative to exact: 1.667×
- Candidate fraction: 8/64 = 0.125
- Query source inspections: 6
- Build source inspections: 64
- Full-validation source inspections: 64

### Bounded result

Within the frozen 64-occurrence source and canonical serialisation, exact addressing used less measured derived storage, provided sharper routing resolution, and required fewer query source inspections than depth-2 VRRD.

VRRD's coarser range representation produced no compensating storage advantage in this fixture.

Coarser routing resolution does not imply smaller derived structure.

### Audit outcomes

- lake build: EXIT 0
- strict trust/axiom audit: PASS
- sorryAx: ABSENT
- new Classical.choice footprint: not introduced
- custom axioms: ABSENT
- fdht/ changed: NO
- network/API requests: 0
- XAI_API_KEY accessed: NO
- push: SUCCESS

### Command provenance

SE₀ preserves the audit outcomes but does not preserve complete literal command provenance for every audit step. No command line is reconstructed as historical execution evidence.

### Evidence boundary

SE₀ does NOT establish:

- asymptotic storage complexity;
- in-memory or heap footprint;
- runtime reduction;
- compute reduction;
- scaling with source size;
- scaling with prefix depth;
- repeated-query amortisation;
- cache behaviour;
- generic superiority of exact addressing;
- generic inferiority of VRRD;
- trajectory-projection storage compression;
- permanent FDHT pressure;
- new mathematics;
- promotion.

Trajectory projection is a semantic quotient, not an established physical storage-compression mechanism.
