namespace CRTFactorisation

/-!
# CRT Factorisation Persistence / Restoration Boundary

Research evidence only. Not permanent FDHT mathematics.

This probe freezes the generic factorisation persistence theorem and
its dual restoration/non-factorisation corollary.
-/

def SufficientFor {X Y R : Type}
    (T : X → Y) (C : X → R) : Prop :=
  ∀ x y, T x = T y → C x = C y

def ObservableLoss {X Y R : Type}
    (T : X → Y) (C : X → R) : Prop :=
  ∃ x y, T x = T y ∧ C x ≠ C y

/-- A representation `U` factors entirely through `T`
    when `U` can be computed from `T`'s output alone. -/
def FactorsThrough {X Y Z : Type}
    (T : X → Y)
    (U : X → Z) : Prop :=
  ∃ P : Y → Z, ∀ x, U x = P (T x)


/-- Consumer-relative loss persists through every representation
    that factors entirely through the lossy transformation. -/
theorem observableLoss_of_factorsThrough
    {X Y Z R : Type}
    (T : X → Y)
    (U : X → Z)
    (C : X → R)
    (hFactor : FactorsThrough T U)
    (hLoss : ObservableLoss T C) :
    ObservableLoss U C := by
  obtain ⟨P, hP⟩ := hFactor
  obtain ⟨x, y, hT, hC⟩ := hLoss
  refine ⟨x, y, ?_, hC⟩
  calc
    U x = P (T x) := hP x
    _ = P (T y) := congrArg P hT
    _ = U y := (hP y).symm


/-- If `T` loses a distinction required by `C`, but `U` is sufficient
    for `C`, then `U` cannot be determined solely from `T`'s output. -/
theorem restoration_implies_not_factorsThrough
    {X Y Z R : Type}
    (T : X → Y)
    (U : X → Z)
    (C : X → R)
    (hLoss : ObservableLoss T C)
    (hSuff : SufficientFor U C) :
    ¬ FactorsThrough T U := by
  intro hFactor
  have hULoss : ObservableLoss U C :=
    observableLoss_of_factorsThrough T U C hFactor hLoss
  obtain ⟨x, y, hU, hC⟩ := hULoss
  exact hC (hSuff x y hU)


/-- Direct proof control without invoking observableLoss_of_factorsThrough. -/
theorem restoration_direct
    {X Y Z R : Type}
    (T : X → Y)
    (U : X → Z)
    (C : X → R)
    (hLoss : ObservableLoss T C)
    (hSuff : SufficientFor U C) :
    ¬ FactorsThrough T U := by
  intro hFactor
  obtain ⟨P, hP⟩ := hFactor
  obtain ⟨x, y, hT, hC⟩ := hLoss
  have hU : U x = U y := by
    calc
      U x = P (T x) := hP x
      _ = P (T y) := congrArg P hT
      _ = U y := (hP y).symm
  exact hC (hSuff x y hU)


/-! ## Minimal two-state boundary fixture -/

inductive MicroX where | a | b deriving DecidableEq

def microT : MicroX → Unit := fun _ => ()

def microC : MicroX → Bool
  | .a => false
  | .b => true

def microU : MicroX → Bool
  | .a => false
  | .b => true

theorem micro_observableLoss :
    ObservableLoss microT microC := by
  exact ⟨MicroX.a, MicroX.b, rfl, by decide⟩

theorem micro_sufficient :
    SufficientFor microU microC := by
  intro x y h
  cases x <;> cases y <;> simp [microU, microC] at *

theorem micro_not_factorsThrough :
    ¬ FactorsThrough microT microU :=
  restoration_implies_not_factorsThrough microT microU microC micro_observableLoss micro_sufficient


/-! ## Factor-through control -/

def microUfactor : MicroX → Unit := fun _ => ()

theorem micro_ufactor_factorsThrough :
    FactorsThrough microT microUfactor := by
  refine ⟨id, ?_⟩
  intro x
  rfl

theorem micro_ufactor_has_loss :
    ObservableLoss microUfactor microC := by
  exact ⟨MicroX.a, MicroX.b, rfl, by decide⟩


/-! ## Stronger-claim attacks -/

-- A: ¬ FactorsThrough → SufficientFor (false)
inductive MicroX3 where | a | b | c deriving DecidableEq

def microT3 : MicroX3 → Bool
  | MicroX3.a => false
  | MicroX3.b => false
  | MicroX3.c => true

def microC3 : MicroX3 → Bool
  | MicroX3.a => false
  | MicroX3.b => true
  | MicroX3.c => false

def counterU_A3 : MicroX3 → Bool
  | MicroX3.a => false
  | MicroX3.b => true
  | MicroX3.c => true

theorem counterA3_not_factorsThrough :
    ¬ FactorsThrough microT3 counterU_A3 := by
  intro ⟨P, hP⟩
  have ha := hP MicroX3.a
  have hb := hP MicroX3.b
  simp [microT3, counterU_A3] at ha hb
  have : false = true := by
    calc
      false = counterU_A3 MicroX3.a := rfl
      _ = P (microT3 MicroX3.a) := ha.symm
      _ = P (microT3 MicroX3.b) := rfl
      _ = counterU_A3 MicroX3.b := hb
  exact (by decide : false ≠ true) this

theorem counterA3_not_sufficient :
    ¬ SufficientFor counterU_A3 microC3 := by
  intro h
  have : microC3 MicroX3.b = microC3 MicroX3.c := h MicroX3.b MicroX3.c (by decide)
  exact (by decide : microC3 MicroX3.b ≠ microC3 MicroX3.c) this

-- B: SufficientFor → ¬ FactorsThrough (false without ObservableLoss)
def microC_coarse : MicroX → Bool := fun _ => true
def microU_coarse : MicroX → Unit := fun _ => ()

theorem counterB_sufficient :
    SufficientFor microU_coarse microC_coarse := by
  intro x y h
  rfl

theorem counterB_factorsThrough :
    FactorsThrough microT microU_coarse := by
  refine ⟨id, ?_⟩
  intro x
  rfl

-- C: ObservableLoss → ¬ FactorsThrough (false without sufficiency of U)
theorem counterC_factorsThrough_with_loss :
    FactorsThrough microT microUfactor ∧ ObservableLoss microT microC := by
  constructor
  · exact micro_ufactor_factorsThrough
  · exact micro_observableLoss

-- D: ¬ FactorsThrough → Injective (false)
theorem counterD_not_injective :
    ¬ Function.Injective counterU_A3 := by
  intro h
  have : MicroX3.b = MicroX3.c := h (by decide)
  exact (by decide : MicroX3.b ≠ MicroX3.c) this


/-! ## Compile-time surface checks -/

#check SufficientFor
#check ObservableLoss
#check FactorsThrough
#check observableLoss_of_factorsThrough
#check restoration_implies_not_factorsThrough
#check restoration_direct


/-! ## Trust audit -/

#print axioms observableLoss_of_factorsThrough
#print axioms restoration_implies_not_factorsThrough
#print axioms restoration_direct

end CRTFactorisation
