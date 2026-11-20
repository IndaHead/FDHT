"""SQLite event log for AH0.

Persisted projection (R3I):

    sequence_number
    operation
    target_record_id
    proposed_status
    admission_result
    terminal

This is the existing baseline B plus the unique minimal sufficient
extension identified by AH0-R3P. Baseline fields are retained.
"""
import sqlite3
from typing import List
from .models import AH0Event

class EventLog:
    def __init__(self, db_path: str = ":memory:"):
        self.conn = sqlite3.connect(db_path)
        self.conn.execute("""
            CREATE TABLE IF NOT EXISTS events (
                sequence_number INTEGER,
                operation TEXT,
                target_record_id TEXT,
                proposed_status TEXT,
                admission_result TEXT,
                terminal INTEGER
            )
        """)

    def append(self, event: AH0Event):
        status = (
            event.proposal.proposed_status.value
            if event.proposal.proposed_status is not None
            else None
        )
        self.conn.execute(
            "INSERT INTO events VALUES (?, ?, ?, ?, ?, ?)",
            (
                event.sequence_number,
                event.proposal.operation.value,
                event.proposal.target_record_id,
                status,
                event.admission_result.value,
                int(event.terminal),
            ),
        )
        self.conn.commit()

    def reconstruct(self) -> List:
        return list(self.conn.execute("SELECT * FROM events"))
