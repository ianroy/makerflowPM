#!/usr/bin/env python3
"""Comprehensive feature + security + multi-user simulation test suite.

Design goals:
- Exercise major interfaces and write actions across role levels.
- Detect privilege escalation and authz gaps with realistic request flows.
- Simulate 10 collaborating users creating/updating/reassigning shared tasks.
- Produce a readable report for product hardening and regression tracking.
"""

from __future__ import annotations

import io
import json
import os
import re
import sys
import uuid
from dataclasses import dataclass
from html.parser import HTMLParser
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from urllib.parse import urlencode

ROOT = Path(__file__).resolve().parent.parent
REPORT_PATH = ROOT / "analysis_outputs" / "comprehensive_feature_security_report.md"
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.server import (
    FEATURE_INTAKE_ENABLED,
    RATE_LIMIT,
    ROLE_RANK,
    db_connect,
    ensure_bootstrap,
    hash_password,
    iso,
)
from scripts.test_data_cleanup import cleanup_test_data, summarize_counts

DEFAULT_ORG_SLUG = os.environ.get("MAKERSPACE_DEFAULT_ORG_SLUG", "default").strip().lower()


def encode_multipart(fields: Dict[str, str], files: Dict[str, Tuple[str, bytes, str]]) -> Tuple[bytes, str]:
    boundary = f"----makerflow-{uuid.uuid4().hex}"
    out = io.BytesIO()

    for key, value in fields.items():
        out.write(f"--{boundary}\r\n".encode("utf-8"))
        out.write(f'Content-Disposition: form-data; name="{key}"\r\n\r\n'.encode("utf-8"))
        out.write(str(value).encode("utf-8"))
        out.write(b"\r\n")

    for key, (filename, content, content_type) in files.items():
        out.write(f"--{boundary}\r\n".encode("utf-8"))
        out.write(f'Content-Disposition: form-data; name="{key}"; filename="{filename}"\r\n'.encode("utf-8"))
        out.write(f"Content-Type: {content_type}\r\n\r\n".encode("utf-8"))
        out.write(content)
        out.write(b"\r\n")

    out.write(f"--{boundary}--\r\n".encode("utf-8"))
    return out.getvalue(), f"multipart/form-data; boundary={boundary}"


class FormParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.forms: List[Dict[str, str]] = []
        self.buttons = 0

    def handle_starttag(self, tag: str, attrs):
        attr_map = dict(attrs)
        if tag == "form":
            self.forms.append(
                {
                    "action": attr_map.get("action", ""),
                    "method": (attr_map.get("method", "GET") or "GET").upper(),
                    "enctype": attr_map.get("enctype", ""),
                }
            )
        if tag == "button":
            self.buttons += 1


class WSGIClient:
    def __init__(self):
        self.cookies: Dict[str, str] = {}

    def _cookie_header(self) -> str:
        if not self.cookies:
            return ""
        return "; ".join([f"{k}={v}" for k, v in self.cookies.items()])

    def request(
        self,
        path: str,
        method: str = "GET",
        data: Optional[Dict[str, str]] = None,
        files: Optional[Dict[str, Tuple[str, bytes, str]]] = None,
        extra_headers: Optional[Dict[str, str]] = None,
    ) -> Tuple[str, Dict[str, str], str]:
        method = method.upper()
        data = data or {}
        files = files or {}
        extra_headers = extra_headers or {}

        path_info, _, query = path.partition("?")

        if method == "POST" and files:
            body, content_type = encode_multipart(data, files)
        elif method == "POST":
            body = urlencode(data).encode("utf-8")
            content_type = "application/x-www-form-urlencoded"
        else:
            body = b""
            content_type = "application/x-www-form-urlencoded"

        environ = {
            "REQUEST_METHOD": method,
            "PATH_INFO": path_info,
            "QUERY_STRING": query,
            "wsgi.input": io.BytesIO(body),
            "CONTENT_LENGTH": str(len(body)),
            "CONTENT_TYPE": content_type,
            "REMOTE_ADDR": "127.0.0.1",
            "HTTP_USER_AGENT": "comprehensive-feature-security-test",
            "HTTP_COOKIE": self._cookie_header(),
            "wsgi.url_scheme": "http",
            "SERVER_NAME": "localhost",
            "SERVER_PORT": "80",
            "SCRIPT_NAME": "",
            "wsgi.version": (1, 0),
            "wsgi.errors": io.StringIO(),
            "wsgi.multithread": False,
            "wsgi.multiprocess": False,
            "wsgi.run_once": False,
        }
        for key, value in extra_headers.items():
            environ[f"HTTP_{key.upper().replace('-', '_')}"] = value

        captured = {"status": "", "headers": []}

        def start_response(status, headers):
            captured["status"] = status
            captured["headers"] = headers

        from app.server import app

        chunks = app(environ, start_response)
        payload = b"".join(chunks).decode("utf-8", errors="ignore")

        header_map: Dict[str, str] = {}
        for key, value in captured["headers"]:
            header_map[key] = value
            if key.lower() == "set-cookie":
                token = value.split(";", 1)[0]
                if "=" in token:
                    name, cookie_value = token.split("=", 1)
                    self.cookies[name] = cookie_value

        return captured["status"], header_map, payload


