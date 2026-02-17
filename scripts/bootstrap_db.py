#!/usr/bin/env python3
"""Run MakerFlow database bootstrap/migrations and print a quick table summary."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.server import DB_BACKEND, DB_PATH, DATABASE_URL, db_connect, ensure_bootstrap


def main() -> int:
    ensure_bootstrap()
    conn = db_connect()
    try:
        probes = {}
        for table in ("organizations", "users", "memberships", "spaces", "teams", "projects", "tasks", "sessions"):
            probes[table] = int(conn.execute(f"SELECT COUNT(*) AS c FROM {table}").fetchone()["c"])
    finally:
        conn.close()

    print("BOOTSTRAP_OK")
    print("backend:", DB_BACKEND)
    if DB_BACKEND == "postgres":
        print("database_url_set:", bool(DATABASE_URL))
    else:
        print("db_path:", DB_PATH)
    print("counts:", probes)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
