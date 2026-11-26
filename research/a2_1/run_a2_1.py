"""A2_1 independent replication of addressed inspection pruning."""
import json
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent

class SourceRecord:
    """Independent record type."""
    def __init__(self, occurrence_id, record_id, exact_identity, payload, provenance_lineage):
        self.occurrence_id = occurrence_id
        self.record_id = record_id
        self.exact_identity = exact_identity
        self.payload = payload
        self.provenance_lineage = provenance_lineage

class CanonicalRequirement:
    """Independent requirement type."""
    def __init__(self, required_identities):
        self.required_identities = frozenset(required_identities)

class SafeAddress:
    """Independent address type."""
    def __init__(self, source_position, occurrence_id, record_id, exact_identity, provenance_lineage):
        self.source_position = source_position
        self.occurrence_id = occurrence_id
        self.record_id = record_id
        self.exact_identity = exact_identity
        self.provenance_lineage = provenance_lineage

class SafeAddressIndex:
    """Independent sorted-tuple index (not defaultdict)."""
    def __init__(self, source, source_digest):
        self.schema_version = "A2_1_v1"
        self.source_digest = source_digest
        self.source_length = len(source)
        self.entries = []  # sorted tuple of (identity, tuple of addresses)
        self.build_trace = []
        buckets = {}
        for i, r in enumerate(source):
            self.build_trace.append(i)
            if r.exact_identity not in buckets:
                buckets[r.exact_identity] = []
            buckets[r.exact_identity].append(SafeAddress(i, r.occurrence_id, r.record_id, r.exact_identity, r.provenance_lineage))
        # Sort for deterministic order
        for identity in sorted(buckets.keys()):
            self.entries.append((identity, tuple(buckets[identity])))
        self.index_digest = self._compute_digest()
        self.valid = True
    
    def _compute_digest(self):
        content = json.dumps([(k, len(v)) for k, v in self.entries], sort_keys=True)
        return hashlib.sha256(content.encode()).hexdigest()
    
    def lookup(self, identity):
        """Binary search lookup."""
        for k, v in self.entries:
            if k == identity:
                return v
        return ()

def compute_source_digest(source):
    content = json.dumps([{"id": r.record_id, "identity": r.exact_identity} for r in source], sort_keys=True)
    return hashlib.sha256(content.encode()).hexdigest()

def generate_source(source_size, requirement_size, placement):
    """Independent source generator."""
    required = [f"req_{i}" for i in range(requirement_size)]
    source = []
    for i, ident in enumerate(required):
        source.append(SourceRecord(f"occ_{i}", f"rec_{i}", ident, f"payload_{ident}", f"lineage_{ident}"))
    while len(source) < source_size:
        idx = len(source)
        source.append(SourceRecord(f"occ_{idx}", f"rec_{idx}", f"irrelevant_{idx}", f"payload_irr_{idx}", f"lineage_irr_{idx}"))
    if placement == "LATE":
        source = source[requirement_size:] + source[:requirement_size]
    return source, CanonicalRequirement(required)

def source_oracle(source, requirement):
    """Independent source oracle."""
    present = {r.exact_identity for r in source}
    if requirement.required_identities.issubset(present):
        return "ADMIT"
    return "STOP_INSUFFICIENT"

def run_a1(source, requirement):
    """Independent A1 sequential scan."""
    observed = set()
    inspected = []
    for i, r in enumerate(source):
        inspected.append(r.occurrence_id)
        if r.exact_identity in requirement.required_identities:
            observed.add(r.exact_identity)
        if requirement.required_identities.issubset(observed):
            return {"result": "ADMIT", "inspected_count": len(inspected)}
    return {"result": "STOP_INSUFFICIENT", "inspected_count": len(inspected)}

def validate_index(source, index, source_digest):
    """Independent index validation."""
    if source_digest != index.source_digest:
        return "STOP_INDEX_STALE"
    if len(source) != index.source_length:
        return "STOP_INDEX_STALE"
    for i, r in enumerate(source):
        found = False
        for identity, addresses in index.entries:
            if identity == r.exact_identity:
                for addr in addresses:
                    if addr.source_position == i and addr.exact_identity == r.exact_identity:
                        found = True
                        break
        if not found:
            return "STOP_INDEX_INVALID"
    return "VALID"

