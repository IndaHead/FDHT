/-
Verification that observation and domain are unchanged from DFT0.

Observation: O(xs) = xs.length % 2 == 0
Domain: all lists of length <= 2 over {0, 1}
-/

namespace DFT0Unchanged

/-- Observation function (unchanged from DFT0). -/
def O (xs : List Nat) : Bool :=
  xs.length % 2 == 0

/-- Domain (unchanged from DFT0). -/
def domain : List (List Nat) :=
  [[], [0], [1], [0, 0], [0, 1], [1, 0], [1, 1]]

/-- Domain membership. -/
def inDomain (xs : List Nat) : Prop :=
  xs ∈ domain

end DFT0Unchanged
