# FDHT Verification V₁ — Distinct-Target Evidence-Gated Verification

**Status:** FIXTURE-KILL  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `e20c3c2e2d76808f79dc03074abb11a0f8a941cd`

## Question

Does existing FDHT mathematics contain a natural verification target V and an
existing dependency P → V such that exact historical evidence hP : P can be
selected cleanly and used to verify V?

## Result

**FIXTURE-KILL.**

No natural verification target V distinct from P was found in the existing
mathematics.

## Audit Findings

### Downstream Dependency Search

Searched existing permanent mathematics for theorems that depend on
FirstPositiveReturnAt as a prerequisite.

**Result:** No downstream theorems found.

### FirstPositiveReturnAt Usage

FirstPositiveReturnAt is used as:
- a definition
- a theorem conclusion (n8_index_first_return, n6_index_first_return, n4_index_first_return)
- a hypothesis in lemmas within FDHTFirstPositiveReturn.lean

It is NOT used as a prerequisite for any downstream verification target.

### OriginAgeCertificate

OriginAgeCertificate depends on HasUniqueAgeFrom, not on FirstPositiveReturnAt.

### Certificate Surfaces

No certificate surface was found that requires FirstPositiveReturnAt as a
prerequisite.

## Classification

**V₁ FIXTURE-KILL: NO NATURAL DISTINCT VERIFICATION TARGET FOUND.**

The existing mathematics does not contain a natural verification target V
that depends on FirstPositiveReturnAt as a prerequisite.

## What V₁ Would Have Required

For V₁ to proceed, the existing mathematics would need:

1. A natural verification target V distinct from P
2. An existing dependency P → V
3. V can be verified using hP : P
4. No new theorem required

None of these conditions are satisfied by the existing mathematics.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean file: **NONE** (fixture-kill)  
FDHT v3.1 scope: **UNCHANGED**

## Learning Result

V₁ does not add a verification result because there is no natural distinct
verification target that depends on the selected historical evidence.

The existing verification consumer programme has established:

- evidence-gated verification packaging (V₀-R)

But it has NOT established:

- distinct-target verification

This is a valid negative result.
