# FDHT Verification V₀-R — Selection Packaging Repair

**Status:** VERIFIED RESEARCH REPAIR  
**Authority:** RESEARCH RESULT ONLY  
**Promotion:** NOT PROMOTED  
**Starting HEAD:** `69a54f6bf12cf303b4c55b510b73b0125b193c9e`

## Question

Can the exact V₀ evidence-gated verification semantics be implemented cleanly
while preserving finite history, no caller-supplied applicable address, exact
state scope, exact proof payload, baseline no-evidence UNRESOLVED, knockout,
and no theorem fallback, AND eliminating sorryAx?

## Result

**YES.**

The target-indexed structural recursion selector is clean.

## Original V₀ Limitation

V₀ used List.find? over Sigma-packaged evidence, which introduced sorryAx
due to dependent type issues.

## First-Divergence Audit

| Component | Status |
|-----------|--------|
| Sigma packaging | Not the primary cause |
| List.find? | Not the primary cause |
| Equality decision | Not the primary cause |
| Dependent transport | Not the primary cause |
| Target-index preservation | CLEAN |

## Repair Strategy

Use fixture-local non-Sigma representation:

```lean
structure EvidenceEpisodeN8 where
  state : Fin 8
  proof : FirstPositiveReturnAt eightThreadCycle.toFun state 8
```

Use structural recursion with `cases h` for dependent transport:

```lean
def selectFor (i : Fin 8) (episodes : List EvidenceEpisodeN8) :
    EvidenceSelection i :=
  match episodes with
  | [] => .noMatch
  | ep :: rest =>
    if h : ep.state = i then
      .found (by cases h; exact ep.proof)
    else
      selectFor i rest
```

## Trust Footprints

| Theorem | Footprint | Status |
|---------|-----------|--------|
| T2_evidence_episode | [propext, Quot.sound] | CLEAN |
| T3_verification_request | [propext, Quot.sound] | CLEAN |
| T4_verification_result_verified | [propext, Quot.sound] | CLEAN |
| n8_index_first_return | [propext, Quot.sound] | CLEAN |
| baseline_noMatch | [propext, Quot.sound] | CLEAN |
| baseline_unresolved | [propext, Quot.sound] | CLEAN |
| applicable_found | [propext, Quot.sound] | CLEAN |
| applicable_verified | [propext, Quot.sound] | CLEAN |
| concrete_found | [propext, Quot.sound] | CLEAN |
| concrete_verified | [propext, Quot.sound] | CLEAN |
| knockout_noMatch | [propext, Quot.sound] | CLEAN |
| knockout_unresolved | [propext, Quot.sound] | CLEAN |
| verification_request_requires_proof | [propext, Quot.sound] | CLEAN |
| proof_lineage | [propext, Quot.sound] | CLEAN |

## Key Findings

### 1. Baseline is Clean

Empty history produces noMatch and UNRESOLVED with clean footprint.

### 2. Applicable History is Clean

History with exact hP produces found and VERIFIED with clean footprint.

### 3. Concrete History is Clean

History with n8_index_first_return produces found and VERIFIED with clean footprint.

### 4. Knockout is Clean

Removing evidence produces noMatch and UNRESOLVED with clean footprint.

### 5. Proof Lineage is Clean

The proof lineage from hP to VerificationRequest is clean.

## Consumer-Naturalness Audit

The VerificationRequest structure requires a prerequisite proof, and the
VerificationResult structure carries that proof. The verification operation
is:

```lean
def admitVerification (hist : EvidenceHistory) (i : Fin 8) :
    VerificationResult i :=
  match selectEvidence hist i with
  | .found hP => .verified hP
  | .noMatch => .unresolved
```

This is a genuine verification consumer because:
1. The verification request exists independently of history
2. The verification result depends on the historical evidence
3. Removing the evidence changes the result from VERIFIED to UNRESOLVED

## Classification

**PACKAGING REPAIR VERIFIED**

The target-indexed structural recursion selector is clean.

**GENUINE VERIFICATION CONSUMER CONFIRMED**

The verification operation is independently meaningful.

## Disposition

New mathematics: **NO**  
Foundational abstraction: **NO**  
Substrate modification: **NO**  
Lean file: `research/probes/verification_consumer/v0r_selection_packaging_repair.lean`  
FDHT v3.1 scope: **UNCHANGED**
