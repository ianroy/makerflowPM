#!/usr/bin/env python3
"""Load deterministic sample data for usability and accessibility testing."""

import argparse
import os
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.server import LANES, db_connect, ensure_bootstrap, intake_score, iso
from scripts.test_data_cleanup import cleanup_test_data, summarize_counts
import datetime as dt

RANDOM_SEED = 20260216

NAMES = [
    "Alex Rivera",
    "Priya Shah",
    "Jordan Lee",
    "Maya Thompson",
    "Samir Patel",
    "Elena Garcia",
    "Noah Kim",
    "Ari Gold",
    "Jamie Fox",
    "Taylor Quinn",
    "Casey Lin",
    "Morgan Hall",
]

SCHOOLS = ["SET", "AHC", "SSSP", "Business & Economics", "University-wide"]
PROJECT_STATUSES = ["Planned", "Active", "Blocked", "Complete"]
TASK_STATUSES = ["Todo", "In Progress", "Blocked", "Done"]
PRIORITIES = ["Low", "Medium", "High", "Critical"]
ENERGIES = ["Low", "Medium", "High"]
PARTNER_STAGES = ["Discovery", "Active", "Pilot", "Dormant"]
HEALTH = ["Strong", "Medium", "At Risk"]
DEFAULT_ORG_SLUG = os.environ.get("MAKERSPACE_DEFAULT_ORG_SLUG", "default").strip().lower()
DEFAULT_ADMIN_EMAIL = os.environ.get("MAKERSPACE_ADMIN_EMAIL", "admin@makerflow.local").strip().lower()


def rand_date(days_back: int = 30, days_forward: int = 90) -> str:
    today = dt.date.today()
    offset = random.randint(-days_back, days_forward)
    return (today + dt.timedelta(days=offset)).isoformat()


def upsert_sample_users(conn, org_id):
    user_ids = []
    for idx, name in enumerate(NAMES, start=1):
        email = f"sample{idx}@makerflow.local"
        row = conn.execute("SELECT id FROM users WHERE email = ?", (email,)).fetchone()
        if row:
            user_id = row[0]
        else:
            from app.server import hash_password

            pw_hash, pw_salt = hash_password("SamplePassword!2026")
            conn.execute(
                "INSERT INTO users (email, name, password_hash, password_salt, is_active, is_superuser, created_at) VALUES (?, ?, ?, ?, 1, 0, ?)",
                (email, name, pw_hash, pw_salt, iso()),
            )
            user_id = conn.execute("SELECT id FROM users WHERE email = ?", (email,)).fetchone()[0]
        user_ids.append(user_id)

        m = conn.execute(
            "SELECT id FROM memberships WHERE user_id = ? AND organization_id = ?",
            (user_id, org_id),
        ).fetchone()
        if not m:
            role = "student" if idx % 3 == 0 else ("manager" if idx % 5 == 0 else "staff")
            conn.execute(
                "INSERT INTO memberships (user_id, organization_id, role, created_at) VALUES (?, ?, ?, ?)",
                (user_id, org_id, role, iso()),
            )
    return user_ids


def clear_previous_sample(conn, org_id):
    sample_tag = "%[SAMPLE]%"
    conn.execute("DELETE FROM tasks WHERE organization_id = ? AND title LIKE ?", (org_id, sample_tag))
    conn.execute("DELETE FROM projects WHERE organization_id = ? AND name LIKE ?", (org_id, sample_tag))
    conn.execute("DELETE FROM intake_requests WHERE organization_id = ? AND title LIKE ?", (org_id, sample_tag))
    conn.execute("DELETE FROM equipment_assets WHERE organization_id = ? AND name LIKE ?", (org_id, sample_tag))
    conn.execute("DELETE FROM partnerships WHERE organization_id = ? AND partner_name LIKE ?", (org_id, sample_tag))
    conn.execute("DELETE FROM calendar_events WHERE organization_id = ? AND title LIKE ?", (org_id, sample_tag))


