-- CRT-01 Consumer-relative transformation composition
-- External probe. Permanent FDHT untouched.
-- Goal: kill composition hypotheses.

namespace CRT01

def SufficientFor {X Y R : Type} (T : X → Y) (C : X → R) : Prop :=
  ∀ x y, T x = T y → C x = C y

def ObservableLoss {X Y R : Type} (T : X → Y) (C : X → R) : Prop :=
  ∃ x y, T x = T y ∧ C x ≠ C y

-- TASK 2: Two-stage backward sufficiency
theorem downstream_sufficient_implies_upstream
    {X Y Z R : Type} (T : X → Y) (P : Y → Z) (C : X → R)
    (h : SufficientFor (fun x => P (T x)) C) :
    SufficientFor T C := by
  intro x y hT
  exact h x y (congrArg P hT)

-- TASK 3: Converse countermodel
inductive X2 where | a | b
  deriving DecidableEq

inductive Y2 where | ya | yb
  deriving DecidableEq

inductive Z2 where | z
  deriving DecidableEq

inductive R2 where | ra | rb
  deriving DecidableEq

def T2 : X2 → Y2
  | X2.a => Y2.ya
  | X2.b => Y2.yb

def P2 : Y2 → Z2 := fun _ => Z2.z

def C2 : X2 → R2
  | X2.a => R2.ra
  | X2.b => R2.rb

theorem converse_fails :
    SufficientFor T2 C2 ∧
    ¬ SufficientFor (fun x => P2 (T2 x)) C2 := by
  constructor
  · intro x y h
    cases x <;> cases y <;> simp [T2, C2] at *
  · intro h
    exact (by decide : C2 X2.a ≠ C2 X2.b) (h X2.a X2.b rfl)

-- TASK 4: ObservableLoss post-processing
theorem observableLoss_postprocess
    {X Y Z R : Type} (T : X → Y) (P : Y → Z) (C : X → R)
    (hLoss : ObservableLoss T C) :
    ObservableLoss (fun x => P (T x)) C := by
  obtain ⟨x, y, hT, hC⟩ := hLoss
  exact ⟨x, y, congrArg P hT, hC⟩

-- TASK 5: Collision post-processing
theorem collision_postprocess
    {X Y Z : Type} (T : X → Y) (P : Y → Z) (x y : X)
    (h : T x = T y) :
    P (T x) = P (T y) := congrArg P h

-- TASK 6: No deterministic re-separation
-- If T x = T y, then P (T x) = P (T y) for any common P.
-- This is collision_postprocess. No stronger claim is justified.

-- TASK 7: ¬SufficientFor propagation
-- Constructive: ObservableLoss propagates (observableLoss_postprocess).
-- ¬SufficientFor does not constructively provide a witness.
-- Classical bridge requires Classical.choice / byContradiction.

-- TASK 8: Identity consumer / injectivity
theorem sufficient_identity_iff_injective
    {X Y : Type} (T : X → Y) :
    SufficientFor T (fun x => x) ↔ Function.Injective T := by
  constructor
  · intro h x y hT
    exact h x y hT
  · intro h x y hT
    exact h hT

-- TASK 9: Injectivity ≠ constructive reconstruction
-- Function.Injective T does not constructively provide recover : Y → X
-- such that recover (T x) = x for arbitrary types.
-- This requires additional structure (e.g., decidable equality + finiteness,
-- or classical choice). Classification: requires additional structure.

-- TASK 10: Three-stage composition
theorem three_stage_backward
    {X0 X1 X2 X3 R : Type}
    (T1 : X0 → X1) (T2 : X1 → X2) (T3 : X2 → X3) (C : X0 → R)
    (h : SufficientFor (fun x => T3 (T2 (T1 x))) C) :
    SufficientFor (fun x => T2 (T1 x)) C :=
  downstream_sufficient_implies_upstream
    (fun x => T2 (T1 x)) T3 C h

theorem three_stage_backward_again
    {X0 X1 X2 X3 R : Type}
    (T1 : X0 → X1) (T2 : X1 → X2) (T3 : X2 → X3) (C : X0 → R)
    (h : SufficientFor (fun x => T2 (T1 x)) C) :
    SufficientFor T1 C :=
  downstream_sufficient_implies_upstream T1 T2 C h

-- TASK 11: Loss through three stages
theorem loss_propagates_to_f2
    {X0 X1 X2 R : Type}
    (T1 : X0 → X1) (T2 : X1 → X2) (C : X0 → R)
    (h : ObservableLoss T1 C) :
    ObservableLoss (fun x => T2 (T1 x)) C :=
  observableLoss_postprocess T1 T2 C h