def run_a2(source, index, requirement, source_digest):
    """Independent A2 addressed inspection."""
    validation = validate_index(source, index, source_digest)
    if validation != "VALID":
        return {"result": validation, "source_inspections": 0, "lookups": 0}
    
    source_inspections = 0
    lookups = 0
    observed = set()
    for ident in requirement.required_identities:
        lookups += 1
        addresses = index.lookup(ident)
        if not addresses:
            return {"result": "STOP_INSUFFICIENT", "source_inspections": source_inspections, "lookups": lookups}
        source_inspections += 1
        addr = addresses[0]
        if source[addr.source_position].exact_identity == ident:
            observed.add(ident)
    if requirement.required_identities.issubset(observed):
        return {"result": "ADMIT", "source_inspections": source_inspections, "lookups": lookups}
    return {"result": "STOP_INSUFFICIENT", "source_inspections": source_inspections, "lookups": lookups}

def main():
    source_sizes = [32, 64, 128, 256, 512, 1024]
    requirement_sizes = [1, 2, 4, 8, 16]
    placements = ["EARLY", "LATE"]
    query_counts = [1, 2, 4, 8, 16, 32]
    
    cell_results = []
    workload_results = []
    safety_results = []
    
    for xs in source_sizes:
        for rs in requirement_sizes:
            if rs >= xs:
                continue
            for placement in placements:
                source, requirement = generate_source(xs, rs, placement)
                source_digest = compute_source_digest(source)
                index = SafeAddressIndex(source, source_digest)
                
                a1_result = run_a1(source, requirement)
                a2_result = run_a2(source, index, requirement, source_digest)
                oracle_result = source_oracle(source, requirement)
                
                cell_results.append({
                    "source_size": xs,
                    "requirement_size": rs,
                    "placement": placement,
                    "build_inspections": len(index.build_trace),
                    "a1_inspections": a1_result["inspected_count"],
                    "a2_query_inspections": a2_result["source_inspections"],
                    "a1_result": a1_result["result"],
                    "a2_result": a2_result["result"],
                    "oracle_result": oracle_result
                })
                
                # Workload execution
                for qc in query_counts:
                    a1_cumulative = 0
                    a2_cumulative = 0
                    for q in range(qc):
                        a1_r = run_a1(source, requirement)
                        a2_r = run_a2(source, index, requirement, source_digest)
                        a1_cumulative += a1_r["inspected_count"]
                        a2_cumulative += a2_r["source_inspections"]
                    workload_results.append({
                        "source_size": xs,
                        "requirement_size": rs,
                        "placement": placement,
                        "query_count": qc,
                        "a1_cumulative": a1_cumulative,
                        "a2_e2e": len(index.build_trace) + a2_cumulative,
                        "break_even": (len(index.build_trace) + a2_cumulative) < a1_cumulative
                    })
                
                # Safety: missing bucket
                corrupted = SafeAddressIndex(source, source_digest)
                if corrupted.entries:
                    corrupted.entries = corrupted.entries[1:]  # Remove first identity
                corrupted.valid = False
                safety_result = run_a2(source, corrupted, requirement, source_digest)
                safety_results.append({
                    "source_size": xs,
                    "requirement_size": rs,
                    "placement": placement,
                    "attack": "MISSING_BUCKET",
                    "result": safety_result["result"]
                })
    
    (ROOT / "A2_1_CELL_RESULTS.json").write_text(json.dumps({"results": cell_results}, indent=2))
    (ROOT / "A2_1_WORKLOAD_RESULTS.json").write_text(json.dumps({"results": workload_results}, indent=2))
    (ROOT / "A2_1_SAFETY_RESULTS.json").write_text(json.dumps({"results": safety_results}, indent=2))
    
    print(f"Executed {len(cell_results)} cells, {len(workload_results)} workload rows, {len(safety_results)} safety rows")
    
    # Summary
    for rs in requirement_sizes:
        cells = [c for c in cell_results if c["requirement_size"] == rs and c["placement"] == "LATE"]
        if cells:
            c = cells[0]
            print(f"  R={rs} LATE: A1={c['a1_inspections']}, A2_query={c['a2_query_inspections']}, build={c['build_inspections']}")
    
    late_break = [w for w in workload_results if w["placement"] == "LATE" and w["break_even"]]
    early_break = [w for w in workload_results if w["placement"] == "EARLY" and w["break_even"]]
    print(f"  LATE break-even: {len(late_break)}")
    print(f"  EARLY break-even: {len(early_break)}")
    
    safety_invalid = [s for s in safety_results if s["result"] == "STOP_INDEX_INVALID"]
    print(f"  Safety STOP_INDEX_INVALID: {len(safety_invalid)}")

if __name__ == "__main__":
    main()
