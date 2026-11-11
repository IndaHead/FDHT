/-
Candidate countermodel for DFT0.

Witness: [] and [0, 0]
  O([]) = true (even length)
  O([0, 0]) = true (even length)
  C([]) = Accept
  C([0, 0]) = Reject
-/

namespace DFT0Countermodel

inductive ConsumerResult where
  | Accept
  | Reject
  deriving DecidableEq

def O (xs : List Nat) : Bool :=
  xs.length % 2 == 0

def C (xs : List Nat) : ConsumerResult :=
  if xs.isEmpty then ConsumerResult.Accept else ConsumerResult.Reject

/-- The two systems are distinct. -/
theorem systems_distinct : ([] : List Nat) ≠ [0, 0] := by
  decide

/-- The observation tuples are equal. -/
theorem observations_equal : O [] = O [0, 0] := by
  decide

/-- The consumer results differ. -/
theorem consumer_differs : C [] ≠ C [0, 0] := by
  decide

/-- Countermodel theorem. -/
theorem isConsumerDistinguishingCollision :
    ([] : List Nat) ≠ [0, 0] ∧
    O [] = O [0, 0] ∧
    C [] ≠ C [0, 0] := by
  exact ⟨systems_distinct, observations_equal, consumer_differs⟩

end DFT0Countermodel
