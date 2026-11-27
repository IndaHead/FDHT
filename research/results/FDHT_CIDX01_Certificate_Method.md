# FDHT CIDX-01 Certificate Method

## Method
1. Freeze protocol before execution.
2. Reuse exact FSB-01 deterministic source generator; verify digests.
3. Build ExactIndex (mirroring frozen A2).
4. Construct certificate binding sourceDigest, indexDigest, builderDigest, length, domain, canonicalisation.
5. Validate dispositions: CERT_VALID or specific mismatches.
6. Treatments: T0 oracle, T1 full-scan absence, T2 uncertified empty (insufficient), T3 certified absence (local if valid), T4 certified presence.
7. Attacks: stale source, omitted key (and others conceptually).
8. Measure source-record inspections separately from metadata operations.
9. Trust models M0 (self-verified) and M1 (external claim, no authority).

## Firewall
Digest = integrity binding only. No security certification. No amortisation claims.
