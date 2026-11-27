#!/usr/bin/env python3
"""
SCF-03B: Typed Carrier and Transformation Graph

Research-local graph harness.

This script does not infer transformations from similar names or schemas.
Every carrier, transformation and consumer must be recovered from frozen
repository artefacts and registered with explicit provenance.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass, field
from enum import Enum
from hashlib import sha256
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Set, Tuple
import json


class Authority(str, Enum):
    PERMANENT = "PERMANENT"
    RESEARCH = "RESEARCH"
    EXPERIMENTAL = "EXPERIMENTAL"
    HISTORICAL = "HISTORICAL"
    DOCUMENTATION_ONLY = "DOCUMENTATION_ONLY"


class EvidenceStatus(str, Enum):
    PROVED = "PROVED"
    EXECUTABLE_BOUNDED = "EXECUTABLE_BOUNDED"
    DOCUMENTED_ONLY = "DOCUMENTED_ONLY"
    UNDERDETERMINED = "UNDERDETERMINED"


class ConsumerRelation(str, Enum):
    NATIVE = "NATIVE"
    PULLED_BACK = "PULLED_BACK"
    INVALID_DOMAIN = "INVALID_DOMAIN"
    UNRESOLVED = "UNRESOLVED"


class FateStatus(str, Enum):
    SUFFICIENT = "SUFFICIENT"
    OBSERVABLE_LOSS = "OBSERVABLE_LOSS"
    UNRESOLVED = "UNRESOLVED"
    NOT_APPLICABLE = "NOT_APPLICABLE"
    INVALID_DOMAIN_MATCH = "INVALID_DOMAIN_MATCH"


@dataclass(frozen=True)
class Provenance:
    path: str
    symbol: str
    authority: Authority
    commit: str
    evidence: EvidenceStatus
    note: str = ""


@dataclass(frozen=True)
class Carrier:
    id: str
    type_expression: str
    provenance: Provenance
    description: str = ""


@dataclass(frozen=True)
class Transformation:
    id: str
    source_carrier: str
    target_carrier: str
    type_expression: str
    provenance: Provenance
    source_threaded: bool = False
    validity_preconditions: Tuple[str, ...] = ()
    description: str = ""


@dataclass(frozen=True)
class Consumer:
    id: str
    carrier: str
    codomain: str
    type_expression: str
    provenance: Provenance
    description: str = ""


@dataclass(frozen=True)
class ConsumerTransport:
    id: str
    consumer: str
    transformation: str
    transported_consumer: str
    relation: ConsumerRelation
    provenance: Provenance
    description: str = ""


@dataclass(frozen=True)
class FateCell:
    transformation: str
    consumer: str
    status: FateStatus
    provenance: Provenance
    witness: Optional[str] = None
    assumptions: Tuple[str, ...] = ()


@dataclass
class TypedCarrierGraph:
    carriers: Dict[str, Carrier] = field(default_factory=dict)
    transformations: Dict[str, Transformation] = field(default_factory=dict)
    consumers: Dict[str, Consumer] = field(default_factory=dict)
    transports: Dict[str, ConsumerTransport] = field(default_factory=dict)
    fate_cells: List[FateCell] = field(default_factory=list)

    def add_carrier(self, carrier: Carrier) -> None:
        self._require_new(carrier.id, self.carriers, "carrier")
        self.carriers[carrier.id] = carrier

    def add_transformation(self, transformation: Transformation) -> None:
        self._require_new(
            transformation.id,
            self.transformations,
            "transformation",
        )
        self._require_carrier(transformation.source_carrier)
        self._require_carrier(transformation.target_carrier)
        self.transformations[transformation.id] = transformation

    def add_consumer(self, consumer: Consumer) -> None:
        self._require_new(consumer.id, self.consumers, "consumer")
        self._require_carrier(consumer.carrier)
        self.consumers[consumer.id] = consumer

    def add_fate_cell(self, cell: FateCell) -> None:
        if cell.transformation not in self.transformations:
            raise ValueError(f"Unknown transformation: {cell.transformation}")
        if cell.consumer not in self.consumers:
            raise ValueError(f"Unknown consumer: {cell.consumer}")
        transformation = self.transformations[cell.transformation]
        consumer = self.consumers[cell.consumer]
        domains_match = consumer.carrier == transformation.source_carrier
        if not domains_match and cell.status not in {
            FateStatus.INVALID_DOMAIN_MATCH,
            FateStatus.NOT_APPLICABLE,
        }:
            raise ValueError(
                f"Consumer/transformation domain mismatch: "
                f"{consumer.carrier} != {transformation.source_carrier}"
            )
        if cell.status == FateStatus.OBSERVABLE_LOSS and not cell.witness:
            raise ValueError("ObservableLoss requires an explicit witness.")
        self.fate_cells.append(cell)

    def consumers_by_carrier(self) -> Dict[str, List[str]]:
        result: Dict[str, List[str]] = {cid: [] for cid in self.carriers}
        for consumer in self.consumers.values():
            result[consumer.carrier].append(consumer.id)
        for ids in result.values():
            ids.sort()
        return result

    def outgoing(self, carrier_id: str) -> List[str]:
        self._require_carrier(carrier_id)
        return sorted(
            t.id for t in self.transformations.values()
            if t.source_carrier == carrier_id
        )

    def incoming(self, carrier_id: str) -> List[str]:
        self._require_carrier(carrier_id)
        return sorted(
            t.id for t in self.transformations.values()
            if t.target_carrier == carrier_id
        )

    def connected_components(self) -> List[List[str]]:
        adjacency: Dict[str, Set[str]] = {cid: set() for cid in self.carriers}
        for t in self.transformations.values():
            adjacency[t.source_carrier].add(t.target_carrier)
            adjacency[t.target_carrier].add(t.source_carrier)
        visited: Set[str] = set()
        components: List[List[str]] = []
        for start in sorted(self.carriers):
            if start in visited:
                continue
            stack = [start]
            component: List[str] = []
            while stack:
                current = stack.pop()
                if current in visited:
                    continue
                visited.add(current)
                component.append(current)
                for neighbour in sorted(adjacency[current], reverse=True):
                    if neighbour not in visited:
                        stack.append(neighbour)
            components.append(sorted(component))
        return components

    def find_direct_edge(self, source: str, target: str) -> List[str]:
        self._require_carrier(source)
        self._require_carrier(target)
        return sorted(
            t.id for t in self.transformations.values()
            if t.source_carrier == source and t.target_carrier == target
        )

    def validate(self) -> List[str]:
        errors: List[str] = []
        for t in self.transformations.values():
            if t.source_carrier not in self.carriers:
                errors.append(f"{t.id}: missing source carrier")
            if t.target_carrier not in self.carriers:
                errors.append(f"{t.id}: missing target carrier")
        for c in self.consumers.values():
            if c.carrier not in self.carriers:
                errors.append(f"{c.id}: missing native carrier")
        seen_cells: Set[Tuple[str, str]] = set()
        for cell in self.fate_cells:
            key = (cell.transformation, cell.consumer)
            if key in seen_cells:
                errors.append(f"Duplicate fate cell: {cell.transformation}/{cell.consumer}")
            seen_cells.add(key)
        return errors

    def to_payload(self) -> dict:
        return {
            "carriers": [asdict(self.carriers[k]) for k in sorted(self.carriers)],
            "transformations": [asdict(self.transformations[k]) for k in sorted(self.transformations)],
            "consumers": [asdict(self.consumers[k]) for k in sorted(self.consumers)],
            "consumer_transports": [asdict(self.transports[k]) for k in sorted(self.transports)],
            "fate_cells": [
                asdict(c) for c in sorted(
                    self.fate_cells,
                    key=lambda i: (i.transformation, i.consumer),
                )
            ],
            "consumers_by_carrier": self.consumers_by_carrier(),
            "connected_components": self.connected_components(),
            "validation_errors": self.validate(),
        }

    def write_json(self, path: Path) -> str:
        payload = self.to_payload()
        encoded = json.dumps(payload, sort_keys=True, indent=2, separators=(",", ": ")).encode("utf-8")
        path.write_bytes(encoded + b"\n")
        return sha256(encoded + b"\n").hexdigest()

    @staticmethod
    def _require_new(identifier: str, collection: Dict[str, object], kind: str) -> None:
        if identifier in collection:
            raise ValueError(f"Duplicate {kind}: {identifier}")

    def _require_carrier(self, identifier: str) -> None:
        if identifier not in self.carriers:
            raise ValueError(f"Unknown carrier: {identifier}")


def provenance(*, path: str, symbol: str, authority: Authority, commit: str, evidence: EvidenceStatus, note: str = "") -> Provenance:
    return Provenance(path=path, symbol=symbol, authority=authority, commit=commit, evidence=evidence, note=note)


def build_graph_from_recovered_inventory() -> TypedCarrierGraph:
    graph = TypedCarrierGraph()

    # Permanent FDHT carriers
    graph.add_carrier(Carrier(
        id="RawHistory",
        type_expression="List KernelExprContext",
        provenance=provenance(
            path="fdht/FDHT_Audit_ArbitraryCollision.lean",
            symbol="RawHistory",
            authority=Authority.PERMANENT,
            commit="c657979fc81295ad8b02a57ea08c006d674de765",
            evidence=EvidenceStatus.PROVED,
        ),
        description="Permanent FDHT raw-history carrier.",
    ))

    graph.add_carrier(Carrier(
        id="TrajectoryBoundary",
        type_expression="TrajectoryBoundary resolve",
        provenance=provenance(
            path="fdht/FDHT_Audit_ArbitraryCollision.lean",
            symbol="TrajectoryBoundary",
            authority=Authority.PERMANENT,
            commit="c657979fc81295ad8b02a57ea08c006d674de765",
            evidence=EvidenceStatus.PROVED,
        ),
        description="Permanent trajectory quotient carrier.",
    ))

    # Permanent FDHT transformation
    graph.add_transformation(Transformation(
        id="trajectoryProjection",
        source_carrier="RawHistory",
        target_carrier="TrajectoryBoundary",
        type_expression="RawHistory -> TrajectoryBoundary resolve",
        provenance=provenance(
            path="fdht/FDHT_Audit_ArbitraryCollision.lean",
            symbol="trajectoryProjection",
            authority=Authority.PERMANENT,
            commit="c657979fc81295ad8b02a57ea08c006d674de765",
            evidence=EvidenceStatus.PROVED,
        ),
        description="Permanent quotient projection.",
    ))

    # Permanent FDHT consumer
    graph.add_consumer(Consumer(
        id="rawIdentityConsumer",
        carrier="RawHistory",
        codomain="RawHistory",
        type_expression="RawHistory -> RawHistory",
        provenance=provenance(
            path="research/probes/mrt05a/MRT05A_TrajectoryProjectionAdapter.lean",
            symbol="rawIdentityConsumer",
            authority=Authority.RESEARCH,
            commit="dd321fc9d77f5f1a93600daaa5e32bf8d66e1c0f",
            evidence=EvidenceStatus.PROVED,
        ),
        description="Identity consumer over complete raw history.",
    ))

    # Research-local A2 carriers (MRT-05B)
    graph.add_carrier(Carrier(
        id="SourceState",
        type_expression="List SourceRecord",
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="SourceState",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        description="Research-local A2 source state carrier.",
    ))

    graph.add_carrier(Carrier(
        id="ExactIndex",
        type_expression="Identity -> List Position",
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="ExactIndex",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        description="Research-local A2 exact index carrier.",
    ))

    graph.add_carrier(Carrier(
        id="CandidateRepresentation",
        type_expression="List Position",
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="candidateT",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        description="Research-local A2 candidate representation.",
    ))

    # Research-local A2 transformations
    graph.add_transformation(Transformation(
        id="buildExactIndex",
        source_carrier="SourceState",
        target_carrier="ExactIndex",
        type_expression="SourceState -> ExactIndex",
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="buildExactIndex",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        description="Requirement-blind index construction.",
    ))

    graph.add_transformation(Transformation(
        id="candidateT",
        source_carrier="SourceState",
        target_carrier="CandidateRepresentation",
        type_expression="Identity -> SourceState -> List Position",
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="candidateT",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        description="Candidate position lookup.",
    ))

    # Research-local A2 consumers
    graph.add_consumer(Consumer(
        id="identityMembershipConsumer",
        carrier="SourceState",
        codomain="Bool",
        type_expression="Identity -> SourceState -> Bool",
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="identityMembershipConsumer",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        description="Identity membership consumer.",
    ))

    graph.add_consumer(Consumer(
        id="identityMultiplicityConsumer",
        carrier="SourceState",
        codomain="Nat",
        type_expression="Identity -> SourceState -> Nat",
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="identityMultiplicityConsumer",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        description="Identity multiplicity consumer.",
    ))

    graph.add_consumer(Consumer(
        id="completeRecordConsumer",
        carrier="SourceState",
        codomain="Option SourceRecord",
        type_expression="Identity -> SourceState -> Option SourceRecord",
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="completeRecordConsumer",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        description="Complete record consumer.",
    ))

    graph.add_consumer(Consumer(
        id="provenanceConsumer",
        carrier="SourceState",
        codomain="Option Lineage",
        type_expression="Identity -> SourceState -> Option Lineage",
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="provenanceConsumer",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        description="Provenance consumer.",
    ))

    # Fate cells for A2
    graph.add_fate_cell(FateCell(
        transformation="candidateT",
        consumer="identityMembershipConsumer",
        status=FateStatus.SUFFICIENT,
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="c0_membership_structural",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.UNDERDETERMINED,
            note="Structural observation, not fully proved.",
        ),
    ))

    graph.add_fate_cell(FateCell(
        transformation="candidateT",
        consumer="identityMultiplicityConsumer",
        status=FateStatus.SUFFICIENT,
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="c1_multiplicity_structural",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.UNDERDETERMINED,
            note="Structural observation, not fully proved.",
        ),
    ))

    graph.add_fate_cell(FateCell(
        transformation="candidateT",
        consumer="completeRecordConsumer",
        status=FateStatus.OBSERVABLE_LOSS,
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="c2_observableLoss_completeRecord",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        witness="s1=[r1,id1,payload1,lineage1], s2=[r2,id1,payload2,lineage2]",
    ))

    graph.add_fate_cell(FateCell(
        transformation="candidateT",
        consumer="provenanceConsumer",
        status=FateStatus.OBSERVABLE_LOSS,
        provenance=provenance(
            path="research/probes/mrt05b/MRT05B_A2_SourceModel.lean",
            symbol="c3_observableLoss_provenance",
            authority=Authority.RESEARCH,
            commit="9bfc78261e05b166edb4726c6f7e896f7a5ad8d2",
            evidence=EvidenceStatus.EXECUTABLE_BOUNDED,
        ),
        witness="s1=[r1,id1,payload1,lineage1], s2=[r2,id1,payload2,lineage2]",
    ))

    # No SourceState <-> RawHistory edge.
    # SCF-03A found no existing adapter.

    return graph


def main() -> int:
    graph = build_graph_from_recovered_inventory()
    errors = graph.validate()
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    output = Path("research/scf03b/TYPED_CARRIER_GRAPH.json")
    output.parent.mkdir(parents=True, exist_ok=True)
    digest = graph.write_json(output)
    print(f"carrier_count={len(graph.carriers)}")
    print(f"transformation_count={len(graph.transformations)}")
    print(f"consumer_count={len(graph.consumers)}")
    print(f"component_count={len(graph.connected_components())}")
    print(f"sha256={digest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
