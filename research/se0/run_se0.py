"""SE0: Derived-structure storage versus routing resolution.

Research-local reference implementation.

Measures:
- logical structural units;
- deterministic canonical serialised bytes;
- routing resolution;
- query source inspection;
- build and validation source inspection.

Does not measure:
- runtime;
- Python heap memory;
- compute;
- asymptotic complexity.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable

ROOT = Path(__file__).resolve().parent
SCHEMA_VERSION = "FDHT-SE0-v1"
SOURCE_ORDER_SEED = "FDHT-VRRD0-SOURCE-ORDER-v1"
PREFIX_DEPTH = 2
REQUIREMENT = "ac05"


@dataclass(frozen=True)
class SourceRecord:
    occurrence_id: str
    record_id: str
    exact_identity: str
    payload: str
    provenance_lineage: str


def canonical_json_bytes(value: Any) -> bytes:
    """Deterministic serialisation used for all byte comparisons."""
    return json.dumps(
        value,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=True,
    ).encode("utf-8")


def sha256_hex(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def frozen_identities() -> list[str]:
    return [
        f"{first}{second}{number:02d}"
        for first in ("a", "b")
        for second in ("a", "b", "c", "d")
        for number in range(8)
    ]


def source_order_key(identity: str) -> str:
    payload = f"{SOURCE_ORDER_SEED}{identity}".encode("utf-8")
    return sha256_hex(payload)


def build_frozen_source() -> tuple[SourceRecord, ...]:
    identities = sorted(frozen_identities(), key=source_order_key)

    return tuple(
        SourceRecord(
            occurrence_id=f"occ_{index:02d}",
            record_id=f"rec_{index:02d}",
            exact_identity=identity,
            payload=f"payload_{identity}",
            provenance_lineage=f"lineage_{identity}",
        )
        for index, identity in enumerate(identities)
    )


def source_manifest(source: tuple[SourceRecord, ...]) -> dict[str, Any]:
    return {
        "schema_version": SCHEMA_VERSION,
        "records": [
            {
                "position": position,
                "occurrence_id": record.occurrence_id,
                "record_id": record.record_id,
                "exact_identity": record.exact_identity,
                "payload": record.payload,
                "provenance_lineage": record.provenance_lineage,
            }
            for position, record in enumerate(source)
        ],
    }


def source_digest(source: tuple[SourceRecord, ...]) -> str:
    return sha256_hex(canonical_json_bytes(source_manifest(source)))


def derived_order(source: tuple[SourceRecord, ...]) -> tuple[int, ...]:
    """Requirement-blind order by prefix, full identity and occurrence ID."""
    return tuple(
        sorted(
            range(len(source)),
            key=lambda position: (
                source[position].exact_identity[:PREFIX_DEPTH],
                source[position].exact_identity,
                source[position].occurrence_id,
            ),
        )
    )


def build_exact_address_structure(
    source: tuple[SourceRecord, ...],
) -> tuple[dict[str, Any], list[int]]:
    build_trace: list[int] = []
    entries: list[dict[str, Any]] = []

    for position, record in enumerate(source):
        build_trace.append(position)
        entries.append(
            {
                "identity": record.exact_identity,
                "source_positions": [position],
            }
        )

    entries.sort(key=lambda entry: entry["identity"])

    structure = {
        "schema_version": SCHEMA_VERSION,
        "structure_type": "EXACT_ADDRESS",
        "source_digest": source_digest(source),
        "source_length": len(source),
        "entries": entries,
    }
    structure["structure_digest"] = sha256_hex(
        canonical_json_bytes(structure)
    )
    return structure, build_trace


def build_vrrd_structure(
    source: tuple[SourceRecord, ...],
) -> tuple[dict[str, Any], list[int], tuple[int, ...]]:
    order = derived_order(source)
    build_trace: list[int] = []
    references: list[dict[str, Any]] = []

    for derived_position, source_position in enumerate(order):
        build_trace.append(source_position)
        record = source[source_position]
        references.append(
            {
                "derived_position": derived_position,
                "source_position": source_position,
                "occurrence_id": record.occurrence_id,
            }
        )

    ranges: list[dict[str, Any]] = []
    start = 0

    while start < len(order):
        prefix = source[order[start]].exact_identity[:PREFIX_DEPTH]
        end = start + 1

        while (
            end < len(order)
            and source[order[end]].exact_identity[:PREFIX_DEPTH] == prefix
        ):
            end += 1

        ranges.append(
            {
                "prefix": prefix,
                "start": start,
                "end": end,
                "count": end - start,
            }
        )
        start = end

    structure = {
        "schema_version": SCHEMA_VERSION,
        "structure_type": "VRRD_DEPTH_2",
        "source_digest": source_digest(source),
        "source_length": len(source),
        "prefix_depth": PREFIX_DEPTH,
        "references": references,
        "ranges": ranges,
    }
    structure["structure_digest"] = sha256_hex(
        canonical_json_bytes(structure)
    )
    return structure, build_trace, order


def exact_query(
    source: tuple[SourceRecord, ...],
    structure: dict[str, Any],
    requirement: str,
) -> dict[str, Any]:
    metadata_trace: list[str] = []
    dereference_trace: list[int] = []

    for entry in structure["entries"]:
        metadata_trace.append(entry["identity"])

        if entry["identity"] != requirement:
            continue

        for position in entry["source_positions"]:
            dereference_trace.append(position)
            if source[position].exact_identity == requirement:
                return {
                    "outcome": "ADMIT",
                    "metadata_trace": metadata_trace,
                    "source_trace": dereference_trace,
                    "active_identity": requirement,
                }

    return {
        "outcome": "STOP_INSUFFICIENT",
        "metadata_trace": metadata_trace,
        "source_trace": dereference_trace,
        "active_identity": None,
    }


def vrrd_query(
    source: tuple[SourceRecord, ...],
    structure: dict[str, Any],
    requirement: str,
) -> dict[str, Any]:
    prefix = requirement[: structure["prefix_depth"]]
    radix_trace: list[str] = []
    reference_trace: list[int] = []
    source_trace: list[int] = []

    matching_range = None

    for descriptor in structure["ranges"]:
        radix_trace.append(descriptor["prefix"])
        if descriptor["prefix"] == prefix:
            matching_range = descriptor
            break

    if matching_range is None:
        return {
            "outcome": "STOP_INSUFFICIENT",
            "radix_trace": radix_trace,
            "reference_trace": reference_trace,
            "source_trace": source_trace,
            "active_identity": None,
        }

    for derived_position in range(
        matching_range["start"],
        matching_range["end"],
    ):
        reference = structure["references"][derived_position]
        reference_trace.append(derived_position)

        source_position = reference["source_position"]
        source_trace.append(source_position)

        if source[source_position].exact_identity == requirement:
            return {
                "outcome": "ADMIT",
                "radix_trace": radix_trace,
                "reference_trace": reference_trace,
                "source_trace": source_trace,
                "active_identity": requirement,
            }

    return {
        "outcome": "STOP_INSUFFICIENT",
        "radix_trace": radix_trace,
        "reference_trace": reference_trace,
        "source_trace": source_trace,
        "active_identity": None,
    }


def logical_metrics(structure: dict[str, Any]) -> dict[str, int]:
    if structure["structure_type"] == "EXACT_ADDRESS":
        entries = structure["entries"]
        return {
            "identity_keys": len(entries),
            "prefix_keys": 0,
            "address_references": sum(
                len(entry["source_positions"]) for entry in entries
            ),
            "range_descriptors": 0,
            "derived_references": 0,
            "structure_nodes": len(entries),
            "validation_digest_fields": 2,
        }

    if structure["structure_type"] == "VRRD_DEPTH_2":
        ranges = structure["ranges"]
        references = structure["references"]
        return {
            "identity_keys": 0,
            "prefix_keys": len(ranges),
            "address_references": 0,
            "range_descriptors": len(ranges),
            "derived_references": len(references),
            "structure_nodes": len(ranges),
            "validation_digest_fields": 2,
        }

    raise ValueError(f"Unknown structure: {structure['structure_type']}")


def serialised_storage_metrics(structure: dict[str, Any]) -> dict[str, Any]:
    whole_bytes = canonical_json_bytes(structure)

    if structure["structure_type"] == "EXACT_ADDRESS":
        key_bytes = sum(
            len(canonical_json_bytes(entry["identity"]))
            for entry in structure["entries"]
        )
        reference_bytes = sum(
            len(canonical_json_bytes(entry["source_positions"]))
            for entry in structure["entries"]
        )
        range_bytes = 0
        node_bytes = len(canonical_json_bytes(structure["entries"]))

    else:
        key_bytes = sum(
            len(canonical_json_bytes(descriptor["prefix"]))
            for descriptor in structure["ranges"]
        )
        reference_bytes = len(
            canonical_json_bytes(structure["references"])
        )
        range_bytes = len(canonical_json_bytes(structure["ranges"]))
        node_bytes = range_bytes

    validation_metadata = {
        "schema_version": structure["schema_version"],
        "source_digest": structure["source_digest"],
        "source_length": structure["source_length"],
        "structure_digest": structure["structure_digest"],
    }

    return {
        "canonical_serialised_bytes": len(whole_bytes),
        "canonical_sha256": sha256_hex(whole_bytes),
        "canonical_key_bytes": key_bytes,
        "canonical_reference_bytes": reference_bytes,
        "canonical_range_bytes": range_bytes,
        "canonical_node_bytes": node_bytes,
        "canonical_validation_metadata_bytes": len(
            canonical_json_bytes(validation_metadata)
        ),
    }


def validate_structure(
    source: tuple[SourceRecord, ...],
    structure: dict[str, Any],
) -> list[int]:
    """Full source validation trace. Returns inspected source positions."""
    trace = list(range(len(source)))

    if structure["source_digest"] != source_digest(source):
        raise AssertionError("Source digest mismatch")

    if structure["source_length"] != len(source):
        raise AssertionError("Source length mismatch")

    if structure["structure_type"] == "EXACT_ADDRESS":
        represented = set()

        for entry in structure["entries"]:
            for position in entry["source_positions"]:
                if source[position].exact_identity != entry["identity"]:
                    raise AssertionError("Exact-address identity mismatch")
                represented.add(position)

        if represented != set(range(len(source))):
            raise AssertionError("Exact index is incomplete")

    elif structure["structure_type"] == "VRRD_DEPTH_2":
        represented = set()

        for descriptor in structure["ranges"]:
            expected_prefix = descriptor["prefix"]

            for derived_position in range(
                descriptor["start"],
                descriptor["end"],
            ):
                reference = structure["references"][derived_position]
                source_position = reference["source_position"]

                if (
                    source[source_position]
                    .exact_identity[:PREFIX_DEPTH]
                    != expected_prefix
                ):
                    raise AssertionError("VRRD range-prefix mismatch")

                represented.add(source_position)

        if represented != set(range(len(source))):
            raise AssertionError("VRRD is incomplete")

    else:
        raise AssertionError("Unknown structure")

    return trace


def main() -> None:
    source = build_frozen_source()

    exact, exact_build_trace = build_exact_address_structure(source)
    vrrd, vrrd_build_trace, order = build_vrrd_structure(source)

    exact_validation_trace = validate_structure(source, exact)
    vrrd_validation_trace = validate_structure(source, vrrd)

    exact_result = exact_query(source, exact, REQUIREMENT)
    vrrd_result = vrrd_query(source, vrrd, REQUIREMENT)

    ac_range = next(
        descriptor
        for descriptor in vrrd["ranges"]
        if descriptor["prefix"] == "ac"
    )

    ac_candidate_positions = [
        vrrd["references"][derived_position]["source_position"]
        for derived_position in range(ac_range["start"], ac_range["end"])
    ]

    results = {
        "schema_version": SCHEMA_VERSION,
        "source": {
            "occurrences": len(source),
            "source_digest": source_digest(source),
            "requirement": REQUIREMENT,
        },
        "exact_address": {
            "logical": logical_metrics(exact),
            "storage": serialised_storage_metrics(exact),
            "build_source_inspections": len(exact_build_trace),
            "validation_source_inspections": len(
                exact_validation_trace
            ),
            "query_metadata_inspections": len(
                exact_result["metadata_trace"]
            ),
            "query_source_inspections": len(
                exact_result["source_trace"]
            ),
            "candidate_source_occurrences": 1,
            "candidate_fraction": 1 / len(source),
            "outcome": exact_result["outcome"],
            "active_identity": exact_result["active_identity"],
        },
        "vrrd": {
            "logical": logical_metrics(vrrd),
            "storage": serialised_storage_metrics(vrrd),
            "build_source_inspections": len(vrrd_build_trace),
            "validation_source_inspections": len(
                vrrd_validation_trace
            ),
            "query_metadata_inspections": (
                len(vrrd_result["radix_trace"])
                + len(vrrd_result["reference_trace"])
            ),
            "query_radix_node_probes": len(
                vrrd_result["radix_trace"]
            ),
            "query_range_reference_inspections": len(
                vrrd_result["reference_trace"]
            ),
            "query_source_inspections": len(
                vrrd_result["source_trace"]
            ),
            "candidate_source_occurrences": len(
                ac_candidate_positions
            ),
            "candidate_fraction": (
                len(ac_candidate_positions) / len(source)
            ),
            "derived_order_reference_count": len(order),
            "outcome": vrrd_result["outcome"],
            "active_identity": vrrd_result["active_identity"],
        },
    }

    exact_bytes = results["exact_address"]["storage"][
        "canonical_serialised_bytes"
    ]
    vrrd_bytes = results["vrrd"]["storage"][
        "canonical_serialised_bytes"
    ]

    results["comparison"] = {
        "vrrd_minus_exact_bytes": vrrd_bytes - exact_bytes,
        "vrrd_to_exact_byte_ratio": vrrd_bytes / exact_bytes,
        "exact_bytes_per_source_occurrence": (
            exact_bytes / len(source)
        ),
        "vrrd_bytes_per_source_occurrence": (
            vrrd_bytes / len(source)
        ),
        "exact_candidate_resolution": (
            results["exact_address"]["candidate_fraction"]
        ),
        "vrrd_candidate_resolution": (
            results["vrrd"]["candidate_fraction"]
        ),
        "exact_query_source_inspections": (
            results["exact_address"]["query_source_inspections"]
        ),
        "vrrd_query_source_inspections": (
            results["vrrd"]["query_source_inspections"]
        ),
    }

    output_path = ROOT / "SE0_RESULTS.json"
    output_path.write_text(
        json.dumps(results, indent=2, sort_keys=True),
        encoding="utf-8",
    )

    print(json.dumps(results["comparison"], indent=2))


if __name__ == "__main__":
    main()
