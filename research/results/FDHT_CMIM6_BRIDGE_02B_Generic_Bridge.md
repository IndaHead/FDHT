# FDHT CMIM6-BRIDGE-02B Generic Support-Sufficiency ↔ Markov ↔ Zero-CMI

## Classification
D — PROOF/INFRASTRUCTURE BLOCKED

## Summary
Probe executed in isolated LeanInfoTheory v0.2.0 sidecar (commit 953b785, Lean 4.33.1).

Independent definition:
SupportSufficient p M C := ∀ x y, x ∈ p.support → y ∈ p.support → M x = M y → C x = C y

Control proved:
GlobalSufficient M C → SupportSufficient p M C

Forward (SupportSufficient → IsMarkovChainOf p id M C) and reverse directions not completed.
IsSufficientStatisticOf not used as the definition of support sufficiency.
No FDHT source modified. No sorry in final artefacts.

## Claim boundary
Generic bridge not established. Does not establish CERTMEM-02 probabilistic results or permanent FDHT mathematics.
