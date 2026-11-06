import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC3

/-!
# C₃ — Evidence-Gated Downstream Request Admission

Dependent consumer-trajectory test.
Upstream established result unlocks downstream request construction.
Probe-local only. Not a generic Consumer API.
-/

/-! ============================================================
    TASK 1 — Minimum C₂ shapes (duplicated, C₂ unchanged)
============================================================ -/

structure ChiralityDescriptionRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  family : ThreadFamily resolve n
  value  : ChiralityValue

def ChiralityDescriptionRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n) : Prop :=
  ChiralityValueDescribes resolve req.family req.value

inductive ChiralityDescriptionResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n) where
  | established : req.claim → ChiralityDescriptionResult req
  | refuted     : (req.claim → False) → ChiralityDescriptionResult req
  | unresolved  : ChiralityDescriptionResult req

def establishChiralityDescription
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n)
    (h : req.claim) :
    ChiralityDescriptionResult req :=
  .established h

/-! ============================================================
    TASK 2 — Upstream request
============================================================ -/

def input_separated_request
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionRequest resolve 2 where
  family := familyUnequal resolve 2 h
  value  := .separated

def result_input_separated
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionResult (input_separated_request resolve h) :=
  establishChiralityDescription
    (input_separated_request resolve h)
    (familyUnequal_chiralityValue_separated_n2 resolve h)

/-! ============================================================
    TASK 3 — Downstream transition request
============================================================ -/

structure FoldedTransitionRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  transform      : AggregateFamilyTransform resolve n
  input          : ThreadFamily resolve n
  fromValue      : ChiralityValue
  toValue        : ChiralityValue
  inputDescribed : ChiralityValueDescribes resolve input fromValue

/-! ============================================================
    TASK 4 — Downstream claim
============================================================ -/

def FoldedTransitionRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : FoldedTransitionRequest resolve n) : Prop :=
  ThreadFamilyKernel resolve (req.transform req.input) req.input
  ∧
  ChiralityValueDescribes resolve (req.transform req.input) req.toValue

/-! ============================================================
    TASK 5 — Downstream result
============================================================ -/

inductive FoldedTransitionResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : FoldedTransitionRequest resolve n) where
  | established : req.claim → FoldedTransitionResult req
  | refuted     : (req.claim → False) → FoldedTransitionResult req
  | unresolved  : FoldedTransitionResult req

def establishFoldedTransition
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : FoldedTransitionRequest resolve n)
    (h : req.claim) :
    FoldedTransitionResult req :=
  .established h

/-! ============================================================
    TASK 6 — Admission function (dependent type)
============================================================ -/

def AdmittedFoldedTransition
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    {inputReq : ChiralityDescriptionRequest resolve n}
    (upstream : ChiralityDescriptionResult inputReq) : Type :=
  match upstream with
  | .established _ => FoldedTransitionRequest resolve n
  | .refuted _     => PEmpty
  | .unresolved    => PEmpty

-- Admission function requires explicit proof payload recovery.
-- Status alone is insufficient. The proof must be extracted by pattern matching.
-- Classification: TYPE-LEVEL SEPARATION

/-! ============================================================
    TASK 7 — Established prerequisite admits
============================================================ -/

def admitted_transition_request
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    FoldedTransitionRequest resolve 2 :=
  {
    transform := neighbourComposeTransform resolve h
    input := familyUnequal resolve 2 h
    fromValue := .separated
    toValue := .aligned
    inputDescribed := familyUnequal_chiralityValue_separated_n2 resolve h
  }

/-! ============================================================
    TASK 8 — Establish downstream claim
============================================================ -/

theorem downstream_claim_established
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    (admitted_transition_request resolve h).claim := by
  have hFT := neighbourCompose_foldedTrivial_chiralityTransition_n2 resolve h
  exact ⟨hFT.1, hFT.2.2⟩

def result_folded_transition
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    FoldedTransitionResult (admitted_transition_request resolve h) :=
  establishFoldedTransition
    (admitted_transition_request resolve h)
    (downstream_claim_established resolve h)

/-! ============================================================
    TASK 9 — Reconstruct complete transition
============================================================ -/

