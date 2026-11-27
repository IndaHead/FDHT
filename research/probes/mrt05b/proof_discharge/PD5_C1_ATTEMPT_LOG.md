# PD5 C1 Attempt Log

## Attempt 1
Direct induction on source (as left by prior probe).
Failed with unsolved goals in nil.cons / cons.nil and type mismatch on IH application due to zipIdx offset 1.
Class: OFFSET_NOT_GENERALISED

## Attempt 2
Offset-generalised theorem with pipeline `|`.length syntax.
Syntax error.
Class: OTHER (syntax)

## Attempt 3
Explicit parentheses on map length; direct simp including IH on the combined filter-map.
Unsolved goals after simp reduced the goal past the map, IH not applied.
Class: SIMP_IH_NOT_USED / MAP_LENGTH_MISMATCH

## Attempt 4 (success)
Separated:
- `map_length_eq` (ordinary induction)
- `zipIdx_filter_length_eq_source_filter_length` (offset-generalised induction, by_cases on head, IH at offset+1)
- `zipIdx_filter_map_length_eq_source_filter_length` = map length of filter
- `candidateT_length_eq_multiplicity` at offset 0
- c1 via congrArg List.length + rewrite

Compiled with axioms [propext].
