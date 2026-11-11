/-
Frozen external consumer for DFT0.

Defined independently of FDHT vocabulary.
Does not import FDHT modules.
-/

namespace DFT0Consumer

/-- Consumer result type. -/
inductive ConsumerResult where
  | Accept
  | Reject
  deriving DecidableEq, Repr

/-- External consumer: path-sensitive admissibility.
    
A history is Accept if and only if it is the empty list.
Non-empty histories are Reject.

This is a natural consumer question: "Does this history represent
a clean initial state?" The answer depends on raw history identity,
not on any projected equivalence.
-/
def C (xs : List Nat) : ConsumerResult :=
  if xs.isEmpty then ConsumerResult.Accept else ConsumerResult.Reject

end DFT0Consumer
