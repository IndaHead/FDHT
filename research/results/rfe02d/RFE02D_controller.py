#!/usr/bin/env python3
"""
RFE-02D Controller
Deterministic routing for G0, G2, and GP treatments.
ZERO API REQUESTS.
"""

import json
import hashlib
from dataclasses import dataclass
from typing import Optional

SYSTEM_PROMPT = """You are evaluating one information candidate against one declared consumer requirement.

Use only the supplied requirement and candidate evidence.

Do not infer omitted information.
Do not decide whether the candidate should have been structurally pruned.

Return JSON only."""

USER_PROMPT_TEMPLATE = """REQUIREMENT:
{requirement}

CANDIDATE:
{candidate}

RETURN EXACTLY:

{{
  "status": "SUFFICIENT | INSUFFICIENT | UNRESOLVED",
  "answer": "<minimal answer derived from supplied evidence>"
}}"""

PLANNED_MODEL = "grok-4"
PLANNED_REASONING_EFFORT = "medium"

@dataclass
class CandidateAction:
    fixture_id: str
    candidate_id: str
    treatment: str
    action: str  # EVALUATE, THEOREM_PRUNE, ARBITRARY_PRUNE
    reason: str
    prompt_hash: Optional[str] = None

class DryRunReasoner:
    """Sentinel reasoner that never makes API calls."""
    
    def evaluate(self, prompt: str) -> dict:
        return {
            "status": "NOT_EXECUTED",
            "answer": None,
            "dry_run": True
        }

class Controller:
    def __init__(self, fixtures: list):
        self.fixtures = fixtures
        self.reasoner = DryRunReasoner()
        self.events = []
        self.api_requests_attempted = 0
        self.factorisation_checks = 0
        self.pruning_decisions = 0
        
    def generate_prompt(self, requirement: str, payload: str) -> tuple:
        user_prompt = USER_PROMPT_TEMPLATE.format(
            requirement=requirement,
            candidate=payload
        )
        full_prompt = SYSTEM_PROMPT + "\n\n" + user_prompt
        prompt_hash = hashlib.sha256(full_prompt.encode()).hexdigest()
        return full_prompt, prompt_hash
    
    def g0_route(self, fixture: dict) -> list:
        """G0: Evaluate every candidate."""
        actions = []
        for cand in fixture["candidates"]:
            prompt, prompt_hash = self.generate_prompt(
                fixture["requirement"],
                cand["payload"]
            )
            actions.append(CandidateAction(
                fixture_id=fixture["fixture_id"],
                candidate_id=cand["candidate_id"],
                treatment="G0",
                action="EVALUATE",
                reason="G0 evaluates all candidates",
                prompt_hash=prompt_hash
            ))
            self.events.append({
                "fixture_id": fixture["fixture_id"],
                "treatment": "G0",
                "candidate_id": cand["candidate_id"],
                "event_type": "WOULD_CALL_MODEL",
                "prompt_hash": prompt_hash,
                "planned_model": PLANNED_MODEL,
                "planned_reasoning_effort": PLANNED_REASONING_EFFORT
            })
        return actions
    
    def g2_route(self, fixture: dict) -> list:
        """G2: Theorem-prune factorising candidates of lossy parent."""
        actions = []
        parent_lossy = fixture["observable_loss_verified"]
        
        for cand in fixture["candidates"]:
            self.factorisation_checks += 1
            self.pruning_decisions += 1
            
            if parent_lossy and cand["factors_through_parent"]:
                if cand["factorisation_evidence_id"] is None:
                    raise ValueError(f"Factorisation claimed without evidence: {cand['candidate_id']}")
                actions.append(CandidateAction(
                    fixture_id=fixture["fixture_id"],
                    candidate_id=cand["candidate_id"],
                    treatment="G2",
                    action="THEOREM_PRUNE",
                    reason="Factors through lossy parent"
                ))
            else:
                prompt, prompt_hash = self.generate_prompt(
                    fixture["requirement"],
                    cand["payload"]
                )
                actions.append(CandidateAction(
                    fixture_id=fixture["fixture_id"],
                    candidate_id=cand["candidate_id"],
                    treatment="G2",
                    action="EVALUATE",
                    reason="Does not factor through lossy parent",
                    prompt_hash=prompt_hash
                ))
                self.events.append({
                    "fixture_id": fixture["fixture_id"],
                    "treatment": "G2",
                    "candidate_id": cand["candidate_id"],
                    "event_type": "WOULD_CALL_MODEL",
                    "prompt_hash": prompt_hash,
                    "planned_model": PLANNED_MODEL,
                    "planned_reasoning_effort": PLANNED_REASONING_EFFORT
                })
        return actions
    
    def gp_route(self, fixture: dict, g2_prune_count: int) -> list:
        """GP: Remove first k candidates (semantic-blind)."""
        actions = []
        candidates = fixture["candidates"]
        
        for i, cand in enumerate(candidates):
            if i < g2_prune_count:
                actions.append(CandidateAction(
                    fixture_id=fixture["fixture_id"],
                    candidate_id=cand["candidate_id"],
                    treatment="GP",
                    action="ARBITRARY_PRUNE",
                    reason=f"First {g2_prune_count} in frozen order"
                ))
            else:
                prompt, prompt_hash = self.generate_prompt(
                    fixture["requirement"],
                    cand["payload"]
                )
                actions.append(CandidateAction(
                    fixture_id=fixture["fixture_id"],
                    candidate_id=cand["candidate_id"],
                    treatment="GP",
                    action="EVALUATE",
                    reason="Survives arbitrary pruning",
                    prompt_hash=prompt_hash
                ))
                self.events.append({
                    "fixture_id": fixture["fixture_id"],
                    "treatment": "GP",
                    "candidate_id": cand["candidate_id"],
                    "event_type": "WOULD_CALL_MODEL",
                    "prompt_hash": prompt_hash,
                    "planned_model": PLANNED_MODEL,
                    "planned_reasoning_effort": PLANNED_REASONING_EFFORT
                })
        return actions
    
    def run_all(self) -> dict:
        """Run all treatments for all fixtures."""
        results = {
            "fixtures": [],
            "totals": {
                "G0_would_calls": 0,
                "G2_theorem_prunes": 0,
                "G2_would_calls": 0,
                "GP_arbitrary_prunes": 0,
                "GP_would_calls": 0
            }
        }
        
        for fixture in self.fixtures:
            g0_actions = self.g0_route(fixture)
            g2_actions = self.g2_route(fixture)
            
            g2_prune_count = sum(1 for a in g2_actions if a.action == "THEOREM_PRUNE")
            gp_actions = self.gp_route(fixture, g2_prune_count)
            
            g0_calls = sum(1 for a in g0_actions if a.action == "EVALUATE")
            g2_calls = sum(1 for a in g2_actions if a.action == "EVALUATE")
            gp_prunes = sum(1 for a in gp_actions if a.action == "ARBITRARY_PRUNE")
            gp_calls = sum(1 for a in gp_actions if a.action == "EVALUATE")
            
            results["fixtures"].append({
                "fixture_id": fixture["fixture_id"],
                "g0_calls": g0_calls,
                "g2_prunes": g2_prune_count,
                "g2_calls": g2_calls,
                "gp_prunes": gp_prunes,
                "gp_calls": gp_calls
            })
            
            results["totals"]["G0_would_calls"] += g0_calls
            results["totals"]["G2_theorem_prunes"] += g2_prune_count
            results["totals"]["G2_would_calls"] += g2_calls
            results["totals"]["GP_arbitrary_prunes"] += gp_prunes
            results["totals"]["GP_would_calls"] += gp_calls
        
        return results
