#!/usr/bin/env python3
"""
RFE-02D Evaluator
Deterministic evaluation of controller decisions against ground truth.
"""

from dataclasses import dataclass
from typing import Optional

@dataclass
class EvaluationResult:
    theorem_false_pruning: int
    theorem_pruned_sufficient: int
    theorem_pruned_insufficient: int
    surviving_sufficient: int
    surviving_insufficient: int
    complementary_preserved: int
    family_exhaustion_correct: bool
    assertions_passed: int
    assertions_failed: int
    failures: list

class Evaluator:
    def __init__(self, fixtures: list):
        self.fixtures = fixtures
        
    def evaluate(self, controller_results: dict) -> EvaluationResult:
        failures = []
        theorem_false_pruning = 0
        theorem_pruned_sufficient = 0
        theorem_pruned_insufficient = 0
        surviving_sufficient = 0
        surviving_insufficient = 0
        complementary_preserved = 0
        family_exhaustion_correct = True
        assertions_passed = 0
        assertions_failed = 0
        
        for fixture in self.fixtures:
            fid = fixture["fixture_id"]
            
            # Find controller results for this fixture
            fixture_result = None
            for fr in controller_results["fixtures"]:
                if fr["fixture_id"] == fid:
                    fixture_result = fr
                    break
            
            if fixture_result is None:
                failures.append(f"Missing controller result for {fid}")
                assertions_failed += 1
                continue
            
            # Check family exhaustion
            if fixture["expected_final_outcome"] == "STOP_FAMILY_EXHAUSTED":
                if fixture_result["g2_calls"] != 0:
                    failures.append(f"Family exhaustion {fid} has non-zero G2 calls")
                    family_exhaustion_correct = False
                    assertions_failed += 1
                else:
                    assertions_passed += 1
            
            # Check each candidate
            for cand in fixture["candidates"]:
                cid = cand["candidate_id"]
                expected_status = cand["expected_status"]
                factors = cand["factors_through_parent"]
                expected_g2 = cand["expected_g2_action"]
                
                # Assertion: G2-pruned candidates must factor through parent
                if expected_g2 == "PRUNE":
                    if not factors:
                        failures.append(f"{fid}/{cid}: G2-pruned but does not factor")
                        assertions_failed += 1
                    else:
                        assertions_passed += 1
                    
                    # Assertion: G2-pruned candidates must be insufficient
                    if expected_status != "INSUFFICIENT":
                        failures.append(f"{fid}/{cid}: G2-pruned but status is {expected_status}")
                        theorem_false_pruning += 1
                        theorem_pruned_sufficient += 1
                        assertions_failed += 1
                    else:
                        theorem_pruned_insufficient += 1
                        assertions_passed += 1
                else:
                    # Surviving candidates
                    if expected_status == "SUFFICIENT":
                        surviving_sufficient += 1
                    else:
                        surviving_insufficient += 1
                    
                    # Check complementary preservation
                    if cand.get("complementary_label") in ["JOINT_ROUTE", "COMPLEMENTARY_PAIR_MEMBER"]:
                        if expected_g2 == "EVALUATE":
                            complementary_preserved += 1
                            assertions_passed += 1
                        else:
                            failures.append(f"{fid}/{cid}: Complementary route pruned")
                            assertions_failed += 1
        
        return EvaluationResult(
            theorem_false_pruning=theorem_false_pruning,
            theorem_pruned_sufficient=theorem_pruned_sufficient,
            theorem_pruned_insufficient=theorem_pruned_insufficient,
            surviving_sufficient=surviving_sufficient,
            surviving_insufficient=surviving_insufficient,
            complementary_preserved=complementary_preserved,
            family_exhaustion_correct=family_exhaustion_correct,
            assertions_passed=assertions_passed,
            assertions_failed=assertions_failed,
            failures=failures
        )
