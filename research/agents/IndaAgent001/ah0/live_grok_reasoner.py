"""Minimal live Grok reasoner adapter for AH0.

This module provides the reasoner interface expected by AH0StateMachine:

    proposal = reasoner.propose_next_operation(state)

Network calls occur only when both:
  - AH0_RUN_LIVE_GROK is set to a truthy value, and
  - XAI_API_KEY is present.

Otherwise the adapter fails closed. Parsing of model output is pure and
can be exercised with local dummy payloads; a transport callable may be
injected for zero-cost tests.
"""
from __future__ import annotations

import json
import os
import urllib.request
from typing import Any, Callable, Optional

from .models import AgentProposal, Operation, EvidenceStatus

_API_URL = "https://api.x.ai/v1/responses"
_DEFAULT_MODEL = "grok-4.7"


class LiveReasonerDisabled(RuntimeError):
    """Raised when a live call is requested but the adapter is not enabled."""


class LiveReasonerParseError(ValueError):
    """Raised when the model response cannot be parsed into AgentProposal."""



def canonical_operation_values() -> tuple[str, ...]:
    """Single-source canonical operation vocabulary derived from Operation."""
    return tuple(op.value for op in Operation)


def _is_enabled() -> bool:
    flag = os.environ.get("AH0_RUN_LIVE_GROK", "").strip().lower()
    key = os.environ.get("XAI_API_KEY", "").strip()
    return flag in ("1", "true", "yes") and bool(key)


def parse_proposal(payload: Any, proposal_id: str) -> AgentProposal:
    """Parse a dict (or JSON string) into AgentProposal. Fail closed."""
    if isinstance(payload, str):
        try:
            payload = json.loads(payload)
        except json.JSONDecodeError as exc:
            raise LiveReasonerParseError(f"invalid JSON: {exc}") from exc
    if not isinstance(payload, dict):
        raise LiveReasonerParseError("response is not an object")

    op_raw = payload.get("operation")
    if op_raw is None:
        raise LiveReasonerParseError("missing operation")
    try:
        operation = Operation(op_raw)
    except ValueError as exc:
        raise LiveReasonerParseError(f"unknown operation: {op_raw}") from exc

    status_raw = payload.get("proposed_status")
    proposed_status: Optional[EvidenceStatus] = None
    if status_raw is not None:
        try:
            proposed_status = EvidenceStatus(status_raw)
        except ValueError as exc:
            raise LiveReasonerParseError(f"unknown status: {status_raw}") from exc

    justification = payload.get("justification")
    if not isinstance(justification, str) or not justification:
        raise LiveReasonerParseError("missing or empty justification")

    gain = payload.get("expected_information_gain")
    if not isinstance(gain, str) or not gain:
        raise LiveReasonerParseError("missing or empty expected_information_gain")

    return AgentProposal(
        proposal_id=proposal_id,
        operation=operation,
        target_record_id=payload.get("target_record_id"),
        target_obligation_id=payload.get("target_obligation_id"),
        proposed_status=proposed_status,
        justification=justification,
        expected_information_gain=gain,
    )


def _default_transport(prompt: str) -> str:
    """Call the xAI API. Only invoked when the adapter is enabled."""
    key = os.environ["XAI_API_KEY"]
    body = json.dumps({
        "model": _DEFAULT_MODEL,
        "input": prompt,
    }).encode()
    req = urllib.request.Request(
        _API_URL,
        data=body,
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        data = json.loads(resp.read().decode())
    # Responses API shape: output text is nested; fail closed if absent.
    output = data.get("output")
    if not output:
        raise LiveReasonerParseError("empty API output")
    # Extract first text content if present.
    for item in output if isinstance(output, list) else [output]:
        if isinstance(item, dict):
            content = item.get("content") or item.get("text")
            if isinstance(content, str):
                return content
            if isinstance(content, list):
                for c in content:
                    if isinstance(c, dict) and isinstance(c.get("text"), str):
                        return c["text"]
    raise LiveReasonerParseError("no text content in API output")


class LiveGrokReasoner:
    """Reasoner that calls Grok only when explicitly enabled.

    A transport callable may be supplied for zero-cost tests. When no
    transport is supplied, the default network transport is used, but only
    if the enablement gate passes; otherwise LiveReasonerDisabled is raised.
    """

    def __init__(
        self,
        transport: Optional[Callable[[str], str]] = None,
        proposal_prefix: str = "live",
    ):
        self._transport = transport
        self._prefix = proposal_prefix
        self._step = 0

    def propose_next_operation(self, visible_state) -> AgentProposal:
        if self._transport is None and not _is_enabled():
            raise LiveReasonerDisabled(
                "live Grok reasoner is disabled "
                "(set AH0_RUN_LIVE_GROK=1 and XAI_API_KEY to enable)"
            )
        transport = self._transport or _default_transport
        # Visible state is serialised only for the prompt; oracle fields
        # are not part of AH0State, so they are not included.
        ops = canonical_operation_values()
        prompt = json.dumps(
            {
                "instruction": (
                    "Propose the next AH0 operation as a JSON object. "
                    "The operation field MUST be exactly one of: "
                    + ", ".join(ops)
                    + ". Synonyms, aliases, abbreviations, and unlisted values are invalid. "
                    "INSPECT is invalid unless it appears in the list above. "
                    "Output only the proposal object. "
                    "justification and expected_information_gain are required. "
                    "You propose only; you do not execute operations."
                ),
                "allowed_operations": list(ops),
                "state": visible_state.model_dump() if hasattr(visible_state, "model_dump") else str(visible_state),
            },
            default=str,
        )
        raw = transport(prompt)
        self._step += 1
        return parse_proposal(raw, f"{self._prefix}-{self._step}")
