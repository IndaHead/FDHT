# FDHT MRT-05B-PD4 C0 Membership Proof

## Classification
A — C0 PROVED CONSTRUCTIVELY IN TARGET FILE

## Summary
c0_membership_structural proved under Lean 4.35.0 using offset-generalised emptiness helper.

candidateT r source isEmpty iff not identityMembershipConsumer r source.

Candidate list equality therefore implies membership Bool equality.

Definitions of SourceRecord, SourceState, ExactIndex, buildExactIndex, candidateT, identityMembershipConsumer unchanged.

## Helper
theorem candidateT_isEmpty_eq_not_membership
    (r : Identity) (source : SourceState) :
    (candidateT r source).isEmpty = !(identityMembershipConsumer r source)

Proved via:
- zipIdx_cons
- filter_map_snd_isEmpty_iff_no_match
- zipIdx_filter_empty_iff_source_no_match (induction generalizing offset)

## c0
Uses congrArg List.isEmpty + rewrite by helper + Bool.not_eq_eq_eq_not + Bool.not_not.

Axioms: propext only.

## Out of Scope
c1, c4, c5 remain with unsolved goals (OUT_OF_SCOPE).
c2, c3 preserved (native_decide fixtures).

## Claim Boundary
Only membership sufficiency for the research-local A2 candidate addressing.
Does not establish multiplicity, verified, complete MRT-05B, or permanent FDHT pressure.
