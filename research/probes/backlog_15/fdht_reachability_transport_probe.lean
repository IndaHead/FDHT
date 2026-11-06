/-!
# Reachability Transport Probe
Temporary. Not for commit.
Local TransGen/ReflTransGen for probe isolation.
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

/-! Local TransGen -/
inductive TransGen {α : Type} (r : α → α → Prop) : α → α → Prop where
  | single {a b} : r a b → TransGen r a b
  | tail {a b c} : TransGen r a b → r b c → TransGen r a c

/-! Local ReflTransGen -/
inductive ReflTransGen {α : Type} (r : α → α → Prop) : α → α → Prop where
  | refl {a} : ReflTransGen r a a
  | tail {a b c} : ReflTransGen r a b → r b c → ReflTransGen r a c

/-! TransGen preservation -/
theorem preserves_transGen
    {A B : Type}
    {RA : A → A → Prop}
    {RB : B → B → Prop}
    (T : NeighborhoodPreservingTransport A B RA RB)
    {a b : A}
    (h : TransGen RA a b) :
    TransGen RB (T.transport a) (T.transport b) := by
  induction h with
  | single hab => exact TransGen.single (T.preserves hab)
  | tail _ hab ih => exact TransGen.tail ih (T.preserves hab)

/-! ReflTransGen preservation -/
theorem preserves_reflTransGen
    {A B : Type}
    {RA : A → A → Prop}
    {RB : B → B → Prop}
    (T : NeighborhoodPreservingTransport A B RA RB)
    {a b : A}
    (h : ReflTransGen RA a b) :
    ReflTransGen RB (T.transport a) (T.transport b) := by
  induction h with
  | refl => exact ReflTransGen.refl
  | tail _ hab ih => exact ReflTransGen.tail ih (T.preserves hab)

/-! Noninjective transport still preserves reachability -/
def noninjectiveTransport :
    NeighborhoodPreservingTransport (Fin 2) (Fin 1) (fun _ _ => True) (fun _ _ => True) where
  transport := fun _ => 0
  preserves := fun _ => trivial

theorem noninjective_preserves_transGen
    {a b : Fin 2}
    (h : TransGen (fun _ _ => True) a b) :
    TransGen (fun _ _ => True) (noninjectiveTransport.transport a) (noninjectiveTransport.transport b) :=
  preserves_transGen noninjectiveTransport h

#print axioms preserves_transGen
#print axioms preserves_reflTransGen
#print axioms noninjective_preserves_transGen
