#!/usr/bin/env python3
"""Reset runtime data to a clean release baseline.

This script removes the SQLite database files and reboots the app bootstrap path,
leaving only the default workspace/admin baseline records.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.server import DB_PATH, db_connect, ensure_bootstrap


def main() -> int:
    db_files = {DB_PATH, Path(f"{DB_PATH}-shm"), Path(f"{DB_PATH}-wal")}
    data_dir = ROOT / "data"
    if data_dir.exists():
        for pattern in ("*_ops.db", "*_ops.db-shm", "*_ops.db-wal"):
            db_files.update(data_dir.glob(pattern))

    for path in sorted(db_files):
        try:
            if path.exists():
                path.unlink()
        except FileNotFoundError:
            pass

    ensure_bootstrap()

    conn = db_connect()
    try:
        summary = {
            "organizations": int(conn.execute("SELECT COUNT(*) AS c FROM organizations").fetchone()["c"]),
            "users": int(conn.execute("SELECT COUNT(*) AS c FROM users").fetchone()["c"]),
            "projects": int(conn.execute("SELECT COUNT(*) AS c FROM projects").fetchone()["c"]),
            "tasks": int(conn.execute("SELECT COUNT(*) AS c FROM tasks").fetchone()["c"]),
            "intake_requests": int(conn.execute("SELECT COUNT(*) AS c FROM intake_requests").fetchone()["c"]),
            "equipment_assets": int(conn.execute("SELECT COUNT(*) AS c FROM equipment_assets").fetchone()["c"]),
            "consumables": int(conn.execute("SELECT COUNT(*) AS c FROM consumables").fetchone()["c"]),
            "partnerships": int(conn.execute("SELECT COUNT(*) AS c FROM partnerships").fetchone()["c"]),
            "meeting_agendas": int(conn.execute("SELECT COUNT(*) AS c FROM meeting_agendas").fetchone()["c"]),
            "meeting_note_sources": int(conn.execute("SELECT COUNT(*) AS c FROM meeting_note_sources").fetchone()["c"]),
        }
        org = conn.execute("SELECT id, name, slug FROM organizations ORDER BY id LIMIT 1").fetchone()
        admin = conn.execute("SELECT id, email, name FROM users ORDER BY id LIMIT 1").fetchone()
    finally:
        conn.close()

    print("RELEASE_STATE_RESET")
    print("org", dict(org) if org else None)
    print("admin", dict(admin) if admin else None)
    print("counts", summary)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