def parse_csrf(html: str) -> str:
    meta = re.search(r'<meta name="csrf-token" content="([^"]+)"', html)
    if meta:
        return meta.group(1)
    hidden = re.search(r'name="csrf_token"\s+value="([^"]+)"', html)
    if hidden:
        return hidden.group(1)
    return ""


def role_allows(role: str, minimum: str) -> bool:
    return ROLE_RANK.get(role, 0) >= ROLE_RANK.get(minimum, 999)


@dataclass
class Finding:
    severity: str
    area: str
    detail: str


def ensure_user(conn, org_id: int, email: str, name: str, password: str, role: str) -> int:
    row = conn.execute("SELECT id FROM users WHERE email = ?", (email,)).fetchone()
    pw_hash, pw_salt = hash_password(password)
    if row:
        user_id = int(row["id"])
        conn.execute(
            "UPDATE users SET name = ?, password_hash = ?, password_salt = ?, is_active = 1 WHERE id = ?",
            (name, pw_hash, pw_salt, user_id),
        )
    else:
        conn.execute(
            """
            INSERT INTO users (email, name, password_hash, password_salt, is_active, is_superuser, created_at)
            VALUES (?, ?, ?, ?, 1, 0, ?)
            """,
            (email, name, pw_hash, pw_salt, iso()),
        )
        user_id = int(conn.execute("SELECT last_insert_rowid() AS id").fetchone()["id"])

    membership = conn.execute(
        "SELECT id FROM memberships WHERE user_id = ? AND organization_id = ?",
        (user_id, org_id),
    ).fetchone()
    if membership:
        conn.execute(
            "UPDATE memberships SET role = ? WHERE user_id = ? AND organization_id = ?",
            (role, user_id, org_id),
        )
    else:
        conn.execute(
            "INSERT INTO memberships (user_id, organization_id, role, created_at) VALUES (?, ?, ?, ?)",
            (user_id, org_id, role, iso()),
        )
    return user_id


def login(email: str, password: str) -> WSGIClient:
    client = WSGIClient()
    status, _, _ = client.request("/login")
    assert status.startswith("200"), f"login page unavailable: {status}"
    status, headers, _ = client.request("/login", method="POST", data={"email": email, "password": password})
    assert status.startswith("302"), f"login failed for {email}: {status}"
    assert headers.get("Location", "").startswith("/dashboard"), f"login redirect mismatch for {email}"
    return client


def post_with_csrf(
    client: WSGIClient,
    path: str,
    data: Optional[Dict[str, str]] = None,
    files: Optional[Dict[str, Tuple[str, bytes, str]]] = None,
    include_csrf: bool = True,
) -> Tuple[str, Dict[str, str], str]:
    data = dict(data or {})
    headers: Dict[str, str] = {}
    if include_csrf:
        status, _, page = client.request("/dashboard")
        assert status.startswith("200"), "could not load dashboard for csrf"
        csrf = parse_csrf(page)
        data["csrf_token"] = csrf
        headers["X-CSRF-Token"] = csrf
    return client.request(path, method="POST", data=data, files=files or {}, extra_headers=headers)


