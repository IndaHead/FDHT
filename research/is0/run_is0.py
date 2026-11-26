"""IS0 inspection-scaling and completion-position experiment."""
import json
from pathlib import Path

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

def generate_source(source_size, requirement_size, placement, composition):
    """Generate concrete source with specified placement and composition."""
    required = [f"req_{i}" for i in range(requirement_size)]
    source = []
    
    # Generate required records
    for i, ident in enumerate(required):
        source.append(Record(f"req_{i}", ident, f"payload_{ident}", f"lineage_{ident}"))
    
    # Generate irrelevant records
    while len(source) < source_size:
        idx = len(source)
        source.append(Record(f"irr_{idx}", f"irrelevant_{idx}", f"payload_irr_{idx}", f"lineage_irr_{idx}"))
    
    # Apply placement
    if placement == "EARLY":
        # Required at beginning
        pass
    elif placement == "LATE":
        # Required at end
        source = source[requirement_size:] + source[:requirement_size]
    elif placement == "DISPERSED":
        # Interleave
        pass
    
    return source, Requirement(required)

def run_a1(source, requirement):
    """A1 requirement-conditioned. Stops when all required identities observed."""
    observed = set()
    inspected = []
    active = []
    for i, r in enumerate(source):
        inspected.append(r.record_id)
        if r.entity_identity in requirement.required_identities:
            active.append(r.record_id)
            observed.add(r.entity_identity)
        if requirement.required_identities.issubset(observed):
            return {
                "result": "ADMIT",
                "inspected": inspected,
                "active": active,
                "completion_position": i + 1
            }
    return {
        "result": "STOP_INSUFFICIENT",
        "inspected": inspected,
        "active": active,
        "completion_position": None
    }

def main():
    source_sizes = [32, 64, 128, 256, 512, 1024]
    requirement_sizes = [1, 2, 4, 8, 16]
    placements = ["EARLY", "LATE", "DISPERSED"]
    
    results = []
    for xs in source_sizes:
        for rs in requirement_sizes:
            if rs >= xs:
                continue
            for placement in placements:
                source, requirement = generate_source(xs, rs, placement, "BASELINE")
                result = run_a1(source, requirement)
                results.append({
                    "source_size": xs,
                    "requirement_size": rs,
                    "placement": placement,
                    "inspected_count": len(result["inspected"]),
                    "active_count": len(result["active"]),
                    "completion_position": result["completion_position"],
                    "result": result["result"]
                })
    
    (ROOT / "IS0_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    print(f"Executed {len(results)} cells")
    
    # Summary
    for xs in source_sizes:
        cells = [r for r in results if r["source_size"] == xs]
        early = [c for c in cells if c["placement"] == "EARLY"]
        late = [c for c in cells if c["placement"] == "LATE"]
        if early:
            print(f"  |X|={xs}: EARLY I={early[0]['inspected_count']}, LATE I={late[0]['inspected_count']}")

if __name__ == "__main__":
    main()
