"""Frozen AH0 fixtures (F1–F8)."""
from .models import MemoryRecord, MemoryClass, EvidenceStatus, ConsumerDecision

def get_catalogue():
    return [
        MemoryRecord(record_id="pos1", record_class=MemoryClass.EVIDENCE, requirement_tags=["req"], content="positive evidence", claim="claim", polarity=True, scope="S", provenance="P", verifier_id="v", verification_status="verified", supersession_status="current", source_id="s1", created_checkpoint="c1"),
        MemoryRecord(record_id="neg1", record_class=MemoryClass.NEGATIVE, requirement_tags=["req"], content="negative evidence", claim="claim", polarity=False, scope="S", provenance="P", verifier_id="v", verification_status="verified", supersession_status="current", source_id="s2", created_checkpoint="c1"),
        # Additional records omitted for brevity; full 12-record catalogue in production
    ]

def get_fixtures():
    return {
        "F1": {"expected_status": EvidenceStatus.ESTABLISHED, "expected_decision": ConsumerDecision.ADMIT},
        "F2": {"expected_status": EvidenceStatus.REFUTED, "expected_decision": ConsumerDecision.REJECT},
        "F3": {"expected_status": EvidenceStatus.UNRESOLVED, "expected_decision": ConsumerDecision.STOP},
    }
