# PD6 C4 Attempt Log

## Attempt 1
Naive isolation with mixed contradiction for some-implies and aggressive simp.
Failed: type mismatches (any reduced to exists Prop), noConfusion orientation, duplicate declaration.
Class: BOOL_PROP_MISMATCH / OTHER

## Attempt 2
Cleaner induction for some-implies; still simp reduced any to exists.
Failed on IH application.
Class: BOOL_PROP_MISMATCH

## Attempt 3 (success)
Explicit `List.any_cons` + controlled `simp [h]` / `rw`; presence bridge by cases on find? with direct rw of helpers.
Compiled. Axioms [propext, Quot.sound].
