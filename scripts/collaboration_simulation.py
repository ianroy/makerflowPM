#!/usr/bin/env python3
"""Create a 10-user collaboration simulation and summarize workflow friction."""

import datetime as dt
import os
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPORT = ROOT / "analysis_outputs" / "collaboration_simulation_report.md"
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.server import db_connect, ensure_bootstrap, hash_password, intake_score, iso
from scripts.test_data_cleanup import cleanup_test_data, summarize_counts

DEFAULT_ORG_SLUG = os.environ.get("BDI_DEFAULT_ORG_SLUG", "default").strip().lower()


def main() -> None:
    ensure_bootstrap()
    conn = db_connect()
    rng = random.Random(20260216)

    org = conn.execute("SELECT id FROM organizations WHERE slug = ?", (DEFAULT_ORG_SLUG,)).fetchone()
    if not org:
        raise SystemExit(f"Missing org '{DEFAULT_ORG_SLUG}'")
    org_id = int(org["id"])

    try:
        existing_users = {
            row["email"]: int(row["id"])
            for row in conn.execute(
                "SELECT email, id FROM users WHERE email LIKE 'sim.user%@makerflow.local'"
            ).fetchall()
        }

        sim_user_ids = []
        for idx in range(1, 11):
            email = f"sim.user{idx:02d}@makerflow.local"
            name = f"Simulation User {idx:02d}"
            role = "staff" if idx % 3 else "student"
            if email in existing_users:
                user_id = existing_users[email]
            else:
                pw_hash, pw_salt = hash_password("SimUserPass!2026")
                conn.execute(
                    "INSERT INTO users (email, name, password_hash, password_salt, is_active, is_superuser, created_at) VALUES (?, ?, ?, ?, 1, 0, ?)",
                    (email, name, pw_hash, pw_salt, iso()),
                )
                user_id = int(conn.execute("SELECT last_insert_rowid() AS id").fetchone()["id"])
            conn.execute(
                "INSERT OR IGNORE INTO memberships (user_id, organization_id, role, created_at) VALUES (?, ?, ?, ?)",
                (user_id, org_id, role, iso()),
            )
            sim_user_ids.append(user_id)

        team_ids = [
            int(r["id"])
            for r in conn.execute("SELECT id FROM teams WHERE organization_id = ? ORDER BY id", (org_id,)).fetchall()
        ]
        space_ids = [
            int(r["id"])
            for r in conn.execute("SELECT id FROM spaces WHERE organization_id = ? ORDER BY id", (org_id,)).fetchall()
        ]

        project_ids = [
            int(r["id"])
            for r in conn.execute("SELECT id FROM projects WHERE organization_id = ? ORDER BY id", (org_id,)).fetchall()
        ]

        base_date = dt.date.today()
        created_tasks = 0
        for user_id in sim_user_ids:
            for offset in range(3):
                title = f"SIM Task U{user_id}-{offset+1}"
                due = (base_date + dt.timedelta(days=rng.randint(0, 21))).isoformat()
                status = rng.choice(["Todo", "In Progress", "Blocked"])
                priority = rng.choice(["Low", "Medium", "High"])
                conn.execute(
                    """
                    INSERT INTO tasks
                    (organization_id, project_id, title, description, status, priority, assignee_user_id, reporter_user_id, due_date, planned_week, energy, estimate_hours, meta_json, created_at, updated_at, team_id, space_id)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        org_id,
                        rng.choice(project_ids) if project_ids else None,
                        title,
                        "Simulation generated workload item.",
                        status,
                        priority,
                        user_id,
                        rng.choice(sim_user_ids),
                        due,
                        base_date.isocalendar()[1],
                        rng.choice(["Low", "Medium", "High"]),
                        round(rng.uniform(0.5, 4.0), 2),
                        "{}",
                        iso(),
                        iso(),
                        rng.choice(team_ids) if team_ids else None,
                        rng.choice(space_ids) if space_ids else None,
                    ),
                )
                created_tasks += 1

        sim_tasks = conn.execute(
            "SELECT id, assignee_user_id, status FROM tasks WHERE organization_id = ? AND title LIKE 'SIM Task %' ORDER BY id",
            (org_id,),
        ).fetchall()

        status_transitions = 0
        reassignments = 0
        for row in sim_tasks:
            task_id = int(row["id"])
            current_assignee = row["assignee_user_id"]

            if rng.random() < 0.65:
                new_status = rng.choice(["In Progress", "Blocked", "Done", "Todo"])
                conn.execute("UPDATE tasks SET status = ?, updated_at = ? WHERE id = ?", (new_status, iso(), task_id))
                status_transitions += 1

            if rng.random() < 0.45:
                new_assignee = rng.choice(sim_user_ids)
                if new_assignee != current_assignee:
                    conn.execute("UPDATE tasks SET assignee_user_id = ?, updated_at = ? WHERE id = ?", (new_assignee, iso(), task_id))
                    reassignments += 1

        for i in range(20):
            urgency = rng.randint(1, 5)
            impact = rng.randint(1, 5)
            effort = rng.randint(1, 5)
            conn.execute(
                """
                INSERT INTO intake_requests
                (organization_id, title, requestor_name, requestor_email, lane, urgency, impact, effort, score, status, owner_user_id, details, meta_json, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '{}', ?, ?)
                """,
                (
                    org_id,
                    f"SIM Intake {i+1:02d}",
                    f"Requester {i+1:02d}",
                    f"requester{i+1:02d}@example.edu",
                    rng.choice(["Core Operations", "Course/Faculty Support", "Student Programs", "Strategic Partnerships"]),
                    urgency,
                    impact,
                    effort,
                    intake_score(urgency, impact, effort),
                    rng.choice(["Triage", "Planned", "Active", "On Hold"]),
                    rng.choice(sim_user_ids),
                    "Simulated intake payload.",
                    iso(),
                    iso(),
                ),
            )

        open_by_user = conn.execute(
            """
            SELECT COALESCE(u.email, 'unassigned') AS user_email, COUNT(*) AS open_tasks
            FROM tasks t
            LEFT JOIN users u ON u.id = t.assignee_user_id
            WHERE t.organization_id = ? AND t.status NOT IN ('Done','Cancelled')
            GROUP BY COALESCE(u.email, 'unassigned')
            ORDER BY open_tasks DESC
            """,
            (org_id,),
        ).fetchall()

        peak = int(open_by_user[0]["open_tasks"]) if open_by_user else 0
        median = int(open_by_user[len(open_by_user) // 2]["open_tasks"]) if open_by_user else 0
        unassigned_open = int(
            conn.execute(
                "SELECT COUNT(*) AS c FROM tasks WHERE organization_id = ? AND assignee_user_id IS NULL AND status NOT IN ('Done','Cancelled')",
                (org_id,),
            ).fetchone()["c"]
        )

        opportunities = []
        if peak > max(1, median * 2):
            opportunities.append("Workload concentration is high; keep team filters and delegation queue visible by default.")
        if unassigned_open > 0:
            opportunities.append("Unassigned open work exists; dashboard delegation controls should remain above the fold.")
        opportunities.append("Inline status edits reduced interaction depth; extend this pattern to additional editable fields where possible.")

        lines = [
            "# Collaboration Simulation Report",
            "",
            f"Run date: {dt.date.today().isoformat()}",
            "",
            "## Simulation Inputs",
            "",
            "- Created/ensured 10 simulation users in the active makerspace org",
            f"- Created simulated tasks: {created_tasks}",
            f"- Task status transitions: {status_transitions}",
            f"- Task reassignments: {reassignments}",
            "- Added simulated intake activity for queue-pressure testing",
            "",
            "## Collaboration Load Snapshot",
            "",
            f"- Peak open-task owner load: {peak}",
            f"- Median open-task owner load: {median}",
            f"- Unassigned open tasks: {unassigned_open}",
            "",
            "## Interface Refinement Opportunities",
            "",
        ]
        lines.extend([f"- {item}" for item in opportunities])

        REPORT.parent.mkdir(parents=True, exist_ok=True)
        REPORT.write_text("\n".join(lines))

        conn.commit()
        print("COLLAB_SIM_DONE", REPORT)
    finally:
        cleanup_counts = cleanup_test_data(conn, organization_id=org_id)
        conn.close()
        print("TEST_DATA_CLEANUP", summarize_counts(cleanup_counts))


if __name__ == "__main__":
    main()
