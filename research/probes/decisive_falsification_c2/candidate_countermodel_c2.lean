/-
Candidate countermodel for DFT0-C2.

Witness: [0] and [1]
  O([0]) = false (odd length)
  O([1]) = false (odd length)
  C2([0]) = BLOCK
  C2([1]) = ALLOW
-/

namespace DFT0CountermodelC2

inductive ConsumerResult where
  | NO_EVENT
  | BLOCK
  | ALLOW
  deriving DecidableEq

def O (xs : List Nat) : Bool :=
  xs.length % 2 == 0

def C2 (xs : List Nat) : ConsumerResult :=
  match xs.getLast? with
  | none => ConsumerResult.NO_EVENT
  | some 0 => ConsumerResult.BLOCK
  | some _ => ConsumerResult.ALLOW

/-- The two systems are distinct. -/
theorem systems_distinct : ([0] : List Nat) ≠ [1] := by
  decide

/-- The observation tuples are equal. -/
theorem observations_equal : O [0] = O [1] := by
  decide

/-- The consumer results differ. -/
theorem consumer_differs : C2 [0] ≠ C2 [1] := by
  decide

/-- Both belong to the domain. -/
theorem x_in_domain : [0] ∈ [[], [0], [1], [0, 0], [0, 1], [1, 0], [1, 1]] := by
  decide

theorem y_in_domain : [1] ∈ [[], [0], [1], [0, 0], [0, 1], [1, 0], [1, 1]] := by
  decide

/-- Countermodel theorem. -/
theorem isC2Collision :
    ([0] : List Nat) ≠ [1] ∧
    O [0] = O [1] ∧
    C2 [0] ≠ C2 [1] ∧
    [0] ∈ [[], [0], [1], [0, 0], [0, 1], [1, 0], [1, 1]] ∧
    [1] ∈ [[], [0], [1], [0, 0], [0, 1], [1, 0], [1, 1]] := by
  exact ⟨systems_distinct, observations_equal, consumer_differs, x_in_domain, y_in_domain⟩

end DFT0CountermodelC2
