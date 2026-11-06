# FDHT Consumer C₁₉ — Universal Instance Audit

**Status:** FIXTURE-KILL  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED

## Question

Can proof-bearing universal evidence specialise to a natural concrete instance
whose specialised proof is required by a downstream typed consumer?

## Result

Constructive universal evidence exists.

The primary audited surface was ClassifierInvariant:

```lean
∀ x y, E x y → C.classify x = C.classify y
```

Additional universal candidates included:

- neighbourCompose_foldedTrivial_iff_pointwiseStabiliser
- ThreadPermutation.projectedAction_rotation_eq_pointwise

No natural instance-specific downstream consumer was found.

The universal proposition is mathematically specialisable, but no specialised
instance has a natural outgoing consumer edge in the audited substrate.

## Classification

**F — FALSE REQUIREMENT / COUNTERMODEL**

This result is scoped to the audited substrate and does not establish that
instance-specific universal consumers are impossible.

## Architectural consequence

No C₁₉ Lean consumer probe.

No UniversalEvidence API.  
No Instantiation API.  
No InstanceRegistry.  
No Rule Engine.  
No generic Evidence API.  
No generic Consumer API.  
No action layer.

## Boundary

Universal derivability  
≠  
consumer dependency.

## Disposition

New mathematics: **NO**  
Foundational modification: **NO**  
C₁₉ Lean file: **NONE**  
Build: **NOT RUN** — documentation only  
Strict audit: **NOT RUN** — documentation only  
Permanent/main diff: **EMPTY**  
FDHT v3.1 scope: **UNCHANGED**  
Recommended action: **STOP**