theorem loss_propagates_to_f3
    {X0 X1 X2 X3 R : Type}
    (T1 : X0 → X1) (T2 : X1 → X2) (T3 : X2 → X3) (C : X0 → R)
    (h : ObservableLoss (fun x => T2 (T1 x)) C) :
    ObservableLoss (fun x => T3 (T2 (T1 x))) C :=
  observableLoss_postprocess (fun x => T2 (T1 x)) T3 C h

-- TASK 12: Sufficiency profile
-- Downstream sufficiency implies upstream. Patterns like
-- false, true, true are impossible.
-- true, true, false is possible (post-processing can destroy).

inductive Xc where | p | q
  deriving DecidableEq

inductive Yc where | ya | yb
  deriving DecidableEq

inductive Zc where | z
  deriving DecidableEq

inductive Rc where | ra | rb
  deriving DecidableEq

def F1 : Xc → Yc
  | Xc.p => Yc.ya
  | Xc.q => Yc.yb

def F2 : Yc → Zc := fun _ => Zc.z

def Cc : Xc → Rc
  | Xc.p => Rc.ra
  | Xc.q => Rc.rb

theorem profile_true_true_false :
    SufficientFor F1 Cc ∧
    SufficientFor (fun x => F2 (F1 x)) Cc = False := by
  constructor
  · intro x y h
    cases x <;> cases y <;> simp [F1, Cc] at *
  · intro h
    exact (by decide : Cc Xc.p ≠ Cc Xc.q) (h Xc.p Xc.q rfl)

-- true, true, true: identity chain
theorem profile_true_true_true :
    SufficientFor id (fun x : Xc => x) ∧
    SufficientFor id (fun x : Xc => x) ∧
    SufficientFor id (fun x : Xc => x) := by
  constructor
  · intro x y h; exact h
  · constructor
    · intro x y h; exact h
    · intro x y h; exact h

-- TASK 13: First loss index candidate
-- F1 sufficient, F2 insufficient is possible (profile_true_true_false).
-- This is a finite fixture observation only. No permanent FirstLoss.

-- TASK 14: Augmentation can restore
inductive W where | wa | wb
  deriving DecidableEq

def A : Xc → W
  | Xc.p => W.wa
  | Xc.q => W.wb

def augmented : Xc → Zc × W := fun x => (F2 (F1 x), A x)

theorem augmentation_restores :
    ObservableLoss F1 Cc ∧
    SufficientFor augmented Cc := by
  constructor
  · exact ⟨Xc.p, Xc.q, rfl, by decide⟩
  · intro x y h
    cases x <;> cases y <;> simp [augmented, F1, F2, A, Cc] at *

-- TASK 15: Irrelevant augmentation
def A_irrelevant : Xc → W
  | Xc.p => W.wa
  | Xc.q => W.wb

def augmented_irrelevant : Xc → Yc × W := fun x => (F1 x, A_irrelevant x)

theorem irrelevant_augmentation_preserves :
    SufficientFor F1 Cc ∧
    SufficientFor augmented_irrelevant Cc ∧
    augmented_irrelevant Xc.p ≠ augmented_irrelevant Xc.q ∧
    Cc Xc.p = Cc Xc.q := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro x y h
    cases x <;> cases y <;> simp [F1, Cc] at *
  · intro x y h
    cases x <;> cases y <;> simp [augmented_irrelevant, F1, A_irrelevant, Cc] at *
  · decide
  · decide

-- TASK 16: Pair consumers through composition
def pairConsumer {X R1 R2 : Type} (c1 : X → R1) (c2 : X → R2) : X → R1 × R2 :=
  fun x => (c1 x, c2 x)

theorem pair_through_composition
    {X Y Z R1 R2 : Type}
    (T : X → Y) (P : Y → Z) (C1 : X → R1) (C2 : X → R2)
    (h : SufficientFor (fun x => P (T x)) (pairConsumer C1 C2)) :
    SufficientFor T C1 ∧ SufficientFor T C2 := by
  constructor
  · intro x y hT
    exact congrArg Prod.fst (h x y (congrArg P hT))
  · intro x y hT
    exact congrArg Prod.snd (h x y (congrArg P hT))

-- TASK 17: Kernel inclusion is informal interpretation only.
-- SufficientFor T C is exactly ∀ x y, T x = T y → C x = C y.
-- Composition gives T x = T y → P (T x) = P (T y).
-- No permanent Kernel abstraction.

-- TASK 18: Recurrence is theorem reuse under function composition.
-- No fractal theorem.

#check SufficientFor
#check ObservableLoss
#check downstream_sufficient_implies_upstream
#check observableLoss_postprocess
#check collision_postprocess
#check sufficient_identity_iff_injective
#check three_stage_backward
#check augmentation_restores

end CRT01
