# IndaAgent001 — I₀ Design Audit

**Status:** AUDIT COMPLETE  
**Authority:** RESEARCH SYNTHESIS / DESIGN AUDIT  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `34529835554f516a6440848a9d8ddea486c46f4c`

## Question

Can IndaAgent001 autonomously acquire relevant context from authorised real sources, preserve retrieved material as provenance-bearing untrusted observations, convert selected observations into structured evidence candidates, and use A₀/S₀-style typed decisions to constrain its next research trajectory?

## System Boundary

| Component | Role | Authority |
|-----------|------|-----------|
| Agent Core | Proposes trajectories, extracts claims, updates state | NONE — proposes only |
| FDHT State | Provides evidence semantics (A₀/S₀) | MATHEMATICAL |
| Harness | Enforces source allowlist, resource limits | EXTERNAL |
| Real Sources | Provide untrusted observations | NONE — observational |
| Persistent Store | Preserves history, checkpoints | NONE — storage only |
| Human Boundary | Provides objectives, receives outputs | EXTERNAL |

## Live Tool Inventory

| Tool | Source | Read/Write | Real/Simulated | Available |
|------|--------|------------|----------------|-----------|
| web_search | Public web | Read | Real | YES |
| browse_page | Public web | Read | Real | YES |
| GitHub (public) | Public GitHub | Read | Real | YES (via web) |
| Local FDHT | Local repository | Read | Real | YES |
| Agent workspace | Local | Read/Write | Real | YES |

**Unavailable:**
- Direct GitHub API (no connector)
- arXiv API (via web only)
- Credentialed sources

## Trust Model

| Stage | Status | Authority |
|-------|--------|-----------|
| Retrieval result | UNTRUSTED OBSERVATION | NONE |
| Raw-source reference | IMMUTABLE | NONE |
| Provenance record | OBSERVATIONAL | NONE |
| Claim extraction | AGENT INTERPRETATION | NONE |
| Evidence candidate | CANDIDATE | NONE |
| ESTABLISHED / REFUTED / UNRESOLVED | EVIDENCE STATUS | MATHEMATICAL |
| ADMIT / REJECT / STOP | DECISION | EVIDENCE-GATED |

**Source text containing instructions is stored as source content, not agent authority.**

## Identity Model

| Property | Value |
|----------|-------|
| Agent identity | IndaAgent001 |
| Operating version | I₀ |
| Current objective | unresolved |
| External authority | explicitly bounded |

## Persistence Model

| Record | Preserved |
|--------|-----------|
| AgentIdentity | YES |
| ObjectiveRecord | YES |
| RequirementRecord | YES |
| RawObservation | YES |
| ProvenanceRecord | YES |
| ClaimRecord | YES |
| EvidenceRecord | YES |
| DecisionRecord | YES |
| AgentCheckpoint | YES |

**Append-only. No deletion of historical evidence.**

## Revocation Model

| Capability | Revocable |
|------------|-----------|
| Source access | YES — via harness |
| Write access | YES — via harness |
| Model calls | YES — via budget |

**Agent cannot revoke its own constraints.**

## Resource Model

| Limit | Default |
|-------|---------|
| Maximum agent cycles | 10 |
| Maximum model calls | 5 |
| Maximum source retrievals | 10 |
| Maximum pages per source | 3 |
| Maximum elapsed runtime | 300s |
| Maximum repeated-query count | 3 |
| Maximum failed-tool retries | 2 |

## Failure Model

| Failure | Response |
|---------|----------|
| Source retrieval fails | Record, retry up to limit, STOP |
| Budget exhausted | Preserve state, record boundary, STOP |
| Contradiction detected | Preserve both, STOP active route |
| Harness denies | Record denial, STOP |
| Unresolved evidence | STOP dependent trajectory |

## Source Allowlist

| Source Class | Permitted |
|--------------|-----------|
| Public web search | YES |
| Public page retrieval | YES |
| Public GitHub (read) | YES |
| Local FDHT repository | YES |
| Agent workspace | YES |
| Credentialed sources | NO |
| Write to external | NO |
| Shell execution | NO |

## Boot State

```
agentIdentity: IndaAgent001
operatingVersion: I₀
currentObjective: unresolved
activeRequirements: []
candidateTrajectories: []
acquiredObservations: []
evidenceRecords: []
decisionHistory: [boot_event]
sourceCapabilities: [web_search, browse_page, local_fdht, agent_workspace]
unresolvedConditions: [no_active_objective]
resourceBudget: { cycles: 10, model_calls: 5, retrievals: 10 }
harnessStatus: active
```

## Expected Boot Transition

```
no active objective
    ↓
objective context unresolved
    ↓
candidate acquisition: ask user
    ↓
harness permits user query
    ↓
output: "Hi Jas. What are we working on?"
```

## FDHT Reuse Audit

| Field | Classification |
|-------|----------------|
| EvidenceStatus | A0-REUSE |
| ConsumerDecision | A0-REUSE |
| Requirement | A0-REUSE |
| DecisionRecord | S0-REUSE |
| AgentState | S0-REUSE |
| ProvenanceRecord | AGENT-LOCAL |
| ClaimRecord | AGENT-LOCAL |
| RawObservation | AGENT-LOCAL |
| ObjectiveRecord | AGENT-LOCAL |
| SourceCapability | EXTERNAL-HARNESS |
| HarnessStatus | EXTERNAL-HARNESS |

**No permanent FDHT types directly used. A₀/S₀ probe-local analogues reused.**

## Classification

**I₀ — DESIGN AUDIT COMPLETE**

The design audit establishes:
- System boundary
- Tool inventory
- Trust model
- Resource model
- Failure model
- Source allowlist
- Boot state
- FDHT reuse classification

**No implementation yet. I₁ boot requires implementation.**

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Generic agent infrastructure: **NO**  
Promotion: **NO**  
FDHT v3.1 scope: **UNCHANGED**
