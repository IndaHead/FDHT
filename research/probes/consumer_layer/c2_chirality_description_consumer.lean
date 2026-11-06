import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC2

/-!
# C₂ — Cross-Domain Chirality-Value Description Consumer

Domain-specific chirality-description consumer.
Probe-local only. Not a generic Consumer API.
Outside first-positive-return domain.
-/

/-! ============================================================
    TASK 1 — Domain-specific request
============================================================ -/

structure ChiralityDescriptionRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  family : ThreadFamily resolve n
  value  : ChiralityValue

/-! ============================================================
    TASK 2 — Requested claim
============================================================ -/

def ChiralityDescriptionRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n) : Prop :=
  ChiralityValueDescribes resolve req.family req.value

/-! ============================================================
    TASK 3 — Domain-specific result
============================================================ -/

inductive ChiralityDescriptionResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n) where

  | established :
      req.claim →
      ChiralityDescriptionResult req

  | refuted :
      (req.claim → False) →
      ChiralityDescriptionResult req

  | unresolved :
      ChiralityDescriptionResult req

/-! ============================================================
    TASK 4 — Proof-driven constructors
============================================================ -/

def establishChiralityDescription
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n)
    (h : req.claim) :
    ChiralityDescriptionResult req :=
  .established h

def refuteChiralityDescription
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : ChiralityDescriptionRequest resolve n)
    (h : req.claim → False) :
    ChiralityDescriptionResult req :=
  .refuted h

/-! ============================================================
    TASK 5 — Domain-specific status observer
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

/-! ============================================================
    TASK 6 — R1: Original separated ESTABLISHED
============================================================ -/

def req_original_separated
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionRequest resolve 2 where
  family := familyUnequal resolve 2 h
  value  := .separated

def result_original_separated
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionResult (req_original_separated resolve h) :=
  establishChiralityDescription
    (req_original_separated resolve h)
    (familyUnequal_chiralityValue_separated_n2 resolve h)

/-! ============================================================
    TASK 7 — R2: Original aligned REFUTED
============================================================ -/

def req_original_aligned
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionRequest resolve 2 where
  family := familyUnequal resolve 2 h
  value  := .aligned

theorem original_not_aligned
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ¬ ChiralityValueDescribes resolve (familyUnequal resolve 2 h) .aligned := by
  intro hAl
  have hSep := familyUnequal_chiralityValue_separated_n2 resolve h
  exact chiralityValueDescribes_exclusive resolve (familyUnequal resolve 2 h) ⟨hAl, hSep⟩

def result_original_aligned
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionResult (req_original_aligned resolve h) :=
  refuteChiralityDescription
    (req_original_aligned resolve h)
    (original_not_aligned resolve h)

/-! ============================================================
    TASK 8 — R3: Transformed aligned ESTABLISHED
============================================================ -/

def req_transformed_aligned
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionRequest resolve 2 where
  family := neighbourComposeTransform resolve h (familyUnequal resolve 2 h)
  value  := .aligned

def result_transformed_aligned
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionResult (req_transformed_aligned resolve h) :=
  establishChiralityDescription
    (req_transformed_aligned resolve h)
    (neighbourCompose_familyUnequal_chiralityValue_aligned_n2 resolve h)

/-! ============================================================
    TASK 9 — R4: Transformed separated REFUTED
============================================================ -/

def req_transformed_separated
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionRequest resolve 2 where
  family := neighbourComposeTransform resolve h (familyUnequal resolve 2 h)
  value  := .separated

theorem transformed_not_separated
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ¬ ChiralityValueDescribes
        resolve
        (neighbourComposeTransform resolve h (familyUnequal resolve 2 h))
        .separated := by
  intro hSep
  have hAl := neighbourCompose_familyUnequal_chiralityValue_aligned_n2 resolve h
  exact chiralityValueDescribes_exclusive
    resolve
    (neighbourComposeTransform resolve h (familyUnequal resolve 2 h))
    ⟨hAl, hSep⟩

def result_transformed_separated
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ChiralityDescriptionResult (req_transformed_separated resolve h) :=
  refuteChiralityDescription
    (req_transformed_separated resolve h)
    (transformed_not_separated resolve h)

/-! ============================================================
    TASK 10 — R5: Arbitrary aligned UNRESOLVED
============================================================ -/

def req_arbitrary_aligned
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 2) :
    ChiralityDescriptionRequest resolve 2 where
  family := p
  value  := .aligned

def result_arbitrary_aligned
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 2) :
    ChiralityDescriptionResult (req_arbitrary_aligned resolve p) :=
  .unresolved

/-! ============================================================
    TASK 11 — R6: Arbitrary separated UNRESOLVED
============================================================ -/

def req_arbitrary_separated
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 2) :
    ChiralityDescriptionRequest resolve 2 where
  family := p
  value  := .separated

def result_arbitrary_separated
    (resolve : KernelExpr → Store → Location)
    (p : ThreadFamily resolve 2) :
    ChiralityDescriptionResult (req_arbitrary_separated resolve p) :=
  .unresolved

/-! ============================================================
    TASK 12 — Status sequence
============================================================ -/

def status_sequence
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (p : ThreadFamily resolve 2) :
    List ChiralityDescriptionStatus :=
  [
    (result_original_separated resolve h).status,
    (result_original_aligned resolve h).status,
    (result_transformed_aligned resolve h).status,
    (result_transformed_separated resolve h).status,
    (result_arbitrary_aligned resolve p).status,
    (result_arbitrary_separated resolve p).status
  ]

theorem status_sequence_expected
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2)
    (p : ThreadFamily resolve 2) :
    status_sequence resolve h p =
    [
      .established,
      .refuted,
      .established,
      .refuted,
      .unresolved,
      .unresolved
    ] :=
  rfl

/-! ============================================================
    TASK 13 — Proof payload retention
============================================================ -/

def has_established_proof
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    {req : ChiralityDescriptionRequest resolve n}
    (r : ChiralityDescriptionResult req) : Prop :=
  match r with
  | .established _ => True
  | .refuted _     => False
  | .unresolved    => False

def has_refuted_proof
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    {req : ChiralityDescriptionRequest resolve n}
    (r : ChiralityDescriptionResult req) : Prop :=
  match r with
  | .established _ => False
  | .refuted _     => True
  | .unresolved    => False

theorem proof_retention_r1
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    has_established_proof (result_original_separated resolve h) :=
  trivial

theorem refutation_retention_r2
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    has_refuted_proof (result_original_aligned resolve h) :=
  trivial

theorem proof_retention_r3
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    has_established_proof (result_transformed_aligned resolve h) :=
  trivial

theorem refutation_retention_r4
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    has_refuted_proof (result_transformed_separated resolve h) :=
  trivial

/-! ============================================================
    TASK 15 — Same folded position, different raw description
============================================================ -/

theorem same_folded_different_description
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ∃ p q : ThreadFamily resolve 2,
      ThreadFamilyKernel resolve p q
      ∧
      ChiralityValueDescribes resolve p .separated
      ∧
      ChiralityValueDescribes resolve q .aligned :=
  chiralityValue_changes_at_same_folded_position_n2 resolve h

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms original_not_aligned
#print axioms transformed_not_separated
#print axioms proof_retention_r1
#print axioms refutation_retention_r2
#print axioms proof_retention_r3
#print axioms refutation_retention_r4
#print axioms status_sequence_expected
#print axioms same_folded_different_description

end ConsumerC2