theorem complete_transition_reconstructed
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    FoldedTrivialChiralityTransition
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      .separated
      .aligned := by
  exact neighbourCompose_foldedTrivial_chiralityTransition_n2 resolve h

/-! ============================================================
    TASK 10 — Refuted prerequisite must not admit
============================================================ -/

theorem original_not_aligned
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ¬ ChiralityValueDescribes resolve (familyUnequal resolve 2 h) .aligned := by
  intro hAl
  have hSep := familyUnequal_chiralityValue_separated_n2 resolve h
  exact chiralityValueDescribes_exclusive resolve (familyUnequal resolve 2 h) ⟨hAl, hSep⟩

def result_input_aligned_refuted
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionResult
      { family := familyUnequal resolve 2 h, value := .aligned } :=
  .refuted (original_not_aligned resolve h)

-- Attempting to construct FoldedTransitionRequest with fromValue := .aligned
-- requires ChiralityValueDescribes resolve p .aligned, which is refuted.
-- The following is intentionally ill-typed and commented:
--
-- def invalid_admitted_from_refuted
--     (resolve : KernelExpr → Store → Location)
--     (h : 1 < 2) :
--     FoldedTransitionRequest resolve 2 :=
--   {
--     transform := neighbourComposeTransform resolve h
--     input := familyUnequal resolve 2 h
--     fromValue := .aligned
--     toValue := .separated
--     inputDescribed := by contradiction  -- proof unavailable and refuted
--   }
--
-- Classification: TYPE/THEOREM REJECTION

/-! ============================================================
    TASK 11 — Unresolved prerequisite must not admit
============================================================ -/

def result_arbitrary_unresolved
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 2) :
    ChiralityDescriptionResult { family := p, value := .aligned } :=
  .unresolved

-- Unresolved carries no proof. Cannot construct FoldedTransitionRequest
-- without supplying an explicit proof.
-- Classification: LACK OF JUSTIFIED EVIDENCE

/-! ============================================================
    TASK 12 — Status-only firewall
============================================================ -/

inductive ChiralityDescriptionStatus where
  | established
  | refuted
  | unresolved

def ChiralityDescriptionResult.status
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    {req : ChiralityDescriptionRequest resolve n}
    : ChiralityDescriptionResult req → ChiralityDescriptionStatus
  | .established _ => .established
  | .refuted _     => .refuted
  | .unresolved    => .unresolved

-- status = established is not sufficient to inhabit ChiralityValueDescribes.
-- The actual proof payload must be recovered by dependent pattern matching.
-- Classification: TYPE-LEVEL SEPARATION

/-! ============================================================
    TASK 13 — Refuted vs Unresolved distinction
============================================================ -/

-- Both block downstream construction, but remain semantically distinct:
-- REFUTED carries: input claim → False
-- UNRESOLVED carries: neither proof nor refutation
--
-- Option-based admission would map both to None (lossy).
-- Dependent type-based admission maps both to PEmpty (lossy for distinction).
-- The original proof-bearing upstream result must be retained separately.
--
-- Classification: Option/PEmpty sufficient for "can admission proceed?"
-- but original result must be retained separately.

/-! ============================================================
    TASK 20 — Trajectory certificate (probe-local useful)
============================================================ -/

structure FoldedTransitionTrajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  prerequisiteRequest  : ChiralityDescriptionRequest resolve n
  prerequisiteResult   : ChiralityDescriptionResult prerequisiteRequest
  transitionRequest    : FoldedTransitionRequest resolve n
  prerequisiteMatches  :
    transitionRequest.input = prerequisiteRequest.family
    ∧
    transitionRequest.fromValue = prerequisiteRequest.value
  transitionResult     : FoldedTransitionResult transitionRequest

def trajectory_n2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    FoldedTransitionTrajectory resolve 2 where
  prerequisiteRequest := input_separated_request resolve h
  prerequisiteResult  := result_input_separated resolve h
  transitionRequest   := admitted_transition_request resolve h
  prerequisiteMatches := ⟨rfl, rfl⟩
  transitionResult    := result_folded_transition resolve h

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms downstream_claim_established
#print axioms complete_transition_reconstructed
#print axioms original_not_aligned

end ConsumerC3
