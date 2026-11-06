import AggregateFamilyTransform

open KernelExprContext

namespace ConsumerC6

/-!
# C₆ — Conjunctive Evidence Admission

Multi-evidence dependency test.
Downstream request requires two independent proof payloads.
Probe-local only. Not a generic Evidence API.
-/

/-! ============================================================
    TASK 2/3 — Independent evidence fixtures
============================================================ -/

-- P : family description (about the family, not the transform)
-- Q : transform property (about the transform, not the family)
--
-- P = ChiralityValueDescribes resolve p .separated
--   = ¬ RawAllEqual resolve p
--
-- Q = IsRelationallyAggregate resolve transform
--   = ¬ IsReindexedComponentwise resolve transform
--
-- Independence:
-- - P is about the family p
-- - Q is about the transform
-- - P does not imply Q (family property ≠ transform property)
-- - Q does not imply P (transform property ≠ family property)
-- - Neither contains the other as a conjunct
--
-- Classification: GENUINE INDEPENDENCE

/-! ============================================================
    TASK 5 — Source request/result for P
============================================================ -/

structure FamilyDescriptionRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  family : ThreadFamily resolve n
  value  : ChiralityValue

def FamilyDescriptionRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : FamilyDescriptionRequest resolve n) : Prop :=
  ChiralityValueDescribes resolve req.family req.value

inductive FamilyDescriptionResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : FamilyDescriptionRequest resolve n) where
  | established : req.claim → FamilyDescriptionResult req
  | refuted     : (req.claim → False) → FamilyDescriptionResult req
  | unresolved  : FamilyDescriptionResult req

def p_request
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    FamilyDescriptionRequest resolve 2 where
  family := familyUnequal resolve 2 h
  value  := .separated

def p_result
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    FamilyDescriptionResult (p_request resolve h) :=
  .established (familyUnequal_chiralityValue_separated_n2 resolve h)

/-! ============================================================
    TASK 6 — Source request/result for Q
============================================================ -/

structure TransformPropertyRequest
    (resolve : KernelExpr → Store → Location)
    (n : Nat) where
  transform : AggregateFamilyTransform resolve n

def TransformPropertyRequest.claim
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : TransformPropertyRequest resolve n) : Prop :=
  IsRelationallyAggregate resolve req.transform

inductive TransformPropertyResult
    {resolve : KernelExpr → Store → Location}
    {n : Nat}
    (req : TransformPropertyRequest resolve n) where
  | established : req.claim → TransformPropertyResult req
  | refuted     : (req.claim → False) → TransformPropertyResult req
  | unresolved  : TransformPropertyResult req

def q_request
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    TransformPropertyRequest resolve 2 where
  transform := neighbourComposeTransform resolve h

def q_result
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    TransformPropertyResult (q_request resolve h) :=
  .established (neighbourComposeTransform_isRelationallyAggregate resolve 2 h)

/-! ============================================================
    TASK 7 — Conjunctive downstream request
============================================================ -/

structure ConjunctiveContinuationRequest
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) where
  familyEvidence :
    ChiralityValueDescribes
      resolve
      (familyUnequal resolve 2 h)
      .separated
  transformEvidence :
    IsRelationallyAggregate
      resolve
      (neighbourComposeTransform resolve h)

def ConjunctiveContinuationRequest.claim
    {resolve : KernelExpr → Store → Location}
    {h : 1 < 2}
    (_req : ConjunctiveContinuationRequest resolve h) : Prop :=
  RelationalAggregateChiralityTransition
    resolve
    (neighbourComposeTransform resolve h)
    (familyUnequal resolve 2 h)
    .separated
    .aligned

/-! ============================================================
    TASK 8 — P + Q positive admission
============================================================ -/

theorem conjunctive_request
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ConjunctiveContinuationRequest resolve h :=
  {
    familyEvidence := familyUnequal_chiralityValue_separated_n2 resolve h
    transformEvidence := neighbourComposeTransform_isRelationallyAggregate resolve 2 h
  }

theorem conjunctive_admission_from_both
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ConjunctiveContinuationRequest resolve h :=
  conjunctive_request resolve h

/-! ============================================================
    TASK 9 — P-only firewall
============================================================ -/

-- Attempting to construct ConjunctiveContinuationRequest from P alone:
--
-- def invalid_from_p_only
--     (resolve : KernelExpr → Store → Location)
--     (h : 1 < 2)
--     (hP : ChiralityValueDescribes resolve (familyUnequal resolve 2 h) .separated) :
--     ConjunctiveContinuationRequest resolve h :=
--   {
--     familyEvidence := hP
--     transformEvidence := ???  -- NO Q EVIDENCE
--   }
--
-- Classification: TYPE REJECTION
-- P alone does not provide transformEvidence.
-- Missing Q is NOT a refutation of Q.

/-! ============================================================
    TASK 10 — Q-only firewall
============================================================ -/

-- Attempting to construct ConjunctiveContinuationRequest from Q alone:
--
-- def invalid_from_q_only
--     (resolve : KernelExpr → Store → Location)
--     (h : 1 < 2)
--     (hQ : IsRelationallyAggregate resolve (neighbourComposeTransform resolve h)) :
--     ConjunctiveContinuationRequest resolve h :=
--   {
--     familyEvidence := ???  -- NO P EVIDENCE
--     transformEvidence := hQ
--   }
--
-- Classification: TYPE REJECTION
-- Q alone does not provide familyEvidence.
-- Missing P is NOT a refutation of P.

/-! ============================================================
    TASK 16 — Conjunction vs aggregation
============================================================ -/

-- Ordinary dependent structure is sufficient.
-- No EvidenceBundle, EvidenceAggregate, or EvidenceCollection required.
-- Classification: CONJUNCTION SUFFICIENT

/-! ============================================================
    TASK 17 — Conjunction vs merging
============================================================ -/

structure ConjunctiveTrajectory
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) where
  pRequest          : FamilyDescriptionRequest resolve 2
  pResult           : FamilyDescriptionResult pRequest
  qRequest          : TransformPropertyRequest resolve 2
  qResult           : TransformPropertyResult qRequest
  downstreamRequest : ConjunctiveContinuationRequest resolve h

def conjunctive_trajectory
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    ConjunctiveTrajectory resolve h where
  pRequest          := p_request resolve h
  pResult           := p_result resolve h
  qRequest          := q_request resolve h
  qResult           := q_result resolve h
  downstreamRequest := conjunctive_request resolve h

-- P history retained. Q history retained. R depends on both.
-- Classification: CONJUNCTION ≠ MERGING

/-! ============================================================
    TASK 20 — Downstream claim determination
============================================================ -/

theorem downstream_claim_established
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 2) :
    RelationalAggregateChiralityTransition
      resolve
      (neighbourComposeTransform resolve h)
      (familyUnequal resolve 2 h)
      .separated
      .aligned :=
  neighbourCompose_relationalAggregate_chiralityTransition_n2 resolve h

-- Admission from P + Q does not automatically imply ESTABLISHED claim.
-- The claim is established by a separate permanent theorem.
-- Classification: ADMISSION ≠ DETERMINATION

/-! ============================================================
    Axiom footprints
============================================================ -/

#print axioms conjunctive_admission_from_both
#print axioms downstream_claim_established

end ConsumerC6
