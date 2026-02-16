#!/usr/bin/env python3
"""Purge QA/SIM/SAMPLE test artifacts from the MakerFlow database.

Why this exists:
- Multiple local verification scripts generate synthetic rows for QA.
- Test rows should not persist in normal workspace data after scripts finish.
- This utility centralizes marker-based cleanup logic so every script uses the same rules.
"""

from __future__ import annotations

import argparse
import re
import sqlite3
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.server import db_connect, ensure_bootstrap

DEFAULT_MARKERS: Sequence[str] = ("qa", "sim", "sample")


def build_marker_pattern(markers: Sequence[str]) -> re.Pattern[str]:
    """Compile a matcher that catches common QA/SIM/SAMPLE tagging styles.

    Matching strategy:
    - Bracketed labels: [QA ...], [SIM ...], [SAMPLE ...]
    - Standalone words: QA, SIM, SAMPLE, SIMULATION
    - Known synthetic email patterns used by local scripts.
    """
    marker_tokens = [m.strip().lower() for m in markers if m and m.strip()]
    if not marker_tokens:
        marker_tokens = list(DEFAULT_MARKERS)
    token_union = "|".join(re.escape(token) for token in marker_tokens)

    return re.compile(
        rf"""
        (
            \[(?:{token_union})[^\]]*\] |
            \b(?:{token_union}|simulation)\b |
            qa\.[\w.+-]+@makerflow\.local\b |
            qa\.collab\d+@makerflow\.local\b |
            sim\.user\d+@makerflow\.local\b |
            sample\d+@makerflow\.local\b
        )
        """,
        re.IGNORECASE | re.VERBOSE,
    )


def table_names(conn: sqlite3.Connection) -> List[str]:
    rows = conn.execute(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
    ).fetchall()
    return [str(row["name"]) for row in rows]


def table_columns(conn: sqlite3.Connection, table: str) -> List[sqlite3.Row]:
    return conn.execute(f"PRAGMA table_info({table})").fetchall()


def text_columns(conn: sqlite3.Connection, table: str) -> List[str]:
    names: List[str] = []
    for row in table_columns(conn, table):
        col_type = str(row["type"] or "").upper()
        if "TEXT" in col_type:
            names.append(str(row["name"]))
    return names


def primary_identifier(conn: sqlite3.Connection, table: str) -> str:
    cols = table_columns(conn, table)
    names = [str(row["name"]) for row in cols]
    if "id" in names:
        return "id"
    return "rowid"


def has_column(conn: sqlite3.Connection, table: str, column: str) -> bool:
    return any(str(row["name"]) == column for row in table_columns(conn, table))


def deletion_order(all_tables: Iterable[str]) -> List[str]:
    ordered = [
        "meeting_items",
        "onboarding_assignments",
        "team_members",
        "calendar_sync_links",
        "calendar_sync_settings",
        "memberships",
        "password_resets",
        "sessions",
        "user_preferences",
        "item_comments",
        "email_messages",
        "audit_log",
        "tasks",
        "projects",
        "intake_requests",
        "equipment_assets",
        "consumables",
        "partnerships",
        "meeting_note_sources",
        "meeting_agendas",
        "onboarding_templates",
        "report_templates",
        "custom_views",
        "spaces",
        "teams",
        "calendar_events",
        "users",
        "insight_snapshots",
    ]
    seen = set()
    result: List[str] = []
    for table in ordered:
        if table in all_tables and table not in seen:
            result.append(table)
            seen.add(table)
    for table in sorted(all_tables):
        if table not in seen and table != "organizations":
            result.append(table)
    return result


def row_has_marker(values: Iterable[object], pattern: re.Pattern[str]) -> bool:
    for value in values:
        if value is None:
            continue
        if pattern.search(str(value)):
            return True
    return False


def collect_matching_ids(
    conn: sqlite3.Connection,
    table: str,
    id_col: str,
    text_cols: Sequence[str],
    pattern: re.Pattern[str],
    organization_id: Optional[int],
) -> List[int]:
    scoped = has_column(conn, table, "organization_id") and organization_id is not None
    where = " WHERE organization_id = ?" if scoped else ""
    params: tuple = (organization_id,) if scoped else ()
    sql = f"SELECT {id_col} AS row_id, {', '.join(text_cols)} FROM {table}{where}"

    matches: List[int] = []
    for row in conn.execute(sql, params).fetchall():
        values = [row[col] for col in text_cols]
        if row_has_marker(values, pattern):
            try:
                matches.append(int(row["row_id"]))
            except (TypeError, ValueError):
                continue
    return matches


def delete_rows(conn: sqlite3.Connection, table: str, id_col: str, ids: Sequence[int]) -> int:
    if not ids:
        return 0
    total = 0
    chunk_size = 250
    for start in range(0, len(ids), chunk_size):
        chunk = ids[start : start + chunk_size]
        placeholders = ", ".join(["?"] * len(chunk))
        cursor = conn.execute(f"DELETE FROM {table} WHERE {id_col} IN ({placeholders})", tuple(chunk))
        total += int(cursor.rowcount or 0)
    return total


def cleanup_test_data(
    conn: sqlite3.Connection,
    organization_id: Optional[int] = None,
    markers: Sequence[str] = DEFAULT_MARKERS,
    dry_run: bool = False,
) -> Dict[str, int]:
    """Delete marker-matching test rows and return counts by table."""
    pattern = build_marker_pattern(markers)
    counts: Dict[str, int] = {}
    tables = table_names(conn)

    for table in deletion_order(tables):
        txt_cols = text_columns(conn, table)
        if not txt_cols:
            continue
        id_col = primary_identifier(conn, table)
        ids = collect_matching_ids(conn, table, id_col, txt_cols, pattern, organization_id)
        if not ids:
            continue
        counts[table] = len(ids) if dry_run else delete_rows(conn, table, id_col, ids)

    if not dry_run:
        conn.commit()
    return counts


def summarize_counts(counts: Dict[str, int]) -> str:
    if not counts:
        return "no rows removed"
    parts = [f"{table}:{count}" for table, count in sorted(counts.items()) if int(count) > 0]
    return ", ".join(parts) if parts else "no rows removed"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Remove QA/SIM/SAMPLE test records from MakerFlow data.")
    parser.add_argument("--org-id", type=int, default=None, help="Optional organization_id scope.")
    parser.add_argument(
        "--markers",
        nargs="*",
        default=list(DEFAULT_MARKERS),
        help="Marker words to match (default: qa sim sample).",
    )
    parser.add_argument("--dry-run", action="store_true", help="Show matched counts without deleting.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    ensure_bootstrap()
    conn = db_connect()
    try:
        counts = cleanup_test_data(
            conn,
            organization_id=args.org_id,
            markers=args.markers,
            dry_run=args.dry_run,
        )
    finally:
        conn.close()
    print("TEST_DATA_CLEANUP", summarize_counts(counts))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
