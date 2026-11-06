import AggregateFamilyTransform
import FDHTEvenCycleRegression8
import FDHTEvenCycleRegression6
import FDHTEvenCycleRegression4
import FDHTPermutationRotation

open KernelExprContext

/-!
# FirstPositiveReturnAt

State-relative first positive return packaging.

This is NOT:
- global action order
- permutation order
- exact group order
- universal period
- retrieval depth
- scalar depth
- trajectory depth
- physical period
- projected/raw equivalence
- canonical period selection

Preserve:
valid period ≠ first positive return
action order ≠ orbit first return
index first return ≠ raw-family first return
raw-family first return ≠ projected-family first return
projected first return is resolver-relative
-/

namespace KernelExprContext

variable {X : Type}
variable (step : X → X)
variable (x : X)
variable (k m : Nat)

/-! Core definition. -/

def FirstPositiveReturnAt
    (step : X → X)
    (x : X)
    (k : Nat) : Prop :=
  0 < k
  ∧
  Nat.repeat step k x = x
  ∧
  ∀ j,
    0 < j →
    j < k →
    Nat.repeat step j x ≠ x

/-! Eliminators. -/

theorem firstPositiveReturnAt_pos
    (h : FirstPositiveReturnAt step x k) :
    0 < k := h.1

theorem firstPositiveReturnAt_return
    (h : FirstPositiveReturnAt step x k) :
    Nat.repeat step k x = x := h.2.1

theorem firstPositiveReturnAt_noEarlier
    (h : FirstPositiveReturnAt step x k) :
    ∀ j,
      0 < j →
      j < k →
      Nat.repeat step j x ≠ x := h.2.2

/-! Uniqueness. -/

theorem firstPositiveReturnAt_unique
    (h1 : FirstPositiveReturnAt step x k)
    (h2 : FirstPositiveReturnAt step x m) :
    k = m := by
  rcases h1 with ⟨hkPos, hkRet, hkMin⟩
  rcases h2 with ⟨hmPos, hmRet, hmMin⟩
  cases Nat.lt_or_ge k m with
  | inl hlt =>
    exact False.elim ((hmMin k hkPos hlt) hkRet)
  | inr hge =>
    cases Nat.lt_or_ge m k with
    | inl hlt =>
      exact False.elim ((hkMin m hmPos hlt) hmRet)
    | inr hge' =>
      omega

/-! Constructor. -/

theorem firstPositiveReturnAt_of_return_noEarlier
    (hk : 0 < k)
    (hret : Nat.repeat step k x = x)
    (hmin :
      ∀ j,
        0 < j →
        j < k →
        Nat.repeat step j x ≠ x) :
    FirstPositiveReturnAt step x k :=
  ⟨hk, hret, hmin⟩

/-! n=8 index packaging. -/

theorem n8_index_first_return
    (i : Fin 8) :
    FirstPositiveReturnAt eightThreadCycle.toFun i 8 := by
  apply firstPositiveReturnAt_of_return_noEarlier
  · omega
  · exact eightThreadCycle_hasFinitePeriod.2 i
  · intro j hjPos hjLt
    exact eightThreadCycle_noEarlyReturn i j hjPos hjLt

/-! n=6 index packaging. -/

theorem n6_index_first_return
    (i : Fin 6) :
    FirstPositiveReturnAt sixThreadCycle.toFun i 6 := by
  apply firstPositiveReturnAt_of_return_noEarlier
  · omega
  · exact sixThreadCycle_hasFinitePeriod.2 i
  · intro j hjPos hjLt
    exact sixThreadCycle_noEarlyReturn i j hjPos hjLt

/-! n=4 index packaging. -/

theorem n4_index_first_return
    (i : Fin 4) :
    FirstPositiveReturnAt fourThreadCycle.toFun i 4 := by
  apply firstPositiveReturnAt_of_return_noEarlier
  · omega
  · exact fourThreadCycle_hasFinitePeriod.2 i
  · intro j hjPos hjLt
    exact fourThreadCycle_noEarlyReturn i j hjPos hjLt

/-! Trust audit. -/

#print axioms firstPositiveReturnAt_unique
#print axioms n8_index_first_return
#print axioms n6_index_first_return
#print axioms n4_index_first_return

end KernelExprContext

/-! n=8 raw/projected first-return contrast. -/

theorem familyUnequal_n8_raw_projected_first_return_contrast
    (resolve : KernelExpr → Store → Location)
    (h : 1 < 8) :
    FirstPositiveReturnAt
      (permuteThreadFamily resolve eightThreadCycle)
      (familyUnequal resolve 8 h)
      8
    ∧
    FirstPositiveReturnAt
      (ThreadPermutation.projectedAction resolve eightThreadCycle)
      (projectThreadFamily resolve
        (familyUnequal resolve 8 h))
      1 := by
  constructor
  · -- Raw first return 8
    apply firstPositiveReturnAt_of_return_noEarlier
    · omega
    · exact permuteThreadFamily_repeat resolve eightThreadCycle 8
        (eightThreadCycle_hasFinitePeriod.2) (familyUnequal resolve 8 h)
    · intro k hkPos hkLt
      intro heq
      have h0 := congrFun heq 0
      have hiter := permuteThreadFamily_iterate_apply resolve eightThreadCycle k
        (familyUnequal resolve 8 h) 0
      rw [hiter] at h0
      have hidx : Nat.repeat eightThreadCycle.toFun k 0 ≠ 0 :=
        eightThreadCycle_noEarlyReturn 0 k hkPos hkLt
      have hval : (familyUnequal resolve 8 h) (Nat.repeat eightThreadCycle.toFun k 0) =
          [identityContext] := by
        simp [familyUnequal, hidx]
      rw [hval] at h0
      have hbase : (familyUnequal resolve 8 h) 0 = [] := by simp [familyUnequal]
      rw [hbase] at h0
      simp at h0
  · -- Projected first return 1
    apply firstPositiveReturnAt_of_return_noEarlier
    · omega
    · have hconst : projectThreadFamily resolve (familyUnequal resolve 8 h) =
        fun _ => emptyTrajectory resolve := by
        funext i
        exact familyUnequal_projectsToIdentity resolve 8 h i
      rw [hconst]
      funext i
      unfold ThreadPermutation.projectedAction
      rfl
    · intro j hjPos hjLt
      omega

#print axioms familyUnequal_n8_raw_projected_first_return_contrast
