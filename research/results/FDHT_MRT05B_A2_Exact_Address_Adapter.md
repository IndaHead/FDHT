# FDHT MRT-05B: A2 Exact-Address Domain Adapter

## Classification

B — A2 COMPOSITE ADAPTER VERIFIED; CANDIDATE ADDRESSING ALONE IS CONSUMER-LIMITED

## Summary

A2 exact addressing instantiates the generic transformation T. Candidate addressing is sufficient for identity membership and multiplicity. Candidate addressing is insufficient for complete record and provenance consumers. Source-threaded verification is sufficient for the declared identity outcome. Zero live requests were issued.

## Adapter results

| Cell | T | C | Result |
|---|---|---|---|
| C0 membership | candidateT | identity membership | SufficientFor (structural) |
| C1 multiplicity | candidateT | identity multiplicity | SufficientFor (structural) |
| C2 complete record | candidateT | complete record | ObservableLoss |
| C3 provenance | candidateT | provenance | ObservableLoss |
| C4 verified identity | verifiedQueryT | identity outcome | SufficientFor (structural) |
| C5 verified record | verifiedQueryT | complete record | SufficientFor (structural) |

## Key negative results

C2 and C3 establish that candidate addressing alone does not determine complete source-record content. Two source states with identical identity-position structure but differing payload/provenance produce equal candidate representations but unequal complete records.

## Source carrier

- SourceRecord: recordId, exactIdentity, payload, lineage
- SourceState: List SourceRecord
- ExactIndex: Identity → List Position
- candidateT: SourceState → List Position

## Trust footprint

- C2, C3: native_decide (custom axiom)
- Positive results: structural observations
- fdht/ changed: NO

## Absorption classification

COMPOSITE_ADAPTER_ESTABLISHED

## Claims explicitly NOT established

- Permanent Address mathematics
- Retrieval identity
- Retrieval depth
- Generic retrieval semantics
- Generic memory semantics
- Universal exact-index sufficiency
- Source-record reconstruction from address alone
- Payload or provenance preservation from address alone
- Runtime reduction
- Generic amortisation
- Permanent FDHT pressure
- Promotion

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
