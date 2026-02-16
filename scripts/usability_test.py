#!/usr/bin/env python3
"""WSGI-level usability test against major authenticated routes.

Design choice:
- This script intentionally validates rendered HTML and key flows without a browser automation
  dependency so contributors can run it quickly on any machine.
"""

import io
import os
import re
import sys
from pathlib import Path
from urllib.parse import urlencode

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.server import FEATURE_INTAKE_ENABLED, app, db_connect, ensure_bootstrap, iso
from scripts.test_data_cleanup import cleanup_test_data, summarize_counts

DEFAULT_ORG_SLUG = os.environ.get("BDI_DEFAULT_ORG_SLUG", "default").strip().lower()
DEFAULT_ADMIN_EMAIL = os.environ.get("BDI_ADMIN_EMAIL", "admin@makerflow.local").strip().lower()
DEFAULT_ADMIN_PASSWORD = os.environ.get("BDI_ADMIN_PASSWORD", "ChangeMeNow!2026")


class WSGIClient:
    """Tiny cookie-aware in-process client for integration-style route checks."""
    def __init__(self):
        self.cookies = {}

    def _cookie_header(self):
        if not self.cookies:
            return ""
        return "; ".join([f"{k}={v}" for k, v in self.cookies.items()])

    def request(self, path, method="GET", data=None):
        data = data or {}
        body = urlencode(data).encode("utf-8") if method == "POST" else b""
        path_info, _, query = path.partition("?")

        environ = {
            "REQUEST_METHOD": method,
            "PATH_INFO": path_info,
            "QUERY_STRING": query,
            "wsgi.input": io.BytesIO(body),
            "CONTENT_LENGTH": str(len(body)),
            "CONTENT_TYPE": "application/x-www-form-urlencoded",
            "REMOTE_ADDR": "127.0.0.1",
            "HTTP_USER_AGENT": "usability-test",
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

        captured = {"status": None, "headers": []}

        def start_response(status, headers):
            captured["status"] = status
            captured["headers"] = headers

        chunks = app(environ, start_response)
        payload = b"".join(chunks).decode("utf-8", errors="ignore")

        for key, value in captured["headers"]:
            if key.lower() == "set-cookie":
                token = value.split(";", 1)[0]
                if "=" in token:
                    k, v = token.split("=", 1)
                    self.cookies[k] = v

        return captured["status"], dict(captured["headers"]), payload


ROUTES = [
    "/dashboard",
    "/reports",
    "/projects",
    "/tasks",
    "/agenda",
    "/calendar",
    "/views",
    "/onboarding",
    "/assets",
    "/partnerships",
    "/admin/users",
    "/settings",
]
if FEATURE_INTAKE_ENABLED:
    ROUTES.insert(8, "/intake")


def find_csrf(html):
    m = re.search(r'name="csrf_token"\s+value="([^"]+)"', html)
    return m.group(1) if m else ""


def main():
    ensure_bootstrap()
    setup_conn = db_connect()
    org = setup_conn.execute("SELECT id FROM organizations WHERE slug = ?", (DEFAULT_ORG_SLUG,)).fetchone()
    if not org:
        raise SystemExit(f"Missing required org slug '{DEFAULT_ORG_SLUG}'")
    org_id = int(org["id"])
    admin = setup_conn.execute("SELECT id FROM users WHERE email = ?", (DEFAULT_ADMIN_EMAIL,)).fetchone()
    if not admin:
        raise SystemExit(f"Missing {DEFAULT_ADMIN_EMAIL} account")
    temp_task_title = "[QA CASE] Usability Temp Task"
    setup_conn.execute(
        """
        INSERT INTO tasks
        (organization_id, project_id, title, description, status, priority, assignee_user_id, reporter_user_id, due_date, planned_week, energy, estimate_hours, meta_json, created_at, updated_at)
        VALUES (?, NULL, ?, ?, 'Todo', 'Low', NULL, ?, NULL, NULL, 'Low', 0.25, '{}', ?, ?)
        """,
        (org_id, temp_task_title, "Temporary task for usability script update-flow check.", int(admin["id"]), iso(), iso()),
    )
    temp_task_id = int(setup_conn.execute("SELECT last_insert_rowid() AS id").fetchone()["id"])
    setup_conn.commit()
    setup_conn.close()

    client = WSGIClient()
    try:
        status, _, _ = client.request("/login")
        assert status.startswith("200"), f"login page failed: {status}"

        status, headers, _ = client.request(
            "/login",
            method="POST",
            data={"email": DEFAULT_ADMIN_EMAIL, "password": DEFAULT_ADMIN_PASSWORD},
        )
        assert status.startswith("302"), f"login post failed: {status}"
        assert headers.get("Location") == "/dashboard", "login redirect mismatch"

        findings = []
        for route in ROUTES:
            status, _, body = client.request(route)
            if not status.startswith("200"):
                findings.append({"route": route, "severity": "high", "issue": f"status {status}"})
                continue

            if "<h1>" not in body:
                findings.append({"route": route, "severity": "medium", "issue": "missing primary heading"})

            row_count = body.count("<tr>")
            dense_table_routes = {"/calendar", "/assets", "/partnerships"}
            if FEATURE_INTAKE_ENABLED:
                dense_table_routes.add("/intake")
            if route in dense_table_routes and row_count < 5:
                findings.append({"route": route, "severity": "medium", "issue": "low table density under sample load"})
            if route in {"/projects", "/tasks"}:
                column_count = body.count("class='kanban-col'") + body.count('class=\"kanban-col\"')
                if column_count < 3:
                    findings.append({"route": route, "severity": "high", "issue": "kanban columns not rendering"})

            if route == "/tasks" and "id=\"task-search\"" not in body:
                findings.append({"route": route, "severity": "medium", "issue": "task search control missing"})
            if route == "/tasks" and "Quick Add Task" not in body:
                findings.append({"route": route, "severity": "medium", "issue": "quick-add composer missing"})

            if route == "/dashboard" and "My Daily Focus" not in body:
                findings.append({"route": route, "severity": "high", "issue": "key panel missing"})

        # update disposable QA task to validate action flow without mutating production tasks
        status, _, tasks_html = client.request("/tasks")
        csrf = find_csrf(tasks_html)
        if csrf:
            status, _, _ = client.request(
                "/tasks/update",
                method="POST",
                data={"task_id": str(temp_task_id), "status": "Done", "csrf_token": csrf},
            )
            if not status.startswith("302"):
                findings.append({"route": "/tasks/update", "severity": "high", "issue": "task update failed"})
        else:
            findings.append({"route": "/tasks", "severity": "high", "issue": "could not find task update form"})

        # check data portability endpoint
        status, headers, csv_body = client.request("/export/tasks.csv")
        if not status.startswith("200") or "text/csv" not in headers.get("Content-Type", ""):
            findings.append({"route": "/export/tasks.csv", "severity": "high", "issue": "csv export failed"})
        if "title" not in csv_body:
            findings.append({"route": "/export/tasks.csv", "severity": "medium", "issue": "csv header appears incomplete"})

        summary = {
            "routes_checked": len(ROUTES),
            "findings": findings,
            "finding_count": len(findings),
        }
        print("USABILITY_TEST_SUMMARY", summary)
    finally:
        cleanup_conn = db_connect()
        try:
            cleanup_counts = cleanup_test_data(cleanup_conn, organization_id=org_id)
            print("TEST_DATA_CLEANUP", summarize_counts(cleanup_counts))
        finally:
            cleanup_conn.close()


if __name__ == "__main__":
    main()
