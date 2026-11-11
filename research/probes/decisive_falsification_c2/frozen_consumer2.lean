/-
Frozen external Consumer 2 for DFT0-C2.

Defined independently of FDHT.
Does not import FDHT modules or DFT0 countermodel.

Consumer question: "What disposition was recorded by the most recent
event in this history?"

Semantics:
  []: NO_EVENT
  non-empty ending in 0: BLOCK
  non-empty ending in 1: ALLOW
-/

namespace DFT0Consumer2

/-- Consumer result type. -/
inductive ConsumerResult where
  | NO_EVENT
  | BLOCK
  | ALLOW
  deriving DecidableEq, Repr

/-- Terminal-event disposition consumer.

Independent motivation: a downstream component requiring the disposition
of the most recent recorded event. Does not ask whether the history is
empty, whether length is even, or for complete history identity.
-/
def C2 (xs : List Nat) : ConsumerResult :=
  match xs.getLast? with
  | none => ConsumerResult.NO_EVENT
  | some 0 => ConsumerResult.BLOCK
  | some _ => ConsumerResult.ALLOW

end DFT0Consumer2