def parse_args():
    parser = argparse.ArgumentParser(description="Load deterministic sample data.")
    parser.add_argument(
        "--keep-data",
        action="store_true",
        help="Keep generated sample rows after the script exits.",
    )
    parser.add_argument(
        "--cleanup-only",
        action="store_true",
        help="Only remove QA/SIM/SAMPLE marker data; do not generate new sample rows.",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    random.seed(RANDOM_SEED)
    ensure_bootstrap()
    conn = db_connect()
    org = conn.execute("SELECT id FROM organizations WHERE slug = ?", (DEFAULT_ORG_SLUG,)).fetchone()
    org_id = org[0]
    cleanup_ran = False
    try:
        if args.cleanup_only:
            counts = cleanup_test_data(conn, organization_id=org_id)
            print("TEST_DATA_CLEANUP", summarize_counts(counts))
            cleanup_ran = True
            return

        clear_previous_sample(conn, org_id)
        user_ids = upsert_sample_users(conn, org_id)
        owner_id = conn.execute("SELECT id FROM users WHERE email = ?", (DEFAULT_ADMIN_EMAIL,)).fetchone()[0]

        project_ids = []
        for i in range(28):
            lane = random.choice(LANES)
            status = random.choice(PROJECT_STATUSES)
            priority = random.choice(PRIORITIES)
            school = random.choice(SCHOOLS)
            name = f"[SAMPLE] {school} Initiative {i+1}"
            conn.execute(
                """
                INSERT INTO projects
                (organization_id, name, description, lane, status, priority, owner_user_id, start_date, due_date, tags, meta_json, created_by, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    name,
                    f"Sample project for {school} with lane {lane}.",
                    lane,
                    status,
                    priority,
                    random.choice(user_ids),
                    rand_date(60, 15),
                    rand_date(0, 120),
                    f"sample,school:{school}",
                    "{}",
                    owner_id,
                    iso(),
                    iso(),
                ),
            )
            project_ids.append(conn.execute("SELECT last_insert_rowid()").fetchone()[0])

        for i in range(260):
            status = random.choices(TASK_STATUSES, weights=[4, 3, 1, 2], k=1)[0]
            priority = random.choices(PRIORITIES, weights=[2, 4, 3, 1], k=1)[0]
            title = f"[SAMPLE] Task {i+1}: {random.choice(['Prep workshop', 'Faculty sync', 'Prototype support', 'Cert review', 'Documentation'])}"
            conn.execute(
                """
                INSERT INTO tasks
                (organization_id, project_id, title, description, status, priority, assignee_user_id, reporter_user_id, due_date, planned_week, energy, estimate_hours, meta_json, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    random.choice(project_ids),
                    title,
                    "Generated for usability test load.",
                    status,
                    priority,
                    random.choice(user_ids),
                    owner_id,
                    rand_date(15, 30),
                    dt.date.today().isocalendar()[1],
                    random.choice(ENERGIES),
                    round(random.uniform(0.5, 6.0), 2),
                    "{}",
                    iso(),
                    iso(),
                ),
            )

        for i in range(36):
            urgency = random.randint(1, 5)
            impact = random.randint(1, 5)
            effort = random.randint(1, 5)
            conn.execute(
                """
                INSERT INTO intake_requests
                (organization_id, title, requestor_name, requestor_email, lane, urgency, impact, effort, score, status, owner_user_id, details, meta_json, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    f"[SAMPLE] Intake request {i+1}",
                    random.choice(NAMES),
                    f"requestor{i+1}@example.edu",
                    random.choice(LANES),
                    urgency,
                    impact,
                    effort,
                    intake_score(urgency, impact, effort),
                    random.choice(["Triage", "In Review", "Planned", "Done"]),
                    random.choice(user_ids),
                    "Sample intake workload for queue testing.",
                    "{}",
                    iso(),
                    iso(),
                ),
            )

        spaces = ["MakerLab", "Automation Lab", "Digital Scholarship Lab"]
        asset_types = ["3D Printer", "Laser Cutter", "CNC", "Scanner", "Electronics Bench"]
        for i in range(24):
            conn.execute(
                """
                INSERT INTO equipment_assets
                (organization_id, name, space, asset_type, last_maintenance, next_maintenance, cert_required, cert_name, status, owner_user_id, notes, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    f"[SAMPLE] Asset {i+1}",
                    random.choice(spaces),
                    random.choice(asset_types),
                    rand_date(90, 0),
                    rand_date(0, 60),
                    random.choice([0, 1]),
                    random.choice(["", "CNC Safety", "Laser Safety", "Printer Safety"]),
                    random.choice(["Operational", "Needs Service", "Down"]),
                    random.choice(user_ids),
                    "",
                    iso(),
                    iso(),
                ),
            )

        for i in range(26):
            conn.execute(
                """
                INSERT INTO partnerships
                (organization_id, partner_name, school, stage, last_contact, next_followup, owner_user_id, health, notes, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    f"[SAMPLE] Partner {i+1}",
                    random.choice(SCHOOLS),
                    random.choice(PARTNER_STAGES),
                    rand_date(50, 0),
                    rand_date(0, 50),
                    random.choice(user_ids),
                    random.choice(HEALTH),
                    "",
                    iso(),
                    iso(),
                ),
            )

        categories = [
            "Teaching & Mentoring",
            "Coordination Meetings",
            "Project Delivery",
            "Operations & Admin",
            "Partnerships & Outreach",
            "Personal/Recovery",
            "Other",
        ]
        for _ in range(420):
            start = dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=random.randint(0, 365), hours=random.randint(0, 12))
            duration = dt.timedelta(minutes=random.choice([30, 45, 60, 90, 120]))
            end = start + duration
            title = random.choice(
                [
                    "[SAMPLE] Makerspace staff meeting",
                    "[SAMPLE] Course support sync",
                    "[SAMPLE] Workshop facilitation",
                    "[SAMPLE] Project build block",
                    "[SAMPLE] Partner follow-up",
                ]
            )
            conn.execute(
                """
                INSERT INTO calendar_events
                (organization_id, user_id, source, title, start_at, end_at, attendees_count, location, description, category, energy_score, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    random.choice(user_ids),
                    "sample",
                    title,
                    start.replace(microsecond=0).isoformat(),
                    end.replace(microsecond=0).isoformat(),
                    random.randint(1, 12),
                    random.choice(spaces),
                    "Sample event for trend testing.",
                    random.choice(categories),
                    random.randint(1, 5),
                    iso(),
                ),
            )

        conn.commit()
        summary = {
            "sample_users": len(user_ids),
            "projects": conn.execute("SELECT COUNT(*) FROM projects WHERE organization_id = ?", (org_id,)).fetchone()[0],
            "tasks": conn.execute("SELECT COUNT(*) FROM tasks WHERE organization_id = ?", (org_id,)).fetchone()[0],
            "intake": conn.execute("SELECT COUNT(*) FROM intake_requests WHERE organization_id = ?", (org_id,)).fetchone()[0],
            "assets": conn.execute("SELECT COUNT(*) FROM equipment_assets WHERE organization_id = ?", (org_id,)).fetchone()[0],
            "partnerships": conn.execute("SELECT COUNT(*) FROM partnerships WHERE organization_id = ?", (org_id,)).fetchone()[0],
            "calendar_events": conn.execute("SELECT COUNT(*) FROM calendar_events WHERE organization_id = ?", (org_id,)).fetchone()[0],
        }
        print("SAMPLE_DATA_LOADED", summary)
    finally:
        if not args.keep_data and not cleanup_ran:
            counts = cleanup_test_data(conn, organization_id=org_id)
            print("TEST_DATA_CLEANUP", summarize_counts(counts))
        conn.close()


if __name__ == "__main__":
    main()
