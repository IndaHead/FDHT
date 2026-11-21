-- MRT-01 Three-operation decomposition falsification probe
-- External. Permanent FDHT untouched.
-- Goal: kill or weaken the three-operation model.

namespace MRT01

abbrev Persist (Store Input : Type) := Store → Input → Store
abbrev Recall (Store Requirement RecallState : Type) :=
  Store → Requirement → RecallState

structure MemoryOps (Store Input Requirement RecallState : Type) where
  persist : Persist Store Input
  recallOp : Recall Store Requirement RecallState

inductive Store where | empty | hasA | hasB
  deriving DecidableEq, Repr

inductive Input where | a | b
  deriving DecidableEq, Repr

inductive Requirement where | q0 | q1
  deriving DecidableEq, Repr

inductive RecallState where | none | gotA | gotB
  deriving DecidableEq, Repr

def concretePersist : Persist Store Input
  | _, Input.a => Store.hasA
  | _, Input.b => Store.hasB

def concreteRecall : Recall Store Requirement RecallState
  | Store.hasA, _ => RecallState.gotA
  | Store.hasB, _ => RecallState.gotB
  | Store.empty, _ => RecallState.none

def concreteOps : MemoryOps Store Input Requirement RecallState :=
  { persist := concretePersist, recallOp := concreteRecall }

theorem persist_returns_store (g : Store) (i : Input) :
    concreteOps.persist g i = concretePersist g i := rfl

theorem recall_returns_state (g : Store) (req : Requirement) :
    concreteOps.recallOp g req = concreteRecall g req := rfl

def CanPersistChange {Store Input : Type}
    (persist : Persist Store Input) : Prop :=
  ∃ g i, persist g i ≠ g

theorem concrete_can_persist_change :
    CanPersistChange concretePersist := by
  refine ⟨Store.empty, Input.a, ?_⟩
  decide

def persistIdentity : Persist Store Input := fun g _ => g

theorem identity_cannot_persist_change :
    ¬ CanPersistChange persistIdentity := by
  intro ⟨g, i, h⟩
  simp [persistIdentity] at h

def RequirementSensitive {Store Requirement RecallState : Type}
    (recallOp : Recall Store Requirement RecallState) : Prop :=
  ∃ g r₁ r₂, r₁ ≠ r₂ ∧ recallOp g r₁ ≠ recallOp g r₂

theorem concrete_not_requirement_sensitive :
    ¬ RequirementSensitive concreteRecall := by
  intro ⟨g, r₁, r₂, _, hne⟩
  cases g <;> cases r₁ <;> cases r₂ <;> simp [concreteRecall] at hne

def requirementSensitiveRecall : Recall Store Requirement RecallState
  | Store.hasA, Requirement.q0 => RecallState.gotA
  | Store.hasA, Requirement.q1 => RecallState.gotB
  | Store.hasB, _ => RecallState.gotB
  | Store.empty, _ => RecallState.none

theorem requirement_sensitive_witness :
    RequirementSensitive requirementSensitiveRecall := by
  refine ⟨Store.hasA, Requirement.q0, Requirement.q1, ?_, ?_⟩
  · decide
  · decide

def recallConstant : Recall Store Requirement RecallState :=
  fun _ _ => RecallState.none

theorem constant_not_requirement_sensitive :
    ¬ RequirementSensitive recallConstant := by
  intro ⟨_, _, _, _, hne⟩
  simp [recallConstant] at hne

def StoreSensitive {Store Requirement RecallState : Type}
    (recallOp : Recall Store Requirement RecallState) : Prop :=
  ∃ g₁ g₂ r, g₁ ≠ g₂ ∧ recallOp g₁ r ≠ recallOp g₂ r

theorem concrete_store_sensitive :
    StoreSensitive concreteRecall := by
  refine ⟨Store.hasA, Store.empty, Requirement.q0, ?_, ?_⟩
  · decide
  · decide

def recallIgnoringStore : Recall Store Requirement RecallState :=
  fun _ req => match req with
    | Requirement.q0 => RecallState.gotA
    | Requirement.q1 => RecallState.gotB

