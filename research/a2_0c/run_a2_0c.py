"""A2_0C address-structure accounting correction."""
import json
from pathlib import Path
from collections import defaultdict

ROOT = Path(__file__).resolve().parent

class Record:
    def __init__(self, record_id, entity_identity, payload, lineage):
        self.record_id = record_id
        self.entity_identity = entity_identity
        self.payload = payload
        self.lineage = lineage

class Requirement:
    def __init__(self, required_identities):
        self.required_identities = frozenset(required_identities)

class IdentityAddressIndex:
    def __init__(self, source):
        self.source_length = len(source)
        self.entries = defaultdict(list)
        self.build_trace = []
        for i, r in enumerate(source):
            self.build_trace.append(i)
            self.entries[r.entity_identity].append(i)
    
    def lookup(self, identity):
        return self.entries.get(identity, [])

def generate_source(source_size, requirement_size, placement):
    required = [f"req_{i}" for i in range(requirement_size)]
    source = []
    for i, ident in enumerate(required):
        source.append(Record(f"req_{i}", ident, f"payload_{ident}", f"lineage_{ident}"))
    while len(source) < source_size:
        idx = len(source)
        source.append(Record(f"irr_{idx}", f"irrelevant_{idx}", f"payload_irr_{idx}", f"lineage_irr_{idx}"))
    if placement == "LATE":
        source = source[requirement_size:] + source[:requirement_size]
    return source, Requirement(required)

def run_a1(source, requirement):
    observed = set()
    inspected = []
    for r in source:
        inspected.append(r.record_id)
        if r.entity_identity in requirement.required_identities:
            observed.add(r.entity_identity)
        if requirement.required_identities.issubset(observed):
            return {"result": "ADMIT", "inspected_count": len(inspected), "trace": inspected}
    return {"result": "STOP_INSUFFICIENT", "inspected_count": len(inspected), "trace": inspected}

def run_a2(source, index, requirement):
    source_inspections = 0
    lookups = 0
    dereference_trace = []
    observed = set()
    for ident in requirement.required_identities:
        lookups += 1
        addresses = index.lookup(ident)
        if not addresses:
            return {"result": "STOP_INSUFFICIENT", "source_inspections": source_inspections, "lookups": lookups, "trace": dereference_trace}
        pos = addresses[0]
        source_inspections += 1
        dereference_trace.append(pos)
        if source[pos].entity_identity == ident:
            observed.add(ident)
    if requirement.required_identities.issubset(observed):
        return {"result": "ADMIT", "source_inspections": source_inspections, "lookups": lookups, "trace": dereference_trace}
    return {"result": "STOP_INSUFFICIENT", "source_inspections": source_inspections, "lookups": lookups, "trace": dereference_trace}

def run_workload(source, index, requirement, query_count):
    """Execute repeated queries and calculate cumulative totals."""
    a1_cumulative = 0
    a2_cumulative = 0
    for q in range(query_count):
        a1_result = run_a1(source, requirement)
        a2_result = run_a2(source, index, requirement)
        a1_cumulative += a1_result["inspected_count"]
        a2_cumulative += a2_result["source_inspections"]
    return {
        "a1_cumulative": a1_cumulative,
        "a2_query_cumulative": a2_cumulative,
        "a2_e2e": index.source_length + a2_cumulative
    }

def main():
    source_sizes = [32, 64, 128, 256, 512, 1024]
    requirement_sizes = [1, 2, 4, 8, 16]
    placements = ["EARLY", "LATE"]
    query_counts = [1, 2, 4, 8, 16, 32]
    
    cell_results = []
    workload_results = []
    
    for xs in source_sizes:
        for rs in requirement_sizes:
            if rs >= xs:
                continue
            for placement in placements:
                source, requirement = generate_source(xs, rs, placement)
                index = IdentityAddressIndex(source)
                a1_result = run_a1(source, requirement)
                a2_result = run_a2(source, index, requirement)
                
                cell_results.append({
                    "source_size": xs,
                    "requirement_size": rs,
                    "placement": placement,
                    "build_inspections": len(index.build_trace),
                    "a1_inspections": a1_result["inspected_count"],
                    "a2_query_inspections": a2_result["source_inspections"],
                    "a2_lookups": a2_result["lookups"],
                    "a1_result": a1_result["result"],
                    "a2_result": a2_result["result"]
                })
                
                for qc in query_counts:
                    workload = run_workload(source, index, requirement, qc)
                    workload_results.append({
                        "source_size": xs,
                        "requirement_size": rs,
                        "placement": placement,
                        "query_count": qc,
                        "a1_cumulative": workload["a1_cumulative"],
                        "a2_query_cumulative": workload["a2_query_cumulative"],
                        "a2_e2e": workload["a2_e2e"],
                        "break_even": workload["a2_e2e"] < workload["a1_cumulative"]
                    })
    
    (ROOT / "A2_0C_CELL_RESULTS.json").write_text(json.dumps({"results": cell_results}, indent=2))
    (ROOT / "A2_0C_WORKLOAD_RESULTS.json").write_text(json.dumps({"results": workload_results}, indent=2))
    
    print(f"Executed {len(cell_results)} cells, {len(workload_results)} workload rows")
    
    # Summary by R
    for rs in requirement_sizes:
        cells = [c for c in cell_results if c["requirement_size"] == rs and c["placement"] == "LATE"]
        if cells:
            c = cells[0]
            print(f"  R={rs} LATE: A1={c['a1_inspections']}, A2_query={c['a2_query_inspections']}, A2_build={c['build_inspections']}")
    
    # Break-even summary
    late_break = [w for w in workload_results if w["placement"] == "LATE" and w["break_even"]]
    early_break = [w for w in workload_results if w["placement"] == "EARLY" and w["break_even"]]
    print(f"  LATE break-even rows: {len(late_break)}")
    print(f"  EARLY break-even rows: {len(early_break)}")

if __name__ == "__main__":
    main()
