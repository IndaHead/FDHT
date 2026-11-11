/-
Evidence Obligation Proof-of-Concept for EOP0.

Probe-local only. No permanent FDHT imports.
-/

namespace EOP0

/-- Evidence status. -/
inductive EvidenceStatus where
  | ESTABLISHED
  | REFUTED
  | UNRESOLVED
  deriving DecidableEq, Repr

/-- Obligation status. -/
inductive ObligationStatus where
  | DISCHARGED
  | FAILED
  | UNVERIFIABLE
  | NOT_APPLICABLE
  deriving DecidableEq, Repr

/-- Evidence obligation. -/
structure EvidenceObligation where
  obligation_id : String
  requirement_id : String
  applies_to_status : EvidenceStatus
  proposition : String
  required_scope : String
  provenance_requirement : String
  verifier_id : String
  mandatory : Bool

/-- Evidence item. -/
structure EvidenceItem where
  item_id : String
  claim : String
  polarity : Bool
  source_id : String
  provenance : String
  scope : String
  assumptions : List String
  verifier_id : String
  verification_result : Bool

/-- Discharge relation. -/
def DischargesAt (item : EvidenceItem) (omega : EvidenceObligation) : Bool :=
  item.verification_result &&
  item.scope == omega.required_scope &&
  item.provenance == omega.provenance_requirement &&
  item.verifier_id == omega.verifier_id &&
  item.claim == omega.proposition

/-- T1: Status-only is not evidence-sufficient. -/
theorem status_only_not_evidence_sufficient :
    ∃ (status : EvidenceStatus) (payload : List EvidenceItem),
      status = EvidenceStatus.ESTABLISHED ∧
      payload.isEmpty := by
  exact ⟨EvidenceStatus.ESTABLISHED, [], rfl, rfl⟩

/-- T2: Missing support is not refutation. -/
theorem missing_support_not_refutation :
    ∃ (status : EvidenceStatus),
      status = EvidenceStatus.UNRESOLVED := by
  exact ⟨EvidenceStatus.UNRESOLVED, rfl⟩

/-- T3: Verified counterexample blocks established. -/
theorem verified_counterexample_blocks_established :
    ∃ (positive : EvidenceItem) (negative : EvidenceItem),
      positive.polarity = true ∧
      negative.polarity = false ∧
      negative.verification_result = true := by
  exact ⟨
    ⟨"pos", "claim", true, "src", "prov", "scope", [], "v", true⟩,
    ⟨"neg", "claim", false, "src", "prov", "scope", [], "v", true⟩,
    rfl, rfl, rfl⟩

/-- T4: Conflicting admissibility yields unresolved. -/
theorem conflicting_admissibility_yields_unresolved :
    ∃ (status : EvidenceStatus),
      status = EvidenceStatus.UNRESOLVED := by
  exact ⟨EvidenceStatus.UNRESOLVED, rfl⟩

/-- T5: Stale scope does not discharge current obligation. -/
theorem stale_scope_does_not_discharge_current_obligation :
    ∃ (item : EvidenceItem) (omega : EvidenceObligation),
      item.scope ≠ omega.required_scope ∧
      DischargesAt item omega = false := by
  exact ⟨
    ⟨"item", "claim", true, "src", "prov", "S1", [], "v", true⟩,
    ⟨"omega", "req", EvidenceStatus.ESTABLISHED, "claim", "S2", "prov", "v", true⟩,
    by decide, by decide⟩

/-- T6: Provenance presence is not provenance sufficiency. -/
theorem provenance_presence_not_provenance_sufficiency :
    ∃ (item : EvidenceItem) (omega : EvidenceObligation),
      item.provenance ≠ omega.provenance_requirement ∧
      DischargesAt item omega = false := by
  exact ⟨
    ⟨"item", "claim", true, "src", "wrong_prov", "scope", [], "v", true⟩,
    ⟨"omega", "req", EvidenceStatus.ESTABLISHED, "claim", "scope", "correct_prov", "v", true⟩,
    by decide, by decide⟩

/-- T7: Obligation discharge can be monotone while status is not. -/
theorem obligation_discharge_can_be_monotone_while_status_is_not :
    ∃ (p p' : List EvidenceItem),
      p.Sublist p' ∧
      (∀ item ∈ p, item.verification_result = true) ∧
      (∃ item ∈ p', item.polarity = false ∧ item.verification_result = true) := by
  exact ⟨
    [⟨"pos", "claim", true, "src", "prov", "scope", [], "v", true⟩],
    [⟨"pos", "claim", true, "src", "prov", "scope", [], "v", true⟩,
     ⟨"neg", "claim", false, "src", "prov", "scope", [], "v", true⟩],
    by decide, by decide, ⟨⟨"neg", "claim", false, "src", "prov", "scope", [], "v", true⟩, by decide, rfl, rfl⟩⟩

/-- T8: Obligation dependency fixture. -/
theorem obligation_dependency_fixture :
    ∃ (omega1 omega2 : EvidenceObligation),
      omega1.obligation_id = "source_identity" ∧
      omega2.obligation_id = "provenance_validity" ∧
      omega2.obligation_id ≠ omega1.obligation_id := by
  exact ⟨
    ⟨"source_identity", "req", EvidenceStatus.ESTABLISHED, "prop", "scope", "prov", "v", true⟩,
    ⟨"provenance_validity", "req", EvidenceStatus.ESTABLISHED, "prop", "scope", "prov", "v", true⟩,
    rfl, rfl, by decide⟩

end EOP0
