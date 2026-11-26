"""Research-level information-control spine.

This is research packaging. It does not promote AH₀.
It does not duplicate permanent FDHT mathematics.
It does not import domain semantics.
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Callable, Generic, Mapping, Protocol, Sequence, TypeVar


X = TypeVar("X")
Y = TypeVar("Y")
R = TypeVar("R")
E = TypeVar("E")


class SufficiencyStatus(str, Enum):
    SUFFICIENT = "SUFFICIENT"
    INSUFFICIENT = "INSUFFICIENT"


class EvaluationStatus(str, Enum):
    ESTABLISHED = "ESTABLISHED"
    REFUTED = "REFUTED"
    UNRESOLVED = "UNRESOLVED"
    CONFLICTING = "CONFLICTING"


class GateResult(str, Enum):
    ADMIT = "ADMIT"
    REJECT = "REJECT"
    STOP = "STOP"


@dataclass(frozen=True)
class Requirement(Generic[Y, R]):
    requirement_id: str
    observation: Callable[[Y], object]
    consumer: Callable[[Y], R]


@dataclass(frozen=True)
class ObservableLossWitness(Generic[Y, R]):
    left: Y
    right: Y
    shared_observation: object
    left_consumer_result: R
    right_consumer_result: R


@dataclass(frozen=True)
class SufficiencyResult(Generic[Y, R]):
    status: SufficiencyStatus
    witness: ObservableLossWitness[Y, R] | None = None


@dataclass(frozen=True)
class TransformationRecord(Generic[X, Y]):
    transformation_id: str
    source: X
    output: Y
    source_digest: str | None = None
    output_digest: str | None = None
    provenance: Mapping[str, str] | None = None


@dataclass(frozen=True)
class EvaluationResult(Generic[E]):
    status: EvaluationStatus
    value: E | None
    justification: str


@dataclass(frozen=True)
class ControlDecision(Generic[X, Y, E]):
    transformation: TransformationRecord[X, Y]
    sufficiency: SufficiencyResult[Y, object]
    evaluation: EvaluationResult[E] | None
    gate: GateResult
    reason: str


class Transformer(Protocol[X, Y]):
    def __call__(self, source: X) -> Y:
        ...


class Evaluator(Protocol[Y, E]):
    def __call__(self, working_state: Y) -> EvaluationResult[E]:
        ...


def check_bounded_sufficiency(
    states: Sequence[Y],
    requirement: Requirement[Y, R],
) -> SufficiencyResult[Y, R]:
    """Bounded executable check. Not a universal proof."""
    for left_index, left in enumerate(states):
        left_observation = requirement.observation(left)
        left_result = requirement.consumer(left)
        for right in states[left_index + 1 :]:
            right_observation = requirement.observation(right)
            if left_observation != right_observation:
                continue
            right_result = requirement.consumer(right)
            if left_result != right_result:
                return SufficiencyResult(
                    status=SufficiencyStatus.INSUFFICIENT,
                    witness=ObservableLossWitness(
                        left=left,
                        right=right,
                        shared_observation=left_observation,
                        left_consumer_result=left_result,
                        right_consumer_result=right_result,
                    ),
                )
    return SufficiencyResult(status=SufficiencyStatus.SUFFICIENT)


def gate_evaluation(result: EvaluationResult[object]) -> GateResult:
    if result.status is EvaluationStatus.ESTABLISHED:
        return GateResult.ADMIT
    if result.status is EvaluationStatus.REFUTED:
        return GateResult.REJECT
    return GateResult.STOP


def execute_information_control(
    *,
    transformation_id: str,
    source: X,
    transformer: Transformer[X, Y],
    bounded_states: Sequence[Y],
    requirement: Requirement[Y, object],
    evaluator: Evaluator[Y, E],
    provenance: Mapping[str, str] | None = None,
) -> ControlDecision[X, Y, E]:
    working_state = transformer(source)
    transformation = TransformationRecord(
        transformation_id=transformation_id,
        source=source,
        output=working_state,
        provenance=provenance,
    )
    sufficiency = check_bounded_sufficiency(
        states=bounded_states,
        requirement=requirement,
    )
    if sufficiency.status is SufficiencyStatus.INSUFFICIENT:
        return ControlDecision(
            transformation=transformation,
            sufficiency=sufficiency,
            evaluation=None,
            gate=GateResult.STOP,
            reason="STOP_INSUFFICIENT",
        )
    evaluation = evaluator(working_state)
    gate = gate_evaluation(evaluation)
    return ControlDecision(
        transformation=transformation,
        sufficiency=sufficiency,
        evaluation=evaluation,
        gate=gate,
        reason=f"{evaluation.status.value}_{gate.value}",
    )
