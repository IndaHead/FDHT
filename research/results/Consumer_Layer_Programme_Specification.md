# FDHT Consumer-Layer Programme

Research branch: `research/consumer-layer`

Base HEAD: `0e378c044edacd6adec1e40fc426abb5d5680a65`

## Purpose

Consumer engineering above the verified FDHT substrate.

The substrate has reached a legitimate STOP state. No missing mathematics, packaging, or blocked consumer currently requires substrate expansion.

This programme constructs increasingly demanding typed consumers and uses their successes and failures to discover which additional mathematics, packaging, or interfaces are actually required.

## Governing rule

```
CONSUMER ASKS.
SUBSTRATE CONSTRAINS.
INTERFACE PRESERVES WHAT THE EVIDENCE ACTUALLY PERMITS.
EXPANSION OCCURS ONLY WHEN REPEATED VERIFIED CONSUMER PRESSURE REQUIRES IT.
```

## Method

```
Concrete consumer
  → typed request
  → existing evidence
  → result
  → adversarial regression
  → identify exact pressure point
  → classify
  → only then consider expansion
```

## Result states currently earned

- ESTABLISHED
- REFUTED
- UNRESOLVED

## Result states not yet earned

- CONDITIONAL
- MULTIPLE
- INSUFFICIENT
- INADMISSIBLE
- ACTIONABLE
- CERTIFIED
- probabilistic/confidence states

Do not add unearned states to implementation merely for documentation symmetry.

## C₀ design principles

| ID | Principle |
|----|-----------|
| C₀-01 | Ask a question; do not encode a desired answer. |
| C₀-02 | Request ≠ evidence ≠ result ≠ status. |
| C₀-03 | Established results retain supporting proof. |
| C₀-04 | Refuted results retain refuting evidence. |
| C₀-05 | Unresolved ≠ refuted. |
| C₀-06 | Absence of proof ≠ proof of falsehood. |
| C₀-07 | Preserve carrier and layer in the proposition type. |
| C₀-08 | Use existing types for applicability before inventing metadata. |
| C₀-09 | Weaker evidence must not be silently strengthened. |
| C₀-10 | Valid period ≠ first positive return. |
| C₀-11 | Raw evidence ≠ projected evidence. |
| C₀-12 | Status observation must not erase proof payloads. |
| C₀-13 | Boolean output is insufficient for the verified result space. |
| C₀-14 | Consumer protocol ≠ proof search. |
| C₀-15 | Evidence retrieval is not yet justified. |
| C₀-16 | One successful consumer does not justify a universal Consumer API. |
| C₀-17 | Interface expansion requires concrete consumer pressure. |
| C₀-18 | A consumer requiring no substrate expansion is a successful probe. |

## Pressure classification

For future probes, classify any break as one of:

| Code | Classification |
|------|----------------|
| A | EXISTING THEOREM MISSED |
| B | THEOREM-SHAPE MISMATCH |
| C | CONSUMER-TYPE DESIGN FAILURE |
| D | PACKAGING GAP |
| E | MATHEMATICAL GAP |
| F | FALSE REQUIREMENT / COUNTERMODEL |
| G | UNDERDETERMINED |
| H | EXISTING SUBSTRATE SUFFICIENT |

This classification belongs to research governance. Do not automatically encode it into Lean.

## Firewalls

### Substrate modification firewall

Consumer probes must not modify main-substrate mathematics in place. If a consumer appears to require new mathematics:

1. STOP the consumer expansion.
2. Record the exact blocking type/goal.
3. Open a separate substrate audit.

No consumer may silently grow the substrate to make itself succeed.

### Result-state firewall

```
ESTABLISHED:  proof exists and is retained
REFUTED:      refuting evidence exists and is retained
UNRESOLVED:   neither establishment nor refutation supplied
```

Never map automatically:

- UNRESOLVED → REFUTED
- failure to find proof → REFUTED
- result → Bool (as the semantic interface)

### Applicability firewall

Do not introduce explicit Applicability metadata while Lean's types already separate the relevant propositions. C₀ demonstrated that raw request type ≠ projected request type.

### Evidence firewall

Do not introduce EvidenceStore, EvidenceQuery, EvidenceEngine, EvidenceRanking, or EvidenceGraph API during branch initialisation. The current admissible evidence mechanism is explicit typed Lean proof.

### Action firewall

The initial consumer branch is query/reasoning interface research. Do not implement action execution, state mutation, external effects, autonomous optimisation, or automatic objective pursuit during branch initialisation.

### Provenance firewall

Do not collapse FDHT's existing provenance planes. Preserve distinction between mathematical applicability, trust provenance, and research/repository provenance.

### No generic ConsumerResult yet

Do not create ConsumerRequest, ConsumerResult, or ConsumerStatus as permanent or generic abstractions at branch initialisation. A generic Consumer API requires evidence from multiple independently useful consumer families.

## C₀ — First regression

Location: `research/probes/consumer_layer/c0_first_return_consumer.lean`

Status sequence:

```
ESTABLISHED
REFUTED
ESTABLISHED
REFUTED
UNRESOLVED
```

Proof payloads remain recoverable. Raw/projected type separation remains visible. No automatic evaluator.

## Disposition

PROBE-LOCAL ONLY. Not promoted. Not a permanent API.

## Trust

No new mathematics. No new foundational abstraction. No substrate modification.

