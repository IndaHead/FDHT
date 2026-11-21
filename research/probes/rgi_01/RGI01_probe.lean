/-
RGI-01: RG-01 → FDHT Interface Conservation Probe
External probe only. Does not modify fdht/.
-/

namespace RGI01

-- ============================================================
-- EXISTING FDHT CONSUMER MATHEMATICS
-- ============================================================

def SufficientFor {X Y R : Type} (T : X → Y) (C : X → R) : Prop :=
  ∀ x y, T x = T y → C x = C y

def ObservableLoss {X Y R : Type} (T : X → Y) (C : X → R) : Prop :=
  ∃ x y, T x = T y ∧ C x ≠ C y

def FactorsThrough {X Y Z : Type} (T : X → Y) (U : X → Z) : Prop :=
  ∃ P : Y → Z, ∀ x, U x = P (T x)

theorem loss_factor_implies_insufficient {X Y Z R : Type}
    (T : X → Y) (U : X → Z) (C : X → R)
    (hLoss : ObservableLoss T C) (hFactor : FactorsThrough T U) :
    ¬ SufficientFor U C := by
  intro hSuff
  obtain ⟨x, y, hT, hC⟩ := hLoss
  obtain ⟨P, hP⟩ := hFactor
  have hU : U x = U y := by rw [hP x, hT, ← hP y]
  exact hC (hSuff x y hU)

-- ============================================================
-- CANDIDATE INTERFACES (packaging only)
-- ============================================================

structure ResidenceInterface (Node : Type) where
  inside : Node → Node → Prop
  within : Node → Node → Prop

structure RelationInterface (Node : Type) (Kind : Type) where
  related : Kind → Node → Node → Prop

structure ObservationInterface (Node : Type) (X : Type) where
  Codomain : Node → Type
  observe : (n : Node) → X → Codomain n

def NodeFactorsThrough {Node X : Type} (O : ObservationInterface Node X) (a b : Node) : Prop :=
  FactorsThrough (O.observe a) (O.observe b)

def NodeSufficientFor {Node X R : Type} (O : ObservationInterface Node X) (n : Node) (C : X → R) : Prop :=
  SufficientFor (O.observe n) C

def NodeObservableLoss {Node X R : Type} (O : ObservationInterface Node X) (n : Node) (C : X → R) : Prop :=
  ObservableLoss (O.observe n) C

-- ============================================================
-- FINITE MODEL
-- ============================================================

inductive Node where
  | outer | middle | inner | sibling | external | regionA | regionB
deriving DecidableEq

inductive Kind where
  | dataFlow | controlFlow
deriving DecidableEq

abbrev X := Bool × Bool

def obsOuter : X → Bool := fun x => x.1
def obsMiddle : X → Bool := fun x => x.2
def obsInner : X → X := id
def obsSibling : X → Bool := fun x => x.1
def obsExternal : X → Bool := fun x => x.1
def obsRegionA : X → Bool := fun x => x.1
def obsRegionB : X → Bool := fun x => x.2

def inside : Node → Node → Prop := fun child parent =>
  (child = .inner ∧ parent = .middle) ∨
  (child = .middle ∧ parent = .outer) ∨
  (child = .sibling ∧ parent = .outer) ∨
  (child = .regionA ∧ parent = .outer) ∨
  (child = .regionB ∧ parent = .outer)

def within : Node → Node → Prop := fun a b =>
  inside a b ∨ ∃ m, inside a m ∧ inside m b

def related : Kind → Node → Node → Prop := fun k a b =>
  k = .dataFlow ∧ a = .middle ∧ b = .outer

def C : X → X := id

-- ============================================================
-- TASK 2: RESIDENCE CONSERVATION
-- ============================================================

theorem residence_not_dependency :
    (inside .sibling .outer ∧ FactorsThrough obsOuter obsSibling) ∧
    (inside .inner .middle ∧ ¬ FactorsThrough obsMiddle obsInner) := by
  constructor
  · constructor
    · simp [inside]
    · refine ⟨id, fun _ => rfl⟩
  · constructor
    · simp [inside]
    · intro ⟨P, hP⟩
      have h1 := hP (true, false)
      have h2 := hP (false, false)
      simp only [obsMiddle, obsInner] at h1 h2
      exact absurd (h1.trans h2.symm) (by simp)

-- ============================================================
-- TASK 3: RELATION CONSERVATION
-- ============================================================

theorem relation_not_dependency :
    (related .dataFlow .middle .outer ∧ ¬ FactorsThrough obsMiddle obsOuter) ∧
    (FactorsThrough obsOuter obsExternal ∧ ¬ ∃ k, related k .outer .external) := by
  constructor
  · constructor
    · simp [related]
    · intro ⟨P, hP⟩
      have h1 := hP (true, false)
      have h3 := hP (false, false)
      simp only [obsMiddle, obsOuter] at h1 h3
      exact absurd (h1.trans h3.symm) (by simp)
  · constructor
    · refine ⟨id, fun _ => rfl⟩
    · intro ⟨k, h⟩
      simp [related] at h

-- ============================================================
-- TASK 4: OBSERVATION HAND-OFF
-- ============================================================

theorem observation_handoff :
    SufficientFor obsInner C ∧ ObservableLoss obsOuter C := by
  constructor
  · intro x y h
    simp only [obsInner] at h
    exact h
  · refine ⟨(true, false), (true, true), ?_, ?_⟩
    · simp [obsOuter]
    · simp [C]

