"""A2_2 Verified Bloom Partition Tree structurally distinct pruning probe."""
import json
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent

class SourceRecord:
    def __init__(self, occurrence_id, record_id, exact_identity, payload, provenance_lineage):
        self.occurrence_id = occurrence_id
        self.record_id = record_id
        self.exact_identity = exact_identity
        self.payload = payload
        self.provenance_lineage = provenance_lineage

class CanonicalRequirement:
    def __init__(self, required_identities):
        self.required_identities = frozenset(required_identities)

class BloomFilter:
    """Simple Bloom filter for structural distinction."""
    def __init__(self, bit_count=64, hash_probes=3):
        self.bit_count = bit_count
        self.hash_probes = hash_probes
        self.bits = [False] * bit_count
    
    def _hash(self, identity, probe):
        content = f"{identity}:{probe}"
        h = int(hashlib.sha256(content.encode()).hexdigest(), 16)
        return h % self.bit_count
    
    def insert(self, identity):
        for p in range(self.hash_probes):
            self.bits[self._hash(identity, p)] = True
    
    def may_contain(self, identity):
        for p in range(self.hash_probes):
            if not self.bits[self._hash(identity, p)]:
                return False
        return True

class VBPTNode:
    def __init__(self, node_id, interval_start, interval_end, level):
        self.node_id = node_id
        self.interval_start = interval_start
        self.interval_end = interval_end
        self.level = level
        self.bloom = BloomFilter()
        self.left = None
        self.right = None
        self.identities = set()

class VBPT:
    """Verified Bloom Partition Tree."""
    def __init__(self, source, source_digest, leaf_size=16):
        self.source_digest = source_digest
        self.source_length = len(source)
        self.leaf_size = leaf_size
        self.build_trace = []
        self.nodes = []
        self.root = self._build(source, 0, len(source), 0)
    
    def _build(self, source, start, end, level):
        node = VBPTNode(f"node_{len(self.nodes)}", start, end, level)
        self.nodes.append(node)
        for i in range(start, end):
            self.build_trace.append(i)
            node.bloom.insert(source[i].exact_identity)
            node.identities.add(source[i].exact_identity)
        if end - start > self.leaf_size:
            mid = (start + end) // 2
            node.left = self._build(source, start, mid, level + 1)
            node.right = self._build(source, mid, end, level + 1)
        return node
    
    def query(self, source, requirement):
        """Query VBPT for required identities."""
        source_inspections = 0
        bloom_probes = 0
        candidate_leaves = 0
        observed = set()
        
        def search(node, identity):
            nonlocal source_inspections, bloom_probes, candidate_leaves
            bloom_probes += 1
            if not node.bloom.may_contain(identity):
                return False
            if node.left is None:
                candidate_leaves += 1
                for i in range(node.interval_start, node.interval_end):
                    source_inspections += 1
                    if source[i].exact_identity == identity:
                        return True
                return False
            return search(node.left, identity) or search(node.right, identity)
        
        for ident in requirement.required_identities:
            if search(self.root, ident):
                observed.add(ident)
        
        if requirement.required_identities.issubset(observed):
            return {"result": "ADMIT", "source_inspections": source_inspections, "bloom_probes": bloom_probes, "candidate_leaves": candidate_leaves}
        return {"result": "STOP_INSUFFICIENT", "source_inspections": source_inspections, "bloom_probes": bloom_probes, "candidate_leaves": candidate_leaves}

def compute_source_digest(source):
    content = json.dumps([{"id": r.record_id, "identity": r.exact_identity} for r in source], sort_keys=True)
    return hashlib.sha256(content.encode()).hexdigest()

def generate_source(source_size, requirement_size, placement):
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

def run_a1(source, requirement):
    observed = set()
    inspected = []
    for r in source:
        inspected.append(r.occurrence_id)
        if r.exact_identity in requirement.required_identities:
            observed.add(r.exact_identity)
        if requirement.required_identities.issubset(observed):
            return {"result": "ADMIT", "inspected_count": len(inspected)}
    return {"result": "STOP_INSUFFICIENT", "inspected_count": len(inspected)}

def main():
    source_sizes = [32, 64, 128, 256, 512, 1024]
    requirement_sizes = [1, 2, 4, 8, 16]
    placements = ["EARLY", "LATE"]
    leaf_sizes = [8, 16, 32]
    
    cell_results = []
    
    for xs in source_sizes:
        for rs in requirement_sizes:
            if rs >= xs:
                continue
            for placement in placements:
                for leaf_size in leaf_sizes:
                    source, requirement = generate_source(xs, rs, placement)
                    source_digest = compute_source_digest(source)
                    tree = VBPT(source, source_digest, leaf_size)
                    
                    a1_result = run_a1(source, requirement)
                    vbpt_result = tree.query(source, requirement)
                    
                    cell_results.append({
                        "source_size": xs,
                        "requirement_size": rs,
                        "placement": placement,
                        "leaf_size": leaf_size,
                        "build_inspections": len(tree.build_trace),
                        "a1_inspections": a1_result["inspected_count"],
                        "vbpt_inspections": vbpt_result["source_inspections"],
                        "bloom_probes": vbpt_result["bloom_probes"],
                        "candidate_leaves": vbpt_result["candidate_leaves"],
                        "a1_result": a1_result["result"],
                        "vbpt_result": vbpt_result["result"]
                    })
    
    (ROOT / "A2_2_CELL_RESULTS.json").write_text(json.dumps({"results": cell_results}, indent=2))
    
    print(f"Executed {len(cell_results)} cells")
    
    # Summary
    for placement in placements:
        cells = [c for c in cell_results if c["placement"] == placement and c["leaf_size"] == 16]
        if cells:
            avg_a1 = sum(c["a1_inspections"] for c in cells) / len(cells)
            avg_vbpt = sum(c["vbpt_inspections"] for c in cells) / len(cells)
            print(f"  {placement}: A1={avg_a1:.1f}, VBPT={avg_vbpt:.1f}")
    
    # Safety: false positive does not cause false ADMIT
    false_positives = [c for c in cell_results if c["candidate_leaves"] > c["requirement_size"] and c["vbpt_result"] == "ADMIT"]
    print(f"  False-positive branches with ADMIT: {len(false_positives)}")

if __name__ == "__main__":
    main()