theorem ignoring_store_not_store_sensitive :
    ¬ StoreSensitive recallIgnoringStore := by
  intro ⟨g₁, g₂, r, _, hne⟩
  cases r <;> simp [recallIgnoringStore] at hne

def collapsePersist {Store Input Record : Type}
    (memorise : Input → Record)
    (retain : Store → Record → Store) :
    Persist Store Input :=
  fun g i => retain g (memorise i)

theorem collapsePersist_apply
    {Store Input Record : Type}
    (memorise : Input → Record)
    (retain : Store → Record → Store)
    (g : Store) (i : Input) :
    collapsePersist memorise retain g i = retain g (memorise i) := rfl

theorem everyPersist_has_trivial_factorisation
    {Store Input : Type}
    (persist : Persist Store Input) :
    ∃ (memorise : Input → Input) (retain : Store → Input → Store),
      ∀ g i, persist g i = retain g (memorise i) := by
  refine ⟨id, persist, ?_⟩
  intro g i
  rfl

inductive Action where
  | persistAct : Input → Action
  | recallAct : Requirement → Action

def step : Store → Action → Store × Option RecallState
  | g, Action.persistAct i => (concretePersist g i, none)
  | g, Action.recallAct req => (g, some (concreteRecall g req))

theorem tagged_can_encode :
    (step Store.empty (Action.persistAct Input.a)).1 = Store.hasA ∧
    (step Store.hasA (Action.recallAct Requirement.q0)).2 = some RecallState.gotA := by
  constructor
  · rfl
  · rfl

def SufficientFor {X Q Y : Type} (O : X → Q) (C : X → Y) : Prop :=
  ∀ x₁ x₂, O x₁ = O x₂ → C x₁ = C x₂

def cStore : Input → Store := fun i => concretePersist Store.empty i
def cRecall : Requirement → RecallState := concreteRecall Store.hasA

theorem store_consumer_determined :
    SufficientFor id cStore := by
  intro x₁ x₂ h
  simp [cStore]
  exact congrArg (concretePersist Store.empty) h

theorem recall_consumer_determined :
    SufficientFor id cRecall := by
  intro x₁ x₂ h
  simp [cRecall]
  exact congrArg (concreteRecall Store.hasA) h

def selectivePersist : Persist Store Input
  | g, Input.a => Store.hasA
  | g, Input.b => g

theorem selective_changes_for_a_not_b :
    selectivePersist Store.empty Input.a ≠ Store.empty ∧
    selectivePersist Store.empty Input.b = Store.empty := by
  constructor
  · decide
  · rfl

def reqOnly : Recall Store Requirement RecallState
  | _, Requirement.q0 => RecallState.gotA
  | _, Requirement.q1 => RecallState.gotB

theorem req_only_is_req_sensitive :
    RequirementSensitive reqOnly := by
  refine ⟨Store.empty, Requirement.q0, Requirement.q1, ?_, ?_⟩
  · decide
  · decide

theorem req_only_not_store_sensitive :
    ¬ StoreSensitive reqOnly := by
  intro ⟨g₁, g₂, r, _, hne⟩
  cases r <;> simp [reqOnly] at hne

def bothSensitive : Recall Store Requirement RecallState
  | Store.hasA, Requirement.q0 => RecallState.gotA
  | Store.hasA, Requirement.q1 => RecallState.gotB
  | Store.hasB, _ => RecallState.gotB
  | Store.empty, _ => RecallState.none

theorem both_sensitive_req :
    RequirementSensitive bothSensitive := by
  refine ⟨Store.hasA, Requirement.q0, Requirement.q1, ?_, ?_⟩
  · decide
  · decide

theorem both_sensitive_store :
    StoreSensitive bothSensitive := by
  refine ⟨Store.hasA, Store.empty, Requirement.q0, ?_, ?_⟩
  · decide
  · decide

#check MemoryOps
#check collapsePersist_apply
#check everyPersist_has_trivial_factorisation
#check concrete_can_persist_change
#check identity_cannot_persist_change
#check requirement_sensitive_witness
#check concrete_store_sensitive
#check tagged_can_encode

end MRT01