def main() -> int:
    ensure_bootstrap()
    conn = db_connect()
    findings: List[Finding] = []

    org = conn.execute("SELECT id FROM organizations WHERE slug = ?", (DEFAULT_ORG_SLUG,)).fetchone()
    if not org:
        raise SystemExit(f"Missing required org slug '{DEFAULT_ORG_SLUG}'")
    org_id = int(org["id"])

    role_users = {
        "owner": ("qa.owner@makerflow.local", "QA Owner", "QaOwnerPass!2026"),
        "workspace_admin": ("qa.workspace.admin@makerflow.local", "QA Workspace Admin", "QaWorkspaceAdmin!2026"),
        "manager": ("qa.manager@makerflow.local", "QA Manager", "QaManagerPass!2026"),
        "staff": ("qa.staff@makerflow.local", "QA Staff", "QaStaffPass!2026"),
        "student": ("qa.student@makerflow.local", "QA Student", "QaStudentPass!2026"),
        "viewer": ("qa.viewer@makerflow.local", "QA Viewer", "QaViewerPass!2026"),
    }

    role_user_ids: Dict[str, int] = {}
    for role, (email, name, password) in role_users.items():
        role_user_ids[role] = ensure_user(conn, org_id, email, name, password, role)

    collab_ids: List[int] = []
    for i in range(1, 11):
        role = "student" if i % 3 == 0 else "staff"
        uid = ensure_user(
            conn,
            org_id,
            f"qa.collab{i:02d}@makerflow.local",
            f"QA Collaborator {i:02d}",
            "QaCollabPass!2026",
            role,
        )
        collab_ids.append(uid)

    space = conn.execute("SELECT id FROM spaces WHERE organization_id = ? ORDER BY id LIMIT 1", (org_id,)).fetchone()
    if not space:
        conn.execute(
            "INSERT INTO spaces (organization_id, name, location, description, created_by, created_at) VALUES (?, ?, ?, ?, ?, ?)",
            (org_id, "QA Space", "QA Building", "QA generated space", role_user_ids["owner"], iso()),
        )
        space_id = int(conn.execute("SELECT last_insert_rowid() AS id").fetchone()["id"])
    else:
        space_id = int(space["id"])

    team = conn.execute("SELECT id FROM teams WHERE organization_id = ? ORDER BY id LIMIT 1", (org_id,)).fetchone()
    if not team:
        conn.execute(
            "INSERT INTO teams (organization_id, name, focus_area, lead_user_id, created_at) VALUES (?, ?, ?, ?, ?)",
            (org_id, "QA Team", "Regression test", role_user_ids["manager"], iso()),
        )
        team_id = int(conn.execute("SELECT last_insert_rowid() AS id").fetchone()["id"])
    else:
        team_id = int(team["id"])

    conn.execute("DELETE FROM tasks WHERE organization_id = ? AND title LIKE '[SIM QA] %'", (org_id,))
    conn.execute("DELETE FROM tasks WHERE organization_id = ? AND title LIKE '[QA CASE] %'", (org_id,))
    conn.execute("DELETE FROM projects WHERE organization_id = ? AND name LIKE '[QA CASE] %'", (org_id,))
    conn.commit()

    conn.execute(
        """
        INSERT INTO projects
        (organization_id, name, description, lane, status, priority, owner_user_id, start_date, due_date, tags, meta_json, created_by, created_at, updated_at, team_id, space_id, progress_pct)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            org_id,
            "[QA CASE] Baseline Project",
            "Created by comprehensive test suite.",
            "Core Operations",
            "Active",
            "High",
            role_user_ids["manager"],
            None,
            None,
            "qa",
            "{}",
            role_user_ids["owner"],
            iso(),
            iso(),
            team_id,
            space_id,
            15,
        ),
    )
    project_id = int(conn.execute("SELECT last_insert_rowid() AS id").fetchone()["id"])

    conn.execute(
        """
        INSERT INTO tasks
        (organization_id, project_id, title, description, status, priority, assignee_user_id, reporter_user_id, due_date, planned_week, energy, estimate_hours, meta_json, created_at, updated_at, team_id, space_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            org_id,
            project_id,
            "[QA CASE] Baseline Task",
            "Baseline mutable task for role/permission checks.",
            "Todo",
            "Medium",
            role_user_ids["staff"],
            role_user_ids["manager"],
            None,
            1,
            "Medium",
            1.0,
            "{}",
            iso(),
            iso(),
            team_id,
            space_id,
        ),
    )
    baseline_task_id = int(conn.execute("SELECT last_insert_rowid() AS id").fetchone()["id"])
    sim_title = "[SIM QA] Collaborative Task"
    # Seed an allowed title option so staff/student users (restricted title edit) can create simulation tasks.
    conn.execute(
        """
        INSERT INTO tasks
        (organization_id, project_id, title, description, status, priority, assignee_user_id, reporter_user_id, due_date, planned_week, energy, estimate_hours, meta_json, created_at, updated_at, team_id, space_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            org_id,
            project_id,
            sim_title,
            "Seed row for role-constrained title options.",
            "Todo",
            "Low",
            role_user_ids["staff"],
            role_user_ids["owner"],
            None,
            1,
            "Low",
            0.5,
            "{}",
            iso(),
            iso(),
            team_id,
            space_id,
        ),
    )
    template_row = conn.execute(
        "SELECT id FROM onboarding_templates WHERE organization_id = ? ORDER BY id LIMIT 1",
        (org_id,),
    ).fetchone()
    template_id = int(template_row["id"]) if template_row else 1
    conn.commit()

    clients: Dict[str, WSGIClient] = {}
    RATE_LIMIT.clear()
    for role, (email, _name, password) in role_users.items():
        clients[role] = login(email, password)

    # Interface coverage by role.
    pages = [
        "/dashboard",
        "/projects",
        "/tasks",
        "/agenda",
        "/calendar",
        "/reports",
        "/views",
        "/onboarding",
        "/spaces",
        "/intake",
        "/assets",
        "/consumables",
        "/partnerships",
        "/settings",
        "/data-hub",
        "/admin/users",
    ]
    page_min_role = {
        "/admin/users": "workspace_admin",
        "/data-hub": "manager",
    }
    route_checks = 0
    for role, client in clients.items():
        for page in pages:
            route_checks += 1
            status, _, body = client.request(page)
            expected = role_allows(role, page_min_role.get(page, "viewer"))
            if expected and not status.startswith("200"):
                findings.append(Finding("high", "route-access", f"{role} expected 200 on {page}, got {status}"))
            if (not expected) and status.startswith("200"):
                findings.append(Finding("high", "route-access", f"{role} unexpectedly accessed {page}"))
            if expected and status.startswith("200") and "<h1>" not in body:
                findings.append(Finding("medium", "route-render", f"{page} rendered without h1 for role {role}"))

    # Owner form/button wiring sweep.
    form_checks = 0
    owner_client = clients["owner"]
    for page in pages:
        status, _, html = owner_client.request(page)
        if not status.startswith("200"):
            continue
        parser = FormParser()
        parser.feed(html)
        if parser.buttons == 0:
            findings.append(Finding("medium", "ui-coverage", f"{page} contains no button elements"))
        csrf = parse_csrf(html)
        for form in parser.forms:
            action = form.get("action", "").strip()
            method = form.get("method", "GET")
            enctype = (form.get("enctype") or "").lower()
            if not action.startswith("/"):
                continue
            # Skip side-effect-heavy/sensitive actions in wiring sweep; they are tested explicitly below.
            if action in {
                "/logout",
                "/admin/users/toggle",
                "/admin/users/reset",
                "/admin/users/role",
                "/admin/workspaces/new",
                "/admin/orgs/new",
                "/settings/password",
            }:
                continue
            if method == "POST":
                form_checks += 1
                data = {"csrf_token": csrf}
                files = {}
                if "multipart/form-data" in enctype:
                    files = {"file": ("qa.csv", b"title,status,priority\n[QA IMPORT] row,Todo,Low\n", "text/csv")}
                status, _headers, _payload = owner_client.request(
                    action,
                    method="POST",
                    data=data,
                    files=files,
                    extra_headers={"X-CSRF-Token": csrf},
                )
                if status.startswith("404") or status.startswith("500"):
                    findings.append(Finding("high", "form-action", f"{page} form action {action} returned {status}"))

    # Role-based write permission matrix.
    action_cases = [
        {
            "name": "projects_new",
            "path": "/projects/new",
            "min_role": "staff",
            "data": lambda: {
                "name": "[QA CASE] Project via form",
                "lane": "Core Operations",
                "status": "Planned",
                "priority": "Medium",
                "team_id": str(team_id),
                "space_id": str(space_id),
            },
        },
        {
            "name": "tasks_new",
            "path": "/tasks/new",
            "min_role": "student",
            "data": lambda: {
                "title": "[QA CASE] Task via form",
                "project_id": str(project_id),
                "status": "Todo",
                "priority": "High",
                "assignee_user_id": str(role_user_ids["staff"]),
                "team_id": str(team_id),
                "space_id": str(space_id),
            },
        },
        {
            "name": "tasks_update",
            "path": "/tasks/update",
            "min_role": "student",
            "data": lambda: {"task_id": str(baseline_task_id), "status": "Done"},
        },
        {
            "name": "tasks_delegate",
            "path": "/tasks/delegate",
            "min_role": "staff",
            "data": lambda: {"task_id": str(baseline_task_id), "assignee_user_id": str(role_user_ids["student"])},
        },
        {
            "name": "agenda_new",
            "path": "/agenda/new",
            "min_role": "student",
            "data": lambda: {"title": "[QA CASE] Agenda", "meeting_date": "2026-02-16", "notes": "QA"},
        },
        {
            "name": "agenda_item_new",
            "path": "/agenda/item/new",
            "min_role": "student",
            "data": lambda: {"agenda_id": "1", "section": "QA", "title": "QA Item", "minutes_estimate": "5"},
        },
        {
            "name": "agenda_note_new",
            "path": "/agenda/note/new",
            "min_role": "student",
            "data": lambda: {"title": "QA Note", "body": "QA note body"},
        },
        {
            "name": "calendar_gcal_pull",
            "path": "/calendar/gcal/pull",
            "min_role": "student",
            "data": lambda: {"calendar_id": "primary", "lookback_days": "7", "lookahead_days": "7", "push_window_days": "7"},
        },
        {
            "name": "calendar_import",
            "path": "/calendar/import",
            "min_role": "student",
            "data": lambda: {"view": "week", "date": "2026-02-16"},
            "files": lambda: {
                "file": (
                    "calendar.csv",
                    (
                        "Subject,Start Date,Start Time,End Date,End Time,Description,Location\n"
                        "QA Meeting,02/16/2026,09:00 AM,02/16/2026,10:00 AM,QA import,MakerLab\n"
                    ).encode("utf-8"),
                    "text/csv",
                )
            },
        },
        {
            "name": "reports_new",
            "path": "/reports/new",
            "min_role": "student",
            "data": lambda: {"name": f"[QA CASE] Report {uuid.uuid4().hex[:6]}", "template_key": "impact_report"},
        },
        {
            "name": "onboarding_template_new",
            "path": "/onboarding/template/new",
            "min_role": "manager",
            "data": lambda: {
                "name": "QA Template",
                "role_target": "Student Worker",
                "task_title": "QA Task",
                "details": "QA",
                "sequence": "10",
                "due_offset_days": "3",
            },
        },
        {
            "name": "onboarding_assign",
            "path": "/onboarding/assign",
            "min_role": "staff",
            "data": lambda: {"template_id": str(template_id), "assignee_user_id": str(role_user_ids["student"])},
        },
        {
            "name": "assets_new",
            "path": "/assets/new",
            "min_role": "staff",
            "data": lambda: {"name": "[QA CASE] Asset", "space": "MakerLab", "status": "Operational", "owner_user_id": str(role_user_ids["staff"])},
        },
        {
            "name": "consumables_new",
            "path": "/consumables/new",
            "min_role": "staff",
            "data": lambda: {"name": "[QA CASE] Consumable", "space_id": str(space_id), "quantity_on_hand": "5", "reorder_point": "2", "status": "In Stock", "owner_user_id": str(role_user_ids["staff"])},
        },
        {
            "name": "partnerships_new",
            "path": "/partnerships/new",
            "min_role": "staff",
            "data": lambda: {"partner_name": "[QA CASE] Partner", "stage": "Discovery", "health": "Medium", "owner_user_id": str(role_user_ids["manager"])},
        },
        {
            "name": "settings_spaces_new",
            "path": "/settings/spaces/new",
            "min_role": "manager",
            "data": lambda: {"name": f"QA Space {uuid.uuid4().hex[:6]}", "location": "QA", "description": "QA"},
        },
        {
            "name": "admin_users_new_staff",
            "path": "/admin/users/new",
            "min_role": "workspace_admin",
            "data": lambda: {"name": "QA Temp Staff", "email": f"qa.temp.staff.{uuid.uuid4().hex[:6]}@makerflow.local", "password": "QaTempPass!2026", "role": "staff"},
        },
        {
            "name": "import_tasks_csv",
            "path": "/import/tasks.csv",
            "min_role": "manager",
            "data": lambda: {},
            "files": lambda: {
                "file": (
                    "tasks.csv",
                    "title,status,priority\n[QA IMPORT] Task Row,Todo,Low\n".encode("utf-8"),
                    "text/csv",
                )
            },
        },
    ]
    if FEATURE_INTAKE_ENABLED:
        action_cases.insert(
            8,
            {
                "name": "intake_new",
                "path": "/intake/new",
                "min_role": "staff",
                "data": lambda: {
                    "title": "[QA CASE] Intake",
                    "urgency": "3",
                    "impact": "4",
                    "effort": "2",
                    "owner_user_id": str(role_user_ids["manager"]),
                },
            },
        )

    action_checks = 0
    for case in action_cases:
        for role, client in clients.items():
            action_checks += 1
            data = case["data"]()
            files = case["files"]() if "files" in case else {}
            status, _, _ = post_with_csrf(client, case["path"], data=data, files=files)
            allowed = not status.startswith("403")
            should_allow = role_allows(role, case["min_role"])
            if should_allow and not allowed:
                findings.append(Finding("high", "permission-matrix", f"{role} blocked on {case['name']} ({status})"))
            if (not should_allow) and allowed:
                findings.append(Finding("critical", "permission-matrix", f"{role} unexpectedly allowed on {case['name']} ({status})"))

    # Export gate check (GET route).
    for role, client in clients.items():
        status, _, _ = client.request("/export/tasks.csv")
        should_allow = role_allows(role, "manager")
        allowed = not status.startswith("403")
        if should_allow and not allowed:
            findings.append(Finding("high", "permission-matrix", f"{role} blocked on export/tasks.csv ({status})"))
        if (not should_allow) and allowed:
            findings.append(Finding("critical", "permission-matrix", f"{role} unexpectedly allowed export/tasks.csv"))

    # CSRF check.
    status, _, _ = clients["student"].request(
        "/tasks/new",
        method="POST",
        data={"title": "No CSRF", "project_id": str(project_id)},
    )
    if not status.startswith("400"):
        findings.append(Finding("high", "csrf", f"Missing-csrf write did not fail with 400 (got {status})"))

    # Security exploit checks against privileged accounts.
    owner_id = role_user_ids["owner"]
    workspace_admin_client = clients["workspace_admin"]

    before_reset = int(
        conn.execute(
            "SELECT COUNT(*) AS c FROM password_resets WHERE user_id = ? AND used_at IS NULL",
            (owner_id,),
        ).fetchone()["c"]
    )
    status, _, _ = post_with_csrf(workspace_admin_client, "/admin/users/reset", data={"target_user_id": str(owner_id)})
    after_reset = int(
        conn.execute(
            "SELECT COUNT(*) AS c FROM password_resets WHERE user_id = ? AND used_at IS NULL",
            (owner_id,),
        ).fetchone()["c"]
    )
    if status.startswith("302") and after_reset > before_reset:
        findings.append(Finding("critical", "security-escalation", "workspace_admin could issue reset token for owner"))

    owner_active_before = int(conn.execute("SELECT is_active FROM users WHERE id = ?", (owner_id,)).fetchone()["is_active"])
    status, _, _ = post_with_csrf(
        workspace_admin_client,
        "/admin/users/toggle",
        data={"target_user_id": str(owner_id), "is_active": "0"},
    )
    owner_active_after = int(conn.execute("SELECT is_active FROM users WHERE id = ?", (owner_id,)).fetchone()["is_active"])
    if status.startswith("302") and owner_active_before != owner_active_after:
        findings.append(Finding("critical", "security-escalation", "workspace_admin could disable owner account"))

    status, _, _ = post_with_csrf(
        workspace_admin_client,
        "/admin/users/role",
        data={"target_user_id": str(owner_id), "role": "staff"},
    )
    owner_role = conn.execute(
        "SELECT role FROM memberships WHERE organization_id = ? AND user_id = ?",
        (org_id, owner_id),
    ).fetchone()["role"]
    if owner_role != "owner":
        findings.append(Finding("critical", "security-escalation", "workspace_admin changed owner role"))
        conn.execute(
            "UPDATE memberships SET role = 'owner' WHERE organization_id = ? AND user_id = ?",
            (org_id, owner_id),
        )
        conn.commit()

    # Multi-user simulation (10 users sharing task creation + edits).
    sim_created = 0
    sim_updated = 0
    sim_task_ids: List[int] = []
    collab_clients: List[Tuple[int, WSGIClient]] = []
    RATE_LIMIT.clear()
    for i in range(1, 11):
        RATE_LIMIT.clear()
        email = f"qa.collab{i:02d}@makerflow.local"
        client = login(email, "QaCollabPass!2026")
        uid = int(conn.execute("SELECT id FROM users WHERE email = ?", (email,)).fetchone()["id"])
        collab_clients.append((uid, client))

    for idx, (uid, client) in enumerate(collab_clients, start=1):
        title = sim_title
        status, _, payload = post_with_csrf(
            client,
            "/api/tasks/create",
            data={
                "title": title,
                "description": "Simulation-created task",
                "project_id": str(project_id),
                "status": "Todo",
                "priority": "Medium",
                "assignee_user_id": str(uid),
                "team_id": str(team_id),
                "space_id": str(space_id),
            },
        )
        if not status.startswith("200"):
            findings.append(Finding("high", "multi-user", f"collab user {uid} failed create via api/tasks/create ({status})"))
            continue
        try:
            parsed = json.loads(payload)
        except json.JSONDecodeError:
            parsed = {}
        if parsed.get("ok"):
            sim_created += 1
            try:
                sim_task_ids.append(int(parsed.get("task_id")))
            except (TypeError, ValueError):
                pass

    created_ids = sorted({task_id for task_id in sim_task_ids if task_id})
    if len(created_ids) < 10:
        findings.append(Finding("high", "multi-user", f"expected >=10 simulated tasks, found {len(created_ids)}"))

    for idx, (_uid, client) in enumerate(collab_clients):
        if not created_ids:
            break
        target_task = created_ids[idx % len(created_ids)]
        next_uid = collab_clients[(idx + 1) % len(collab_clients)][0]
        status, _, payload = post_with_csrf(
            client,
            "/api/tasks/save",
            data={
                "task_id": str(target_task),
                "status": "In Progress",
                "assignee_user_id": str(next_uid),
                "priority": "High",
            },
        )
        if not status.startswith("200"):
            findings.append(Finding("high", "multi-user", f"task save failed for task {target_task}: {status}"))
            continue
        try:
            parsed = json.loads(payload)
        except json.JSONDecodeError:
            parsed = {}
        if parsed.get("ok"):
            sim_updated += 1

    if created_ids:
        placeholders = ", ".join(["?"] * len(created_ids))
        sim_stats = conn.execute(
            f"""
            SELECT
              COUNT(*) AS total,
              COUNT(DISTINCT assignee_user_id) AS assignees,
              SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) AS in_progress
            FROM tasks
            WHERE organization_id = ? AND id IN ({placeholders})
            """,
            tuple([org_id] + created_ids),
        ).fetchone()
    else:
        sim_stats = {"total": 0, "assignees": 0, "in_progress": 0}

    if int(sim_stats["assignees"] or 0) < 5:
        findings.append(Finding("high", "multi-user", "simulated tasks were not distributed across at least 5 assignees"))

    conn.commit()

    severity_rank = {"critical": 4, "high": 3, "medium": 2, "low": 1}
    findings_sorted = sorted(findings, key=lambda f: severity_rank.get(f.severity, 0), reverse=True)
    critical_count = sum(1 for f in findings_sorted if f.severity == "critical")
    high_count = sum(1 for f in findings_sorted if f.severity == "high")
    medium_count = sum(1 for f in findings_sorted if f.severity == "medium")

    lines = [
        "# Comprehensive Feature + Security Test Report",
        "",
        "## Scope",
        "",
        "- Interface access coverage across role levels",
        "- Form-action wiring checks across primary pages",
        "- Permission matrix checks for key write actions",
        "- Security exploit probes (admin privilege escalation + CSRF)",
        "- 10-user collaboration simulation with shared task editing",
        "",
        "## Summary",
        "",
        f"- Route checks executed: {route_checks}",
        f"- Form action checks executed: {form_checks}",
        f"- Permission/action checks executed: {action_checks}",
        f"- Multi-user tasks created: {sim_created}",
        f"- Multi-user task updates: {sim_updated}",
        f"- Multi-user task total in DB: {int(sim_stats['total'] or 0)}",
        f"- Multi-user distinct assignees: {int(sim_stats['assignees'] or 0)}",
        f"- Multi-user In Progress count: {int(sim_stats['in_progress'] or 0)}",
        f"- Findings: critical={critical_count}, high={high_count}, medium={medium_count}, total={len(findings_sorted)}",
        "",
        "## Findings",
        "",
    ]
    if findings_sorted:
        for idx, finding in enumerate(findings_sorted, start=1):
            lines.append(f"{idx}. [{finding.severity.upper()}] {finding.area}: {finding.detail}")
    else:
        lines.append("No findings.")

    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text("\n".join(lines))
    print("COMPREHENSIVE_TEST_REPORT", REPORT_PATH)
    print(json.dumps({"critical": critical_count, "high": high_count, "medium": medium_count, "total": len(findings_sorted)}))

    # Fail CI/test runs on high-severity findings.
    exit_code = 1 if (critical_count > 0 or high_count > 0) else 0
    try:
        cleanup_counts = cleanup_test_data(conn, organization_id=org_id)
        print("TEST_DATA_CLEANUP", summarize_counts(cleanup_counts))
    finally:
        conn.close()
    return exit_code

if __name__ == "__main__":
    exit_code = 1
    try:
        exit_code = main()
    finally:
        # Safety net: if the suite exits early on an exception, still purge test artifacts.
        ensure_bootstrap()
        safety_conn = db_connect()
        try:
            cleanup_counts = cleanup_test_data(safety_conn)
            summary = summarize_counts(cleanup_counts)
            if summary != "no rows removed":
                print("TEST_DATA_CLEANUP_SAFETY", summary)
        finally:
            safety_conn.close()
    raise SystemExit(exit_code)
