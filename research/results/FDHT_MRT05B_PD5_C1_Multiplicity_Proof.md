# FDHT MRT-05B-PD5 C1 Exact-Index Multiplicity Proof

## Classification
A — C1 PROVED CONSTRUCTIVELY IN TARGET FILE

## Summary
Under Lean 4.35.0, with frozen definitions, `c1_multiplicity_structural` is proved constructively.

The proof rests on an offset-generalised length invariant:
the length of the filtered-and-mapped `zipIdx` position list equals the length of the source filter on matching identities, for every offset.

`candidateT` length therefore equals `identityMultiplicityConsumer`. Candidate-list equality transports to multiplicity equality via `congrArg List.length`.

No definitions changed. No `sorry`/`admit`. Axioms limited to `propext` for the new results. `fdht/` and toolchain unchanged. c0, c2, c3 regressions preserved. c4/c5 left untouched.

## Key helper
```lean
theorem candidateT_length_eq_multiplicity
    (r : Identity)
    (source : SourceState) :
    (candidateT r source).length = identityMultiplicityConsumer r source
```

## Commit
research: prove MRT-05B multiplicity sufficiency
