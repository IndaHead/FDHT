# FDHT CIDX-01 Certified Exact-Index Absence Experiment

## Classification
A — CERTIFIED INDEX SUPPORTS QUERY-LOCAL VERIFIED ABSENCE ACROSS FULL TESTED SCALE

## Secondary
D — CERTIFICATE INTEGRITY HOLDS; EXTERNAL AUTHORITY REMAINS UNESTABLISHED (M1)

## Summary
Across the reused FSB-01 source family (N=64…16384), with digests verified identical:

- Uncertified empty lookup (T2) always returns STOP_INSUFFICIENT_EVIDENCE.
- Certified empty lookup under valid binding (T3) returns verifiedAbsent with zero source-record inspections at query time (query-local).
- Present queries (R1) remain verifiedPresent with source-record dereference.
- Semantic equivalence to oracle held for all cells.
- Selected attacks (stale source, omitted identity key) rejected by certificate validation at every scale.
- Certificate size constant (metadata only).

Integrity binding holds under M0 self-verified snapshot. M1 external claim does not establish issuer authority (no signature infrastructure).

No cryptographic security claimed. No total-efficiency claim. No fdht/ modification. FSB-01 results unaltered.

## Claim boundary
Finite-range operational result only. Does not establish permanent Address mathematics, retrieval identity, or promotion.
