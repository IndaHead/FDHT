# FDHT CERTMEM-01 Six-Class Memory → Certification Absorption Test

## Classification
A — SIX EXISTING MEMORY CLASSES ABSORB CERTIFICATION; NO SEVENTH CLASS REQUIRED

## Summary
The ten frozen certification obligations (O1–O10) from CIDX-01 are expressible via the existing six memory classes:

- ObservationRecord supplies source/index observations.
- ClaimRecord supplies the scoped completeness/absence claim.
- EvidenceRecord supplies supporting validation evidence.
- NegativeRecord preserves invalidating conditions (stale, mismatch, etc.).
- ObjectiveRecord binds the consumer requirement.
- CheckpointRecord binds current state/version.

A research-local CertificationProjection derives CertificateState solely from MemoryState6. Primary fixture yields CERTIFIED_VALID → CertifiedAbsent.

Controls confirm:
- Claim without evidence → STOP_INSUFFICIENT_EVIDENCE.
- Applicable negative → fails closed (does not yield CertifiedAbsent).
- Authority promotion blocked.
- No seventh-class pressure.

Certificate is a consumer-relative derived projection, not a seventh persistent memory class. No fdht/ modification. No redesign of memory or certification.

## Claim boundary
Within the frozen certification workload only. Does not establish permanent mathematics or external authority.
