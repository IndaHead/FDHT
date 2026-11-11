/-
Bounded countermodel search for DFT0-C2.

Searches for pairs x, y where:
  O(x) = O(y) (observationally equivalent under length parity)
  C2(x) != C2(y) (consumer distinguishes them)
-/

namespace DFT0SearchC2

/-- Observation: length parity (unchanged). -/
def O (xs : List Nat) : Bool :=
  xs.length % 2 == 0

/-- Consumer 2: terminal-event disposition. -/
inductive ConsumerResult where
  | NO_EVENT
  | BLOCK
  | ALLOW
  deriving DecidableEq

def C2 (xs : List Nat) : ConsumerResult :=
  match xs.getLast? with
  | none => ConsumerResult.NO_EVENT
  | some 0 => ConsumerResult.BLOCK
  | some _ => ConsumerResult.ALLOW

/-- Domain (unchanged). -/
def domain : List (List Nat) :=
  [[], [0], [1], [0, 0], [0, 1], [1, 0], [1, 1]]

/-- Search for consumer-distinguishing observational collision. -/
def searchCollision : Option (List Nat × List Nat) :=
  domain.findSome? fun x =>
    domain.findSome? fun y =>
      if O x = O y ∧ C2 x ≠ C2 y ∧ x ≠ y then some (x, y) else none

/-- First collision under canonical enumeration. -/
theorem collision_exists : searchCollision.isSome = true := by
  native_decide

/-- The collision pair. -/
def collisionPair : List Nat × List Nat :=
  searchCollision.get collision_exists

end DFT0SearchC2
