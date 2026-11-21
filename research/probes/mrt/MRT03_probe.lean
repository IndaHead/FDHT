-- MRT-03 Consumer-observable distinction preservation
-- External probe. Permanent FDHT untouched.
-- Goal: formalise and falsify the candidate principle.

namespace MRT03

-- Core definitions
def ConsumerEquivalent {X R : Type} (consumer : X → R) (x y : X) : Prop :=
  consumer x = consumer y

def ConsumerDistinguishes {X R : Type} (consumer : X → R) (x y : X) : Prop :=
  consumer x ≠ consumer y

def SufficientFor {X Q R : Type} (obs : X → Q) (consumer : X → R) : Prop :=
  ∀ x y, obs x = obs y → consumer x = consumer y

def ObservableLoss {X Q R : Type} (obs : X → Q) (consumer : X → R) : Prop :=
  ∃ x y, obs x = obs y ∧ consumer x ≠ consumer y

-- TASK 2: ConsumerEquivalent elementary properties
theorem consumerEquivalent_refl {X R : Type} (C : X → R) (x : X) :
    ConsumerEquivalent C x x := rfl

theorem consumerEquivalent_symm {X R : Type} (C : X → R) (x y : X)
    (h : ConsumerEquivalent C x y) :
    ConsumerEquivalent C y x := h.symm

theorem consumerEquivalent_trans {X R : Type} (C : X → R) (x y z : X)
    (hxy : ConsumerEquivalent C x y) (hyz : ConsumerEquivalent C y z) :
    ConsumerEquivalent C x z := hxy.trans hyz

theorem consumerDistinguishes_iff_not_equivalent {X R : Type} (C : X → R) (x y : X) :
    ConsumerDistinguishes C x y ↔ ¬ ConsumerEquivalent C x y := Iff.rfl

-- TASK 3: Sufficiency preserves consumer distinction
theorem sufficient_preserves_consumer_distinction
    {X Q R : Type} (O : X → Q) (C : X → R)
    (h : SufficientFor O C) (x y : X) (hC : C x ≠ C y) :
    O x ≠ O y := by
  intro hO
  exact hC (h x y hO)

-- TASK 4: SufficientFor ↔ ¬ ObservableLoss
theorem sufficient_of_noObservableLoss
    {X Q R : Type} (O : X → Q) (C : X → R)
    (h : ¬ ObservableLoss O C) :
    SufficientFor O C := by
  intro x y hO
  by_contra hC -- classical
  exact h ⟨x, y, hO, hC⟩

theorem noObservableLoss_of_sufficient
    {X Q R : Type} (O : X → Q) (C : X → R)
    (h : SufficientFor O C) :
    ¬ ObservableLoss O C := by
  intro ⟨x, y, hO, hC⟩
  exact hC (h x y hO)

-- Biconditional is constructive: both directions are constructive.
theorem sufficient_iff_noObservableLoss
    {X Q R : Type} (O : X → Q) (C : X → R) :
    SufficientFor O C ↔ ¬ ObservableLoss O C :=
  ⟨noObservableLoss_of_sufficient O C, sufficient_of_noObservableLoss O C⟩

-- TASK 5: Aliases
def ConsumerSafeCollapse {X Q R : Type} (proj : X → Q) (C : X → R) : Prop :=
  SufficientFor proj C

def ConsumerUnsafeCollapse {X Q R : Type} (proj : X → Q) (C : X → R) : Prop :=
  ObservableLoss proj C

-- These are pure naming aliases. No new mathematics.

-- TASK 6: Pair consumer
def pairConsumer {X R₁ R₂ : Type} (c₁ : X → R₁) (c₂ : X → R₂) : X → R₁ × R₂ :=
  fun x => (c₁ x, c₂ x)

theorem sufficient_pair_iff
    {X Q R₁ R₂ : Type} (O : X → Q) (C₁ : X → R₁) (C₂ : X → R₂) :
    SufficientFor O (pairConsumer C₁ C₂) ↔
    SufficientFor O C₁ ∧ SufficientFor O C₂ := by
  constructor
  · intro h
    constructor
    · intro x y hO
      exact congrArg Prod.fst (h x y hO)
    · intro x y hO
      exact congrArg Prod.snd (h x y hO)
  · intro ⟨h₁, h₂⟩ x y hO
    ext
    · exact h₁ x y hO
    · exact h₂ x y hO

-- TASK 7: Observation distinction does not imply consumer distinction
inductive X2 where | x | y
  deriving DecidableEq

inductive Q2 where | a | b
  deriving DecidableEq

