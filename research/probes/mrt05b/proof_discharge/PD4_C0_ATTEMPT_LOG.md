# PD4 C0 Attempt Log

## Initial State
- HEAD: 95da89e5d1ebfb1c1faf920d068fb424449ea2c5
- Lean: 4.35.0
- Target SHA-256: 6fbae4e85af92cc301be8f47a56a865caf12a265b10b27cc33b28678bf5ab174
- buildExactIndex: source.zipIdx.filter (fun ⟨rec, _⟩ => rec.exactIdentity = ident).map Prod.snd
- Initial c0 error: unsolved goals at induction cases involving zipIdx offset 1

## Attempt 1: Direct induction on source for candidateT_eq_nil_iff
- Classification: INDUCTION_HYPOTHESIS_TOO_NARROW / ZIPIDX_API_MISMATCH
- Goal mismatch on tail.zipIdx 1 vs IH at offset 0

## Attempt 2: Generalized positionsFromZipIdx with offset parameter
- Still failed on simp normal form of filter/map emptiness vs forall

## Attempt 3: isEmpty-based lemmas
- filter_map_snd_isEmpty_iff_no_match: SUCCESS (after including ih in simp)
- zipIdx_filter_empty_iff_source_no_match: SUCCESS (generalizing offset, using zipIdx_cons)
- candidateT_isEmpty_eq_not_membership: SUCCESS
- c0 using congrArg isEmpty + Bool.not_eq_eq_eq_not + Bool.not_not: SUCCESS

## Final
- Isolation compiled cleanly
- Transplanted to target: c0 compiles; later theorems remain unsolved (OUT_OF_SCOPE)
- Axioms: propext only for helper and c0
