# Semantic Correspondence Audit — OC0

## Informal Conjecture

Any integer n > 1 can be written as x + y with x, y > 0 such that both x + ny and x² + ny² are prime.

## Formal Statement

```lean
def A (n : ℕ) : Prop :=
  ∃ x y : ℕ, 0 < x ∧ 0 < y ∧ n = x + y ∧ (x + n * y).Prime ∧ (x ^ 2 + n * y ^ 2).Prime

theorem conjecture (n : ℕ) (hn : 1 < n) : A n
```

## Audit

| Property | Informal | Formal | Match |
|----------|----------|--------|-------|
| Domain | Positive integers n > 1 | ℕ with 1 < n | YES |
| Quantifier | For all n > 1 | ∀ n, 1 < n → ... | YES |
| Decomposition | x + y with x, y > 0 | ∃ x y, 0 < x ∧ 0 < y ∧ n = x + y | YES |
| First prime condition | x + ny prime | (x + n * y).Prime | YES |
| Second prime condition | x² + ny² prime | (x ^ 2 + n * y ^ 2).Prime | YES |
| Positivity | x, y > 0 | 0 < x ∧ 0 < y | YES |

## Classification

**SUFFICIENTLY_FAITHFUL_FOR_FIXTURE**

No material mismatch identified.