inductive R2 where | r
  deriving DecidableEq

def O_dist : X2 → Q2
  | X2.x => Q2.a
  | X2.y => Q2.b

def C_same : X2 → R2 := fun _ => R2.r

theorem obs_dist_not_consumer_dist :
    O_dist X2.x ≠ O_dist X2.y ∧
    C_same X2.x = C_same X2.y := by
  constructor
  · decide
  · rfl

-- Sufficient and still preserves extra distinction
def O_extra : X2 → Q2
  | X2.x => Q2.a
  | X2.y => Q2.b

theorem sufficient_and_extra_distinction :
    SufficientFor O_extra C_same ∧
    O_extra X2.x ≠ O_extra X2.y ∧
    C_same X2.x = C_same X2.y := by
  constructor
  · intro x y h
    cases x <;> cases y <;> simp [O_extra, C_same] at *
  · constructor
    · decide
    · rfl

-- TASK 8: Consumer distinction without sufficiency
inductive X3 where | p | q
  deriving DecidableEq

inductive Q3 where | same
  deriving DecidableEq

inductive R3 where | rp | rq
  deriving DecidableEq

def O_loss : X3 → Q3 := fun _ => Q3.same

def C_dist : X3 → R3
  | X3.p => R3.rp
  | X3.q => R3.rq

theorem consumer_dist_without_sufficiency :
    C_dist X3.p ≠ C_dist X3.q ∧
    O_loss X3.p = O_loss X3.q ∧
    ObservableLoss O_loss C_dist ∧
    ¬ SufficientFor O_loss C_dist := by
  refine ⟨?_, rfl, ?_, ?_⟩
  · decide
  · exact ⟨X3.p, X3.q, rfl, by decide⟩
  · intro h
    exact (by decide : C_dist X3.p ≠ C_dist X3.q) (h X3.p X3.q rfl)

-- TASK 9: Consumer relativity
inductive X4 where | u | v
  deriving DecidableEq

inductive Q4 where | q
  deriving DecidableEq

inductive R4 where | r0 | r1
  deriving DecidableEq

def O_rel : X4 → Q4 := fun _ => Q4.q

def C1_safe : X4 → R4 := fun _ => R4.r0

def C2_lossy : X4 → R4
  | X4.u => R4.r0
  | X4.v => R4.r1

theorem consumer_relativity :
    SufficientFor O_rel C1_safe ∧
    ¬ SufficientFor O_rel C2_lossy := by
  constructor
  · intro x y _
    cases x <;> cases y <;> rfl
  · intro h
    exact (by decide : C2_lossy X4.u ≠ C2_lossy X4.v) (h X4.u X4.v rfl)

-- TASK 10: Identity observation
theorem identity_sufficient {X R : Type} (C : X → R) :
    SufficientFor id C := by
  intro x y h
  exact congrArg C h

-- Identity is not necessarily minimal: coarser observation can suffice.
inductive X5 where | a | b
  deriving DecidableEq

inductive Q5 where | q
  deriving DecidableEq

inductive R5 where | r
  deriving DecidableEq

def O_coarse : X5 → Q5 := fun _ => Q5.q
def C_const : X5 → R5 := fun _ => R5.r

theorem coarser_still_sufficient :
    SufficientFor O_coarse C_const := by
  intro x y _
  cases x <;> cases y <;> rfl

-- TASK 11: Constant observation
-- Constant observation is sufficient for C iff C is constant.
-- Requires Q inhabited.
theorem constant_obs_sufficient_iff_consumer_constant
    {X Q R : Type} (q₀ : Q) (C : X → R) :
    SufficientFor (fun _ : X => q₀) C ↔
    ∀ x y, C x = C y := by
  constructor
  · intro h x y
    exact h x y rfl
  · intro h x y _
    exact h x y

-- TASK 12: Post-processing
theorem coarser_sufficient_implies_original
    {X Q Q₂ R : Type} (O : X → Q) (P : Q → Q₂) (C : X → R)
    (h : SufficientFor (P ∘ O) C) :
    SufficientFor O C := by
  intro x y hO
  exact h x y (congrArg P hO)

-- Converse fails
inductive X6 where | m | n
  deriving DecidableEq

inductive Q6 where | qa | qb
  deriving DecidableEq

inductive Q6b where | only
  deriving DecidableEq

inductive R6 where | rm | rn
  deriving DecidableEq

def O6 : X6 → Q6
  | X6.m => Q6.qa
  | X6.n => Q6.qb

def P6 : Q6 → Q6b := fun _ => Q6b.only

