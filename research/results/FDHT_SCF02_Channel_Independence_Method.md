# FDHT SCF-02: Channel Independence Method

## Method

1. Recover exact channel definition from SCF-01 artefacts
2. Freeze channel subject before witness search
3. Test pairwise factorisation
4. Test combined-consumer factorisation
5. Test domain restrictions
6. Update channel lattice
7. Measure fate-matrix impact

## Domain mismatch handling

When channels operate on different carriers, independence cannot be tested. The channels are not comparable and cannot be classified as independent or dependent relative to each other.

## Controls

- Direction reversal: NOT_APPLICABLE (domain mismatch)
- Combined-consumer: NOT_APPLICABLE (domain mismatch)
- Domain-restriction: NOT_APPLICABLE (domain mismatch)
- Artificial-witness filter: PASSED
- Label-ablation: PASSED
- Fixture-permutation: NOT_APPLICABLE
- Negative control: NOT_APPLICABLE
- Positive control: NOT_APPLICABLE
- Factorisation/fate consistency: NOT_APPLICABLE
- Source-threading: NOT_APPLICABLE

## Conclusion

Domain mismatch is a valid reason for underdetermined independence. It is not a failure of the method.
