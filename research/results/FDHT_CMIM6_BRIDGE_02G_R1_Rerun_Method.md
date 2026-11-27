# Method

1. Located existing verified LeanInfoTheory checkout at 953b785 under Lean 4.33.1.
2. Wrote the three frozen targets exactly as specified.
3. Compiled via direct lean with LEAN_PATH pointing at the verified dependency build.
4. Produced olean, ran axiom audit, deleted olean, cold-recompiled.
5. Classified A. STOP.
