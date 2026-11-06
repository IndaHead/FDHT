## Provenance Audit Consumer API Certification

**Certified HEAD:** `83e461433477024fb9f67c3968aaebc07b479eda`

The FDHT provenance-audit consumer surface is now compiler-verified and
regression-certified.

### Certified API

- Evidence-bearing `ProvenanceRelation`
  - `sameRaw`
  - `projectedDistinct`
  - `collapsed`
- `CollapseCertificate`
- `ProjectedDistinctionCertificate`
- Prop-valued `ObservableFactorisationCertificate`
- resolver-specific `DistinguishingResolveCertificate`
- no total provenance classifier

### Consumer regression certification

Regression suite:

`fdht/FDHTProvenanceAuditAPIRegression.lean`

Certified fixtures:

1. raw equality via `sameRaw`;
2. `[]` / `[identityContext]` raw-distinct projected collapse;
3. projected distinction under `distinguishingResolve`;
4. Stage 4 synchronous distinction→collapse;
5. complete `DistinguishingResolveCertificate` cancellation frontier;
6. Prop-valued observable factorisation without witness extraction.

Invalid-state regressions also certify rejection of:

- raw equality together with raw inequality;
- projected equality together with projected inequality.

### Trust boundary

No new foundational mathematics was introduced.

No new mathematical bridge was required.

No total classifier was introduced.

No `Classical.choice` was introduced by the new consumer declarations.

Reported axiom footprints:

- `fixtureA_sameRaw`: `[Quot.sound]`
- `fixtureB_certificate`: `[Quot.sound]`
- `fixtureC_projectedDistinct`: `[propext, Quot.sound]`
- `fixtureD_certificate`: `[propext, Quot.sound]`
- `fixtureE_certificate`: `[propext, Quot.sound]`
- `fixtureF_certificate`: `[Quot.sound]`

### Verification

- `lake build`: EXIT 0 (43 jobs)
- strict FDHT axiom audit: PASS
- regression commit:
  `83e461433477024fb9f67c3968aaebc07b479eda`
- remote HEAD:
  `83e461433477024fb9f67c3968aaebc07b479eda`

### Classification

**FDHT PROVENANCE AUDIT CONSUMER REGRESSIONS CERTIFIED;
EVIDENCE-DRIVEN API VALIDATED**

The provenance audit is therefore a verified downstream consumer of the
frozen FDHT substrate rather than an extension of the foundational
mathematics.

Governing rule remains:

**If it doesn't pass Lean, it dies.**
