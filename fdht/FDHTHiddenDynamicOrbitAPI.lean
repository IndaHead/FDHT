import AggregateFamilyTransform

/-!
# FDHT Hidden Dynamic Orbit API

Packaging layer. All mathematics is defined in AggregateFamilyTransform.
This module re-exports the public orbit surface and the headline split theorem.
-/

open KernelExprContext

-- Public core
#check RawOrbit
#check RawOrbitReturnsAt
#check RawOrbitNeverReturns
#check RawOrbitInjective
#check FoldedOrbit
#check FoldedOrbitReturnsAt
#check FoldedOrbitStationary
#check RawFoldedOrbitSplit
#check OrbitKernelStable
#check HiddenDynamicOrbit
#check RawFoldedOrbitCertificate
#check RawOrbit_zero
#check RawOrbit_succ
#check RawOrbit_add
#check rawReturn_implies_foldedReturn
#check OrbitKernelStable_iff_FoldedOrbitStationary
#check RawFoldedOrbitSplit_iff_NeverReturns_and_KernelStable
#check InjectiveStationaryFoldOrbit_implies_Nontrivial

-- Concrete n=2
#check familyUnequal_rawOrbit_injective_n2
#check familyUnequal_foldedOrbit_constant_n2
#check familyUnequal_raw_folded_orbit_split_n2
#check familyUnequal_hiddenDynamicOrbit_n2
#check rawOrbit_collapses_to_single_folded_position_n2
#check distinct_raw_same_folded_n2
#check hiddenDynamicOrbit_folded_does_not_recover_index
#check familyUnequal_hidden_dynamic_split_n2
