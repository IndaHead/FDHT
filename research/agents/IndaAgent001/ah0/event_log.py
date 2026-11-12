"""SQLite event log for AH0."""
import sqlite3
from typing import List
from .models import AH0Event

class EventLog:
    def __init__(self, db_path: str = ":memory:"):
        self.conn = sqlite3.connect(db_path)
        self.conn.execute("""
            CREATE TABLE IF NOT EXISTS events (
                sequence_number INTEGER,
                admission_result TEXT,
                terminal INTEGER
            )
        """)

    def append(self, event: AH0Event):
        self.conn.execute(
            "INSERT INTO events VALUES (?, ?, ?)",
            (event.sequence_number, event.admission_result.value, int(event.terminal)),
        )
        self.conn.commit()

    def reconstruct(self) -> List:
        return list(self.conn.execute("SELECT * FROM events"))
