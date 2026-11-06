/-!
# Neighbourhood-Preserving Transport Probe
Temporary. Not for commit.
-/

structure NeighborhoodPreservingTransport
    (A B : Type)
    (NeighbourA : A → A → Prop)
    (NeighbourB : B → B → Prop) where
  transport : A → B
  preserves :
    ∀ {a b},
      NeighbourA a b →
      NeighbourB (transport a) (transport b)

/-! Identity -/
def idTransport
    (A : Type)
    (Neighbour : A → A → Prop) :
    NeighborhoodPreservingTransport A A Neighbour Neighbour where
  transport := id
  preserves := fun h => h

/-! Composition -/
def composeTransport
    {A B C : Type}
    {NA : A → A → Prop}
    {NB : B → B → Prop}
    {NC : C → C → Prop}
    (T : NeighborhoodPreservingTransport A B NA NB)
    (U : NeighborhoodPreservingTransport B C NB NC) :
    NeighborhoodPreservingTransport A C NA NC where
  transport := U.transport ∘ T.transport
  preserves := fun h => U.preserves (T.preserves h)

/-! Noninjective preserving countermodel -/
def noninjectiveTransport :
    NeighborhoodPreservingTransport (Fin 2) (Fin 1) (fun _ _ => True) (fun _ _ => True) where
  transport := fun _ => 0
  preserves := fun _ => trivial

theorem noninjectiveTransport_not_injective :
    ¬ Function.Injective noninjectiveTransport.transport := by
  intro hinj
  have : (0 : Fin 2) = 1 := hinj rfl
  exact absurd this (by decide)

/-! Nonreflection: map equality to always-true, then 0 and 1 are related in target but not source -/
def enlargingTransport :
    NeighborhoodPreservingTransport (Fin 2) (Fin 2)
      (fun a b => a = b)
      (fun _ _ => True) where
  transport := id
  preserves := fun _ => trivial

theorem enlargingTransport_not_reflecting :
    (fun _ _ => True) (enlargingTransport.transport 0) (enlargingTransport.transport 1) ∧
    ¬ ((0 : Fin 2) = 1) := by
  constructor
  · trivial
  · decide

#print axioms idTransport
#print axioms composeTransport
#print axioms noninjectiveTransport
#print axioms noninjectiveTransport_not_injective
#print axioms enlargingTransport
#print axioms enlargingTransport_not_reflecting