-- ============================================================
-- TASK 5: DEPTH INVARIANCE CONTROL
-- ============================================================

theorem depth_invariance :
    (inside .sibling .outer ∧ FactorsThrough obsOuter obsSibling) ∧
    (¬ inside .external .outer ∧ FactorsThrough obsOuter obsExternal) := by
  constructor
  · constructor
    · simp [inside]
    · refine ⟨id, fun _ => rfl⟩
  · constructor
    · simp [inside]
    · refine ⟨id, fun _ => rfl⟩

-- ============================================================
-- TASK 6: LOSS + FACTORISATION PRUNING
-- ============================================================

theorem factorising_child_pruned :
    ObservableLoss obsOuter C → FactorsThrough obsOuter obsSibling →
    ¬ SufficientFor obsSibling C :=
  loss_factor_implies_insufficient obsOuter obsSibling C

-- ============================================================
-- TASK 7: CONTAINED NON-FACTORISING CONTROL
-- ============================================================

theorem contained_nonfactorising_not_prunable :
    inside .inner .middle ∧ ¬ FactorsThrough obsMiddle obsInner := by
  constructor
  · simp [inside]
  · intro ⟨P, hP⟩
    have h1 := hP (true, false)
    have h2 := hP (false, false)
    simp only [obsMiddle, obsInner] at h1 h2
    exact absurd (h1.trans h2.symm) (by simp)

-- ============================================================
-- TASK 8: NON-CONTAINED FACTORISING CONTROL
-- ============================================================

theorem cross_boundary_factorising_pruned :
    ¬ inside .external .outer →
    ObservableLoss obsOuter C →
    FactorsThrough obsOuter obsExternal →
    ¬ SufficientFor obsExternal C := by
  intro _ hLoss hFactor
  exact loss_factor_implies_insufficient obsOuter obsExternal C hLoss hFactor

-- ============================================================
-- TASK 9: COMPLEMENTARITY FIREWALL
-- ============================================================

theorem complementarity_preserved :
    ObservableLoss obsOuter C ∧
    ObservableLoss obsMiddle C ∧
    SufficientFor obsInner C := by
  constructor
  · refine ⟨(true, false), (true, true), ?_, ?_⟩
    · simp [obsOuter]
    · simp [C]
  constructor
  · refine ⟨(false, true), (true, true), ?_, ?_⟩
    · simp [obsMiddle]
    · simp [C]
  · intro x y h
    simp only [obsInner] at h
    exact h

-- ============================================================
-- TASK 10: NON-PRUNABLE ≠ SUFFICIENT
-- ============================================================

theorem nonprunable_not_sufficient :
    ¬ FactorsThrough obsMiddle obsInner ∧ ¬ SufficientFor obsMiddle C := by
  constructor
  · intro ⟨P, hP⟩
    have h1 := hP (true, false)
    have h2 := hP (false, false)
    simp only [obsMiddle, obsInner] at h1 h2
    exact absurd (h1.trans h2.symm) (by simp)
  · intro hSuff
    have h1 : obsMiddle (false, true) = obsMiddle (true, true) := by simp [obsMiddle]
    have h2 : C (false, true) ≠ C (true, true) := by simp [C]
    exact h2 (hSuff (false, true) (true, true) h1)

-- ============================================================
-- TASK 11: STRUCTURAL DECISION
-- ============================================================

inductive StructuralDecision where
  | prune
  | unresolved

-- ============================================================
-- TASK 14: FAMILY EXHAUSTION
-- ============================================================

def family : Fin 3 → (X → Bool) := fun i =>
  match i with
  | ⟨0, _⟩ => obsSibling
  | ⟨1, _⟩ => obsExternal
  | ⟨2, _⟩ => obsRegionA

theorem family_exhaustion :
    ObservableLoss obsOuter C →
    (∀ i, FactorsThrough obsOuter (family i)) →
    ∀ i, ¬ SufficientFor (family i) C := by
  intro hLoss hFactor i
  exact loss_factor_implies_insufficient obsOuter (family i) C hLoss (hFactor i)

-- ============================================================
-- TASK 16: CROSS-BOUNDARY COMPLEMENTARITY
-- ============================================================

theorem cross_boundary_complementarity :
    (inside .regionA .outer ∧ ObservableLoss obsRegionA C) ∧
    (inside .regionB .outer ∧ ObservableLoss obsRegionB C) ∧
    SufficientFor obsInner C := by
  constructor
  · constructor
    · simp [inside]
    · refine ⟨(true, false), (true, true), ?_, ?_⟩
      · simp [obsRegionA]
      · simp [C]
  constructor
  · constructor
    · simp [inside]
    · refine ⟨(false, true), (true, true), ?_, ?_⟩
      · simp [obsRegionB]
      · simp [C]
  · intro x y h
    simp only [obsInner] at h
    exact h

-- ============================================================
-- AXIOM AUDIT
-- ============================================================

#print axioms residence_not_dependency
#print axioms relation_not_dependency
#print axioms observation_handoff
#print axioms depth_invariance
#print axioms factorising_child_pruned
#print axioms contained_nonfactorising_not_prunable
#print axioms cross_boundary_factorising_pruned
#print axioms complementarity_preserved
#print axioms nonprunable_not_sufficient
#print axioms family_exhaustion
#print axioms cross_boundary_complementarity

end RGI01
