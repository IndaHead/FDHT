# FDHT TG₀: Temporal Graph Information-Fate Survey

## Classification

B — MULTIPLE EXTERNAL TRANSFORMATION CANDIDATES LOCATED

## Summary

TGN, TGAT, and CAW-N expose distinct information-fate boundaries. TGN maintains persistent per-node memory updated by events. TGAT constructs representations from temporal neighbourhoods at query time. CAW-N samples temporal walks and anonymises node identities. These are architectural analogues, not FDHT equivalences. Zero live requests were issued.

## Architecture dispositions

| Architecture | Disposition | Persistence model |
|---|---|---|
| TGN | EXPERIMENT_CANDIDATE | PERSISTENT_MEMORY_CENTRED |
| TGAT | EXPERIMENT_CANDIDATE | QUERY_TIME_NEIGHBOURHOOD_CENTRED |
| CAW-N | EXPERIMENT_CANDIDATE | TRAJECTORY_SAMPLING_CENTRED |

## TGN

**Task**: Dynamic link prediction, node classification

**Pipeline**: timed event → message → memory update → embedding → prediction

**Persistence**: Per-node memory vector updated after each event

**Information carriers**: Event history (RAW_SOURCE), node memory (PERSISTENT_STATE), embeddings (EMBEDDING)

**Candidate boundaries**:
- B-TGN-1: history → message (EXPLICIT_TRANSFORMATION)
- B-TGN-2: messages → memory (LEARNED_UPDATE)
- B-TGN-3: memory + neighbourhood → embedding (EXPLICIT_AGGREGATION)
- B-TGN-4: embedding → prediction (READOUT)

**Active-frontier pressure**: NATURAL_EXTERNAL_PRESSURE (memory growth vs history growth)

## TGAT

**Task**: Link prediction, node classification

**Pipeline**: temporal neighbourhood → time encoding → attention → embedding → prediction

**Persistence**: No persistent memory; representations constructed at query time

**Information carriers**: Temporal neighbourhood (SELECTED_CONTEXT), time encoding (TRANSFORMED_STATE), embeddings (EMBEDDING)

**Candidate boundaries**:
- B-TGAT-1: history → sampled temporal neighbourhood (EXPLICIT_SELECTION)
- B-TGAT-2: neighbourhood + time encoding → attention input (EXPLICIT_TRANSFORMATION)
- B-TGAT-3: attention aggregation → embedding (EXPLICIT_AGGREGATION)
- B-TGAT-4: embedding → prediction (READOUT)

**Active-frontier pressure**: NATURAL_EXTERNAL_PRESSURE (neighbourhood sampling budget)

## CAW-N

**Task**: Link prediction

**Pipeline**: temporal walks → anonymisation → encoding → aggregation → prediction

**Persistence**: No persistent memory; walks sampled per prediction

**Information carriers**: Temporal walks (SAMPLED_TRAJECTORY), anonymous walks (ANONYMISED_REPRESENTATION), embeddings (EMBEDDING)

**Candidate boundaries**:
- B-CAW-1: history → sampled temporal walks (STOCHASTIC_SAMPLING)
- B-CAW-2: walks → anonymous walks (EXPLICIT_ANONYMISATION)
- B-CAW-3: anonymous walks → encoded representation (EXPLICIT_TRANSFORMATION)
- B-CAW-4: encoded representation → prediction (READOUT)

**Active-frontier pressure**: NATURAL_EXTERNAL_PRESSURE (walk sampling budget)

## FDHT correspondence

| External | FDHT | Classification |
|---|---|---|
| event history | history | STRUCTURAL_ANALOGUE |
| memory update | transformation | STRUCTURAL_ANALOGUE |
| node memory | persistent state | STRUCTURAL_ANALOGUE |
| temporal neighbourhood | inspected frontier | PARTIAL |
| attention aggregation | active frontier | ARCHITECTURAL_ANALOGUE_ONLY |
| temporal walk | trajectory | STRUCTURAL_ANALOGUE |
| anonymous walk | quotient/projection | STRUCTURAL_ANALOGUE |
| embedding | transformed representation | STRUCTURAL_ANALOGUE |
| prediction task | consumer | NO_MATCH |

## Claims explicitly NOT established

- Architectural equivalence to FDHT
- Active-frontier equivalence
- Representation invertibility
- Information loss from dimensionality
- Consumer sufficiency from benchmark accuracy
- Permanent FDHT pressure
- New mathematics
- Promotion

## Integrity

- Network/API requests: 3 (web_search)
- XAI_API_KEY accessed: NO
- fdht/ changed: NO
- lake build: EXIT 0
- Strict axiom audit: PASS

## Permanent FDHT pressure

NO

## Promotion justified

NO

## Next transition

STOP
