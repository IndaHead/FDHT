# MRT Memory Operations Programme — Research Archive

**Status:** ARCHIVED / FROZEN  
**Authority:** RESEARCH EVIDENCE ONLY  
**Promotion:** NOT PROMOTED  
**Permanent FDHT mathematics:** UNCHANGED

## 1. Motivation

The MRT programme investigated a candidate operational decomposition of memory operations:

```text
Input
  ↓
Memorise
  ↓
Record
  ↓
Retain / Save
  ↓
persistent Store
  ↓
restart
  ↓
Recall(Requirement)
  ↓
RecallState
```

The question was whether these operations introduce genuinely necessary distinctions for a natural downstream consumer (IndaAgent001), or whether the pre-existing agent-local memory architecture already absorbs them.

## 2. Candidate operation signatures

```text
Memorise   : Input → Record
Retain     : Store → Record → Store
Recall     : Store → Requirement → RecallState
```

All results remain probe-local. No permanent Memorise / Retain / Recall API was introduced.

## 3. MRT-01

Type-level scaffold only. Three-way separation of the candidate operations was initially OPEN. No concrete behavioural witness was established at this stage.

## 4. MRT-01B — Restart separation

Concrete restart separation verified at fixture level.

- Formed-but-unretained record → restart → later requirement → MISSING
- Formed → retained → restart → same later requirement → FOUND

Additional concrete properties:

- Wrong identity rejected
- Wrong relation rejected
- Payload inert when not required
- Recall read-only with respect to Store

## 5. MRT-01C — Multi-record recall

Concrete multi-record fixtures verified:

- Multiple retained records traversed
- Unique valid match found
- Same Store + different Requirement → different correct Recall result
- Unique-match ordering inert
- Duplicate valid matches produce first-match behaviour
- Current RecallState has only `missing` and `found`; no ambiguity constructor was added

## 6. MRT-01D — Recall-only consumer pressure

No Recall-only consumer pressure for uniqueness.

Verified:

- Unique-match Store and multiple-match Store can produce identical RecallState
- Every pure function of that identical RecallState produces the same result on both observations
- A uniqueness-sensitive consumer requires information outside current RecallState

## 7. MRT-01E / MRT-01E-F — UNIQUE/MULTIPLE information-loss

Concrete UNIQUE/MULTIPLE information-loss boundary closed.

```text
Recall(storeUnique, R) = Recall(storeMultiple, R)
while
MatchClass(storeUnique) ≠ MatchClass(storeMultiple)
```

Specifically, UNIQUE ≠ MULTIPLE is an upstream Store distinction collapsed by current first-match Recall. This does not imply every consumer requires that distinction. The loss is consumer-relative.

## 8. IA-MRT-01 — IndaAgent001 absorption

Natural-consumer absorption test against the pre-existing IndaAgent001 I₆/I₇ architecture.

Classification: **ABSORPTION — NO NEW OPERATIONAL DISTINCTION REQUIRED**

The pre-existing architecture already contained:

- Persistent semantic records
- Restart continuity
- Requirement-conditioned retrieval
- Negative-history preservation
- Stale/superseded exclusion
- Irrelevant-record exclusion
- Conflicting/unresolved preservation
- Provenance preservation
- Objective integrity
- Authority separation
- Retrieved ≠ evidence
- UNRESOLVED → STOP

MRT did not force modification of that architecture.

## 9. IA-MRT-01N — Final ablation

Negative control: remove all MRT-specific labels, wrappers, and objects.

Historical I₇ consumer-visible result vector remained unchanged:

| Metric | Result |
|--------|--------|
| Prior records available | 11 |
| Retrieved by requirement | 3 |
| Relevant-negative retrieved | YES |
| Stale/superseded excluded | YES |
| Irrelevant excluded | YES |
| Conflicting preserved | YES |
| Unresolved preserved | YES |
| Objective unchanged | YES |
| Authority intact | YES |
| Retrieved as evidence | NO |
| Evidence as authority | NO |
| UNRESOLVED terminal valid | YES |
| Final decision | STOP |

Classification: **BEHAVIOURAL EQUIVALENCE CONFIRMED**

## 10. Evidence levels

| Stage | Level | Permanent status |
|-------|-------|------------------|
| MRT-01 | Type scaffold | Probe-local |
| MRT-01B | Concrete restart fixture | Probe-local |
| MRT-01C | Concrete multi-record fixture | Probe-local |
| MRT-01D | Consumer-pressure negative | Probe-local |
| MRT-01E/F | Information-loss fixture | Probe-local |
| IA-MRT-01 | Natural-consumer absorption | Research evidence |
| IA-MRT-01N | Ablation / equivalence | Research evidence |

## 11. Explicit non-claims

- No universal memory architecture is claimed
- IndaAgent001 memory completeness or optimality is not claimed
- First-match Recall is not claimed optimal
- No MULTIPLE RecallState constructor is justified
- No permanent Memorise / Retain / Recall API is justified
- No retrieval frontier reopening is justified
- No IndaAgent modification is justified
- No new mathematics is required
- No foundational abstraction is required
- No permanent FDHT pressure is established
- No promotion is justified

## 12. Final disposition

The MRT programme established useful bounded operational and information-loss fixtures, but the pre-existing IndaAgent001 memory architecture absorbed every tested MRT distinction relevant to its natural I₇ consumer. Removing MRT entirely produced no consumer-visible difference.

**RETAIN RESEARCH EVIDENCE / STOP**

---

*Historical I₆/I₇ provenance: research/results/IndaAgent001_I6_Result.md, research/results/IndaAgent001_I7_Result.md (committed prior to this archive).*
