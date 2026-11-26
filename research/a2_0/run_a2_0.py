"""A2_0 requirement-blind address structure experiment."""
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
    """Requirement-blind address structure."""
    def __init__(self, source):
        self.source_length = len(source)
        self.entries = defaultdict(list)
        self.build_inspections = 0
        # Build index without requirement access
        for i, r in enumerate(source):
            self.build_inspections += 1
            self.entries[r.entity_identity].append(i)
    
    def lookup(self, identity):
        return self.entries.get(identity, [])

def generate_source(source_size, requirement_size, placement):
    """Generate concrete source."""
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
    """A1 sequential requirement-conditioned."""
    observed = set()
    inspected = []
    for r in source:
        inspected.append(r.record_id)
        if r.entity_identity in requirement.required_identities:
            observed.add(r.entity_identity)
        if requirement.required_identities.issubset(observed):
            return {"result": "ADMIT", "inspected_count": len(inspected)}
    return {"result": "STOP_INSUFFICIENT", "inspected_count": len(inspected)}

def run_a2(source, index, requirement):
    """A2 requirement-conditioned addressed inspection."""
    source_inspections = 0
    lookups = 0
    observed = set()
    for ident in requirement.required_identities:
        lookups += 1
        addresses = index.lookup(ident)
        if not addresses:
            return {"result": "STOP_INSUFFICIENT", "source_inspections": source_inspections, "lookups": lookups}
        # Verify first occurrence
        pos = addresses[0]
        source_inspections += 1
        if source[pos].entity_identity == ident:
            observed.add(ident)
    if requirement.required_identities.issubset(observed):
        return {"result": "ADMIT", "source_inspections": source_inspections, "lookups": lookups}
    return {"result": "STOP_INSUFFICIENT", "source_inspections": source_inspections, "lookups": lookups}

def main():
    source_sizes = [32, 64, 128, 256, 512, 1024]
    requirement_sizes = [1, 2, 4, 8, 16]
    placements = ["EARLY", "LATE"]
    
    results = []
    for xs in source_sizes:
        for rs in requirement_sizes:
            if rs >= xs:
                continue
            for placement in placements:
                source, requirement = generate_source(xs, rs, placement)
                index = IdentityAddressIndex(source)
                a1_result = run_a1(source, requirement)
                a2_result = run_a2(source, index, requirement)
                results.append({
                    "source_size": xs,
                    "requirement_size": rs,
                    "placement": placement,
                    "a1_inspected": a1_result["inspected_count"],
                    "a2_source_inspections": a2_result["source_inspections"],
                    "a2_lookups": a2_result["lookups"],
                    "a2_build_inspections": index.build_inspections,
                    "a1_result": a1_result["result"],
                    "a2_result": a2_result["result"]
                })
    
    (ROOT / "A2_0_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    print(f"Executed {len(results)} cells")
    
    # Summary
    for xs in source_sizes:
        cells = [r for r in results if r["source_size"] == xs and r["placement"] == "LATE"]
        if cells:
            c = cells[0]
            print(f"  |X|={xs} LATE: A1={c['a1_inspected']}, A2_query={c['a2_source_inspections']}, A2_build={c['a2_build_inspections']}")

if __name__ == "__main__":
    main()
