# FDHT Verification V₀ — Evidence-Gated Verification

**Status:** FIXTURE-KILL / PACKAGING GAP  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `18d25bdb36808a3459bd2482398b9ef6e08bef33`

## Question

Can a concrete verification consumer distinguish between cases where required
historical evidence is absent vs present while preserving exact typed evidence,
exact case scope, proof provenance, and historical lineage?

## Result

**FIXTURE-KILL / PACKAGING GAP.**

The structural architecture for evidence-gated verification is established,
but proof reduction requires sorryAx due to dependent type issues in the
historical selection function.

## Consumer Purpose

The Verification Consumer maintains concrete cases requiring verification.
A verification request for a case may be admitted only when the exact
prerequisite evidence required for that case is available.

## Selected Case

**Case C:** FirstPositiveReturnAt for n=8  
**Verification question:** Does state i have a first positive return at k=8?  
**Prerequisite P:** FirstPositiveReturnAt eightThreadCycle.toFun i 8  
**Source hP:** n8_index_first_return i

## Structural Architecture

```lean
structure VerificationRequest (i : Fin 8) where
  prerequisite : FirstPositiveReturnAt eightThreadCycle.toFun i 8

inductive VerificationResult (i : Fin 8) where
  | verified : FirstPositiveReturnAt eightThreadCycle.toFun i 8 → VerificationResult i
  | unresolved : VerificationResult i
```

## Packaging Gap

The selectEvidence function uses List.find? with dependent type matching.
The dependent type transport does not reduce definitionally with rfl.

This is a packaging gap, not a mathematical gap.

## Trust Footprints

| Theorem | Footprint |
|---------|-----------|
| baseline_unresolved | [propext, sorryAx, Quot.sound] |
| applicable_verified | [propext, sorryAx, Quot.sound] |
| knockout_unresolved | [propext, sorryAx, Quot.sound] |
| concrete_verified | [propext, sorryAx, Quot.sound] |
| verification_request_requires_proof | [propext, Quot.sound] |

## Classification

**V₀ FIXTURE-KILL: PACKAGING GAP**

The structural architecture is sound, but proof reduction requires sorryAx
due to dependent type issues in the historical selection function.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean file: `research/probes/verification_consumer/v0_evidence_gated_verification.lean`  
FDHT v3.1 scope: **UNCHANGED**
