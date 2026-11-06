# Probe Index

| Name | Backlog | Status | Original Path | Archived Path | SHA256 | Compile Exit | Trust | Promoted |
|------|---------|--------|---------------|---------------|--------|--------------|-------|----------|
| n6_halfpower_probe | #14 | PROMOTED HISTORICAL FIXTURE | /tmp/n6_halfpower_probe.lean | research/probes/backlog_14/n6_halfpower_probe.lean | 3fd04cecab5a3391037fdc3d976b6e0af46f4f15171e99baf176e9a9db997d72 | 0 (after API-drift adaptation) | [propext, Quot.sound] | YES (fdht/FDHTEvenCycleRegression6.lean) |
| n8_halfpower_probe | #14 | PROMOTED HISTORICAL FIXTURE | /tmp/n8_halfpower_probe.lean | research/probes/backlog_14/n8_halfpower_probe.lean | d969560ec7932a2d144b91957bbb5a954499d172b270e3bf8b69b5cdc61c9b21 | 0 (after API-drift adaptation) | [propext, Quot.sound] | YES (fdht/FDHTEvenCycleRegression8.lean) |
| fdht_neighbourhood_transport_probe | #15D | PROBE VERIFIED | /tmp/fdht_neighbourhood_transport_probe.lean | research/probes/backlog_15/fdht_neighbourhood_transport_probe.lean | 2b182702b6c3f0ecab27a61d518ffc92963032ba23b9ed9e2a439a75876743a4 | 0 | no axioms / [propext] | NO |
| fdht_reachability_transport_probe | #15E | PROBE VERIFIED | /tmp/fdht_reachability_transport_probe.lean | research/probes/backlog_15/fdht_reachability_transport_probe.lean | 14b992111e353c6117281e5db918d6d3397c4ee5b0011d8b3e267465793d61d3 | 0 | no axioms / [propext] | NO |

## Unrecovered

| Probe | Status |
|-------|--------|
| n2_no_early_return | HISTORICAL PROBE REFERENCED; EXACT ARTEFACT UNRECOVERED |
| n4_coordinate_table_no_early_return | HISTORICAL PROBE REFERENCED; EXACT ARTEFACT UNRECOVERED |

## Backlog #16 — Projected Nonidentity

**Status:** CLOSED (research probe only)  
**Authority:** RESEARCH PROBE ONLY  
**Promotion:** NOT PROMOTED

### Summary

#16A: Minimal separation audit. Carrier-level nontriviality identified as candidate.

#16B: Moved-family indicator bridge compiled. Footprint: `[propext, Quot.sound]`.

#16C: Constructive moved-coordinate extraction compiled. Classical.choice eliminated.

#16D: End-to-end direct generic conditional theorem compiled. No permanent consumer.

#16E: Shared resolverSeparationWitness carrier witness instantiated generic theorem for n=4/6/8.

### Archived Probes

- [backlog_16/HEADER.md](backlog_16/HEADER.md)
- [backlog_16/constructive_moved_coordinate_probe.lean](backlog_16/constructive_moved_coordinate_probe.lean)
- [backlog_16/projectedAction_moved_probe.lean](backlog_16/projectedAction_moved_probe.lean)
- [backlog_16/end_to_end_projected_nonidentity_probe.lean](backlog_16/end_to_end_projected_nonidentity_probe.lean)
- [backlog_16/shared_carrier_witness_n4_n6_n8_probe.lean](backlog_16/shared_carrier_witness_n4_n6_n8_probe.lean)

### Trust Footprint

All preferred theorems: `[propext, Quot.sound]`

Classical.choice: ABSENT  
sorryAx: ABSENT
