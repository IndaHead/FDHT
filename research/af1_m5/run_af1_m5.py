"""AF1-M5 MORPH-5 semantic requirement-representation invariance."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent

class CanonicalRequirement:
    def __init__(self, required_identities):
        self.required_identities = frozenset(required_identities)
    
    def __eq__(self, other):
        return self.required_identities == other.required_identities

def canonicalise_requirement(raw):
    """Canonicalise requirement representation. Returns CanonicalRequirement or error."""
    if isinstance(raw, list):
        return CanonicalRequirement(raw)
    elif isinstance(raw, dict):
        if "required" in raw:
            return CanonicalRequirement(raw["required"])
        elif "required_identities" in raw:
            return CanonicalRequirement(raw["required_identities"])
        else:
            return {"error": "missing required field"}
    else:
        return {"error": "malformed"}

def main():
    # Base semantic requirement
    base_ids = ["entity_001", "entity_002"]
    base_canonical = CanonicalRequirement(base_ids)
    
    # Positive representations (should all canonicalise to same)
    positive = {
        "E0": ["entity_001", "entity_002"],
        "E1": ["entity_002", "entity_001"],  # reordered
        "E2": ["entity_001", "entity_002", "entity_001"],  # duplicates
        "E3": {"required": ["entity_001", "entity_002"]},
        "E4": {"required": ["entity_001", "entity_002"], "notes": "inert"},
        "E5": ["entity_001", "entity_002"],  # formatting variant
        "E6": {"version": "1.0", "required": ["entity_001", "entity_002"]},
        "E7": {"required": ["entity_001", "entity_002"]}  # key order variant
    }
    
    # Negative representations (should differ or error)
    negative = {
        "N0": ["entity_001"],  # one removed
        "N1": ["entity_001", "entity_002", "entity_003"],  # one added
        "N2": ["entity_001", "entity_002_near"],  # near match
        "N3": ["entity_001", "ENTITY_002"],  # case mutation
        "N4": "malformed",  # malformed
        "N5": {"version": "99.0", "required": ["entity_001"]},  # unsupported
        "N6": {"required": ["a", "b"], "required_identities": ["a", "c"]},  # conflict
        "N7": []  # empty
    }
    
    results = {"positive": {}, "negative": {}}
    
    # Test positive
    for key, raw in positive.items():
        result = canonicalise_requirement(raw)
        if isinstance(result, CanonicalRequirement):
            results["positive"][key] = {
                "canonical_equal": result == base_canonical,
                "error": None
            }
        else:
            results["positive"][key] = {
                "canonical_equal": False,
                "error": result.get("error")
            }
    
    # Test negative
    for key, raw in negative.items():
        result = canonicalise_requirement(raw)
        if isinstance(result, CanonicalRequirement):
            results["negative"][key] = {
                "canonical_equal": result == base_canonical,
                "error": None
            }
        else:
            results["negative"][key] = {
                "canonical_equal": False,
                "error": result.get("error")
            }
    
    (ROOT / "AF1_M5_CANONICALISATION_RESULTS.json").write_text(json.dumps(results, indent=2))
    
    # Summary
    pos_equal = sum(1 for r in results["positive"].values() if r["canonical_equal"])
    neg_equal = sum(1 for r in results["negative"].values() if r["canonical_equal"])
    neg_error = sum(1 for r in results["negative"].values() if r["error"])
    
    print(f"Positive canonical equal: {pos_equal}/8")
    print(f"Negative canonical equal: {neg_equal}/8")
    print(f"Negative errors: {neg_error}/8")

if __name__ == "__main__":
    main()
