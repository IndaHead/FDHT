"""A2_0S address-index corruption and freshness safety probe."""
import json
import hashlib
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

class SafeIdentityAddressIndex:
    """Fail-closed address index with digest binding."""
    def __init__(self, source, source_digest):
        self.source_digest = source_digest
        self.source_length = len(source)
        self.entries = defaultdict(list)
        self.build_inspections = 0
        for i, r in enumerate(source):
            self.build_inspections += 1
            self.entries[r.entity_identity].append({
                "position": i,
                "record_id": r.record_id,
                "identity": r.entity_identity,
                "lineage": r.lineage
            })
        self.index_digest = self._compute_index_digest()
        self.valid = True
        self.validated_source_digest = source_digest
    
    def _compute_index_digest(self):
        content = json.dumps({k: v for k, v in sorted(self.entries.items())}, sort_keys=True)
        return hashlib.sha256(content.encode()).hexdigest()
    
    def validate(self, source, source_digest):
        """Validate index against source."""
        if source_digest != self.validated_source_digest:
            return "STOP_INDEX_STALE"
        if len(source) != self.source_length:
            return "STOP_INDEX_STALE"
        # Full validation
        for i, r in enumerate(source):
            if r.entity_identity not in self.entries:
                return "STOP_INDEX_INVALID"
            found = False
            for addr in self.entries[r.entity_identity]:
                if addr["position"] == i and addr["identity"] == r.entity_identity:
                    found = True
                    break
            if not found:
                return "STOP_INDEX_INVALID"
        return "VALID"
    
    def lookup(self, identity):
        return self.entries.get(identity, [])

def compute_source_digest(source):
    content = json.dumps([{"id": r.record_id, "identity": r.entity_identity} for r in source], sort_keys=True)
    return hashlib.sha256(content.encode()).hexdigest()

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

def run_safe_a2(source, index, requirement, source_digest):
    """Safe A2 with fail-closed validation."""
    validation = index.validate(source, source_digest)
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
        if source[addr["position"]].entity_identity == ident:
            observed.add(ident)
    if requirement.required_identities.issubset(observed):
        return {"result": "ADMIT", "source_inspections": source_inspections, "lookups": lookups}
    return {"result": "STOP_INSUFFICIENT", "source_inspections": source_inspections, "lookups": lookups}

def main():
    source_sizes = [32, 128, 1024]
    requirement_sizes = [1, 4, 16]
    placements = ["EARLY", "LATE"]
    
    results = []
    
    for xs in source_sizes:
        for rs in requirement_sizes:
            if rs >= xs:
                continue
            for placement in placements:
                source, requirement = generate_source(xs, rs, placement)
                source_digest = compute_source_digest(source)
                index = SafeIdentityAddressIndex(source, source_digest)
                
                # S0: Valid baseline
                result = run_safe_a2(source, index, requirement, source_digest)
                results.append({
                    "source_size": xs,
                    "requirement_size": rs,
                    "placement": placement,
                    "attack": "S0_VALID",
                    "result": result["result"]
                })
                
                # C1: Missing identity bucket
                corrupted_index = SafeIdentityAddressIndex(source, source_digest)
                if required_ident := list(requirement.required_identities)[0]:
                    del corrupted_index.entries[required_ident]
                    corrupted_index.valid = False
                result = run_safe_a2(source, corrupted_index, requirement, source_digest)
                results.append({
                    "source_size": xs,
                    "requirement_size": rs,
                    "placement": placement,
                    "attack": "C1_MISSING_BUCKET",
                    "result": result["result"]
                })
                
                # R1: Source revision (append)
                revised_source = source + [Record("new", "new_identity", "payload", "lineage")]
                revised_digest = compute_source_digest(revised_source)
                result = run_safe_a2(revised_source, index, requirement, revised_digest)
                results.append({
                    "source_size": xs,
                    "requirement_size": rs,
                    "placement": placement,
                    "attack": "R1_SOURCE_REVISION",
                    "result": result["result"]
                })
    
    (ROOT / "A2_0S_RESULTS.json").write_text(json.dumps({"results": results}, indent=2))
    
    print(f"Executed {len(results)} cells")
    
    # Summary
    for attack in ["S0_VALID", "C1_MISSING_BUCKET", "R1_SOURCE_REVISION"]:
        cells = [r for r in results if r["attack"] == attack]
        results_count = {}
        for c in cells:
            results_count[c["result"]] = results_count.get(c["result"], 0) + 1
        print(f"  {attack}: {results_count}")

if __name__ == "__main__":
    main()