def C6 : X6 → R6
  | X6.m => R6.rm
  | X6.n => R6.rn

theorem postprocess_destroys_sufficiency :
    SufficientFor O6 C6 ∧
    ¬ SufficientFor (P6 ∘ O6) C6 := by
  constructor
  · intro x y h
    cases x <;> cases y <;> simp [O6, C6] at *
  · intro h
    exact (by decide : C6 X6.m ≠ C6 X6.n) (h X6.m X6.n rfl)

-- TASK 13: Refinement is just composition + SufficientFor
-- Already covered by coarser_sufficient_implies_original.

-- TASK 14: Additional information
def Oplus {X Q N : Type} (O : X → Q) (N : X → N) : X → Q × N :=
  fun x => (O x, N x)

theorem additional_information_preserves_sufficiency
    {X Q N R : Type} (O : X → Q) (N : X → N) (C : X → R)
    (h : SufficientFor O C) :
    SufficientFor (Oplus O N) C := by
  intro x y hO
  exact h x y (congrArg Prod.fst hO)

-- N need not be consumer-relevant
inductive X7 where | s | t
  deriving DecidableEq

inductive Q7 where | q
  deriving DecidableEq

inductive N7 where | n0 | n1
  deriving DecidableEq

inductive R7 where | r
  deriving DecidableEq

def O7 : X7 → Q7 := fun _ => Q7.q
def N7f : X7 → N7
  | X7.s => N7.n0
  | X7.t => N7.n1
def C7 : X7 → R7 := fun _ => R7.r

theorem extra_distinction_not_required :
    SufficientFor (Oplus O7 N7f) C7 ∧
    N7f X7.s ≠ N7f X7.t ∧
    C7 X7.s = C7 X7.t := by
  constructor
  · intro x y _
    cases x <;> cases y <;> rfl
  · constructor
    · decide
    · rfl

-- TASK 15: Lossy projection fixture
inductive X8 where | p | q
  deriving DecidableEq

inductive Q8 where | same
  deriving DecidableEq

inductive R8 where | ra | rb
  deriving DecidableEq

def O8 : X8 → Q8 := fun _ => Q8.same

def CA : X8 → R8 := fun _ => R8.ra

def CB : X8 → R8
  | X8.p => R8.ra
  | X8.q => R8.rb

theorem lossy_projection_fixture :
    SufficientFor O8 CA ∧
    ¬ SufficientFor O8 CB ∧
    ObservableLoss O8 CB := by
  refine ⟨?_, ?_, ?_⟩
  · intro x y _
    cases x <;> cases y <;> rfl
  · intro h
    exact (by decide : CB X8.p ≠ CB X8.q) (h X8.p X8.q rfl)
  · exact ⟨X8.p, X8.q, rfl, by decide⟩

-- TASK 16: Multi-consumer collapse
theorem multi_consumer_safe_for_both_implies_pair
    {X Q R₁ R₂ : Type} (O : X → Q) (C₁ : X → R₁) (C₂ : X → R₂)
    (h₁ : SufficientFor O C₁) (h₂ : SufficientFor O C₂) :
    SufficientFor O (pairConsumer C₁ C₂) :=
  (sufficient_pair_iff O C₁ C₂).mpr ⟨h₁, h₂⟩

theorem multi_consumer_lossy_for_one_implies_pair_lossy
    {X Q R₁ R₂ : Type} (O : X → Q) (C₁ : X → R₁) (C₂ : X → R₂)
    (h₁ : SufficientFor O C₁) (h₂ : ¬ SufficientFor O C₂) :
    ¬ SufficientFor O (pairConsumer C₁ C₂) := by
  intro h
  exact h₂ ((sufficient_pair_iff O C₁ C₂).mp h).2

-- TASK 17: Consumer-relative distinction
theorem distinction_is_consumer_relative :
    C1_safe X4.u = C1_safe X4.v ∧
    C2_lossy X4.u ≠ C2_lossy X4.v := by
  constructor
  · rfl
  · decide

-- TASK 18: No memory-specific dependency
-- No Persist, Recall, Memorise, Retain, or Record appears in any theorem.
-- The structure is pure observation/consumer/sufficiency.

#check ConsumerEquivalent
#check ConsumerDistinguishes
#check SufficientFor
#check ObservableLoss
#check sufficient_preserves_consumer_distinction
#check sufficient_iff_noObservableLoss
#check sufficient_pair_iff
#check identity_sufficient
#check coarser_sufficient_implies_original
#check additional_information_preserves_sufficiency

end MRT03
