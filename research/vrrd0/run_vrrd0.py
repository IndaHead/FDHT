"""VRRD0 microscopic verified radix range source-inspection probe."""
import json
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent

# Frozen source domain
IDENTITIES = []
for prefix in ["aa", "ab", "ac", "ad", "ba", "bb", "bc", "bd"]:
    for i in range(8):
        IDENTITIES.append(f"{prefix}{i:02d}")

assert len(IDENTITIES) == 64
assert len(set(IDENTITIES)) == 64

# Source order: SHA-256 permutation
def permute_source(identities):
    def sort_key(identity):
        content = f"FDHT-VRRD0-SOURCE-ORDER-v1{identity}"
        return hashlib.sha256(content.encode()).hexdigest()
    return sorted(identities, key=sort_key)

permuted = permute_source(IDENTITIES)

# Create source records
class SourceRecord:
    def __init__(self, occurrence_id, record_id, exact_identity, payload, provenance_lineage):
        self.occurrence_id = occurrence_id
        self.record_id = record_id
        self.exact_identity = exact_identity
        self.payload = payload
        self.provenance_lineage = provenance_lineage

source = []
for i, ident in enumerate(permuted):
    source.append(SourceRecord(
        f"occ_{i:02d}",
        f"rec_{i:02d}",
        ident,
        f"payload_{ident}",
        f"lineage_{ident}"
    ))

# Derived order: sorted by prefix, then identity
def derived_sort_key(record):
    return (record.exact_identity[:2], record.exact_identity, record.occurrence_id)

derived_order = sorted(source, key=derived_sort_key)

# Build directory: prefix -> range in derived order
directory = {}
current_prefix = None
start_idx = 0
for i, record in enumerate(derived_order):
    prefix = record.exact_identity[:2]
    if prefix != current_prefix:
        if current_prefix is not None:
            directory[current_prefix] = {"start": start_idx, "end": i}
        current_prefix = prefix
        start_idx = i
directory[current_prefix] = {"start": start_idx, "end": len(derived_order)}

# Verify "ac" range
ac_range = directory["ac"]
ac_identities = [derived_order[i].exact_identity for i in range(ac_range["start"], ac_range["end"])]
assert len(ac_identities) == 8
assert "ac05" in ac_identities

# A0: exhaustive
def run_a0(source, requirement):
    inspected = []
    for r in source:
        inspected.append(r.occurrence_id)
        if r.exact_identity == requirement:
            return {"result": "ADMIT", "inspected_count": len(inspected), "active": r.exact_identity}
    return {"result": "STOP_INSUFFICIENT", "inspected_count": len(inspected), "active": None}

# A1: sequential
def run_a1(source, requirement):
    inspected = []
    for i, r in enumerate(source):
        inspected.append(r.occurrence_id)
        if r.exact_identity == requirement:
            return {"result": "ADMIT", "inspected_count": len(inspected), "completion_position": i + 1, "active": r.exact_identity}
    return {"result": "STOP_INSUFFICIENT", "inspected_count": len(inspected), "completion_position": len(source), "active": None}

# VRRD: radix range
def run_vrrd(source, derived_order, directory, requirement):
    prefix = requirement[:2]
    rng = directory[prefix]
    
    radix_probes = 1
    range_refs = 0
    source_derefs = 0
    source_verifications = 0
    
    for i in range(rng["start"], rng["end"]):
        range_refs += 1
        source_derefs += 1
        source_verifications += 1
        if derived_order[i].exact_identity == requirement:
            return {
                "result": "ADMIT",
                "radix_probes": radix_probes,
                "range_refs": range_refs,
                "source_derefs": source_derefs,
                "source_verifications": source_verifications,
                "active": derived_order[i].exact_identity
            }
    return {
        "result": "STOP_INSUFFICIENT",
        "radix_probes": radix_probes,
        "range_refs": range_refs,
        "source_derefs": source_derefs,
        "source_verifications": source_verifications,
        "active": None
    }

# Execute
requirement = "ac05"
a0_result = run_a0(source, requirement)
a1_result = run_a1(source, requirement)
vrrd_result = run_vrrd(source, derived_order, directory, requirement)

# Results
results = {
    "source_count": 64,
    "distinct_identities": 64,
    "requirement": requirement,
    "prefix": "ac",
    "candidate_count": 8,
    "sigma": 8/64,
    "range_amplification": 8,
    "a0_inspections": a0_result["inspected_count"],
    "a0_result": a0_result["result"],
    "a1_inspections": a1_result["inspected_count"],
    "a1_completion_position": a1_result["completion_position"],
    "a1_result": a1_result["result"],
    "vrrd_radix_probes": vrrd_result["radix_probes"],
    "vrrd_range_refs": vrrd_result["range_refs"],
    "vrrd_source_derefs": vrrd_result["source_derefs"],
    "vrrd_source_verifications": vrrd_result["source_verifications"],
    "vrrd_result": vrrd_result["result"],
    "vrrd_active": vrrd_result["active"],
    "build_source": 64,
    "build_metadata": len(directory),
    "validation_source": 64
}

(ROOT / "VRRD0_RESULTS.json").write_text(json.dumps(results, indent=2))

print("VRRD0 microscopic probe complete")
print(f"A0 inspections: {results['a0_inspections']}")
print(f"A1 inspections: {results['a1_inspections']} (K={results['a1_completion_position']})")
print(f"VRRD source derefs: {results['vrrd_source_derefs']}")
print(f"VRRD result: {results['vrrd_result']}")
print(f"Active: {results['vrrd_active']}")
print(f"Query benefit: A1={results['a1_inspections']} vs VRRD={results['vrrd_source_derefs']}")

if __name__ == "__main__":
    pass
