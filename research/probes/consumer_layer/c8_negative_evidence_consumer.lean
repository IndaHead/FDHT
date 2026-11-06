import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC8

/-!
# C₈ — Negative Evidence as Positive Downstream Capability

Refutation-payload consumption test.
REFUTED upstream claim provides positive downstream capability.
Probe-local only. Not a generic NegativeEvidence API.
-/

/-! ============================================================
    TASK 2/3 — Natural negative fixture
============================================================ -/

-- P := FamilyClassifierInvariant resolve C
-- ¬P := ¬ FamilyClassifierInvariant resolve C
--
-- Permanent evidence:
-- aggregateFoldedTrivial_refutes_invariant
--   : AggregateFoldedTrivialClassifierWitness resolve C
--   → ¬ FamilyClassifierInvariant resolve C
--
-- Downstream capability:
-- A request requiring ¬ FamilyClassifierInvariant establishes that the
-- classifier has distinguishing power (it distinguishes folded-equivalent
-- families). This is positive capability derived from negative evidence.
--
-- Classification: GENUINE NEGATIVE FIXTURE

/-! ============================================================
    TASK 5 — Upstream request for P
============================================================ -/

structure InvarianceRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)

def InvarianceRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : InvarianceRequest resolve n) : Prop :=
  FamilyClassifierInvariant resolve req.classifier

/-! ============================================================
    TASK 6 — Upstream result
============================================================ -/

inductive InvarianceResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : InvarianceRequest resolve n) where
  | established : req.claim → InvarianceResult req
  | refuted     : (req.claim → False) → InvarianceResult req
  | unresolved  : InvarianceResult req

/-! ============================================================
    TASK 7 — Construct genuine REFUTED result
============================================================ -/

def invariance_request
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n)) :
    InvarianceRequest resolve n where
  classifier := C

def invariance_result_refuted
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hWitness : AggregateFoldedTrivialClassifierWitness resolve C) :
    InvarianceResult (invariance_request resolve n C) :=
  .refuted (aggregateFoldedTrivial_refutes_invariant resolve C hWitness)

/-! ============================================================
    TASK 8 — Recover negative payload
============================================================ -/

def recover_negative_payload
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    {req : InvarianceRequest resolve n}
    (result : InvarianceResult req) :
    (req.claim → False) ∨ True :=
  match result with
  | .established _ => Or.inr trivial
  | .refuted notP => Or.inl notP
  | .unresolved => Or.inr trivial

theorem negative_payload_recovered
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hWitness : AggregateFoldedTrivialClassifierWitness resolve C) :
    ∃ notP, recover_negative_payload
      (invariance_result_refuted resolve n C hWitness) = Or.inl notP := by
  exists aggregateFoldedTrivial_refutes_invariant resolve C hWitness

/-! ============================================================
    TASK 9 — Downstream request requiring ¬P
============================================================ -/

structure DistinguishingPowerRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  classifier : RelationalClassifier (ThreadFamily resolve n)
  notInvariant : ¬ FamilyClassifierInvariant resolve classifier

def DistinguishingPowerRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : DistinguishingPowerRequest resolve n) : Prop :=
  ¬ FamilyClassifierInvariant resolve req.classifier

/-! ============================================================
    TASK 10 — Refutation-gated admission
============================================================ -/

def distinguishing_power_from_refutation
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hWitness : AggregateFoldedTrivialClassifierWitness resolve C) :
    DistinguishingPowerRequest resolve n where
  classifier := C
  notInvariant := aggregateFoldedTrivial_refutes_invariant resolve C hWitness

def refutation_admits_downstream
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hWitness : AggregateFoldedTrivialClassifierWitness resolve C) :
    DistinguishingPowerRequest resolve n :=
  distinguishing_power_from_refutation resolve n C hWitness

/-! ============================================================
    TASK 11 — Status-only firewall
============================================================ -/

-- Attempting to construct DistinguishingPowerRequest from status alone:
--
-- def invalid_from_status
--     (resolve : KernelExpr → Store → Location)
--     (n : Nat)
--     (C : RelationalClassifier (ThreadFamily resolve n))
--     (status : InvarianceResult (invariance_request resolve n C)) :
--     DistinguishingPowerRequest resolve n :=
--   {
--     classifier := C
--     notInvariant := ???  -- NO PROOF PAYLOAD
--   }
--
-- Classification: TYPE REJECTION
-- REFUTED status ≠ negative proof

/-! ============================================================
    TASK 12 — UNRESOLVED firewall
============================================================ -/

-- UNRESOLVED does not provide ¬P.
-- The .unresolved constructor carries no proof payload.
-- Classification: UNRESOLVED ≠ ¬P

/-! ============================================================
    TASK 13 — ESTABLISHED firewall
============================================================ -/

-- ESTABLISHED hP provides P, not ¬P.
-- The .established constructor carries hP : P.
-- Classification: ESTABLISHED ≠ ¬P

/-! ============================================================
    TASK 18 — Negative evidence has positive capability
============================================================ -/

-- notP : ¬ FamilyClassifierInvariant
-- admits DistinguishingPowerRequest
-- which establishes that the classifier has distinguishing power.
--
-- Classification: NEGATIVE MATHEMATICAL CONTENT
-- CAN PROVIDE POSITIVE DOWNSTREAM CAPABILITY
--
-- Preserve: ¬P ≠ P

/-! ============================================================
    TASK 22 — Refutation ≠ deletion
============================================================ -/

structure NegativeEvidenceTrajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  sourceRequest     : InvarianceRequest resolve n
  sourceResult      : InvarianceResult sourceRequest
  downstreamRequest : DistinguishingPowerRequest resolve n

def negative_evidence_trajectory
    (resolve : KernelExpr → Store → Location)
    (n : Nat)
    (C : RelationalClassifier (ThreadFamily resolve n))
    (hWitness : AggregateFoldedTrivialClassifierWitness resolve C) :
    NegativeEvidenceTrajectory resolve n where
  sourceRequest     := invariance_request resolve n C
  sourceResult      := invariance_result_refuted resolve n C hWitness
  downstreamRequest := distinguishing_power_from_refutation resolve n C hWitness

-- Original request preserved. REFUTED result preserved. Downstream admitted.
-- Classification: REFUTATION ≠ HISTORY ERASURE

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms negative_payload_recovered
#print axioms refutation_admits_downstream

end ConsumerC8
