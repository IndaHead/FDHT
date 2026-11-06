# FDHT Consumer C₁₈ — Existential Witness Audit

**Status:** FIXTURE-KILL  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED

## Question

Does existing FDHT mathematics contain constructive existential evidence
whose extracted witness is naturally required by a downstream typed consumer?

## Result

Existential evidence exists constructively.

The strongest candidate is:

`arbitrarily_long_return_extensions`

which proves:

```lean
∃ extension : List KernelExprContext,
  ReturnsTo resolve xs extension ∧
  extension.length > B
```

with constructive witness:

```lean
neutralPairs (B + 1)
```

The witness and its proof can be extracted without Classical.choice.

No existing natural downstream consumer was found that depends on the
identity of that specific extension.

Other audited existential surfaces were proof-internal and supplied no
witness-dependent consumer boundary.

## Classification

**F — FALSE REQUIREMENT / COUNTERMODEL**

The result is scoped to the audited substrate.

It does not establish that witness-dependent consumers are mathematically
impossible or cannot arise from future FDHT mathematics.

## Architectural consequence

No C₁₈ Lean consumer probe is justified.

No:

- ExistentialEvidence API
- Witness API
- WitnessSearch
- WitnessSelector
- WitnessRegistry
- generic Evidence API
- generic Consumer API
- action layer

is justified.

## Boundary

Constructive witness existence  
≠  
natural downstream witness dependency.

A proof may carry additional information without that information creating a
consumer edge.

## Disposition

New mathematics: **NO**  
Foundational modification: **NO**  
C₁₈ Lean file: **NONE**  
Build: **NOT RUN** — documentation only  
Strict audit: **NOT RUN** — documentation only  
Permanent/main diff: **EMPTY**  
FDHT v3.1 scope: **UNCHANGED**  
Recommended action: **STOP**
