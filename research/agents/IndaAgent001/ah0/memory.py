"""Deterministic, read-only AH0 memory catalogue."""
from typing import List, Dict, Optional
from .models import MemoryRecord, MemoryClass

class MemoryStore:
    def __init__(self, records: List[MemoryRecord]):
        self._records = {r.record_id: r for r in records}
        self._index = self._build_index()

    def _build_index(self) -> List[Dict]:
        return [
            {
                "record_id": r.record_id,
                "record_class": r.record_class.value,
                "requirement_tags": r.requirement_tags,
                "scope_summary": r.scope,
                "provenance_summary": r.provenance,
                "verification_summary": r.verification_status,
                "supersession_summary": r.supersession_status,
                "content_summary": r.content[:80] + "..." if len(r.content) > 80 else r.content,
            }
            for r in self._records.values()
        ]

    def get_visible_index(self) -> List[Dict]:
        return self._index

    def query_index(self, query: str) -> List[Dict]:
        q = query.lower()
        return [
            entry for entry in self._index
            if q in entry["record_id"].lower()
            or any(q in tag.lower() for tag in entry["requirement_tags"])
            or q in entry["content_summary"].lower()
        ]

    def inspect_record(self, record_id: str) -> Optional[MemoryRecord]:
        return self._records.get(record_id)
