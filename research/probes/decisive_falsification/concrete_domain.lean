/-
Concrete finite domain for DFT0.

Tiny carrier: lists of Nat with length at most 2.
-/

namespace DFT0Domain

/-- Concrete system: short list of Nat. -/
abbrev ConcreteSystem := List Nat

/-- Domain: all lists of length at most 2 with elements in {0, 1}. -/
def domain : List ConcreteSystem :=
  [[],
   [0], [1],
   [0, 0], [0, 1], [1, 0], [1, 1]]

/-- Domain membership. -/
def inDomain (xs : ConcreteSystem) : Prop :=
  xs ∈ domain

end DFT0Domain
