#!/usr/bin/env python3
"""Migrate MakerFlow data from SQLite to PostgreSQL.

Usage:
  MAKERSPACE_DATABASE_URL=postgresql://... python3 scripts/migrate_sqlite_to_postgres.py
  python3 scripts/migrate_sqlite_to_postgres.py --source /path/to/makerspace_ops.db --truncate
"""

from __future__ import annotations

import argparse
import os
import sqlite3
import sys
from pathlib import Path
from typing import Dict, List

try:
    import psycopg
except Exception as exc:  # pragma: no cover
    raise SystemExit(f"psycopg is required: {exc}")


ROOT = Path(__file__).resolve().parent.parent


def sqlite_tables(conn: sqlite3.Connection) -> List[str]:
    rows = conn.execute(
        """
        SELECT name
        FROM sqlite_master
        WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
        ORDER BY name
        """
    ).fetchall()
    return [str(r[0]) for r in rows]


def sqlite_columns(conn: sqlite3.Connection, table: str) -> List[str]:
    rows = conn.execute(f"PRAGMA table_info({table})").fetchall()
    return [str(r[1]) for r in rows]


def pg_columns(conn, table: str) -> List[str]:
    rows = conn.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = current_schema() AND table_name = %s
        ORDER BY ordinal_position
        """,
        (table,),
    ).fetchall()
    return [str(r[0]) for r in rows]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", default=str(ROOT / "data" / "makerspace_ops.db"))
    parser.add_argument("--truncate", action="store_true", help="truncate destination tables before import")
    args = parser.parse_args()

    db_url = os.environ.get("MAKERSPACE_DATABASE_URL", os.environ.get("DATABASE_URL", "")).strip()
    if not db_url:
        raise SystemExit("Set MAKERSPACE_DATABASE_URL (or DATABASE_URL) first.")

    source_path = Path(args.source)
    if not source_path.exists():
        raise SystemExit(f"SQLite source not found: {source_path}")

    src = sqlite3.connect(str(source_path))
    src.row_factory = sqlite3.Row
    dst = psycopg.connect(db_url, autocommit=False)

    migrated: Dict[str, int] = {}
    try:
        tables = sqlite_tables(src)
        with dst.cursor() as dcur:
            for table in tables:
                src_cols = sqlite_columns(src, table)
                dst_cols = pg_columns(dcur, table)
                if not dst_cols:
                    continue
                cols = [c for c in src_cols if c in set(dst_cols)]
                if not cols:
                    continue

                if args.truncate:
                    dcur.execute(f'TRUNCATE TABLE "{table}" RESTART IDENTITY CASCADE')

                qcols = ", ".join([f'"{c}"' for c in cols])
                ph = ", ".join(["%s"] * len(cols))
                insert_sql = f'INSERT INTO "{table}" ({qcols}) VALUES ({ph}) ON CONFLICT DO NOTHING'

                rows = src.execute(f'SELECT {qcols} FROM "{table}"').fetchall()
                if not rows:
                    migrated[table] = 0
                    continue

                batch = [tuple(row[c] for c in cols) for row in rows]
                dcur.executemany(insert_sql, batch)
                migrated[table] = len(batch)

        dst.commit()
    finally:
        src.close()
        dst.close()

    total = sum(migrated.values())
    print(f"MIGRATION_COMPLETE tables={len(migrated)} rows={total}")
    for table, count in sorted(migrated.items()):
        print(f"- {table}: {count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
