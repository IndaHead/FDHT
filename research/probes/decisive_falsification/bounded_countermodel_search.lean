/-
Bounded countermodel search for DFT0.

Searches for pairs x, y where:
  O x = O y (observationally equivalent under trajectoryProjection)
  C x != C y (consumer distinguishes them)
-/

import FDHTTrajectoryAPI

namespace DFT0Search

variable {Store : Sort u} {Location : Sort v}

/-- Simplified observation: length parity as a stand-in for trajectory collapse.
    
In FDHT, trajectoryProjection collapses histories that are FoldKernel-equivalent.
For this probe, we model the observation as length parity, which captures
the collapse of even-length histories to one class and odd-length to another.
-/
def O (xs : List Nat) : Bool :=
  xs.length % 2 == 0

/-- Consumer: empty vs non-empty. -/
inductive ConsumerResult where
  | Accept
  | Reject
  deriving DecidableEq

def C (xs : List Nat) : ConsumerResult :=
  if xs.isEmpty then ConsumerResult.Accept else ConsumerResult.Reject

/-- Domain: lists of length at most 2 with elements in {0, 1}. -/
def domain : List (List Nat) :=
  [[], [0], [1], [0, 0], [0, 1], [1, 0], [1, 1]]

/-- Search for consumer-distinguishing observational collision. -/
def searchCollision : Option (List Nat × List Nat) :=
  domain.findSome? fun x =>
    domain.findSome? fun y =>
      if O x = O y ∧ C x ≠ C y ∧ x ≠ y then some (x, y) else none

/-- First collision under canonical enumeration. -/
theorem collision_exists : searchCollision.isSome = true := by
  native_decide

/-- The collision pair. -/
def collisionPair : List Nat × List Nat :=
  searchCollision.get collision_exists

end DFT0Search
