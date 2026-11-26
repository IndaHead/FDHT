"""AF1-ADV2 concrete adversarial fixture execution."""
import json
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent

class Record:
    def __init__(self, record_id, entity_identity, payload, provenance_lineage):
        self.record_id = record_id
        self.entity_identity = entity_identity
        self.payload = payload
        self.provenance_lineage = provenance_lineage

class Requirement:
    def __init__(self, required_identities):
        self.required_identities = set(required_identities)

def generate_fixture(source_size, requirement_size, geometry, attack, shadow, seed):
    """Generate concrete fixture. Does NOT calculate expected outcome."""
    required = [f"entity_{i:03d}" for i in range(requirement_size)]
    
    # Apply attack
    if attack == "M0":
        present = required[:]
        missing = []
    elif attack == "M1":
        present = required[:-1]
        missing = [required[-1]]
    else:  # M50
        half = requirement_size // 2
        present = required[:half]
        missing = required[half:]
    
    # Generate source records
    source = []
    for i, ident in enumerate(present):
        source.append(Record(f"req_{i}", ident, f"payload_{ident}", f"lineage_{ident}"))
    
    # Add irrelevant records to fill source
    while len(source) < source_size:
        idx = len(source)
        source.append(Record(f"irr_{idx}", f"irrelevant_{idx}", f"payload_irr_{idx}", f"lineage_irr_{idx}"))
    
    # Apply geometry (reorder)
    if geometry == "G1":  # dispersed
        # Interleave required with irrelevant
        pass  # simplified
    elif geometry == "G2":  # edge separated
        if len(present) >= 2:
            source[0], source[-1] = source[-1], source[0]
    
    return {
        "source": source,
        "requirement": Requirement(required),
        "present": present,
        "missing": missing,
        "source_size": source_size,
        "requirement_size": requirement_size,
        "geometry": geometry,
        "attack": attack,
        "shadow": shadow
    }

def expected_oracle(fixture):
    """Independent oracle. Uses only source and requirement."""
    present_ids = {r.entity_identity for r in fixture["source"]}
    required = fixture["requirement"].required_identities
    if required.issubset(present_ids):
        return "ADMIT"
    return "STOP_INSUFFICIENT"

def run_a0(source, requirement):
    """A0 exhaustive. Receives only source and requirement."""
    observed = set()
    inspected = []
    active = []
    for r in source:
        inspected.append(r.record_id)
        active.append(r.record_id)
        observed.add(r.entity_identity)
    if requirement.required_identities.issubset(observed):
        return {"result": "ADMIT", "inspected": inspected, "active": active}
    return {"result": "STOP_INSUFFICIENT", "inspected": inspected, "active": active}

def run_a1(source, requirement):
    """A1 requirement-conditioned. Receives only source and requirement."""
    observed = set()
    inspected = []
    active = []
    for r in source:
        inspected.append(r.record_id)
        if r.entity_identity in requirement.required_identities:
            active.append(r.record_id)
            observed.add(r.entity_identity)
        if requirement.required_identities.issubset(observed):
            return {"result": "ADMIT", "inspected": inspected, "active": active}
    return {"result": "STOP_INSUFFICIENT", "inspected": inspected, "active": active}

def main():
    sizes = [64, 256]
    requirements = [2, 4, 8]
    geometries = ["G0", "G1", "G2", "G3", "G4"]
    attacks = ["M0", "M1", "M50"]
    shadows = ["DS0", "DS1", "DS3", "DS4"]
    treatments = ["A0", "A1"]

    results = []
    for x in sizes:
        for r in requirements:
            for g in geometries:
                for a in attacks:
                    for s in shadows:
                        fixture = generate_fixture(x, r, g, a, s, 42)
                        expected = expected_oracle(fixture)
                        for t in treatments:
                            if t == "A0":
                                result = run_a0(fixture["source"], fixture["requirement"])
                            else:
                                result = run_a1(fixture["source"], fixture["requirement"])
                            results.append({
                                "source_size": x,
                                "requirement_size": r,
                                "geometry": g,
                                "attack": a,
                                "shadow": s,
                                "treatment": t,
                                "expected": expected,
                                "observed": result["result"],
                                "match": result["result"] == expected,
                                "active_count": len(result["active"]),
                                "inspected_count": len(result["inspected"])
                            })

    (ROOT / "AF1_ADV2_CELL_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    print(f"Executed {len(results)} cells")

    a1 = [r for r in results if r["treatment"] == "A1"]
    print(f"A1 cells: {len(a1)}")
    print(f"A1 match: {all(r['match'] for r in a1)}")
    print(f"A1 false ADMIT: {sum(1 for r in a1 if r['expected'] == 'STOP_INSUFFICIENT' and r['observed'] == 'ADMIT')}")

if __name__ == "__main__":
    main()
