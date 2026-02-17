#!/usr/bin/env python3
"""MakerFlow Platform

A zero-dependency web app tailored for university makerspace operations.
It uses Python stdlib + SQLite so it can run in restricted environments.
"""

from __future__ import annotations

import base64
import csv
import cgi
import datetime as dt
import hashlib
import hmac
import html
import io
import json
import os
import re
import secrets
import smtplib
import sqlite3
import threading
import traceback
from socketserver import ThreadingMixIn
from urllib import error as urlerror
from urllib import request as urlrequest
from email.message import EmailMessage
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple
from urllib.parse import parse_qs, quote, unquote, urlencode
from wsgiref.simple_server import WSGIServer, make_server
from zoneinfo import ZoneInfo

try:
    import psycopg
    from psycopg.rows import dict_row
except Exception:  # pragma: no cover - optional dependency path
    psycopg = None
    dict_row = None

APP_NAME = "Project Management Platform for Lab Administration"
APP_TAGLINE = "MakerFlow PM for makerspaces, research labs, and library services"
BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
STATIC_DIR = BASE_DIR / "app" / "static"
WEBSITE_DIR = BASE_DIR / "MakerFlow Website"
DB_PATH = Path(os.environ.get("MAKERSPACE_DB_PATH", str(DATA_DIR / "makerspace_ops.db")))
DATABASE_URL = os.environ.get("MAKERSPACE_DATABASE_URL", os.environ.get("DATABASE_URL", "")).strip()
DB_BACKEND = "postgres" if DATABASE_URL.startswith(("postgres://", "postgresql://")) else "sqlite"
SECRET_KEY = os.environ.get("MAKERSPACE_SECRET_KEY", "change-this-secret-in-production")
COOKIE_SECURE = os.environ.get("MAKERSPACE_COOKIE_SECURE", "0") == "1"
SESSION_DAYS = int(os.environ.get("MAKERSPACE_SESSION_DAYS", "14"))
# Prefer generic container vars for App Platform compatibility.
# MAKERSPACE_* vars remain supported and take precedence where set.
HOST = os.environ.get("MAKERSPACE_HOST", os.environ.get("HOST", "127.0.0.1"))
PORT = int(os.environ.get("MAKERSPACE_PORT", os.environ.get("PORT", "8080")))
WSGI_THREADED = os.environ.get("MAKERSPACE_WSGI_THREADED", "1") == "1"
DB_BUSY_TIMEOUT_MS = max(1000, int(os.environ.get("MAKERSPACE_DB_BUSY_TIMEOUT_MS", "6000")))
DB_JOURNAL_MODE = os.environ.get("MAKERSPACE_DB_JOURNAL_MODE", "WAL").strip().upper()
DB_SYNCHRONOUS = os.environ.get("MAKERSPACE_DB_SYNCHRONOUS", "NORMAL").strip().upper()
DB_CACHE_SIZE_KB = max(4096, int(os.environ.get("MAKERSPACE_DB_CACHE_SIZE_KB", "65536")))
DB_MMAP_SIZE_BYTES = max(0, int(os.environ.get("MAKERSPACE_DB_MMAP_SIZE_BYTES", "268435456")))
DB_TEMP_STORE_MEMORY = os.environ.get("MAKERSPACE_DB_TEMP_STORE_MEMORY", "1") == "1"
GCAL_CLIENT_ID = os.environ.get("MAKERSPACE_GCAL_CLIENT_ID", "")
GCAL_CLIENT_SECRET = os.environ.get("MAKERSPACE_GCAL_CLIENT_SECRET", "")
GCAL_REFRESH_TOKEN = os.environ.get("MAKERSPACE_GCAL_REFRESH_TOKEN", "")
GCAL_ACCESS_TOKEN = os.environ.get("MAKERSPACE_GCAL_ACCESS_TOKEN", "")
GCAL_DEFAULT_CALENDAR_ID = os.environ.get("MAKERSPACE_GCAL_CALENDAR_ID", "primary")
GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
GOOGLE_CALENDAR_API_BASE = "https://www.googleapis.com/calendar/v3"
FEATURE_INTAKE_ENABLED = False

LANES = [
    "Core Operations",
    "Course/Faculty Support",
    "Student Programs",
    "Strategic Partnerships",
]

TASK_STATUSES = ["Todo", "In Progress", "Blocked", "Done", "Cancelled"]
PROJECT_STATUSES = ["Planned", "Active", "Blocked", "Complete", "Cancelled"]
INTAKE_STATUSES = ["Triage", "Planned", "Active", "On Hold", "Done", "Rejected"]
ASSET_STATUSES = ["Operational", "Needs Service", "Down"]
CONSUMABLE_STATUSES = ["In Stock", "Low", "Out"]
PARTNERSHIP_STAGES = ["Discovery", "Active", "Pilot", "Dormant", "Closed"]
ONBOARDING_STATUSES = ["Assigned", "In Progress", "Review", "Done"]
ONBOARDING_ROLE_TRACKS = ["Student Worker", "FTE", "Staff", "Manager", "Faculty Partner"]

VIEW_ENTITY_LABELS: Dict[str, str] = {
    "tasks": "Tasks",
    "projects": "Projects",
    "intake": "Intake",
    "partnerships": "Partnerships",
    "assets": "Assets",
    "consumables": "Consumables",
    "onboarding": "Onboarding",
}

VIEW_STATUS_OPTIONS: Dict[str, List[str]] = {
    "tasks": TASK_STATUSES,
    "projects": PROJECT_STATUSES,
    "intake": INTAKE_STATUSES,
    "partnerships": PARTNERSHIP_STAGES,
    "assets": ASSET_STATUSES,
    "consumables": CONSUMABLE_STATUSES,
    "onboarding": ONBOARDING_STATUSES,
}

VIEW_COLUMN_OPTIONS: Dict[str, List[Tuple[str, str]]] = {
    "tasks": [
        ("title", "Task"),
        ("project_name", "Project"),
        ("status", "Status"),
        ("priority", "Priority"),
        ("assignee_name", "Owner"),
        ("due_date", "Due Date"),
        ("team_name", "Team"),
        ("space_name", "Space"),
        ("energy", "Energy"),
        ("estimate_hours", "Est. Hours"),
        ("updated_at", "Updated"),
    ],
    "projects": [
        ("name", "Project"),
        ("lane", "Lane"),
        ("status", "Status"),
        ("priority", "Priority"),
        ("owner_name", "Owner"),
        ("team_name", "Team"),
        ("space_name", "Space"),
        ("progress_pct", "Progress %"),
        ("due_date", "Due Date"),
        ("updated_at", "Updated"),
    ],
    "intake": [
        ("title", "Title"),
        ("lane", "Lane"),
        ("status", "Status"),
        ("score", "Score"),
        ("owner_name", "Owner"),
        ("requestor_name", "Requestor"),
        ("requestor_email", "Requestor Email"),
        ("created_at", "Created"),
        ("updated_at", "Updated"),
    ],
    "partnerships": [
        ("partner_name", "Partner"),
        ("school", "School / Unit"),
        ("stage", "Stage"),
        ("health", "Health"),
        ("owner_name", "Owner"),
        ("next_followup", "Next Follow-up"),
        ("last_contact", "Last Contact"),
        ("updated_at", "Updated"),
    ],
    "assets": [
        ("name", "Asset"),
        ("space", "Space"),
        ("asset_type", "Type"),
        ("status", "Status"),
        ("owner_name", "Owner"),
        ("next_maintenance", "Next Maintenance"),
        ("cert_required", "Certification Required"),
        ("cert_name", "Certification"),
        ("updated_at", "Updated"),
    ],
    "consumables": [
        ("name", "Consumable"),
        ("space_name", "Space"),
        ("category", "Category"),
        ("quantity_on_hand", "On Hand"),
        ("unit", "Unit"),
        ("reorder_point", "Reorder Point"),
        ("status", "Status"),
        ("owner_name", "Owner"),
        ("updated_at", "Updated"),
    ],
    "onboarding": [
        ("assignee_name", "Assignee"),
        ("template_name", "Track"),
        ("task_title", "Task"),
        ("role_target", "Role"),
        ("status", "Status"),
        ("due_date", "Due Date"),
        ("created_at", "Created"),
        ("completed_at", "Completed"),
    ],
}

VIEW_TEMPLATE_LIBRARY: List[Dict[str, object]] = [
    {
        "key": "director_reality",
        "name": "Director Reality Dashboard",
        "entity": "tasks",
        "audience": "Department leader",
        "description": "Cross-team queue of high-risk/high-priority open work.",
        "filters": {"scope": "team", "priority_in": ["Critical", "High"], "status_exclude": ["Done", "Cancelled"]},
        "columns": ["title", "project_name", "status", "priority", "assignee_name", "due_date", "team_name", "space_name"],
    },
    {
        "key": "daily_focus",
        "name": "My Daily Focus",
        "entity": "tasks",
        "audience": "All staff and students",
        "description": "Personal tasks due today/tomorrow with energy and effort context.",
        "filters": {"scope": "my", "due_within_days": 1, "status_exclude": ["Done", "Cancelled"]},
        "columns": ["title", "status", "priority", "due_date", "energy", "estimate_hours", "project_name"],
    },
    {
        "key": "weekly_planner",
        "name": "My Weekly Plan",
        "entity": "tasks",
        "audience": "All staff and students",
        "description": "Week planning view with due dates and ownership clarity.",
        "filters": {"scope": "my", "due_within_days": 7, "status_exclude": ["Done", "Cancelled"]},
        "columns": ["title", "project_name", "status", "priority", "due_date", "energy", "estimate_hours"],
    },
    {
        "key": "delegation_queue",
        "name": "Delegation Queue",
        "entity": "tasks",
        "audience": "Managers and team leads",
        "description": "Unassigned work requiring owner assignment decisions.",
        "filters": {"scope": "team", "only_unassigned": True, "status_exclude": ["Done", "Cancelled"]},
        "columns": ["title", "project_name", "priority", "due_date", "team_name", "space_name"],
    },
    {
        "key": "faculty_support_pipeline",
        "name": "Faculty Support Pipeline",
        "entity": "projects",
        "audience": "Faculty support staff",
        "description": "Active and blocked projects in the Course/Faculty Support lane.",
        "filters": {"lane": "Course/Faculty Support", "status_in": ["Planned", "Active", "Blocked"]},
        "columns": ["name", "status", "priority", "owner_name", "team_name", "space_name", "progress_pct", "due_date"],
    },
    {
        "key": "student_program_delivery",
        "name": "Student Programs Delivery",
        "entity": "projects",
        "audience": "Student program coordinators",
        "description": "Student program portfolio with ownership and timeline checkpoints.",
        "filters": {"lane": "Student Programs", "status_in": ["Planned", "Active", "Blocked"]},
        "columns": ["name", "status", "priority", "owner_name", "progress_pct", "due_date", "space_name"],
    },
    {
        "key": "intake_hotlist",
        "name": "Intake Triage Hotlist",
        "entity": "intake",
        "audience": "Ops triage team",
        "description": "Highest-value requests that need triage action soon.",
        "filters": {"status_in": ["Triage", "Planned", "Active"], "min_score": 6.0},
        "columns": ["title", "lane", "status", "score", "owner_name", "requestor_name", "created_at"],
    },
    {
        "key": "partnership_radar",
        "name": "Partnership Follow-up Radar",
        "entity": "partnerships",
        "audience": "Partnership managers",
        "description": "Upcoming follow-ups in active partnership stages.",
        "filters": {"stage_in": ["Discovery", "Active", "Pilot"], "followup_within_days": 14},
        "columns": ["partner_name", "school", "stage", "health", "owner_name", "next_followup", "last_contact"],
    },
    {
        "key": "asset_maintenance_queue",
        "name": "Asset Maintenance Queue",
        "entity": "assets",
        "audience": "Lab operations staff",
        "description": "Assets due for maintenance in the next 30 days.",
        "filters": {"maintenance_within_days": 30},
        "columns": ["name", "space", "asset_type", "status", "owner_name", "next_maintenance", "cert_required"],
    },
    {
        "key": "certification_critical_assets",
        "name": "Certification-Critical Equipment",
        "entity": "assets",
        "audience": "Safety and training leads",
        "description": "Certified equipment where downtime or ownership gaps are risky.",
        "filters": {"cert_required": True},
        "columns": ["name", "space", "status", "cert_name", "owner_name", "next_maintenance"],
    },
    {
        "key": "onboarding_due_soon",
        "name": "Onboarding Due Soon",
        "entity": "onboarding",
        "audience": "Supervisors and new hire mentors",
        "description": "Open onboarding assignments due in the next two weeks.",
        "filters": {"status_exclude": ["Done"], "due_within_days": 14},
        "columns": ["assignee_name", "template_name", "task_title", "role_target", "status", "due_date"],
    },
    {
        "key": "blocked_recovery",
        "name": "Blocked Work Recovery",
        "entity": "tasks",
        "audience": "Team leads",
        "description": "Blocked tasks requiring decision, escalation, or resource shifts.",
        "filters": {"scope": "team", "status_in": ["Blocked"]},
        "columns": ["title", "project_name", "assignee_name", "priority", "due_date", "team_name", "space_name"],
    },
]

REPORT_CHART_TYPES = ["bar", "pie", "line"]

REPORT_METRIC_LIBRARY: List[Dict[str, object]] = [
    {
        "key": "tasks_by_status",
        "name": "Tasks by Status",
        "description": "Current distribution of task states.",
        "default_chart": "bar",
        "supported_charts": ["bar", "pie"],
    },
    {
        "key": "projects_by_status",
        "name": "Projects by Status",
        "description": "Portfolio state across project statuses.",
        "default_chart": "pie",
        "supported_charts": ["bar", "pie"],
    },
    {
        "key": "projects_by_lane",
        "name": "Projects by Lane",
        "description": "Current project load by strategic lane.",
        "default_chart": "pie",
        "supported_charts": ["bar", "pie"],
    },
    {
        "key": "tasks_completed_by_month",
        "name": "Task Completion Trend",
        "description": "Done tasks by month from historical updates.",
        "default_chart": "line",
        "supported_charts": ["line", "bar"],
    },
    {
        "key": "calendar_hours_by_category",
        "name": "Calendar Hours by Category",
        "description": "Scheduled effort distribution by work category.",
        "default_chart": "bar",
        "supported_charts": ["bar", "pie"],
    },
    {
        "key": "calendar_hours_by_weekday",
        "name": "Calendar Hours by Weekday",
        "description": "Weekly pattern of scheduled effort.",
        "default_chart": "bar",
        "supported_charts": ["bar", "line"],
    },
    {
        "key": "assets_by_status",
        "name": "Equipment by Status",
        "description": "Operational reliability across equipment assets.",
        "default_chart": "pie",
        "supported_charts": ["bar", "pie"],
    },
    {
        "key": "consumables_low_by_space",
        "name": "Low/Out Consumables by Space",
        "description": "Inventory risk concentration by makerspace.",
        "default_chart": "bar",
        "supported_charts": ["bar", "pie"],
    },
    {
        "key": "partnerships_by_stage",
        "name": "Partnership Stage Distribution",
        "description": "External relationship funnel by stage.",
        "default_chart": "pie",
        "supported_charts": ["bar", "pie"],
    },
    {
        "key": "onboarding_completion_by_role",
        "name": "Onboarding Completion by Role",
        "description": "Completion percentage of onboarding assignments.",
        "default_chart": "bar",
        "supported_charts": ["bar", "line"],
    },
    {
        "key": "checkins_by_space_snapshot",
        "name": "Check-ins by Space (Impact Snapshot)",
        "description": "Annual usage volume by makerspace from impact snapshots.",
        "default_chart": "bar",
        "supported_charts": ["bar", "pie"],
    },
    {
        "key": "school_reach_interactions",
        "name": "Engagement by School (Impact Snapshot)",
        "description": "Interactions by school/unit from impact snapshots.",
        "default_chart": "bar",
        "supported_charts": ["bar", "pie"],
    },
    {
        "key": "internal_vs_outward_snapshot",
        "name": "Internal vs Outward Capacity (Impact Snapshot)",
        "description": "Estimated internal vs outward-facing workload mix.",
        "default_chart": "pie",
        "supported_charts": ["pie", "bar"],
    },
]

REPORT_TEMPLATE_LIBRARY: List[Dict[str, object]] = [
    {
        "key": "impact_report",
        "name": "Impact Report - Makerspace Network",
        "audience": "Department leaders and external stakeholders",
        "description": "Bundled annual-impact narrative with usage, capacity, delivery, and reliability charts.",
        "widgets": [
            {"title": "Check-ins by Space", "metric": "checkins_by_space_snapshot", "chart": "bar", "window": "all"},
            {"title": "Engagement by School", "metric": "school_reach_interactions", "chart": "bar", "window": "all"},
            {"title": "Internal vs Outward Capacity", "metric": "internal_vs_outward_snapshot", "chart": "pie", "window": "all"},
            {"title": "Projects by Lane", "metric": "projects_by_lane", "chart": "pie", "window": "all"},
            {"title": "Project Status Mix", "metric": "projects_by_status", "chart": "bar", "window": "all"},
            {"title": "Task Completion Trend", "metric": "tasks_completed_by_month", "chart": "line", "window": "12m"},
            {"title": "Calendar Hours by Category", "metric": "calendar_hours_by_category", "chart": "bar", "window": "all"},
            {"title": "Calendar Load by Weekday", "metric": "calendar_hours_by_weekday", "chart": "bar", "window": "all"},
            {"title": "Equipment Reliability", "metric": "assets_by_status", "chart": "pie", "window": "all"},
            {"title": "Consumable Risk by Space", "metric": "consumables_low_by_space", "chart": "bar", "window": "all"},
            {"title": "Onboarding Completion by Role", "metric": "onboarding_completion_by_role", "chart": "bar", "window": "all"},
        ],
    },
    {
        "key": "operations_pulse",
        "name": "Operations Pulse",
        "audience": "Operations leads",
        "description": "Weekly operations health covering work queue, maintenance risk, and inventory risk.",
        "widgets": [
            {"title": "Tasks by Status", "metric": "tasks_by_status", "chart": "bar", "window": "all"},
            {"title": "Equipment by Status", "metric": "assets_by_status", "chart": "pie", "window": "all"},
            {"title": "Low/Out Consumables by Space", "metric": "consumables_low_by_space", "chart": "bar", "window": "all"},
            {"title": "Partnership Stage Mix", "metric": "partnerships_by_stage", "chart": "pie", "window": "all"},
        ],
    },
    {
        "key": "student_success_pulse",
        "name": "Student Success Pulse",
        "audience": "Student programs and training leads",
        "description": "Program health for onboarding, project execution, and mentoring cadence.",
        "widgets": [
            {"title": "Onboarding Completion by Role", "metric": "onboarding_completion_by_role", "chart": "bar", "window": "all"},
            {"title": "Task Completion Trend", "metric": "tasks_completed_by_month", "chart": "line", "window": "12m"},
            {"title": "Projects by Lane", "metric": "projects_by_lane", "chart": "pie", "window": "all"},
            {"title": "Calendar Hours by Category", "metric": "calendar_hours_by_category", "chart": "bar", "window": "all"},
        ],
    },
]

SMTP_HOST = os.environ.get("MAKERSPACE_SMTP_HOST", "").strip()
SMTP_PORT = int(os.environ.get("MAKERSPACE_SMTP_PORT", "587"))
SMTP_USER = os.environ.get("MAKERSPACE_SMTP_USER", "").strip()
SMTP_PASSWORD = os.environ.get("MAKERSPACE_SMTP_PASSWORD", "")
SMTP_FROM = os.environ.get("MAKERSPACE_SMTP_FROM", "").strip()
SMTP_USE_TLS = os.environ.get("MAKERSPACE_SMTP_TLS", "1") == "1"

KANBAN_COLORS = {
    "Todo": "#67b8ff",
    "In Progress": "#ffc857",
    "Blocked": "#ff6b6b",
    "Done": "#35c36b",
    "Cancelled": "#8c95a1",
    "Planned": "#76a7ff",
    "Active": "#f7a24b",
    "Complete": "#34bf77",
    "On Hold": "#b394f4",
    "Rejected": "#a0a8b8",
    "Operational": "#35c36b",
    "Needs Service": "#f7a24b",
    "Down": "#ff6b6b",
    "In Stock": "#35c36b",
    "Low": "#f7a24b",
    "Out": "#ff6b6b",
    "Discovery": "#76a7ff",
    "Pilot": "#3cc2b3",
    "Dormant": "#a0a8b8",
    "Closed": "#8c95a1",
}

CATEGORY_KEYWORDS = {
    "Teaching & Mentoring": ["class", "course", "office hour", "student worker", "mentoring", "workshop"],
    "Coordination Meetings": ["meeting", "check-in", "standup", "sync", "staff", "slg"],
    "Project Delivery": ["build", "prototype", "design", "fabrication", "deliver", "project"],
    "Operations & Admin": ["admin", "budget", "hiring", "hr", "procurement", "ops"],
    "Partnerships & Outreach": ["partner", "outreach", "community", "visit", "external", "presentation"],
    "Personal/Recovery": ["lunch", "break", "doctor", "personal", "recovery"],
}

ROLE_RANK = {
    "viewer": 1,
    "student": 2,
    "staff": 3,
    "manager": 4,
    "workspace_admin": 5,
    "owner": 6,
}
# Membership roles are ordered from least to most privileged for UI rendering and comparisons.
MEMBERSHIP_ROLE_OPTIONS = ["viewer", "student", "staff", "manager", "workspace_admin", "owner"]

# Sidebar nav definitions are centralized so user/role visibility controls can reuse one source of truth.
NAV_PRIMARY_ITEMS: List[Dict[str, str]] = [
    {"key": "dashboard", "path": "/dashboard", "label": "Dashboard", "min_role": "viewer"},
    {"key": "reports", "path": "/reports", "label": "Reports", "min_role": "viewer"},
    {"key": "tasks", "path": "/tasks", "label": "Tasks", "min_role": "viewer"},
    {"key": "projects", "path": "/projects", "label": "Projects", "min_role": "viewer"},
    {"key": "calendar", "path": "/calendar", "label": "Calendar", "min_role": "viewer"},
    {"key": "agenda", "path": "/agenda", "label": "Agenda", "min_role": "viewer"},
    {"key": "intake", "path": "/intake", "label": "Intake", "min_role": "viewer"},
    {"key": "onboarding", "path": "/onboarding", "label": "Onboarding", "min_role": "viewer"},
    {"key": "spaces", "path": "/spaces", "label": "Spaces", "min_role": "viewer"},
    {"key": "assets", "path": "/assets", "label": "Assets", "min_role": "viewer"},
    {"key": "consumables", "path": "/consumables", "label": "Consumables", "min_role": "viewer"},
    {"key": "partnerships", "path": "/partnerships", "label": "Partnerships", "min_role": "viewer"},
]

NAV_ACCOUNT_ITEMS: List[Dict[str, str]] = [
    {"key": "views", "path": "/views", "label": "Custom Views", "min_role": "viewer"},
    {"key": "data_hub", "path": "/data-hub", "label": "Data Hub", "min_role": "manager"},
    {"key": "deleted", "path": "/deleted", "label": "Deleted Items", "min_role": "workspace_admin"},
    {"key": "admin", "path": "/admin/users", "label": "Admin", "min_role": "workspace_admin"},
    {"key": "settings", "path": "/settings", "label": "Settings", "min_role": "viewer"},
]

# Users can hide most links, but keeping settings visible avoids accidental self-lockout.
NAV_ALWAYS_VISIBLE_KEYS = {"settings"}

# Soft-delete policy mirrors Monday-style "trash" workflows:
# 1) move item to terminal state, 2) delete to hidden trash, 3) admin restores/purges from trash.
DELETE_POLICY: Dict[str, Dict[str, object]] = {
    "task": {
        "label": "Tasks",
        "table": "tasks",
        "title_field": "title",
        "status_field": "status",
        "updated_field": "updated_at",
        "min_role": "student",
        "ready_statuses": ["Cancelled"],
    },
    "project": {
        "label": "Projects",
        "table": "projects",
        "title_field": "name",
        "status_field": "status",
        "updated_field": "updated_at",
        "min_role": "staff",
        "ready_statuses": ["Cancelled"],
    },
    "intake": {
        "label": "Intake",
        "table": "intake_requests",
        "title_field": "title",
        "status_field": "status",
        "updated_field": "updated_at",
        "min_role": "staff",
        "ready_statuses": ["Rejected"],
    },
    "asset": {
        "label": "Assets",
        "table": "equipment_assets",
        "title_field": "name",
        "status_field": "status",
        "updated_field": "updated_at",
        "min_role": "staff",
        "ready_statuses": ["Down"],
    },
    "consumable": {
        "label": "Consumables",
        "table": "consumables",
        "title_field": "name",
        "status_field": "status",
        "updated_field": "updated_at",
        "min_role": "staff",
        "ready_statuses": ["Out"],
    },
    "partnership": {
        "label": "Partnerships",
        "table": "partnerships",
        "title_field": "partner_name",
        "status_field": "stage",
        "updated_field": "updated_at",
        "min_role": "staff",
        "ready_statuses": ["Closed"],
    },
}

# Comments are currently supported on core delivery records first.
# Future entities can be enabled by extending this map and the frontend modal renderer.
COMMENTABLE_ENTITY_TABLE: Dict[str, str] = {
    "task": "tasks",
    "project": "projects",
}

RATE_LIMIT: Dict[str, List[dt.datetime]] = {}
BOOTSTRAPPED = False
BOOTSTRAP_LOCK = threading.Lock()
BOOTSTRAP_ERROR = ""


def utcnow() -> dt.datetime:
    return dt.datetime.now(dt.timezone.utc)


def iso(ts: Optional[dt.datetime] = None) -> str:
    value = ts or utcnow()
    return value.replace(microsecond=0).isoformat()


def h(value: object) -> str:
    if value is None:
        return ""
    return html.escape(str(value), quote=True)


def sign_value(value: str) -> str:
    digest = hmac.new(SECRET_KEY.encode("utf-8"), value.encode("utf-8"), hashlib.sha256).hexdigest()
    return f"{value}.{digest}"


def verify_signed_value(signed: str) -> Optional[str]:
    if not signed or "." not in signed:
        return None
    value, digest = signed.rsplit(".", 1)
    expected = hmac.new(SECRET_KEY.encode("utf-8"), value.encode("utf-8"), hashlib.sha256).hexdigest()
    if hmac.compare_digest(digest, expected):
        return value
    return None


def hash_password(password: str, salt_b64: Optional[str] = None) -> Tuple[str, str]:
    salt = base64.b64decode(salt_b64) if salt_b64 else secrets.token_bytes(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode("utf-8"), salt, 310_000)
    return base64.b64encode(digest).decode("utf-8"), base64.b64encode(salt).decode("utf-8")


def verify_password(password: str, expected_hash: str, salt_b64: str) -> bool:
    computed, _ = hash_password(password, salt_b64)
    return hmac.compare_digest(computed, expected_hash)


def token_hash(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def parse_date(value: str) -> Optional[str]:
    if not value:
        return None
    value = value.strip()
    for fmt in ("%Y-%m-%d", "%m/%d/%Y", "%Y/%m/%d"):
        try:
            return dt.datetime.strptime(value, fmt).date().isoformat()
        except ValueError:
            continue
    return None


def parse_datetime(value: str) -> Optional[str]:
    if not value:
        return None
    value = value.strip()
    for fmt in (
        "%Y-%m-%dT%H:%M:%S",
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M",
        "%m/%d/%Y %H:%M",
        "%m/%d/%Y %I:%M %p",
    ):
        try:
            local = dt.datetime.strptime(value, fmt)
            return local.replace(tzinfo=dt.timezone.utc).isoformat()
        except ValueError:
            continue
    return None


def parse_rfc3339_datetime(value: str) -> Optional[dt.datetime]:
    if not value:
        return None
    normalized = value.strip()
    if normalized.endswith("Z"):
        normalized = normalized[:-1] + "+00:00"
    try:
        parsed = dt.datetime.fromisoformat(normalized)
    except ValueError:
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=dt.timezone.utc)
    return parsed.astimezone(dt.timezone.utc)


def user_timezone_name(conn: sqlite3.Connection, user_id: int) -> str:
    row = conn.execute("SELECT timezone FROM users WHERE id = ?", (user_id,)).fetchone()
    tz_name = str(row["timezone"] or "").strip() if row else ""
    return tz_name or "America/New_York"


def safe_timezone(tz_name: str) -> dt.tzinfo:
    try:
        return ZoneInfo(tz_name)
    except Exception:
        return dt.timezone.utc


def localize_iso_datetime(value: object, tzinfo: dt.tzinfo) -> Optional[dt.datetime]:
    if value in (None, ""):
        return None
    try:
        parsed = dt.datetime.fromisoformat(str(value))
    except ValueError:
        return None
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=dt.timezone.utc)
    return parsed.astimezone(tzinfo)


def format_local_dt(value: object, tzinfo: dt.tzinfo, fallback: str = "-") -> str:
    local = localize_iso_datetime(value, tzinfo)
    if not local:
        return fallback
    return local.strftime("%Y-%m-%d %H:%M")


def clamp_int(value: Optional[str], default: int, minimum: int, maximum: int) -> int:
    parsed = to_int(value, default) or default
    return max(minimum, min(maximum, parsed))


def month_bounds(anchor: dt.date) -> Tuple[dt.date, dt.date]:
    first = anchor.replace(day=1)
    if first.month == 12:
        next_month = dt.date(first.year + 1, 1, 1)
    else:
        next_month = dt.date(first.year, first.month + 1, 1)
    last = next_month - dt.timedelta(days=1)
    return first, last


def week_start(anchor: dt.date) -> dt.date:
    return anchor - dt.timedelta(days=anchor.weekday())


def gcal_api_configured() -> bool:
    if GCAL_ACCESS_TOKEN:
        return True
    return bool(GCAL_CLIENT_ID and GCAL_CLIENT_SECRET and GCAL_REFRESH_TOKEN)


def gcal_access_token() -> Tuple[Optional[str], str]:
    if GCAL_ACCESS_TOKEN:
        return GCAL_ACCESS_TOKEN, ""
    if not gcal_api_configured():
        return None, "Google Calendar API credentials are not configured."
    payload = urlencode(
        {
            "client_id": GCAL_CLIENT_ID,
            "client_secret": GCAL_CLIENT_SECRET,
            "refresh_token": GCAL_REFRESH_TOKEN,
            "grant_type": "refresh_token",
        }
    ).encode("utf-8")
    req = urlrequest.Request(
        GOOGLE_TOKEN_URL,
        data=payload,
        method="POST",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    try:
        with urlrequest.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8", errors="ignore"))
    except urlerror.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="ignore")[:400]
        return None, f"OAuth token error ({exc.code}): {detail or 'No details'}"
    except Exception as exc:
        return None, f"OAuth token error: {str(exc)[:240]}"
    token = str(data.get("access_token") or "")
    if not token:
        return None, "OAuth token response missing access_token."
    return token, ""


def gcal_request(
    method: str,
    endpoint: str,
    access_token: str,
    params: Optional[Dict[str, str]] = None,
    payload: Optional[Dict[str, object]] = None,
) -> Tuple[Optional[Dict[str, object]], str]:
    url = endpoint if endpoint.startswith("http") else f"{GOOGLE_CALENDAR_API_BASE}{endpoint}"
    if params:
        qs = urlencode(params)
        url = f"{url}{'&' if '?' in url else '?'}{qs}"
    body = json.dumps(payload).encode("utf-8") if payload is not None else None
    req = urlrequest.Request(url, data=body, method=method.upper())
    req.add_header("Authorization", f"Bearer {access_token}")
    req.add_header("Accept", "application/json")
    if payload is not None:
        req.add_header("Content-Type", "application/json")

    try:
        with urlrequest.urlopen(req, timeout=20) as resp:
            raw = resp.read().decode("utf-8", errors="ignore")
            return (json.loads(raw) if raw else {}), ""
    except urlerror.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="ignore")[:600]
        return None, f"Google API {exc.code}: {detail or exc.reason}"
    except Exception as exc:
        return None, f"Google API request failed: {str(exc)[:300]}"


def gcal_event_times(item: Dict[str, object]) -> Tuple[Optional[str], Optional[str]]:
    start_obj = item.get("start") if isinstance(item.get("start"), dict) else {}
    end_obj = item.get("end") if isinstance(item.get("end"), dict) else {}
    start_iso: Optional[str] = None
    end_iso: Optional[str] = None

    start_dt = parse_rfc3339_datetime(str(start_obj.get("dateTime", "")))
    end_dt = parse_rfc3339_datetime(str(end_obj.get("dateTime", "")))
    if start_dt:
        start_iso = start_dt.isoformat()
    if end_dt:
        end_iso = end_dt.isoformat()

    if not start_iso:
        start_date = parse_iso_date(start_obj.get("date"))
        if start_date:
            start_iso = dt.datetime.combine(start_date, dt.time(hour=9, tzinfo=dt.timezone.utc)).isoformat()
    if not end_iso:
        end_date = parse_iso_date(end_obj.get("date"))
        if end_date:
            end_iso = dt.datetime.combine(end_date, dt.time(hour=10, tzinfo=dt.timezone.utc)).isoformat()
    if start_iso and not end_iso:
        end_iso = (dt.datetime.fromisoformat(start_iso) + dt.timedelta(hours=1)).isoformat()
    return start_iso, end_iso


def load_calendar_sync_settings(conn: sqlite3.Connection, org_id: int, user_id: int) -> Dict[str, object]:
    row = conn.execute(
        """
        SELECT calendar_id, lookback_days, lookahead_days, push_window_days, last_pull_at, last_push_at
        FROM calendar_sync_settings
        WHERE organization_id = ? AND user_id = ?
        """,
        (org_id, user_id),
    ).fetchone()
    defaults = {
        "calendar_id": GCAL_DEFAULT_CALENDAR_ID or "primary",
        "lookback_days": 30,
        "lookahead_days": 45,
        "push_window_days": 30,
        "last_pull_at": "",
        "last_push_at": "",
    }
    if not row:
        return defaults
    out = dict(defaults)
    out.update({k: row[k] for k in row.keys()})
    return out


def save_calendar_sync_settings(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    calendar_id: str,
    lookback_days: int,
    lookahead_days: int,
    push_window_days: int,
    touch_pull: bool = False,
    touch_push: bool = False,
) -> None:
    existing = conn.execute(
        "SELECT id FROM calendar_sync_settings WHERE organization_id = ? AND user_id = ?",
        (org_id, user_id),
    ).fetchone()
    now = iso()
    if existing:
        conn.execute(
            """
            UPDATE calendar_sync_settings
            SET calendar_id = ?, lookback_days = ?, lookahead_days = ?, push_window_days = ?,
                last_pull_at = CASE WHEN ? THEN ? ELSE last_pull_at END,
                last_push_at = CASE WHEN ? THEN ? ELSE last_push_at END,
                updated_at = ?
            WHERE id = ?
            """,
            (
                calendar_id,
                lookback_days,
                lookahead_days,
                push_window_days,
                1 if touch_pull else 0,
                now,
                1 if touch_push else 0,
                now,
                now,
                existing["id"],
            ),
        )
        return
    conn.execute(
        """
        INSERT INTO calendar_sync_settings
        (organization_id, user_id, calendar_id, lookback_days, lookahead_days, push_window_days, last_pull_at, last_push_at, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            org_id,
            user_id,
            calendar_id,
            lookback_days,
            lookahead_days,
            push_window_days,
            now if touch_pull else None,
            now if touch_push else None,
            now,
            now,
        ),
    )


def pull_google_calendar_events(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    calendar_id: str,
    lookback_days: int,
    lookahead_days: int,
) -> Tuple[int, int, str]:
    token, token_error = gcal_access_token()
    if not token:
        return 0, 0, token_error

    time_min = (utcnow() - dt.timedelta(days=lookback_days)).isoformat().replace("+00:00", "Z")
    time_max = (utcnow() + dt.timedelta(days=lookahead_days)).isoformat().replace("+00:00", "Z")
    endpoint = f"/calendars/{quote(calendar_id, safe='')}/events"
    page_token = ""
    inserted = 0
    updated = 0
    loops = 0

    while loops < 10:
        loops += 1
        params = {
            "singleEvents": "true",
            "orderBy": "startTime",
            "maxResults": "250",
            "timeMin": time_min,
            "timeMax": time_max,
        }
        if page_token:
            params["pageToken"] = page_token
        payload, error = gcal_request("GET", endpoint, token, params=params)
        if error:
            return inserted, updated, error
        if not payload:
            break
        items = payload.get("items")
        if not isinstance(items, list):
            items = []
        for item in items:
            if not isinstance(item, dict):
                continue
            external_id = str(item.get("id") or "").strip()
            if not external_id:
                continue
            start_at, end_at = gcal_event_times(item)
            if not start_at or not end_at:
                continue
            title = str(item.get("summary") or "Untitled")
            description = str(item.get("description") or "")
            location = str(item.get("location") or "")
            attendees = item.get("attendees")
            attendee_count = len(attendees) if isinstance(attendees, list) else None
            category = classify_calendar_event(title, description)
            html_link = str(item.get("htmlLink") or "")

            existing = conn.execute(
                """
                SELECT id FROM calendar_events
                WHERE organization_id = ? AND source = 'google_api' AND external_calendar_id = ? AND external_event_id = ?
                """,
                (org_id, calendar_id, external_id),
            ).fetchone()
            if existing:
                conn.execute(
                    """
                    UPDATE calendar_events
                    SET user_id = ?, title = ?, start_at = ?, end_at = ?, attendees_count = ?, location = ?, description = ?, category = ?, html_link = ?
                    WHERE id = ?
                    """,
                    (
                        user_id,
                        title,
                        start_at,
                        end_at,
                        attendee_count,
                        location,
                        description,
                        category,
                        html_link,
                        existing["id"],
                    ),
                )
                updated += 1
            else:
                conn.execute(
                    """
                    INSERT INTO calendar_events
                    (organization_id, user_id, source, title, start_at, end_at, attendees_count, location, description, category, energy_score, created_at, external_event_id, external_calendar_id, html_link)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        org_id,
                        user_id,
                        "google_api",
                        title,
                        start_at,
                        end_at,
                        attendee_count,
                        location,
                        description,
                        category,
                        None,
                        iso(),
                        external_id,
                        calendar_id,
                        html_link,
                    ),
                )
                inserted += 1
        page_token = str(payload.get("nextPageToken") or "")
        if not page_token:
            break

    return inserted, updated, ""


def build_task_calendar_payload(
    task: sqlite3.Row,
    org_id: int,
    timezone_name: str,
) -> Tuple[Dict[str, object], str]:
    tzinfo = safe_timezone(timezone_name)
    due = parse_iso_date(task["due_date"]) or dt.date.today()
    start_local = dt.datetime.combine(due, dt.time(hour=9, minute=0), tzinfo=tzinfo)
    end_local = start_local + dt.timedelta(minutes=30)
    summary = f"[MakerFlow Task] {task['title']}"
    description = (
        f"MakerFlow task sync\n"
        f"Task ID: {task['id']}\n"
        f"Status: {task['status']}\n"
        f"Priority: {task['priority']}\n"
        f"Assignee: {task['assignee_name'] or 'Unassigned'}\n"
        f"Project: {task['project_name'] or '-'}\n"
        f"Space: {task['space_name'] or '-'}\n"
        f"Details: {task['description'] or ''}"
    )
    payload: Dict[str, object] = {
        "summary": summary,
        "description": description,
        "start": {"dateTime": start_local.isoformat(), "timeZone": timezone_name},
        "end": {"dateTime": end_local.isoformat(), "timeZone": timezone_name},
        "extendedProperties": {
            "private": {
                "makerflow_org_id": str(org_id),
                "makerflow_task_id": str(task["id"]),
            }
        },
    }
    if task["space_name"]:
        payload["location"] = str(task["space_name"])
    raw_hash = "|".join(
        [
            str(task["id"]),
            str(task["title"] or ""),
            str(task["status"] or ""),
            str(task["priority"] or ""),
            str(task["due_date"] or ""),
            str(task["description"] or ""),
            str(task["project_name"] or ""),
            str(task["space_name"] or ""),
        ]
    )
    sync_hash = hashlib.sha256(raw_hash.encode("utf-8")).hexdigest()
    return payload, sync_hash


def push_tasks_to_google_calendar(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    calendar_id: str,
    push_window_days: int,
    selected_space_id: Optional[int] = None,
) -> Tuple[int, int, int, str]:
    token, token_error = gcal_access_token()
    if not token:
        return 0, 0, 0, token_error

    timezone_name = user_timezone_name(conn, user_id)
    start_date = dt.date.today().isoformat()
    end_date = (dt.date.today() + dt.timedelta(days=push_window_days)).isoformat()
    query = """
        SELECT t.id, t.title, t.description, t.status, t.priority, t.due_date,
               u.name AS assignee_name, p.name AS project_name, s.name AS space_name
        FROM tasks t
        LEFT JOIN users u ON u.id = t.assignee_user_id
        LEFT JOIN projects p ON p.id = t.project_id
        LEFT JOIN spaces s ON s.id = t.space_id
        WHERE t.organization_id = ?
          AND t.status NOT IN ('Done', 'Cancelled')
          AND t.due_date IS NOT NULL
          AND t.due_date >= ?
          AND t.due_date <= ?
          AND t.assignee_user_id = ?
    """
    params: List[object] = [org_id, start_date, end_date, user_id]
    if selected_space_id:
        query += " AND t.space_id = ?"
        params.append(selected_space_id)
    query += " ORDER BY t.due_date ASC LIMIT 400"
    tasks = conn.execute(query, tuple(params)).fetchall()

    created = 0
    updated = 0
    skipped = 0
    errors: List[str] = []
    calendar_path = f"/calendars/{quote(calendar_id, safe='')}"
    for task in tasks:
        payload, sync_hash = build_task_calendar_payload(task, org_id, timezone_name)
        link = conn.execute(
            """
            SELECT * FROM calendar_sync_links
            WHERE organization_id = ? AND user_id = ? AND entity_type = 'task' AND entity_id = ? AND calendar_id = ?
            """,
            (org_id, user_id, str(task["id"]), calendar_id),
        ).fetchone()

        if link and str(link["sync_hash"] or "") == sync_hash:
            skipped += 1
            continue

        if link:
            patch_endpoint = f"{calendar_path}/events/{quote(str(link['event_id']), safe='')}"
            _, error = gcal_request("PATCH", patch_endpoint, token, payload=payload)
            if error:
                if "404" not in error:
                    skipped += 1
                    errors.append(f"task {task['id']}: {error}")
                    continue
            else:
                conn.execute(
                    "UPDATE calendar_sync_links SET sync_hash = ?, last_synced_at = ? WHERE id = ?",
                    (sync_hash, iso(), link["id"]),
                )
                updated += 1
                continue

        created_event, error = gcal_request("POST", f"{calendar_path}/events", token, payload=payload)
        if error or not created_event or not created_event.get("id"):
            skipped += 1
            if error:
                errors.append(f"task {task['id']}: {error}")
            continue
        event_id = str(created_event.get("id"))
        if link:
            conn.execute(
                "UPDATE calendar_sync_links SET event_id = ?, sync_hash = ?, last_synced_at = ? WHERE id = ?",
                (event_id, sync_hash, iso(), link["id"]),
            )
        else:
            conn.execute(
                """
                INSERT INTO calendar_sync_links
                (organization_id, user_id, entity_type, entity_id, calendar_id, event_id, sync_hash, last_synced_at, created_at)
                VALUES (?, ?, 'task', ?, ?, ?, ?, ?, ?)
                """,
                (org_id, user_id, str(task["id"]), calendar_id, event_id, sync_hash, iso(), iso()),
            )
        created += 1

    error_summary = "; ".join(errors[:2])
    if len(errors) > 2:
        error_summary += f"; +{len(errors) - 2} more"
    return created, updated, skipped, error_summary


def classify_calendar_event(title: str, description: str) -> str:
    text = f"{title} {description}".lower()
    for category, words in CATEGORY_KEYWORDS.items():
        if any(word in text for word in words):
            return category
    return "Other"


def parse_meta_json(raw: Optional[str]) -> Dict[str, object]:
    if not raw:
        return {}
    try:
        parsed = json.loads(raw)
        return parsed if isinstance(parsed, dict) else {}
    except json.JSONDecodeError:
        return {}


def to_int(value: Optional[str], default: Optional[int] = None) -> Optional[int]:
    if value in (None, ""):
        return default
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def to_float(value: Optional[str], default: float = 0.0) -> float:
    if value in (None, ""):
        return default
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def lines_to_items(raw: Optional[str], limit: int = 30) -> List[str]:
    if not raw:
        return []
    items = [line.strip() for line in str(raw).splitlines() if line.strip()]
    return items[:limit]


def view_template_by_key(key: str) -> Optional[Dict[str, object]]:
    for template in VIEW_TEMPLATE_LIBRARY:
        if str(template.get("key", "")) == key:
            return template
    return None


def view_column_label_map(entity: str) -> Dict[str, str]:
    return {key: label for key, label in VIEW_COLUMN_OPTIONS.get(entity, [])}


def view_default_columns(entity: str) -> List[str]:
    defaults = [key for key, _label in VIEW_COLUMN_OPTIONS.get(entity, [])]
    return defaults[: min(8, len(defaults))]


def parse_view_filters(raw: Optional[str]) -> Dict[str, object]:
    if not raw:
        return {}
    try:
        parsed = json.loads(raw)
        return parsed if isinstance(parsed, dict) else {}
    except json.JSONDecodeError:
        return {}


def parse_view_columns(entity: str, raw: Optional[str]) -> List[str]:
    allowed = {key for key, _label in VIEW_COLUMN_OPTIONS.get(entity, [])}
    if not raw:
        return view_default_columns(entity)
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        parsed = []
    cols: List[str] = []
    if isinstance(parsed, list):
        cols = [str(item) for item in parsed if str(item) in allowed]
    return cols or view_default_columns(entity)


def view_list(value: object) -> List[str]:
    if isinstance(value, list):
        return [str(item).strip() for item in value if str(item).strip()]
    if isinstance(value, str):
        if "," in value:
            return [item.strip() for item in value.split(",") if item.strip()]
        if value.strip():
            return [value.strip()]
    return []


def view_bool(value: object, default: Optional[bool] = None) -> Optional[bool]:
    if value is None:
        return default
    if isinstance(value, bool):
        return value
    text = str(value).strip().lower()
    if text in {"1", "true", "yes", "on"}:
        return True
    if text in {"0", "false", "no", "off"}:
        return False
    return default


def view_int(value: object, default: Optional[int] = None) -> Optional[int]:
    if value in (None, ""):
        return default
    try:
        return int(str(value))
    except (TypeError, ValueError):
        return default


def view_float(value: object, default: Optional[float] = None) -> Optional[float]:
    if value in (None, ""):
        return default
    try:
        return float(str(value))
    except (TypeError, ValueError):
        return default


def parse_iso_date(value: object) -> Optional[dt.date]:
    if value in (None, ""):
        return None
    text = str(value).strip()
    if not text:
        return None
    candidate = text[:10]
    try:
        return dt.date.fromisoformat(candidate)
    except ValueError:
        return None


def date_within_days(value: object, days: Optional[int], anchor: Optional[dt.date] = None) -> bool:
    if days is None:
        return True
    due = parse_iso_date(value)
    if not due:
        return False
    start = anchor or dt.date.today()
    end = start + dt.timedelta(days=max(days, 0))
    return start <= due <= end


def stringify_view_cell(column: str, value: object) -> str:
    if value in (None, ""):
        return "-"
    if column == "cert_required":
        return "Yes" if str(value) in {"1", "true", "True"} else "No"
    if column == "progress_pct":
        try:
            return f"{int(float(str(value)))}%"
        except (TypeError, ValueError):
            return str(value)
    if isinstance(value, float):
        return f"{value:.2f}".rstrip("0").rstrip(".")
    return str(value)


class CompatRow(dict):
    """Row mapping that also supports numeric index access like sqlite3.Row."""

    def __init__(self, data: Dict[str, Any], order: List[str]):
        super().__init__(data)
        self._order = order

    def __getitem__(self, key: object) -> Any:  # type: ignore[override]
        if isinstance(key, int):
            name = self._order[key]
            return super().__getitem__(name)
        return super().__getitem__(str(key))


class CompatCursor:
    """Cursor wrapper with sqlite-like row behavior for PostgreSQL."""

    def __init__(self, cursor: Any, order: Optional[List[str]] = None, lastrowid: Optional[int] = None):
        self._cursor = cursor
        self._order = order or []
        self.lastrowid = lastrowid

    @property
    def rowcount(self) -> int:
        return int(getattr(self._cursor, "rowcount", -1))

    def fetchone(self):
        row = self._cursor.fetchone()
        if row is None:
            return None
        if isinstance(row, dict):
            return CompatRow(row, self._order)
        if isinstance(row, tuple):
            mapped = {self._order[idx]: row[idx] for idx in range(min(len(self._order), len(row)))}
            return CompatRow(mapped, self._order)
        return row

    def fetchall(self):
        rows = self._cursor.fetchall()
        out = []
        for row in rows:
            if isinstance(row, dict):
                out.append(CompatRow(row, self._order))
            elif isinstance(row, tuple):
                mapped = {self._order[idx]: row[idx] for idx in range(min(len(self._order), len(row)))}
                out.append(CompatRow(mapped, self._order))
            else:
                out.append(row)
        return out


def _split_sql_script(script: str) -> List[str]:
    chunks = []
    buf: List[str] = []
    in_single = False
    in_double = False
    for ch in script:
        if ch == "'" and not in_double:
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
        if ch == ";" and not in_single and not in_double:
            stmt = "".join(buf).strip()
            if stmt:
                chunks.append(stmt)
            buf = []
        else:
            buf.append(ch)
    tail = "".join(buf).strip()
    if tail:
        chunks.append(tail)
    return chunks


def _replace_qmark_params(sql: str) -> str:
    out: List[str] = []
    in_single = False
    in_double = False
    for ch in sql:
        if ch == "'" and not in_double:
            in_single = not in_single
        elif ch == '"' and not in_single:
            in_double = not in_double
        if ch == "?" and not in_single and not in_double:
            out.append("%s")
        else:
            out.append(ch)
    return "".join(out)


def _adapt_sql_for_postgres(sql: str) -> str:
    text = sql.strip()
    upper = text.upper()
    # sqlite introspection compatibility used in schema/tooling paths.
    pragma_match = re.match(r"PRAGMA\s+table_info\(([^)]+)\)", text, flags=re.IGNORECASE)
    if pragma_match:
        table = pragma_match.group(1).strip().strip('"')
        return (
            "SELECT column_name AS name, data_type AS type, "
            "CASE WHEN is_nullable = 'NO' THEN 1 ELSE 0 END AS notnull, "
            "column_default AS dflt_value, "
            "CASE WHEN position('nextval' in COALESCE(column_default,'')) > 0 THEN 1 ELSE 0 END AS pk "
            "FROM information_schema.columns "
            "WHERE table_schema = current_schema() AND table_name = %s "
            "ORDER BY ordinal_position"
        )
    if "LAST_INSERT_ROWID()" in upper:
        return "SELECT LASTVAL() AS id"
    # Basic SQLite DDL conversion for init_db() bootstrap.
    text = re.sub(r"INTEGER\s+PRIMARY\s+KEY\s+AUTOINCREMENT", "BIGSERIAL PRIMARY KEY", text, flags=re.IGNORECASE)
    text = re.sub(r"\bAUTOINCREMENT\b", "", text, flags=re.IGNORECASE)
    # SQLite upsert shortcut compatibility.
    text = re.sub(r"INSERT\s+OR\s+IGNORE\s+INTO", "INSERT INTO", text, flags=re.IGNORECASE)
    if re.match(r"^INSERT\s+INTO\s+", text, flags=re.IGNORECASE) and " ON CONFLICT " not in text.upper():
        text = f"{text} ON CONFLICT DO NOTHING"
    return _replace_qmark_params(text)


class PostgresCompatConnection:
    """Small DB-API compatibility layer so existing sqlite-style calls still work."""

    def __init__(self, conn: Any):
        self._conn = conn

    def execute(self, sql: str, params: Tuple[Any, ...] = ()):
        pg_sql = _adapt_sql_for_postgres(sql)
        use_params = params
        if pg_sql.startswith("SELECT column_name AS name") and len(params) == 0:
            pragma_match = re.match(r"PRAGMA\s+table_info\(([^)]+)\)", sql.strip(), flags=re.IGNORECASE)
            if pragma_match:
                use_params = (pragma_match.group(1).strip().strip('"'),)
        cur = self._conn.cursor()
        try:
            cur.execute(pg_sql, use_params)
        except Exception as exc:
            # Preserve existing sqlite IntegrityError handlers in business logic.
            if getattr(exc, "sqlstate", "").startswith("23"):
                raise sqlite3.IntegrityError(str(exc))
            raise
        order = [d.name for d in (cur.description or [])]
        last_id = None
        if pg_sql.strip().upper().startswith("INSERT"):
            try:
                with self._conn.cursor() as c2:
                    c2.execute("SELECT LASTVAL() AS id")
                    row = c2.fetchone()
                    if isinstance(row, dict):
                        last_id = int(row.get("id")) if row.get("id") is not None else None
                    elif isinstance(row, tuple) and row:
                        last_id = int(row[0])
            except Exception:
                last_id = None
        return CompatCursor(cur, order=order, lastrowid=last_id)

    def executescript(self, script: str):
        for stmt in _split_sql_script(script):
            self.execute(stmt)

    def commit(self):
        self._conn.commit()

    def close(self):
        self._conn.close()


def db_connect():
    if DB_BACKEND == "postgres":
        if psycopg is None:
            raise RuntimeError("PostgreSQL backend requested but psycopg is not installed.")
        raw = psycopg.connect(DATABASE_URL, row_factory=dict_row, autocommit=False)
        return PostgresCompatConnection(raw)

    DATA_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(DB_PATH), timeout=DB_BUSY_TIMEOUT_MS / 1000.0)
    conn.row_factory = sqlite3.Row
    conn.execute(f"PRAGMA busy_timeout = {DB_BUSY_TIMEOUT_MS}")
    conn.execute("PRAGMA foreign_keys = ON")
    conn.execute(f"PRAGMA cache_size = {-abs(DB_CACHE_SIZE_KB)}")
    if DB_TEMP_STORE_MEMORY:
        conn.execute("PRAGMA temp_store = MEMORY")

    safe_journal_mode = DB_JOURNAL_MODE if DB_JOURNAL_MODE in {"DELETE", "TRUNCATE", "PERSIST", "MEMORY", "WAL", "OFF"} else "WAL"
    safe_synchronous = DB_SYNCHRONOUS if DB_SYNCHRONOUS in {"OFF", "NORMAL", "FULL", "EXTRA"} else "NORMAL"
    conn.execute(f"PRAGMA journal_mode = {safe_journal_mode}")
    conn.execute(f"PRAGMA synchronous = {safe_synchronous}")
    if DB_MMAP_SIZE_BYTES > 0:
        conn.execute(f"PRAGMA mmap_size = {DB_MMAP_SIZE_BYTES}")
    return conn


class ThreadedWSGIServer(ThreadingMixIn, WSGIServer):
    """Thread-per-request WSGI server for small-team production deployments.

    Decision rationale:
    - `wsgiref.simple_server` is single-threaded by default, which can queue requests.
    - For low to moderate concurrency (e.g., 10-20 users), thread-per-request improves
      responsiveness while preserving zero external dependencies.
    """

    daemon_threads = True


def ensure_column(conn, table: str, column: str, ddl: str) -> None:
    existing = set()
    for row in conn.execute(f"PRAGMA table_info({table})").fetchall():
        try:
            existing.add((row["name"] or "").lower())
        except Exception:
            existing.add((row[1] or "").lower())
    if column.lower() in existing:
        return
    try:
        conn.execute(f"ALTER TABLE {table} ADD COLUMN {column} {ddl}")
    except Exception as exc:
        msg = str(exc).lower()
        if "duplicate column name" not in msg and "already exists" not in msg:
            raise


def run_schema_upgrades(conn: sqlite3.Connection) -> None:
    """Apply additive, idempotent schema upgrades.

    Decision rationale:
    - Keep migrations runtime-driven so deploys stay simple on low-cost hosts.
    - Restrict upgrades to additive changes (columns/tables/indexes) so old data survives.
    - Use IF NOT EXISTS / duplicate-column guards to make startup safe across environments.
    """
    ensure_column(conn, "users", "timezone", "TEXT")
    ensure_column(conn, "users", "title", "TEXT")

    ensure_column(conn, "projects", "team_id", "INTEGER")
    ensure_column(conn, "projects", "space_id", "INTEGER")
    ensure_column(conn, "projects", "progress_pct", "INTEGER DEFAULT 0")
    ensure_column(conn, "projects", "deleted_at", "TEXT")
    ensure_column(conn, "projects", "deleted_by_user_id", "INTEGER")

    ensure_column(conn, "tasks", "team_id", "INTEGER")
    ensure_column(conn, "tasks", "space_id", "INTEGER")
    ensure_column(conn, "tasks", "deleted_at", "TEXT")
    ensure_column(conn, "tasks", "deleted_by_user_id", "INTEGER")
    ensure_column(conn, "calendar_events", "external_event_id", "TEXT")
    ensure_column(conn, "calendar_events", "external_calendar_id", "TEXT")
    ensure_column(conn, "calendar_events", "html_link", "TEXT")
    ensure_column(conn, "intake_requests", "deleted_at", "TEXT")
    ensure_column(conn, "intake_requests", "deleted_by_user_id", "INTEGER")
    ensure_column(conn, "equipment_assets", "deleted_at", "TEXT")
    ensure_column(conn, "equipment_assets", "deleted_by_user_id", "INTEGER")
    ensure_column(conn, "consumables", "deleted_at", "TEXT")
    ensure_column(conn, "consumables", "deleted_by_user_id", "INTEGER")
    ensure_column(conn, "partnerships", "deleted_at", "TEXT")
    ensure_column(conn, "partnerships", "deleted_by_user_id", "INTEGER")
    ensure_column(conn, "onboarding_templates", "doc_url", "TEXT")

    conn.executescript(
        """
        CREATE TABLE IF NOT EXISTS spaces (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            location TEXT,
            description TEXT,
            created_by INTEGER,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
            UNIQUE (organization_id, name)
        );

        CREATE TABLE IF NOT EXISTS teams (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            focus_area TEXT,
            lead_user_id INTEGER,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (lead_user_id) REFERENCES users(id) ON DELETE SET NULL,
            UNIQUE (organization_id, name)
        );

        CREATE TABLE IF NOT EXISTS team_members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            team_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            role TEXT NOT NULL DEFAULT 'member',
            created_at TEXT NOT NULL,
            FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            UNIQUE (team_id, user_id)
        );

        CREATE TABLE IF NOT EXISTS calendar_sync_settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            calendar_id TEXT NOT NULL DEFAULT 'primary',
            lookback_days INTEGER NOT NULL DEFAULT 30,
            lookahead_days INTEGER NOT NULL DEFAULT 45,
            push_window_days INTEGER NOT NULL DEFAULT 30,
            last_pull_at TEXT,
            last_push_at TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            UNIQUE (organization_id, user_id),
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS calendar_sync_links (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            entity_type TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            calendar_id TEXT NOT NULL,
            event_id TEXT NOT NULL,
            sync_hash TEXT,
            last_synced_at TEXT NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE (organization_id, user_id, entity_type, entity_id, calendar_id),
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS meeting_note_sources (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            source_type TEXT NOT NULL,
            doc_url TEXT,
            body TEXT,
            linked_agenda_id INTEGER,
            created_by INTEGER,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (linked_agenda_id) REFERENCES meeting_agendas(id) ON DELETE SET NULL,
            FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS report_templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            config_json TEXT NOT NULL,
            is_shared INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS password_resets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            token_hash TEXT NOT NULL UNIQUE,
            expires_at TEXT NOT NULL,
            used_at TEXT,
            created_by INTEGER,
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS email_messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER,
            recipient_user_id INTEGER,
            recipient_email TEXT NOT NULL,
            subject TEXT NOT NULL,
            body TEXT NOT NULL,
            status TEXT NOT NULL,
            error_message TEXT,
            related_entity TEXT,
            related_id TEXT,
            created_at TEXT NOT NULL,
            sent_at TEXT,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE SET NULL,
            FOREIGN KEY (recipient_user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS role_nav_preferences (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            role TEXT NOT NULL,
            visible_json TEXT NOT NULL,
            updated_by INTEGER,
            updated_at TEXT NOT NULL,
            UNIQUE (organization_id, role),
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS item_comments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            entity TEXT NOT NULL,
            entity_id INTEGER NOT NULL,
            author_user_id INTEGER,
            body TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (author_user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS item_watchers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            entity TEXT NOT NULL,
            entity_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            created_by INTEGER,
            UNIQUE (organization_id, entity, entity_id, user_id),
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS consumables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            space_id INTEGER,
            name TEXT NOT NULL,
            category TEXT,
            quantity_on_hand REAL NOT NULL DEFAULT 0,
            unit TEXT,
            reorder_point REAL NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'In Stock',
            owner_user_id INTEGER,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (space_id) REFERENCES spaces(id) ON DELETE SET NULL,
            FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
        );
        """
    )
    conn.execute(
        """
        CREATE UNIQUE INDEX IF NOT EXISTS idx_calendar_events_google_external
        ON calendar_events (organization_id, source, external_calendar_id, external_event_id)
        """
    )
    conn.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_report_templates_scope
        ON report_templates (organization_id, is_shared, user_id, created_at)
        """
    )
    conn.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_item_comments_entity
        ON item_comments (organization_id, entity, entity_id, created_at)
        """
    )
    conn.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_item_watchers_entity
        ON item_watchers (organization_id, entity, entity_id, user_id)
        """
    )
    conn.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_tasks_deleted_at
        ON tasks (organization_id, deleted_at)
        """
    )
    conn.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_projects_deleted_at
        ON projects (organization_id, deleted_at)
        """
    )


def ensure_bootstrap() -> None:
    """Initialize database once per process.

    Decision rationale:
    - WSGI apps may process concurrent requests; this lock prevents duplicate init work.
    - Bootstrapping is intentionally lazy to keep local setup friction low.
    """
    global BOOTSTRAPPED, BOOTSTRAP_ERROR
    if BOOTSTRAPPED:
        return
    with BOOTSTRAP_LOCK:
        if BOOTSTRAPPED:
            return
        try:
            init_db()
            BOOTSTRAPPED = True
            BOOTSTRAP_ERROR = ""
        except Exception as exc:
            BOOTSTRAP_ERROR = str(exc)
            traceback.print_exc()
            raise


def init_db() -> None:
    """Create baseline schema and seed data for first run.

    This function is safe to call repeatedly because table creation and seed inserts are
    guarded by uniqueness checks and upgrade routines.
    """
    conn = db_connect()
    conn.executescript(
        """
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1,
            is_superuser INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS organizations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            slug TEXT NOT NULL UNIQUE,
            created_at TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS memberships (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            organization_id INTEGER NOT NULL,
            role TEXT NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE (user_id, organization_id),
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            token_hash TEXT NOT NULL UNIQUE,
            csrf_token TEXT NOT NULL,
            expires_at TEXT NOT NULL,
            created_at TEXT NOT NULL,
            last_seen_at TEXT,
            ip_address TEXT,
            user_agent TEXT,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            lane TEXT NOT NULL,
            status TEXT NOT NULL,
            priority TEXT NOT NULL,
            owner_user_id INTEGER,
            start_date TEXT,
            due_date TEXT,
            tags TEXT,
            meta_json TEXT,
            created_by INTEGER,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL,
            FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            project_id INTEGER,
            title TEXT NOT NULL,
            description TEXT,
            status TEXT NOT NULL,
            priority TEXT NOT NULL,
            assignee_user_id INTEGER,
            reporter_user_id INTEGER,
            due_date TEXT,
            planned_week TEXT,
            energy TEXT,
            estimate_hours REAL,
            meta_json TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL,
            FOREIGN KEY (assignee_user_id) REFERENCES users(id) ON DELETE SET NULL,
            FOREIGN KEY (reporter_user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS meeting_agendas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            meeting_date TEXT NOT NULL,
            owner_user_id INTEGER,
            notes TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS meeting_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            agenda_id INTEGER NOT NULL,
            section TEXT NOT NULL,
            title TEXT NOT NULL,
            owner_user_id INTEGER,
            status TEXT NOT NULL,
            minutes_estimate INTEGER DEFAULT 5,
            sort_order INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            FOREIGN KEY (agenda_id) REFERENCES meeting_agendas(id) ON DELETE CASCADE,
            FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS calendar_events (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            user_id INTEGER,
            source TEXT NOT NULL,
            title TEXT NOT NULL,
            start_at TEXT NOT NULL,
            end_at TEXT NOT NULL,
            attendees_count INTEGER,
            location TEXT,
            description TEXT,
            category TEXT NOT NULL,
            energy_score INTEGER,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS custom_views (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            entity TEXT NOT NULL,
            filters_json TEXT,
            columns_json TEXT,
            is_shared INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS field_configs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            entity TEXT NOT NULL,
            field_key TEXT NOT NULL,
            label TEXT NOT NULL,
            field_type TEXT NOT NULL,
            is_required INTEGER NOT NULL DEFAULT 0,
            is_enabled INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL,
            UNIQUE (organization_id, entity, field_key),
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS onboarding_templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            role_target TEXT,
            task_title TEXT NOT NULL,
            details TEXT,
            sequence INTEGER NOT NULL,
            due_offset_days INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS onboarding_assignments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            template_id INTEGER NOT NULL,
            assignee_user_id INTEGER NOT NULL,
            status TEXT NOT NULL,
            due_date TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            completed_at TEXT,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (template_id) REFERENCES onboarding_templates(id) ON DELETE CASCADE,
            FOREIGN KEY (assignee_user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS intake_requests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            requestor_name TEXT,
            requestor_email TEXT,
            lane TEXT NOT NULL,
            urgency INTEGER NOT NULL,
            impact INTEGER NOT NULL,
            effort INTEGER NOT NULL,
            score REAL NOT NULL,
            status TEXT NOT NULL,
            owner_user_id INTEGER,
            details TEXT,
            meta_json TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS equipment_assets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            space TEXT NOT NULL,
            asset_type TEXT,
            last_maintenance TEXT,
            next_maintenance TEXT,
            cert_required INTEGER NOT NULL DEFAULT 0,
            cert_name TEXT,
            status TEXT NOT NULL,
            owner_user_id INTEGER,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS spaces (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            location TEXT,
            description TEXT,
            created_by INTEGER,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
            UNIQUE (organization_id, name)
        );

        CREATE TABLE IF NOT EXISTS teams (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            focus_area TEXT,
            lead_user_id INTEGER,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (lead_user_id) REFERENCES users(id) ON DELETE SET NULL,
            UNIQUE (organization_id, name)
        );

        CREATE TABLE IF NOT EXISTS team_members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            team_id INTEGER NOT NULL,
            user_id INTEGER NOT NULL,
            role TEXT NOT NULL DEFAULT 'member',
            created_at TEXT NOT NULL,
            FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            UNIQUE (team_id, user_id)
        );

        CREATE TABLE IF NOT EXISTS consumables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            space_id INTEGER,
            name TEXT NOT NULL,
            category TEXT,
            quantity_on_hand REAL NOT NULL DEFAULT 0,
            unit TEXT,
            reorder_point REAL,
            status TEXT NOT NULL DEFAULT 'In Stock',
            owner_user_id INTEGER,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (space_id) REFERENCES spaces(id) ON DELETE SET NULL,
            FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS partnerships (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            partner_name TEXT NOT NULL,
            school TEXT,
            stage TEXT NOT NULL,
            last_contact TEXT,
            next_followup TEXT,
            owner_user_id INTEGER,
            health TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
            FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
        );

        CREATE TABLE IF NOT EXISTS user_preferences (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL UNIQUE,
            preferences_json TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS insight_snapshots (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER NOT NULL,
            key TEXT NOT NULL,
            payload_json TEXT NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE (organization_id, key),
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE
        );

        CREATE TABLE IF NOT EXISTS audit_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            organization_id INTEGER,
            user_id INTEGER,
            action TEXT NOT NULL,
            entity TEXT,
            entity_id TEXT,
            details TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE SET NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
        );
        """
    )
    run_schema_upgrades(conn)
    seed_defaults(conn)
    conn.commit()
    conn.close()


def ensure_default_view_templates(conn: sqlite3.Connection, org_id: int, owner_user_id: int) -> None:
    for template in VIEW_TEMPLATE_LIBRARY:
        name = str(template.get("name", "Untitled Template")).strip()
        entity = str(template.get("entity", "tasks")).strip()
        exists = conn.execute(
            """
            SELECT id
            FROM custom_views
            WHERE organization_id = ? AND LOWER(name) = LOWER(?) AND entity = ?
            LIMIT 1
            """,
            (org_id, name, entity),
        ).fetchone()
        if exists:
            continue
        conn.execute(
            """
            INSERT INTO custom_views
            (organization_id, user_id, name, entity, filters_json, columns_json, is_shared, created_at)
            VALUES (?, ?, ?, ?, ?, ?, 1, ?)
            """,
            (
                org_id,
                owner_user_id,
                name,
                entity,
                json.dumps(template.get("filters", {})),
                json.dumps(template.get("columns", [])),
                iso(),
            ),
        )


def report_template_by_key(key: str) -> Optional[Dict[str, object]]:
    for template in REPORT_TEMPLATE_LIBRARY:
        if str(template.get("key", "")) == key:
            return template
    return None


def report_metric_by_key(key: str) -> Optional[Dict[str, object]]:
    for metric in REPORT_METRIC_LIBRARY:
        if str(metric.get("key", "")) == key:
            return metric
    return None


def sanitize_report_widgets(raw_widgets: object) -> List[Dict[str, str]]:
    out: List[Dict[str, str]] = []
    if not isinstance(raw_widgets, list):
        return out
    for item in raw_widgets[:18]:
        if not isinstance(item, dict):
            continue
        metric = str(item.get("metric") or "").strip()
        metric_meta = report_metric_by_key(metric)
        if not metric_meta:
            continue
        supported = [str(v) for v in metric_meta.get("supported_charts", REPORT_CHART_TYPES)]
        chart = str(item.get("chart") or metric_meta.get("default_chart") or "bar").strip().lower()
        if chart not in supported:
            chart = str(metric_meta.get("default_chart") or supported[0] if supported else "bar")
        if chart not in REPORT_CHART_TYPES:
            chart = "bar"
        window = str(item.get("window") or "all").strip().lower()
        if window not in {"all", "12m", "6m"}:
            window = "all"
        title = str(item.get("title") or metric_meta.get("name") or "Chart").strip()
        title = title[:120] if title else str(metric_meta.get("name") or "Chart")
        out.append(
            {
                "title": title,
                "metric": metric,
                "chart": chart,
                "window": window,
            }
        )
    return out


def report_config_from_payload(payload: object) -> Dict[str, object]:
    if isinstance(payload, dict):
        widgets = sanitize_report_widgets(payload.get("widgets"))
        if widgets:
            return {"widgets": widgets}
    return {"widgets": []}


def report_config_json(config: Dict[str, object]) -> str:
    widgets = sanitize_report_widgets(config.get("widgets"))
    return json.dumps({"widgets": widgets})


def most_used_report_widgets(conn: sqlite3.Connection, org_id: int, limit: int = 6) -> List[Dict[str, str]]:
    """Return most frequently used widgets from saved report templates.

    Falls back to the Operations Pulse template when no saved reports exist.
    """

    counter: Dict[str, int] = {}
    exemplar: Dict[str, Dict[str, str]] = {}
    rows = conn.execute(
        "SELECT config_json FROM report_templates WHERE organization_id = ?",
        (org_id,),
    ).fetchall()
    for row in rows:
        parsed = parse_view_filters(row["config_json"])
        widgets = sanitize_report_widgets(report_config_from_payload(parsed).get("widgets"))
        for widget in widgets:
            key = f"{widget['metric']}|{widget['chart']}|{widget['window']}"
            counter[key] = counter.get(key, 0) + 1
            exemplar.setdefault(key, widget)
    if counter:
        ordered = sorted(counter.items(), key=lambda item: (-item[1], item[0]))
        return [exemplar[key] for key, _count in ordered[: max(1, limit)]]
    fallback_tpl = report_template_by_key("operations_pulse") or REPORT_TEMPLATE_LIBRARY[0]
    return sanitize_report_widgets(fallback_tpl.get("widgets"))[: max(1, limit)]


def report_editor_config(
    conn: sqlite3.Connection,
    org_id: int,
    selected_widgets: List[Dict[str, str]],
    selected_name: str,
    selected_description: str,
    selected_space_id: Optional[int] = None,
) -> Dict[str, object]:
    return {
        "metric_library": [
            {
                "key": str(metric["key"]),
                "name": str(metric["name"]),
                "description": str(metric.get("description") or ""),
                "default_chart": str(metric.get("default_chart") or "bar"),
                "supported_charts": [str(v) for v in metric.get("supported_charts", REPORT_CHART_TYPES)],
            }
            for metric in REPORT_METRIC_LIBRARY
        ],
        "chart_types": REPORT_CHART_TYPES,
        "templates": [
            {
                "key": str(template["key"]),
                "name": str(template["name"]),
                "description": str(template.get("description") or ""),
                "widgets": sanitize_report_widgets(template.get("widgets")),
            }
            for template in REPORT_TEMPLATE_LIBRARY
        ],
        "selected_template": {
            "key": "dashboard_top_charts",
            "name": selected_name,
            "description": selected_description,
            "widgets": sanitize_report_widgets(selected_widgets),
        },
        "data_map": report_metric_payloads(conn, org_id, selected_space_id=selected_space_id),
    }


def ensure_default_report_templates(conn: sqlite3.Connection, org_id: int, owner_user_id: int) -> None:
    for template in REPORT_TEMPLATE_LIBRARY:
        name = str(template.get("name", "Untitled Report")).strip()
        exists = conn.execute(
            """
            SELECT id
            FROM report_templates
            WHERE organization_id = ? AND LOWER(name) = LOWER(?)
            LIMIT 1
            """,
            (org_id, name),
        ).fetchone()
        if exists:
            continue
        config = report_config_from_payload({"widgets": template.get("widgets", [])})
        conn.execute(
            """
            INSERT INTO report_templates
            (organization_id, user_id, name, description, config_json, is_shared, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, 1, ?, ?)
            """,
            (
                org_id,
                owner_user_id,
                name,
                str(template.get("description") or ""),
                report_config_json(config),
                iso(),
                iso(),
            ),
        )


def seed_defaults(conn: sqlite3.Connection) -> None:
    # Release-safe bootstrap: create only generic defaults, no sample operational data.
    raw_slug = os.environ.get("MAKERSPACE_DEFAULT_ORG_SLUG", "default").strip().lower()
    org_slug = re.sub(r"[^a-z0-9-]", "-", raw_slug)
    org_slug = re.sub(r"-+", "-", org_slug).strip("-") or "default"
    org_name = os.environ.get("MAKERSPACE_DEFAULT_ORG_NAME", "Default Workspace").strip() or "Default Workspace"

    row = conn.execute("SELECT id FROM organizations WHERE slug = ?", (org_slug,)).fetchone()
    if row:
        org_id = int(row["id"])
    else:
        conn.execute(
            "INSERT INTO organizations (name, slug, created_at) VALUES (?, ?, ?)",
            (org_name, org_slug, iso()),
        )
        org_id = int(conn.execute("SELECT id FROM organizations WHERE slug = ?", (org_slug,)).fetchone()["id"])

    admin_email = os.environ.get("MAKERSPACE_ADMIN_EMAIL", "admin@makerflow.local").lower().strip()
    admin_password = os.environ.get("MAKERSPACE_ADMIN_PASSWORD", "ChangeMeMeow!2026")
    admin_name = os.environ.get("MAKERSPACE_ADMIN_NAME", "MakerFlow Admin")

    admin = conn.execute("SELECT id FROM users WHERE email = ?", (admin_email,)).fetchone()
    if not admin:
        pw_hash, pw_salt = hash_password(admin_password)
        conn.execute(
            """
            INSERT INTO users
            (email, name, password_hash, password_salt, is_active, is_superuser, timezone, created_at)
            VALUES (?, ?, ?, ?, 1, 1, ?, ?)
            """,
            (admin_email, admin_name, pw_hash, pw_salt, "UTC", iso()),
        )
        admin_id = int(conn.execute("SELECT id FROM users WHERE email = ?", (admin_email,)).fetchone()["id"])
    else:
        admin_id = int(admin["id"])
        conn.execute(
            """
            UPDATE users
            SET is_active = 1,
                is_superuser = 1,
                name = COALESCE(NULLIF(name, ''), ?),
                timezone = COALESCE(NULLIF(timezone, ''), 'UTC')
            WHERE id = ?
            """,
            (admin_name, admin_id),
        )

    if not conn.execute(
        "SELECT id FROM memberships WHERE user_id = ? AND organization_id = ?",
        (admin_id, org_id),
    ).fetchone():
        conn.execute(
            "INSERT INTO memberships (user_id, organization_id, role, created_at) VALUES (?, ?, ?, ?)",
            (admin_id, org_id, "owner", iso()),
        )

    # Keep one default team/space so a new install is immediately usable without seeded work items.
    if conn.execute("SELECT COUNT(*) AS c FROM spaces WHERE organization_id = ?", (org_id,)).fetchone()["c"] == 0:
        conn.execute(
            """
            INSERT INTO spaces (organization_id, name, location, description, created_by, created_at)
            VALUES (?, ?, ?, ?, ?, ?)
            """,
            (org_id, "Main Space", "", "Primary makerspace or lab location.", admin_id, iso()),
        )

    if conn.execute("SELECT COUNT(*) AS c FROM teams WHERE organization_id = ?", (org_id,)).fetchone()["c"] == 0:
        conn.execute(
            """
            INSERT INTO teams (organization_id, name, focus_area, lead_user_id, created_at)
            VALUES (?, ?, ?, ?, ?)
            """,
            (org_id, "Operations Team", "Core delivery and operational support", admin_id, iso()),
        )

    team_row = conn.execute(
        "SELECT id FROM teams WHERE organization_id = ? ORDER BY id LIMIT 1",
        (org_id,),
    ).fetchone()
    if team_row and not conn.execute(
        "SELECT id FROM team_members WHERE team_id = ? AND user_id = ?",
        (int(team_row["id"]), admin_id),
    ).fetchone():
        conn.execute(
            "INSERT INTO team_members (team_id, user_id, role, created_at) VALUES (?, ?, ?, ?)",
            (int(team_row["id"]), admin_id, "lead", iso()),
        )

    ensure_default_view_templates(conn, org_id, admin_id)
    ensure_default_report_templates(conn, org_id, admin_id)

    # Baseline field configuration metadata (no seeded projects/tasks).
    if conn.execute("SELECT COUNT(*) AS c FROM field_configs WHERE organization_id = ?", (org_id,)).fetchone()["c"] == 0:
        defaults = [
            ("projects", "impact_goal", "Impact Goal", "text", 0),
            ("projects", "school_target", "Target School", "text", 0),
            ("tasks", "energy_level", "Energy Level", "select", 0),
            ("tasks", "delivery_mode", "Delivery Mode", "select", 0),
            ("intake", "stakeholder_type", "Stakeholder Type", "select", 0),
        ]
        for entity, key, label, field_type, required in defaults:
            conn.execute(
                """
                INSERT INTO field_configs
                (organization_id, entity, field_key, label, field_type, is_required, is_enabled, created_at)
                VALUES (?, ?, ?, ?, ?, ?, 1, ?)
                """,
                (org_id, entity, key, label, field_type, required, iso()),
            )


def maybe_load_snapshot(conn: sqlite3.Connection, org_id: int, key: str, path: Path) -> None:
    if conn.execute(
        "SELECT id FROM insight_snapshots WHERE organization_id = ? AND key = ?", (org_id, key)
    ).fetchone():
        return
    if not path.exists():
        return
    try:
        payload = json.loads(path.read_text())
    except Exception:
        return
    conn.execute(
        "INSERT INTO insight_snapshots (organization_id, key, payload_json, created_at) VALUES (?, ?, ?, ?)",
        (org_id, key, json.dumps(payload), iso()),
    )


def log_action(
    conn: sqlite3.Connection,
    organization_id: Optional[int],
    user_id: Optional[int],
    action: str,
    entity: Optional[str] = None,
    entity_id: Optional[str] = None,
    details: Optional[str] = None,
) -> None:
    conn.execute(
        "INSERT INTO audit_log (organization_id, user_id, action, entity, entity_id, details, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
        (organization_id, user_id, action, entity, entity_id, details, iso()),
    )


AUDIT_ROLLBACK_TABLES = {
    "tasks",
    "projects",
    "intake_requests",
    "equipment_assets",
    "consumables",
    "partnerships",
    "meeting_agendas",
    "meeting_items",
    "teams",
    "spaces",
    "role_nav_preferences",
    "field_configs",
}


def _snapshot_value(value: object) -> object:
    if isinstance(value, (dt.datetime, dt.date)):
        return value.isoformat()
    return value


def snapshot_row(row: Optional[sqlite3.Row]) -> Optional[Dict[str, object]]:
    if row is None:
        return None
    return {key: _snapshot_value(row[key]) for key in row.keys()}


def parse_audit_details(details: Optional[str]) -> Dict[str, object]:
    raw = str(details or "").strip()
    if not raw:
        return {}
    try:
        parsed = json.loads(raw)
    except Exception:
        return {}
    return parsed if isinstance(parsed, dict) else {}


def audit_details_summary(details: Optional[str], limit: int = 180) -> str:
    parsed = parse_audit_details(details)
    if parsed:
        summary = str(parsed.get("summary") or "").strip()
        if summary:
            return summary[:limit]
        source = str(parsed.get("source") or "").strip()
        if source:
            payload = parsed.get("payload")
            if isinstance(payload, dict):
                keys = ", ".join(sorted(payload.keys())[:4])
                return f"{source}: {keys}"[:limit]
            return source[:limit]
    return str(details or "")[:limit]


def log_change_with_rollback(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    action: str,
    table: str,
    entity_id: object,
    before: Optional[Dict[str, object]],
    after: Optional[Dict[str, object]],
    summary: str,
    source: str = "api",
) -> None:
    payload: Dict[str, object] = {
        "source": source,
        "summary": summary[:220],
        "before": before,
        "after": after,
    }
    if table in AUDIT_ROLLBACK_TABLES:
        payload["rollback"] = {
            "table": table,
            "entity_id": str(entity_id),
            "before": before,
        }
    log_action(
        conn,
        org_id,
        user_id,
        action,
        table,
        str(entity_id),
        json.dumps(payload, ensure_ascii=True)[:14000],
    )


def table_columns(conn: sqlite3.Connection, table: str) -> List[str]:
    return [str(row["name"]) for row in conn.execute(f"PRAGMA table_info({table})").fetchall()]


def rollback_audit_entry(conn: sqlite3.Connection, org_id: int, actor_user_id: int, audit_id: int) -> Tuple[bool, str]:
    row = conn.execute(
        "SELECT id, action, entity, entity_id, details FROM audit_log WHERE id = ? AND organization_id = ?",
        (audit_id, org_id),
    ).fetchone()
    if not row:
        return False, "Audit entry not found"
    details = parse_audit_details(row["details"])
    rollback = details.get("rollback")
    if not isinstance(rollback, dict):
        return False, "This audit entry cannot be rolled back"
    table = str(rollback.get("table") or row["entity"] or "").strip()
    if table not in AUDIT_ROLLBACK_TABLES:
        return False, "Rollback table is not allowed"
    entity_id = to_int(str(rollback.get("entity_id") or row["entity_id"] or ""))
    if entity_id is None:
        return False, "Rollback target id is invalid"
    before = rollback.get("before")
    if before is not None and not isinstance(before, dict):
        return False, "Rollback snapshot is invalid"

    columns = set(table_columns(conn, table))
    if "id" not in columns or "organization_id" not in columns:
        return False, "Rollback target table is unsupported"
    existing = conn.execute(
        f"SELECT * FROM {table} WHERE id = ? AND organization_id = ?",
        (entity_id, org_id),
    ).fetchone()

    # Create rollback (before snapshot missing): soft-delete or hard-delete target row.
    if before is None:
        if not existing:
            return False, "Target row no longer exists"
        if "deleted_at" in columns:
            assignments = ["deleted_at = ?"]
            params: List[object] = [iso()]
            if "deleted_by_user_id" in columns:
                assignments.append("deleted_by_user_id = ?")
                params.append(actor_user_id)
            if "updated_at" in columns:
                assignments.append("updated_at = ?")
                params.append(iso())
            params.extend([entity_id, org_id])
            conn.execute(
                f"UPDATE {table} SET {', '.join(assignments)} WHERE id = ? AND organization_id = ?",
                tuple(params),
            )
        else:
            conn.execute(f"DELETE FROM {table} WHERE id = ? AND organization_id = ?", (entity_id, org_id))
        log_action(
            conn,
            org_id,
            actor_user_id,
            "audit_rollback_applied",
            table,
            str(entity_id),
            f"Reverted create from audit #{audit_id}",
        )
        return True, "Rollback applied"

    # Update rollback: restore "before" snapshot into the current row (or recreate if missing).
    restore_values = {k: before[k] for k in before.keys() if k in columns and k not in {"id"}}
    restore_values["organization_id"] = org_id
    if "updated_at" in columns:
        restore_values["updated_at"] = iso()

    if existing:
        if not restore_values:
            return False, "No restorable fields on this entry"
        assignments = [f"{k} = ?" for k in restore_values.keys()]
        params = list(restore_values.values()) + [entity_id, org_id]
        conn.execute(
            f"UPDATE {table} SET {', '.join(assignments)} WHERE id = ? AND organization_id = ?",
            tuple(params),
        )
    else:
        restore_values["id"] = entity_id
        insert_cols = [k for k in restore_values.keys() if k in columns]
        insert_vals = [restore_values[k] for k in insert_cols]
        placeholders = ", ".join(["?"] * len(insert_cols))
        conn.execute(
            f"INSERT INTO {table} ({', '.join(insert_cols)}) VALUES ({placeholders})",
            tuple(insert_vals),
        )

    log_action(
        conn,
        org_id,
        actor_user_id,
        "audit_rollback_applied",
        table,
        str(entity_id),
        f"Restored snapshot from audit #{audit_id}",
    )
    return True, "Rollback applied"


def smtp_is_configured() -> bool:
    return bool(SMTP_HOST and SMTP_FROM)


def send_email(subject: str, body: str, to_email: str) -> Tuple[bool, str]:
    if not smtp_is_configured():
        return False, "SMTP not configured"

    msg = EmailMessage()
    msg["Subject"] = subject
    msg["From"] = SMTP_FROM
    msg["To"] = to_email
    msg.set_content(body)

    try:
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=10) as smtp:
            if SMTP_USE_TLS:
                smtp.starttls()
            if SMTP_USER:
                smtp.login(SMTP_USER, SMTP_PASSWORD)
            smtp.send_message(msg)
        return True, ""
    except Exception as exc:
        return False, str(exc)[:400]


def queue_and_send_email(
    conn: sqlite3.Connection,
    organization_id: int,
    recipient_user_id: Optional[int],
    recipient_email: str,
    subject: str,
    body: str,
    related_entity: str,
    related_id: str,
) -> None:
    now = iso()
    status = "queued"
    sent_at = None
    error_message = ""
    ok, error = send_email(subject, body, recipient_email)
    if ok:
        status = "sent"
        sent_at = now
    else:
        status = "failed"
        error_message = error

    conn.execute(
        """
        INSERT INTO email_messages
        (organization_id, recipient_user_id, recipient_email, subject, body, status, error_message, related_entity, related_id, created_at, sent_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            organization_id,
            recipient_user_id,
            recipient_email,
            subject,
            body,
            status,
            error_message,
            related_entity,
            related_id,
            now,
            sent_at,
        ),
    )


def user_email_pref_enabled(conn: sqlite3.Connection, user_id: int, pref_key: str, default: bool = True) -> bool:
    row = conn.execute("SELECT preferences_json FROM user_preferences WHERE user_id = ?", (user_id,)).fetchone()
    if not row:
        return default
    try:
        prefs = json.loads(row["preferences_json"])
    except Exception:
        return default
    if not isinstance(prefs, dict):
        return default
    value = prefs.get(pref_key)
    if isinstance(value, bool):
        return value
    return default


def enqueue_email_if_opted(
    conn: sqlite3.Connection,
    organization_id: int,
    recipient_user_id: Optional[int],
    recipient_email: str,
    subject: str,
    body: str,
    related_entity: str,
    related_id: str,
    preference_key: str,
) -> None:
    if recipient_user_id and not user_email_pref_enabled(conn, int(recipient_user_id), preference_key, default=True):
        return
    queue_and_send_email(
        conn=conn,
        organization_id=organization_id,
        recipient_user_id=recipient_user_id,
        recipient_email=recipient_email,
        subject=subject,
        body=body,
        related_entity=related_entity,
        related_id=related_id,
    )


MENTION_TOKEN_RE = re.compile(r"@([A-Za-z0-9_.+\-@]+)")


def normalize_mention_token(value: str) -> str:
    return re.sub(r"[^a-z0-9]", "", str(value or "").lower())


def resolve_mentioned_users(conn: sqlite3.Connection, org_id: int, text: str) -> List[sqlite3.Row]:
    if not text:
        return []
    tokens = {str(match.group(1) or "").strip().lower() for match in MENTION_TOKEN_RE.finditer(text)}
    if not tokens:
        return []
    users = conn.execute(
        """
        SELECT u.id, u.name, u.email
        FROM users u
        JOIN memberships m ON m.user_id = u.id
        WHERE m.organization_id = ? AND u.is_active = 1
        """,
        (org_id,),
    ).fetchall()
    matched: List[sqlite3.Row] = []
    for user in users:
        email = str(user["email"] or "").strip().lower()
        local = email.split("@", 1)[0] if "@" in email else email
        name_key = normalize_mention_token(str(user["name"] or ""))
        aliases = {email, local, name_key}
        aliases.update({normalize_mention_token(alias) for alias in aliases})
        if any(token in aliases or normalize_mention_token(token) in aliases for token in tokens):
            matched.append(user)
    return matched


def upsert_item_watcher(
    conn: sqlite3.Connection,
    org_id: int,
    entity: str,
    entity_id: int,
    user_id: Optional[int],
    actor_user_id: Optional[int] = None,
) -> None:
    uid = to_int(user_id)
    if uid is None:
        return
    conn.execute(
        """
        INSERT OR IGNORE INTO item_watchers
        (organization_id, entity, entity_id, user_id, created_at, created_by)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (org_id, str(entity), int(entity_id), int(uid), iso(), actor_user_id),
    )


def watcher_users_for_item(conn: sqlite3.Connection, org_id: int, entity: str, entity_id: int) -> List[sqlite3.Row]:
    return conn.execute(
        """
        SELECT u.id, u.name, u.email
        FROM item_watchers w
        JOIN users u ON u.id = w.user_id
        WHERE w.organization_id = ? AND w.entity = ? AND w.entity_id = ? AND u.is_active = 1
        ORDER BY u.name
        """,
        (org_id, str(entity), int(entity_id)),
    ).fetchall()


def notify_entity_watchers(
    conn: sqlite3.Connection,
    org_id: int,
    entity: str,
    entity_id: int,
    actor_user_id: int,
    actor_name: str,
    actor_email: str,
    title: str,
    summary: str,
    skip_user_ids: Optional[Iterable[int]] = None,
    preference_key: Optional[str] = None,
) -> None:
    entity_key = str(entity or "").strip().lower()
    pref_key = preference_key or ("email_task_updates" if entity_key == "task" else "email_project_updates")
    skip: set[int] = set()
    for raw in (skip_user_ids or []):
        parsed = to_int(raw)
        if parsed is not None:
            skip.add(int(parsed))
    skip.add(int(actor_user_id))
    rows = watcher_users_for_item(conn, org_id, entity_key, entity_id)
    for row in rows:
        uid = int(row["id"])
        if uid in skip:
            continue
        subject = f"[MakerFlow] {entity_key.title()} update: {title}"
        body = (
            f"Hello {row['name']},\n\n"
            f"{summary}\n\n"
            f"{entity_key.title()}: {title}\n"
            f"Updated by: {actor_name} ({actor_email})\n\n"
            f"Open MakerFlow: /{entity_key}s\n"
        )
        enqueue_email_if_opted(
            conn=conn,
            organization_id=org_id,
            recipient_user_id=uid,
            recipient_email=str(row["email"] or ""),
            subject=subject,
            body=body,
            related_entity=f"{entity_key}s",
            related_id=str(entity_id),
            preference_key=pref_key,
        )


def entity_title_and_watch_users(
    conn: sqlite3.Connection,
    org_id: int,
    entity: str,
    entity_id: int,
) -> Tuple[Optional[str], List[int]]:
    entity_key = str(entity or "").strip().lower()
    if entity_key == "task":
        row = conn.execute(
            """
            SELECT title, assignee_user_id, reporter_user_id
            FROM tasks
            WHERE id = ? AND organization_id = ? AND deleted_at IS NULL
            """,
            (entity_id, org_id),
        ).fetchone()
        if not row:
            return None, []
        users = [to_int(row["assignee_user_id"]), to_int(row["reporter_user_id"])]
        watcher_ids = [int(uid) for uid in users if uid is not None]
        return str(row["title"] or f"Task #{entity_id}"), watcher_ids
    if entity_key == "project":
        row = conn.execute(
            """
            SELECT name, owner_user_id
            FROM projects
            WHERE id = ? AND organization_id = ? AND deleted_at IS NULL
            """,
            (entity_id, org_id),
        ).fetchone()
        if not row:
            return None, []
        owner_id = to_int(row["owner_user_id"])
        watcher_ids = [int(owner_id)] if owner_id is not None else []
        return str(row["name"] or f"Project #{entity_id}"), watcher_ids
    return None, []


def ensure_item_watchers_seeded(
    conn: sqlite3.Connection,
    org_id: int,
    entity: str,
    entity_id: int,
    actor_user_id: int,
) -> Optional[str]:
    title, watcher_user_ids = entity_title_and_watch_users(conn, org_id, entity, entity_id)
    if title is None:
        return None
    entity_key = str(entity or "").strip().lower()
    upsert_item_watcher(conn, org_id, entity_key, entity_id, actor_user_id, actor_user_id=actor_user_id)
    for watcher_id in watcher_user_ids:
        upsert_item_watcher(conn, org_id, entity_key, entity_id, watcher_id, actor_user_id=actor_user_id)
    return title


def notify_comment_mentions_and_watchers(
    conn: sqlite3.Connection,
    org_id: int,
    entity: str,
    item_id: int,
    actor_user_id: int,
    actor_name: str,
    actor_email: str,
    comment_body: str,
) -> None:
    entity_key = str(entity or "").strip().lower()
    if entity_key not in {"task", "project"}:
        return
    title = ensure_item_watchers_seeded(conn, org_id, entity_key, item_id, actor_user_id)
    if title is None:
        return

    mentioned = resolve_mentioned_users(conn, org_id, comment_body)
    mentioned_ids: set[int] = set()
    for user in mentioned:
        uid = int(user["id"])
        if uid == int(actor_user_id):
            continue
        mentioned_ids.add(uid)
        upsert_item_watcher(conn, org_id, entity_key, item_id, uid, actor_user_id=actor_user_id)
        subject = f"[MakerFlow] Mentioned on {entity_key}: {title}"
        body = (
            f"Hello {user['name']},\n\n"
            f"{actor_name} mentioned you in a comment.\n\n"
            f"{entity_key.title()}: {title}\n"
            f"Comment:\n{comment_body[:1500]}\n\n"
            f"Open MakerFlow: /{entity_key}s\n"
        )
        enqueue_email_if_opted(
            conn=conn,
            organization_id=org_id,
            recipient_user_id=uid,
            recipient_email=str(user["email"] or ""),
            subject=subject,
            body=body,
            related_entity=f"{entity_key}s",
            related_id=str(item_id),
            preference_key="email_mentions",
        )

    notify_entity_watchers(
        conn=conn,
        org_id=org_id,
        entity=entity_key,
        entity_id=item_id,
        actor_user_id=actor_user_id,
        actor_name=actor_name,
        actor_email=actor_email,
        title=title,
        summary=f"New comment added on this {entity_key}.",
        skip_user_ids=mentioned_ids,
        preference_key="email_comments",
    )


def notify_task_assignment(
    conn: sqlite3.Connection,
    org_id: int,
    task_id: int,
    actor_name: str,
    actor_email: str,
    task_title: str,
    task_status: str,
    assignee_id: Optional[int],
) -> None:
    if not assignee_id:
        return
    recipient = conn.execute("SELECT id, email, name FROM users WHERE id = ?", (assignee_id,)).fetchone()
    if not recipient:
        return
    subject = f"[MakerFlow] Task update: {task_title}"
    body = (
        f"Hello {recipient['name']},\n\n"
        f"A task was assigned or updated for you.\n\n"
        f"Task: {task_title}\n"
        f"Status: {task_status}\n"
        f"Updated by: {actor_name} ({actor_email})\n\n"
        f"Open MakerFlow: /tasks\n"
    )
    enqueue_email_if_opted(
        conn=conn,
        organization_id=org_id,
        recipient_user_id=recipient["id"],
        recipient_email=recipient["email"],
        subject=subject,
        body=body,
        related_entity="tasks",
        related_id=str(task_id),
        preference_key="email_task_updates",
    )


def intake_score(urgency: int, impact: int, effort: int) -> float:
    return round((impact * 2.0 + urgency * 1.5) - (effort * 0.8), 2)


def ensure_operations_project(conn: sqlite3.Connection, org_id: int, actor_user_id: int) -> int:
    row = conn.execute(
        """
        SELECT id
        FROM projects
        WHERE organization_id = ? AND deleted_at IS NULL AND LOWER(name) = LOWER(?)
        ORDER BY id
        LIMIT 1
        """,
        (org_id, "Lab Maintenance"),
    ).fetchone()
    if row:
        return int(row["id"])
    now = iso()
    cursor = conn.execute(
        """
        INSERT INTO projects
        (organization_id, name, description, lane, status, priority, owner_user_id, start_date, due_date, tags, meta_json, created_by, created_at, updated_at, team_id, space_id, progress_pct)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            org_id,
            "Lab Maintenance",
            "Evergreen operations project for recurring makerspace maintenance tasks.",
            "Core Operations",
            "Active",
            "Medium",
            actor_user_id,
            dt.date.today().isoformat(),
            None,
            "operations,evergreen",
            "{}",
            actor_user_id,
            now,
            now,
            None,
            None,
            0,
        ),
    )
    return int(cursor.lastrowid)


def default_space_id_for_org(
    conn: sqlite3.Connection,
    org_id: int,
    preferred_space_id: Optional[int] = None,
) -> Optional[int]:
    if preferred_space_id is not None:
        row = conn.execute(
            "SELECT id FROM spaces WHERE id = ? AND organization_id = ?",
            (preferred_space_id, org_id),
        ).fetchone()
        if row:
            return int(row["id"])
    fallback = conn.execute(
        "SELECT id FROM spaces WHERE organization_id = ? ORDER BY id LIMIT 1",
        (org_id,),
    ).fetchone()
    if fallback:
        return int(fallback["id"])
    return None


def resolve_task_project_and_space(
    conn: sqlite3.Connection,
    org_id: int,
    actor_user_id: int,
    project_candidate: object,
    space_candidate: object,
) -> Tuple[Optional[int], Optional[int], Optional[str]]:
    """Normalize required task relationships.

    Business rule:
    - Every task must belong to a valid project.
    - Every task must belong to a valid makerspace.
    """

    project_id = to_int(str(project_candidate) if project_candidate is not None else None)
    if project_id is None:
        project_id = ensure_operations_project(conn, org_id, actor_user_id)
    project_ok = conn.execute(
        "SELECT id FROM projects WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
        (project_id, org_id),
    ).fetchone()
    if not project_ok:
        return None, None, "invalid_project"

    preferred_space_id = to_int(str(space_candidate) if space_candidate is not None else None)
    space_id = default_space_id_for_org(conn, org_id, preferred_space_id=preferred_space_id)
    if space_id is None:
        return None, None, "missing_space"
    return int(project_id), int(space_id), None


class Request:
    """Thin wrapper over WSGI environ with lazy form/file parsing.

    Decision rationale:
    - Keep dependencies minimal (stdlib only).
    - Expose a predictable interface for route handlers in this single-file app.
    """

    def __init__(self, environ: dict):
        self.environ = environ
        self.method = environ.get("REQUEST_METHOD", "GET").upper()
        self.path = environ.get("PATH_INFO", "/")
        self.query = {k: v[0] for k, v in parse_qs(environ.get("QUERY_STRING", "")).items()}
        self.cookies = self._parse_cookies(environ.get("HTTP_COOKIE", ""))
        self._form = None
        self._files = None

    def _parse_cookies(self, raw_cookie: str) -> Dict[str, str]:
        cookies: Dict[str, str] = {}
        if not raw_cookie:
            return cookies
        for token in raw_cookie.split(";"):
            if "=" not in token:
                continue
            key, value = token.split("=", 1)
            cookies[key.strip()] = unquote(value.strip())
        return cookies

    @property
    def form(self) -> Dict[str, str]:
        if self._form is None:
            self._parse_form_data()
        return self._form or {}

    @property
    def files(self) -> Dict[str, cgi.FieldStorage]:
        if self._files is None:
            self._parse_form_data()
        return self._files or {}

    def _parse_form_data(self) -> None:
        self._form = {}
        self._files = {}
        if self.method not in {"POST", "PUT", "PATCH", "DELETE"}:
            return
        content_type = self.environ.get("CONTENT_TYPE", "")
        if "multipart/form-data" in content_type:
            fs = cgi.FieldStorage(fp=self.environ["wsgi.input"], environ=self.environ, keep_blank_values=True)
            for key in fs.keys():
                field = fs[key]
                if isinstance(field, list):
                    field = field[0]
                if getattr(field, "filename", None):
                    self._files[key] = field
                else:
                    self._form[key] = field.value
            return

        try:
            length = int(self.environ.get("CONTENT_LENGTH") or 0)
        except ValueError:
            length = 0
        body = self.environ["wsgi.input"].read(length).decode("utf-8") if length else ""
        parsed = parse_qs(body)
        self._form = {k: v[0] for k, v in parsed.items()}


class Response:
    """Simple response object that centralizes security headers."""

    def __init__(
        self,
        body: str = "",
        status: str = "200 OK",
        content_type: str = "text/html; charset=utf-8",
        headers: Optional[List[Tuple[str, str]]] = None,
    ):
        self.body = body.encode("utf-8") if isinstance(body, str) else body
        self.status = status
        self.content_type = content_type
        self.headers = headers or []

    def wsgi(self, start_response):
        sec_headers = [
            ("Content-Type", self.content_type),
            ("X-Frame-Options", "DENY"),
            ("X-Content-Type-Options", "nosniff"),
            ("Referrer-Policy", "strict-origin-when-cross-origin"),
            ("Cache-Control", "no-store"),
            ("Permissions-Policy", "camera=(), microphone=(), geolocation=()"),
            (
                "Content-Security-Policy",
                "default-src 'self'; style-src 'self'; script-src 'self'; img-src 'self' data:; base-uri 'self'; form-action 'self'",
            ),
        ]
        start_response(self.status, sec_headers + self.headers)
        return [self.body]


def redirect(location: str, cookies: Optional[List[str]] = None) -> Response:
    headers = [("Location", location)]
    for cookie in cookies or []:
        headers.append(("Set-Cookie", cookie))
    return Response("", status="302 Found", headers=headers)


def json_response(payload: object, status: str = "200 OK") -> Response:
    return Response(json.dumps(payload), status=status, content_type="application/json; charset=utf-8")


def set_cookie(name: str, value: str, max_age: Optional[int] = None, path: str = "/") -> str:
    parts = [f"{name}={quote(value)}", f"Path={path}", "HttpOnly", "SameSite=Lax"]
    if COOKIE_SECURE:
        parts.append("Secure")
    if max_age is not None:
        parts.append(f"Max-Age={max_age}")
    return "; ".join(parts)


def clear_cookie(name: str, path: str = "/") -> str:
    parts = [f"{name}=", "Max-Age=0", f"Path={path}", "HttpOnly", "SameSite=Lax"]
    if COOKIE_SECURE:
        parts.append("Secure")
    return "; ".join(parts)


def create_session(conn: sqlite3.Connection, user_id: int, ip: str, user_agent: str) -> Tuple[str, str]:
    raw_token = secrets.token_urlsafe(32)
    csrf = secrets.token_urlsafe(24)
    expires = utcnow() + dt.timedelta(days=SESSION_DAYS)
    conn.execute(
        "INSERT INTO sessions (user_id, token_hash, csrf_token, expires_at, created_at, last_seen_at, ip_address, user_agent) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        (user_id, token_hash(raw_token), csrf, expires.isoformat(), iso(), iso(), ip, user_agent[:200]),
    )
    return raw_token, csrf


def get_auth_context(conn: sqlite3.Connection, req: Request) -> Dict[str, object]:
    """Return authenticated user/org context for request handling.

    Decision rationale:
    - Memberships are resolved per request to keep authorization source-of-truth in DB.
    - Non-superuser admin accounts are intentionally constrained to one workspace scope.
      This prevents one admin identity from silently controlling multiple departments.
    """
    token = req.cookies.get("session_token")
    if not token:
        return {"user": None, "memberships": [], "active_org": None, "role": None, "csrf": ""}

    session = conn.execute(
        """
        SELECT s.*, u.id as user_id, u.email, u.name, u.is_active, u.is_superuser
        FROM sessions s
        JOIN users u ON u.id = s.user_id
        WHERE s.token_hash = ?
        """,
        (token_hash(token),),
    ).fetchone()

    if not session:
        return {"user": None, "memberships": [], "active_org": None, "role": None, "csrf": ""}

    try:
        expires_at = dt.datetime.fromisoformat(session["expires_at"])
    except ValueError:
        expires_at = utcnow() - dt.timedelta(days=1)

    if expires_at < utcnow() or not session["is_active"]:
        conn.execute("DELETE FROM sessions WHERE id = ?", (session["id"],))
        conn.commit()
        return {"user": None, "memberships": [], "active_org": None, "role": None, "csrf": ""}

    conn.execute("UPDATE sessions SET last_seen_at = ? WHERE id = ?", (iso(), session["id"]))

    memberships = conn.execute(
        """
        SELECT m.organization_id, m.role, o.name, o.slug, m.created_at
        FROM memberships m
        JOIN organizations o ON o.id = m.organization_id
        WHERE m.user_id = ?
        ORDER BY m.created_at, o.name
        """,
        (session["user_id"],),
    ).fetchall()

    if not memberships:
        return {"user": None, "memberships": [], "active_org": None, "role": None, "csrf": ""}

    selected_org = req.query.get("org_id") or verify_signed_value(req.cookies.get("active_org", ""))
    # Enforce a single workspace control scope for non-superuser admin accounts.
    if not bool(session["is_superuser"]):
        admin_memberships = [m for m in memberships if is_workspace_admin_role(str(m["role"]))]
        if admin_memberships:
            selected_admin = None
            if selected_org:
                for m in admin_memberships:
                    if str(m["organization_id"]) == str(selected_org):
                        selected_admin = m
                        break
            memberships = [selected_admin or admin_memberships[0]]
    active = None
    for m in memberships:
        if selected_org and str(m["organization_id"]) == str(selected_org):
            active = m
            break
    if not active:
        active = memberships[0]

    user = {
        "id": session["user_id"],
        "email": session["email"],
        "name": session["name"],
        "is_superuser": bool(session["is_superuser"]),
    }
    return {
        "user": user,
        "memberships": memberships,
        "active_org": active,
        "role": active["role"],
        "csrf": session["csrf_token"],
    }


def role_allows(role: Optional[str], minimum: str) -> bool:
    if role is None:
        return False
    return ROLE_RANK.get(role, 0) >= ROLE_RANK.get(minimum, 99)


def is_workspace_admin_role(role: Optional[str]) -> bool:
    return str(role or "").strip().lower() in {"workspace_admin", "owner"}


def parse_membership_role(raw_role: Optional[str], default: str = "staff") -> str:
    """Normalize and validate membership roles from user input."""
    role = str(raw_role or default).strip().lower()
    if role in MEMBERSHIP_ROLE_OPTIONS:
        return role
    return default


def assignable_membership_roles(can_assign_owner: bool) -> List[str]:
    """Return roles visible/assignable for the acting admin."""
    if can_assign_owner:
        return MEMBERSHIP_ROLE_OPTIONS
    return [role for role in MEMBERSHIP_ROLE_OPTIONS if role not in {"workspace_admin", "owner"}]


def default_user_preferences() -> Dict[str, object]:
    return {
        "default_task_scope": "my",
        "show_weekend_alert": True,
        "dashboard_compact": False,
        "email_task_updates": True,
        "email_project_updates": True,
        "email_comments": True,
        "email_mentions": True,
    }


def load_user_preferences(conn: sqlite3.Connection, user_id: int) -> Dict[str, object]:
    prefs = default_user_preferences()
    row = conn.execute("SELECT preferences_json FROM user_preferences WHERE user_id = ?", (user_id,)).fetchone()
    if not row:
        return prefs
    try:
        parsed = json.loads(row["preferences_json"])
    except Exception:
        parsed = {}
    if isinstance(parsed, dict):
        prefs.update(parsed)
    return prefs


def save_user_preferences(conn: sqlite3.Connection, user_id: int, prefs: Dict[str, object]) -> None:
    existing = conn.execute("SELECT id FROM user_preferences WHERE user_id = ?", (user_id,)).fetchone()
    if existing:
        conn.execute(
            "UPDATE user_preferences SET preferences_json = ?, updated_at = ? WHERE user_id = ?",
            (json.dumps(prefs), iso(), user_id),
        )
    else:
        conn.execute(
            "INSERT INTO user_preferences (user_id, preferences_json, updated_at) VALUES (?, ?, ?)",
            (user_id, json.dumps(prefs), iso()),
        )


def available_nav_items(role: str) -> Tuple[List[Dict[str, str]], List[Dict[str, str]]]:
    primary = [item for item in NAV_PRIMARY_ITEMS if role_allows(role, item["min_role"])]
    if not FEATURE_INTAKE_ENABLED:
        primary = [item for item in primary if str(item.get("key")) != "intake"]
    account = [item for item in NAV_ACCOUNT_ITEMS if role_allows(role, item["min_role"])]
    return primary, account


def nav_keys(items: Iterable[Dict[str, str]]) -> List[str]:
    return [str(item["key"]) for item in items]


def sanitize_nav_key_selection(
    requested: Iterable[object],
    allowed: Iterable[str],
    fallback: Optional[Iterable[str]] = None,
) -> List[str]:
    allowed_set = {str(key) for key in allowed}
    ordered: List[str] = []
    seen = set()
    for raw in requested:
        key = str(raw or "").strip()
        if not key or key not in allowed_set or key in seen:
            continue
        ordered.append(key)
        seen.add(key)
    if not ordered:
        for raw in fallback or []:
            key = str(raw or "").strip()
            if key in allowed_set and key not in seen:
                ordered.append(key)
                seen.add(key)
    for forced in NAV_ALWAYS_VISIBLE_KEYS:
        if forced in allowed_set and forced not in seen:
            ordered.append(forced)
            seen.add(forced)
    return ordered


def load_role_nav_preference(
    conn: sqlite3.Connection,
    org_id: int,
    role: str,
    allowed_keys: Iterable[str],
) -> List[str]:
    allowed = list(allowed_keys)
    row = conn.execute(
        "SELECT visible_json FROM role_nav_preferences WHERE organization_id = ? AND role = ?",
        (org_id, role),
    ).fetchone()
    if not row:
        return sanitize_nav_key_selection(allowed, allowed, fallback=allowed)
    try:
        parsed = json.loads(row["visible_json"])
    except Exception:
        parsed = []
    if not isinstance(parsed, list):
        parsed = []
    return sanitize_nav_key_selection(parsed, allowed, fallback=allowed)


def save_role_nav_preference(
    conn: sqlite3.Connection,
    org_id: int,
    role: str,
    visible_keys: List[str],
    updated_by: int,
) -> None:
    existing = conn.execute(
        "SELECT id FROM role_nav_preferences WHERE organization_id = ? AND role = ?",
        (org_id, role),
    ).fetchone()
    payload = json.dumps(visible_keys)
    if existing:
        conn.execute(
            "UPDATE role_nav_preferences SET visible_json = ?, updated_by = ?, updated_at = ? WHERE organization_id = ? AND role = ?",
            (payload, updated_by, iso(), org_id, role),
        )
    else:
        conn.execute(
            """
            INSERT INTO role_nav_preferences (organization_id, role, visible_json, updated_by, updated_at)
            VALUES (?, ?, ?, ?, ?)
            """,
            (org_id, role, payload, updated_by, iso()),
        )


def visible_nav_for_user(
    conn: sqlite3.Connection,
    org_id: int,
    role: str,
    user_prefs: Dict[str, object],
) -> Tuple[List[Dict[str, str]], List[Dict[str, str]], List[str]]:
    primary_allowed, account_allowed = available_nav_items(role)
    allowed = nav_keys(primary_allowed + account_allowed)
    role_default = load_role_nav_preference(conn, org_id, role, allowed)
    requested = user_prefs.get("nav_visibility")
    if isinstance(requested, list):
        selected = sanitize_nav_key_selection(requested, allowed, fallback=role_default)
    else:
        selected = role_default
    visible_set = set(selected)
    primary_visible = [item for item in primary_allowed if item["key"] in visible_set]
    account_visible = [item for item in account_allowed if item["key"] in visible_set]
    return primary_visible, account_visible, selected


def delete_policy_for_entity(entity: str) -> Optional[Dict[str, object]]:
    return DELETE_POLICY.get(str(entity or "").strip().lower())


def entity_soft_delete(
    conn: sqlite3.Connection,
    org_id: int,
    actor_user_id: int,
    entity: str,
    item_id: int,
) -> Tuple[bool, str]:
    policy = delete_policy_for_entity(entity)
    if not policy:
        return False, "invalid_entity"
    table = str(policy["table"])
    title_field = str(policy["title_field"])
    status_field = str(policy["status_field"])
    updated_field = str(policy.get("updated_field") or "updated_at")
    ready_statuses = [str(s) for s in policy.get("ready_statuses", [])]
    row = conn.execute(
        f"SELECT id, {title_field} AS title, {status_field} AS status, deleted_at FROM {table} WHERE id = ? AND organization_id = ?",
        (item_id, org_id),
    ).fetchone()
    if not row:
        return False, "not_found"
    if row["deleted_at"]:
        return False, "already_deleted"
    current_status = str(row["status"] or "")
    if ready_statuses and current_status not in set(ready_statuses):
        return False, f"status_required:{'|'.join(ready_statuses)}"
    full_before = snapshot_row(
        conn.execute(
            f"SELECT * FROM {table} WHERE id = ? AND organization_id = ?",
            (item_id, org_id),
        ).fetchone()
    )
    conn.execute(
        f"UPDATE {table} SET deleted_at = ?, deleted_by_user_id = ?, {updated_field} = ? WHERE id = ? AND organization_id = ?",
        (iso(), actor_user_id, iso(), item_id, org_id),
    )
    full_after = snapshot_row(
        conn.execute(
            f"SELECT * FROM {table} WHERE id = ? AND organization_id = ?",
            (item_id, org_id),
        ).fetchone()
    )
    log_change_with_rollback(
        conn,
        org_id,
        actor_user_id,
        "item_soft_deleted",
        table,
        item_id,
        full_before,
        full_after,
        f"{policy['label']}: {row['title']}",
        source="delete-workflow",
    )
    return True, "ok"


def restore_soft_deleted_entity(
    conn: sqlite3.Connection,
    org_id: int,
    actor_user_id: int,
    entity: str,
    item_id: int,
) -> Tuple[bool, str]:
    policy = delete_policy_for_entity(entity)
    if not policy:
        return False, "invalid_entity"
    table = str(policy["table"])
    updated_field = str(policy.get("updated_field") or "updated_at")
    row = conn.execute(
        f"SELECT id, deleted_at FROM {table} WHERE id = ? AND organization_id = ?",
        (item_id, org_id),
    ).fetchone()
    if not row:
        return False, "not_found"
    if not row["deleted_at"]:
        return False, "not_deleted"
    full_before = snapshot_row(
        conn.execute(
            f"SELECT * FROM {table} WHERE id = ? AND organization_id = ?",
            (item_id, org_id),
        ).fetchone()
    )
    conn.execute(
        f"UPDATE {table} SET deleted_at = NULL, deleted_by_user_id = NULL, {updated_field} = ? WHERE id = ? AND organization_id = ?",
        (iso(), item_id, org_id),
    )
    full_after = snapshot_row(
        conn.execute(
            f"SELECT * FROM {table} WHERE id = ? AND organization_id = ?",
            (item_id, org_id),
        ).fetchone()
    )
    log_change_with_rollback(
        conn,
        org_id,
        actor_user_id,
        "item_restored",
        table,
        item_id,
        full_before,
        full_after,
        str(policy["label"]),
        source="delete-workflow",
    )
    return True, "ok"


def purge_soft_deleted_entity(
    conn: sqlite3.Connection,
    org_id: int,
    actor_user_id: int,
    entity: str,
    item_id: int,
) -> Tuple[bool, str]:
    policy = delete_policy_for_entity(entity)
    if not policy:
        return False, "invalid_entity"
    table = str(policy["table"])
    row = conn.execute(
        f"SELECT id, deleted_at FROM {table} WHERE id = ? AND organization_id = ?",
        (item_id, org_id),
    ).fetchone()
    if not row:
        return False, "not_found"
    if not row["deleted_at"]:
        return False, "not_deleted"
    full_before = snapshot_row(
        conn.execute(
            f"SELECT * FROM {table} WHERE id = ? AND organization_id = ?",
            (item_id, org_id),
        ).fetchone()
    )
    conn.execute(f"DELETE FROM {table} WHERE id = ? AND organization_id = ?", (item_id, org_id))
    log_change_with_rollback(
        conn,
        org_id,
        actor_user_id,
        "item_purged",
        table,
        item_id,
        full_before,
        None,
        str(policy["label"]),
        source="delete-workflow",
    )
    return True, "ok"


def deleted_rows_for_entity(conn: sqlite3.Connection, org_id: int, entity: str, limit: int = 150) -> List[sqlite3.Row]:
    policy = delete_policy_for_entity(entity)
    if not policy:
        return []
    table = str(policy["table"])
    title_field = str(policy["title_field"])
    status_field = str(policy["status_field"])
    return conn.execute(
        f"""
        SELECT t.id, t.{title_field} AS title, t.{status_field} AS status, t.deleted_at, u.name AS deleted_by_name
        FROM {table} t
        LEFT JOIN users u ON u.id = t.deleted_by_user_id
        WHERE t.organization_id = ? AND t.deleted_at IS NOT NULL
        ORDER BY t.deleted_at DESC
        LIMIT ?
        """,
        (org_id, limit),
    ).fetchall()


def comment_table_for_entity(entity: str) -> Optional[str]:
    return COMMENTABLE_ENTITY_TABLE.get(str(entity or "").strip().lower())


def comment_target_exists(conn: sqlite3.Connection, org_id: int, entity: str, item_id: int) -> bool:
    table = comment_table_for_entity(entity)
    if not table:
        return False
    row = conn.execute(
        f"SELECT id FROM {table} WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
        (item_id, org_id),
    ).fetchone()
    return bool(row)


def load_item_comments(conn: sqlite3.Connection, org_id: int, entity: str, item_id: int, limit: int = 150) -> List[sqlite3.Row]:
    return conn.execute(
        """
        SELECT c.id, c.body, c.created_at, c.author_user_id, u.name AS author_name
        FROM item_comments c
        LEFT JOIN users u ON u.id = c.author_user_id
        WHERE c.organization_id = ? AND c.entity = ? AND c.entity_id = ?
        ORDER BY c.created_at ASC, c.id ASC
        LIMIT ?
        """,
        (org_id, entity, item_id, max(1, limit)),
    ).fetchall()


def purge_keyword_test_data(conn: sqlite3.Connection, org_id: int, keyword: str) -> Dict[str, int]:
    needle = f"%{keyword.lower()}%"
    deleted_counts: Dict[str, int] = {}
    entity_fields = {
        "tasks": ["title", "description"],
        "projects": ["name", "description", "tags"],
        "intake_requests": ["title", "requestor_name", "requestor_email", "details"],
        "equipment_assets": ["name", "space", "asset_type", "notes"],
        "consumables": ["name", "category", "notes"],
        "partnerships": ["partner_name", "school", "notes"],
        "meeting_agendas": ["title", "notes"],
        "meeting_note_sources": ["title", "doc_url", "body"],
        "onboarding_templates": ["name", "task_title", "details", "doc_url"],
    }
    for table, fields in entity_fields.items():
        where = " OR ".join([f"LOWER(COALESCE({field}, '')) LIKE ?" for field in fields])
        params: List[object] = [org_id]
        params.extend([needle] * len(fields))
        cursor = conn.execute(
            f"DELETE FROM {table} WHERE organization_id = ? AND ({where})",
            tuple(params),
        )
        deleted_counts[table] = int(cursor.rowcount or 0)

    # Remove QA-tagged users from this workspace membership scope.
    qa_memberships = conn.execute(
        """
        SELECT m.user_id
        FROM memberships m
        JOIN users u ON u.id = m.user_id
        WHERE m.organization_id = ?
          AND (
            LOWER(COALESCE(u.name, '')) LIKE ?
            OR LOWER(COALESCE(u.email, '')) LIKE ?
          )
        """,
        (org_id, needle, needle),
    ).fetchall()
    removed_memberships = 0
    deactivated_users = 0
    for row in qa_memberships:
        target_id = int(row["user_id"])
        removed_memberships += int(
            conn.execute(
                "DELETE FROM memberships WHERE organization_id = ? AND user_id = ?",
                (org_id, target_id),
            ).rowcount or 0
        )
        remaining = conn.execute("SELECT COUNT(*) AS c FROM memberships WHERE user_id = ?", (target_id,)).fetchone()
        if int(remaining["c"] or 0) == 0:
            conn.execute("DELETE FROM sessions WHERE user_id = ?", (target_id,))
            conn.execute("UPDATE users SET is_active = 0 WHERE id = ?", (target_id,))
            deactivated_users += 1
    deleted_counts["memberships"] = removed_memberships
    deleted_counts["deactivated_users"] = deactivated_users
    return deleted_counts


def admin_org_ids_for_user(conn: sqlite3.Connection, user_id: int) -> List[int]:
    rows = conn.execute(
        """
        SELECT DISTINCT organization_id
        FROM memberships
        WHERE user_id = ? AND role IN ('workspace_admin', 'owner')
        ORDER BY organization_id
        """,
        (user_id,),
    ).fetchall()
    return [int(row["organization_id"]) for row in rows]


def can_manage_workspace_admin_role(conn: sqlite3.Connection, user_id: int, target_org_id: int) -> bool:
    row = conn.execute("SELECT is_superuser FROM users WHERE id = ?", (user_id,)).fetchone()
    if row and int(row["is_superuser"] or 0) == 1:
        return True
    admin_orgs = admin_org_ids_for_user(conn, user_id)
    # Non-superusers can only hold admin rights in one workspace.
    return not admin_orgs or set(admin_orgs).issubset({int(target_org_id)})


def normalize_org_user_id(
    conn: sqlite3.Connection,
    org_id: int,
    candidate: object,
    fallback: Optional[int] = None,
) -> Optional[int]:
    """Return a valid active user id within the org, otherwise fallback/None.

    Decision rationale:
    - UI dropdowns constrain values, but crafted requests can bypass UI controls.
    - Normalizing user references prevents cross-workspace identity leakage.
    """

    candidate_id = to_int(str(candidate) if candidate not in (None, "") else None)
    fallback_id = to_int(str(fallback) if fallback not in (None, "") else None)

    def in_org(uid: Optional[int]) -> bool:
        if uid is None:
            return False
        row = conn.execute(
            """
            SELECT 1
            FROM memberships m
            JOIN users u ON u.id = m.user_id
            WHERE m.organization_id = ? AND m.user_id = ? AND u.is_active = 1
            LIMIT 1
            """,
            (org_id, uid),
        ).fetchone()
        return row is not None

    if in_org(candidate_id):
        return candidate_id
    if in_org(fallback_id):
        return fallback_id
    return None


def admin_target_user_role(conn: sqlite3.Connection, org_id: int, target_user_id: int) -> Optional[str]:
    row = conn.execute(
        """
        SELECT m.role
        FROM memberships m
        WHERE m.organization_id = ? AND m.user_id = ?
        """,
        (org_id, target_user_id),
    ).fetchone()
    if not row:
        return None
    return str(row["role"] or "").strip().lower() or None


def can_admin_manage_user(
    conn: sqlite3.Connection,
    org_id: int,
    actor_user_id: int,
    actor_role: str,
    target_user_id: int,
) -> Tuple[bool, str]:
    """Enforce safe admin-user operations to avoid privilege escalation."""

    actor_row = conn.execute("SELECT is_superuser FROM users WHERE id = ?", (actor_user_id,)).fetchone()
    actor_is_superuser = bool(actor_row and int(actor_row["is_superuser"] or 0) == 1)
    if actor_is_superuser:
        return True, ""

    target_user = conn.execute("SELECT id, is_superuser FROM users WHERE id = ?", (target_user_id,)).fetchone()
    if not target_user:
        return False, "User not found"
    if int(target_user["is_superuser"] or 0) == 1:
        return False, "Only superusers can manage superuser accounts"

    target_role = admin_target_user_role(conn, org_id, target_user_id)
    if not target_role:
        return False, "User is not in this workspace"

    # Owner accounts are managed by owners/superusers only.
    if role_allows(target_role, "owner") and not role_allows(actor_role, "owner"):
        return False, "Only owner-level admins can manage owner accounts"
    # Workspace admin accounts are managed by owners/superusers only.
    if role_allows(target_role, "workspace_admin") and not role_allows(actor_role, "owner"):
        return False, "Only owner-level admins can manage workspace-admin accounts"

    return True, ""


def enforce_rate_limit(ip: str, max_attempts: int = 8, window_minutes: int = 10) -> bool:
    now = utcnow()
    cutoff = now - dt.timedelta(minutes=window_minutes)
    history = RATE_LIMIT.get(ip, [])
    history = [event for event in history if event >= cutoff]
    RATE_LIMIT[ip] = history
    if len(history) >= max_attempts:
        return False
    history.append(now)
    RATE_LIMIT[ip] = history
    return True


def require_auth(ctx: Dict[str, object]) -> Optional[Response]:
    if not ctx.get("user"):
        return redirect("/login")
    return None


def require_role(ctx: Dict[str, object], minimum: str) -> Optional[Response]:
    if not role_allows(ctx.get("role"), minimum):
        return Response("<h1>403 Forbidden</h1>", status="403 Forbidden")
    return None


def validate_csrf(req: Request, ctx: Dict[str, object]) -> bool:
    if req.method not in {"POST", "PUT", "PATCH", "DELETE"}:
        return True
    csrf = req.form.get("csrf_token") or req.query.get("csrf_token") or req.environ.get("HTTP_X_CSRF_TOKEN", "")
    return bool(csrf and csrf == ctx.get("csrf"))


def with_space(path: str, space_id: Optional[int] = None) -> str:
    if not space_id:
        return path
    joiner = "&" if "?" in path else "?"
    return f"{path}{joiner}space_id={space_id}"


def nav_link(path: str, label: str, current: str, space_id: Optional[int] = None) -> str:
    active = current.startswith(path)
    cls = "nav-link active" if active else "nav-link"
    aria = ' aria-current="page"' if active else ""
    href = with_space(path, space_id)
    return f'<a class="{cls}" href="{href}"{aria}>{h(label)}</a>'


def render_layout(
    title: str,
    content: str,
    req: Request,
    ctx: Optional[Dict[str, object]] = None,
    notice: str = "",
) -> str:
    if ctx and ctx.get("user"):
        user = ctx["user"]
        org = ctx.get("active_org")
        active_space_id = ctx.get("active_space_id")
        active_space = ctx.get("active_space")
        spaces = ctx.get("spaces", [])
        org_switch = " ".join(
            [
                f"<a class='org-chip {'active' if int(m['organization_id']) == int(org['organization_id']) else ''}' href='?org_id={m['organization_id']}'>{h(m['name'])}</a>"
                for m in ctx.get("memberships", [])
            ]
        )
        path_for_space = req.path if req.path else "/dashboard"
        space_chips = [f"<a class='space-chip {'active' if not active_space_id else ''}' href='{h(path_for_space)}'>All Spaces</a>"]
        for space in spaces:
            sid = int(space["id"])
            cls = "space-chip active" if active_space_id and sid == int(active_space_id) else "space-chip"
            space_chips.append(f"<a class='{cls}' href='{h(with_space(path_for_space, sid))}'>{h(space['name'])}</a>")
        nav_primary_items = ctx.get("nav_primary_items") or NAV_PRIMARY_ITEMS
        nav_account_items = ctx.get("nav_account_items") or NAV_ACCOUNT_ITEMS
        nav_primary = "".join(
            [nav_link(str(item["path"]), str(item["label"]), req.path, active_space_id) for item in nav_primary_items]
        )
        nav_account = "".join(
            [nav_link(str(item["path"]), str(item["label"]), req.path, active_space_id) for item in nav_account_items]
        )
        sidebar = f"""
        <aside class="sidebar" aria-label="Primary Navigation">
          <div class="sidebar-brand">
            <h1><a class="brand-link" href="/website/">MakerFlow PM</a></h1>
            <p>{h(APP_NAME)}</p>
            <p>{h(APP_TAGLINE)}</p>
          </div>
          <nav class="side-nav" aria-label="Primary">{nav_primary}</nav>
          <section class="sidebar-panel">
            <h4>Space Management</h4>
            <div class="side-links">
              <a class="side-mini-link" href="{h(with_space('/spaces', active_space_id))}">Manage Spaces</a>
              <a class="side-mini-link" href="{h(with_space('/assets', active_space_id))}">Machines</a>
              <a class="side-mini-link" href="{h(with_space('/consumables', active_space_id))}">Consumables</a>
            </div>
            <details>
              <summary>Add New Space</summary>
              <form method="post" action="/settings/spaces/new" class="sidebar-mini-form">
                <input type="hidden" name="csrf_token" value="{h(ctx.get('csrf', ''))}" />
                <label>Name <input name="name" required placeholder="New Space" /></label>
                <label>Location <input name="location" placeholder="Building/Floor" /></label>
                <label>Description <textarea name="description" placeholder="What this space supports"></textarea></label>
                <button type="submit">Add Space</button>
              </form>
            </details>
          </section>
          <div class="sidebar-foot">
            <h4>Workspaces</h4>
            <div class="org-switch">{org_switch}</div>
            <h4>Account Management</h4>
            <nav class="side-nav account-nav" aria-label="Account Management">{nav_account}</nav>
          </div>
        </aside>
        """
        top_bar = f"""
        <header class="topbar">
          <div class="space-switch-wrap">
            <span class="space-label">Space Context: {h(active_space['name']) if active_space else 'All Spaces'}</span>
            <div class="space-switch">{''.join(space_chips)}</div>
          </div>
          <div class="top-actions">
            <button type="button" class="btn" id="global-new-task-btn">New Task</button>
            <button type="button" class="btn ghost" id="theme-toggle" aria-pressed="false" aria-label="Toggle theme">Dark</button>
            <button type="button" class="btn ghost" id="activity-toggle" aria-expanded="false" aria-controls="activity-drawer">Activity</button>
            <span class="pill soft" id="activity-count" aria-live="polite">0</span>
            <span class="user-chip">{h(user['name'])} · {h(org['name']) if org else ''}</span>
            <form method="post" action="/logout">
              <input type="hidden" name="csrf_token" value="{h(ctx.get('csrf', ''))}" />
              <button type="submit">Logout</button>
            </form>
          </div>
        </header>
        """
        modal_shell = """
        <div id="card-editor-modal" class="modal-shell" aria-hidden="true">
          <div class="modal-backdrop" data-close-modal="1"></div>
          <section class="modal-card" role="dialog" aria-modal="true" aria-labelledby="card-editor-title">
            <header class="modal-head">
              <h2 id="card-editor-title">Edit Card</h2>
              <button type="button" class="btn ghost" data-close-modal="1" aria-label="Close editor">Close</button>
            </header>
            <form id="card-editor-form" class="modal-form"></form>
          </section>
        </div>
        <aside id="activity-drawer" class="activity-drawer" aria-hidden="true">
          <header class="activity-drawer-head">
            <h3>Activity</h3>
            <button type="button" class="btn ghost" id="activity-close">Close</button>
          </header>
          <div id="activity-list" class="activity-list"><p class="muted">Loading activity...</p></div>
        </aside>
        <div id="activity-backdrop" class="activity-backdrop" hidden></div>
        """
    else:
        sidebar = ""
        top_bar = f"<header class='topbar'><h1>{h(APP_NAME)}</h1></header>"
        modal_shell = ""

    alert = f"<div class='notice' role='status' aria-live='polite'>{h(notice)}</div>" if notice else ""

    return f"""
    <!doctype html>
    <html lang=\"en\">
      <head>
        <meta charset=\"utf-8\" />
        <meta name=\"viewport\" content=\"width=device-width,initial-scale=1\" />
        <meta name=\"csrf-token\" content=\"{h(ctx.get('csrf', '') if ctx else '')}\" />
        <title>{h(title)} | {h(APP_NAME)}</title>
        <link rel=\"stylesheet\" href=\"/static/style.css\" />
        <script defer src=\"/static/app.js\"></script>
      </head>
      <body data-theme="dark">
        <a class=\"skip-link\" href=\"#main-content\">Skip to main content</a>
        <div class=\"container app-shell\">{sidebar}<section class=\"main-shell\">{top_bar}{alert}<main id=\"main-content\" tabindex=\"-1\">{content}</main></section></div>
        {modal_shell}
      </body>
    </html>
    """


def render_login(req: Request, error: str = "") -> str:
    body = f"""
    <section class=\"card auth\">
      <h2>Secure Sign In</h2>
      <p>Use your organization account. MFA can be enforced at reverse proxy / SSO layer.</p>
      {'<div class="error">'+h(error)+'</div>' if error else ''}
      <form method=\"post\" action=\"/login\">
        <label>Email <input type=\"email\" name=\"email\" required /></label>
        <label>Password <input type=\"password\" name=\"password\" required minlength=\"12\" /></label>
        <button type=\"submit\">Sign In</button>
      </form>
      <p><a href=\"/forgot-password\">Forgot password?</a></p>
      <p><a href=\"/website/\">View Product Website</a></p>
      <p class=\"muted\">Bootstrap accounts are seeded for local setup. Rotate all initial passwords immediately.</p>
    </section>
    """
    return render_layout("Login", body, req)


def create_password_reset(conn: sqlite3.Connection, user_id: int, created_by: Optional[int] = None, hours: int = 24) -> Tuple[str, str]:
    raw_token = secrets.token_urlsafe(32)
    expires = utcnow() + dt.timedelta(hours=hours)
    conn.execute(
        "INSERT INTO password_resets (user_id, token_hash, expires_at, used_at, created_by, created_at) VALUES (?, ?, ?, NULL, ?, ?)",
        (user_id, token_hash(raw_token), expires.isoformat(), created_by, iso()),
    )
    return raw_token, expires.isoformat()


def verify_reset_token(conn: sqlite3.Connection, raw_token: str) -> Optional[sqlite3.Row]:
    row = conn.execute(
        """
        SELECT pr.*, u.email, u.name
        FROM password_resets pr
        JOIN users u ON u.id = pr.user_id
        WHERE pr.token_hash = ?
        """,
        (token_hash(raw_token),),
    ).fetchone()
    if not row or row["used_at"]:
        return None
    try:
        if dt.datetime.fromisoformat(row["expires_at"]) < utcnow():
            return None
    except ValueError:
        return None
    return row


def query_scalar(conn: sqlite3.Connection, sql: str, params: Tuple = ()) -> int:
    row = conn.execute(sql, params).fetchone()
    return int(row[0]) if row else 0


def render_forgot_password(req: Request, message: str = "") -> str:
    body = f"""
    <section class="card auth">
      <h2>Reset Your Password</h2>
      <p>Request a reset link for your account. An admin can also provision reset links from the Admin dashboard.</p>
      {f"<div class='notice'>{h(message)}</div>" if message else ""}
      <form method="post" action="/forgot-password">
        <label>Email <input type="email" name="email" required /></label>
        <button type="submit">Generate Reset Link</button>
      </form>
      <p><a href="/login">Back to login</a></p>
    </section>
    """
    return render_layout("Forgot Password", body, req)


def render_reset_password(req: Request, token: str, error: str = "") -> str:
    body = f"""
    <section class="card auth">
      <h2>Set New Password</h2>
      {f"<div class='error'>{h(error)}</div>" if error else ""}
      <form method="post" action="/reset-password">
        <input type="hidden" name="token" value="{h(token)}" />
        <label>New Password <input type="password" name="password" minlength="12" required /></label>
        <label>Confirm Password <input type="password" name="password_confirm" minlength="12" required /></label>
        <button type="submit">Update Password</button>
      </form>
    </section>
    """
    return render_layout("Reset Password", body, req)


def build_dashboard(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    active_space_id: Optional[int] = None,
    active_space_name: str = "",
    role: str = "viewer",
) -> str:
    project_where = "p.organization_id = ? AND p.deleted_at IS NULL"
    project_params: List[object] = [org_id]
    task_where = "t.organization_id = ? AND t.deleted_at IS NULL"
    task_params: List[object] = [org_id]
    if active_space_id:
        project_where += " AND p.space_id = ?"
        task_where += " AND t.space_id = ?"
        project_params.append(active_space_id)
        task_params.append(active_space_id)

    total_projects = query_scalar(conn, f"SELECT COUNT(*) FROM projects p WHERE {project_where}", tuple(project_params))
    total_teams = query_scalar(conn, "SELECT COUNT(*) FROM teams WHERE organization_id = ?", (org_id,))
    total_spaces = query_scalar(conn, "SELECT COUNT(*) FROM spaces WHERE organization_id = ?", (org_id,))
    active_tasks = query_scalar(
        conn,
        f"SELECT COUNT(*) FROM tasks t WHERE {task_where} AND t.status NOT IN ('Done', 'Cancelled')",
        tuple(task_params),
    )
    due_today = query_scalar(
        conn,
        f"SELECT COUNT(*) FROM tasks t WHERE {task_where} AND t.due_date = ?",
        tuple(task_params + [dt.date.today().isoformat()]),
    )
    overdue = query_scalar(
        conn,
        f"SELECT COUNT(*) FROM tasks t WHERE {task_where} AND t.due_date < ? AND t.status != 'Done'",
        tuple(task_params + [dt.date.today().isoformat()]),
    )

    lane_rows = conn.execute(
        f"SELECT p.lane, COUNT(*) as c FROM projects p WHERE {project_where} GROUP BY p.lane ORDER BY c DESC",
        tuple(project_params),
    ).fetchall()

    intake_open = 0
    if FEATURE_INTAKE_ENABLED:
        intake_open = query_scalar(
            conn,
            "SELECT COUNT(*) FROM intake_requests WHERE organization_id = ? AND deleted_at IS NULL AND status NOT IN ('Done', 'Rejected')",
            (org_id,),
        )
    followups = query_scalar(
        conn,
        "SELECT COUNT(*) FROM partnerships WHERE organization_id = ? AND deleted_at IS NULL AND next_followup <= ?",
        (org_id, (dt.date.today() + dt.timedelta(days=7)).isoformat()),
    )
    maintenance_where = "organization_id = ? AND deleted_at IS NULL"
    maintenance_params: List[object] = [org_id]
    if active_space_name:
        maintenance_where += " AND space = ?"
        maintenance_params.append(active_space_name)
    maintenance_where += " AND next_maintenance <= ?"
    maintenance_params.append((dt.date.today() + dt.timedelta(days=14)).isoformat())
    maintenance_due = query_scalar(
        conn,
        f"SELECT COUNT(*) FROM equipment_assets WHERE {maintenance_where}",
        tuple(maintenance_params),
    )
    consumables_where = "organization_id = ? AND deleted_at IS NULL"
    consumables_params: List[object] = [org_id]
    if active_space_id is not None:
        consumables_where += " AND space_id = ?"
        consumables_params.append(active_space_id)
    consumables_where += " AND (status IN ('Low','Out') OR quantity_on_hand <= reorder_point)"
    consumables_low = query_scalar(
        conn,
        f"SELECT COUNT(*) FROM consumables WHERE {consumables_where}",
        tuple(consumables_params),
    )

    my_focus = conn.execute(
        f"""
        SELECT t.id, t.title, t.status, t.priority, t.due_date, p.name as project_name
        FROM tasks t
        LEFT JOIN projects p ON p.id = t.project_id
        WHERE {task_where} AND t.assignee_user_id = ?
          AND t.status NOT IN ('Done', 'Cancelled')
        ORDER BY COALESCE(t.due_date, '9999-12-31'), t.priority DESC
        LIMIT 8
        """,
        tuple(task_params + [user_id]),
    ).fetchall()
    unassigned = conn.execute(
        f"""
        SELECT t.id, t.title, t.priority, t.due_date, p.name AS project_name
        FROM tasks t
        LEFT JOIN projects p ON p.id = t.project_id
        WHERE {task_where} AND t.assignee_user_id IS NULL AND t.status NOT IN ('Done', 'Cancelled')
        ORDER BY
          CASE t.priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 ELSE 4 END,
          COALESCE(t.due_date, '9999-12-31')
        LIMIT 12
        """,
        tuple(task_params),
    ).fetchall()
    users = get_users_for_org(conn, org_id)
    assignee_opts = "".join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in users])
    team_load = conn.execute(
        f"""
        SELECT COALESCE(tm.name, 'Unassigned') AS team_name, COUNT(*) AS open_tasks
        FROM tasks t
        LEFT JOIN teams tm ON tm.id = t.team_id
        WHERE {task_where} AND t.status NOT IN ('Done', 'Cancelled')
        GROUP BY COALESCE(tm.name, 'Unassigned')
        ORDER BY open_tasks DESC
        """,
        tuple(task_params),
    ).fetchall()
    team_rows = "".join(
        [
            f"<tr><td>{h(r['team_name'])}</td><td>{h(r['open_tasks'])}</td></tr>"
            for r in team_load
        ]
    ) or "<tr><td colspan='2'>No active tasks.</td></tr>"
    people_load = conn.execute(
        f"""
        SELECT COALESCE(u.name, 'Unassigned') AS owner_name,
               COUNT(*) AS open_tasks,
               SUM(CASE WHEN t.due_date < ? THEN 1 ELSE 0 END) AS overdue_tasks
        FROM tasks t
        LEFT JOIN users u ON u.id = t.assignee_user_id
        WHERE {task_where} AND t.status NOT IN ('Done', 'Cancelled')
        GROUP BY COALESCE(u.name, 'Unassigned')
        ORDER BY open_tasks DESC, owner_name
        LIMIT 14
        """,
        tuple([dt.date.today().isoformat()] + task_params),
    ).fetchall()
    people_rows = "".join(
        [
            f"<tr><td>{h(r['owner_name'])}</td><td>{h(r['open_tasks'])}</td><td>{h(r['overdue_tasks'] or 0)}</td></tr>"
            for r in people_load
        ]
    ) or "<tr><td colspan='3'>No active assignments.</td></tr>"

    snapshots = {
        row["key"]: json.loads(row["payload_json"])
        for row in conn.execute(
            "SELECT key, payload_json FROM insight_snapshots WHERE organization_id = ?", (org_id,)
        ).fetchall()
    }

    external_baseline = ""
    dep = snapshots.get("department_metrics")
    cal = snapshots.get("calendar_metrics")
    if dep and cal:
        checkins = dep.get("checkins", {}).get("total_checkins")
        unique_users = dep.get("checkins", {}).get("unique_users")
        internal_ops = dep.get("school_reach", {}).get("allocation_option_a", [{}])[0].get("internal_ops")
        outward = dep.get("school_reach", {}).get("allocation_option_a", [{}])[0].get("outward_facing")
        after_hours = cal.get("last_year", {}).get("after_hours")
        external_baseline = f"""
        <div class=\"card\">
          <h3>Impact Baseline</h3>
          <ul>
            <li>{h(checkins)} annual check-ins from {h(unique_users)} unique users</li>
            <li>Internal operations load snapshot: {h(internal_ops)} vs outward-facing {h(outward)}</li>
            <li>After-hours calendar load baseline: {h(after_hours)} hours/year</li>
          </ul>
        </div>
        """

    lane_html = "".join(
        [f"<li><strong>{h(r['lane'])}</strong>: {h(r['c'])} projects</li>" for r in lane_rows]
    ) or "<li>No projects yet</li>"
    my_focus_html = "".join(
        [
            (
                lambda href: f"<tr><td><a href='{h(href)}'>{h(t['title'])}</a></td><td>{h(t['project_name'] or '-')}</td><td>{h(t['status'])}</td><td>{h(t['priority'])}</td><td>{h(t['due_date'] or '-')}</td></tr>"
            )(with_space(f"/tasks?scope=my&search={quote(str(t['title']))}", active_space_id))
            for t in my_focus
        ]
    ) or "<tr><td colspan='5'>No tasks assigned.</td></tr>"
    unassigned_html = "".join(
        [
            f"""
            <tr>
              <td>{h(t['title'])}</td>
              <td>{h(t['project_name'] or '-')}</td>
              <td>{h(t['priority'])}</td>
              <td>{h(t['due_date'] or '-')}</td>
              <td>
                <form method='post' action='/tasks/delegate' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='active_space_id' value='{h(active_space_id or "")}' />
                  <input type='hidden' name='task_id' value='{t['id']}' />
                  <select name='assignee_user_id' required aria-label='Assign owner for {h(t["title"])}'><option value=''>Assign...</option>{assignee_opts}</select>
                  <button type='submit'>Assign</button>
                </form>
              </td>
            </tr>
            """
            for t in unassigned
        ]
    ) or "<tr><td colspan='5'>No unassigned tasks.</td></tr>"

    top_widgets = most_used_report_widgets(conn, org_id, limit=6)
    dashboard_report_name = "Dashboard Top Charts"
    dashboard_report_description = "Most-used operational charts for quick decision making."
    dashboard_editor_config = report_editor_config(
        conn,
        org_id,
        top_widgets,
        dashboard_report_name,
        dashboard_report_description,
        selected_space_id=active_space_id,
    )
    dashboard_editor_json = json.dumps(dashboard_editor_config).replace("</", "<\\/")
    dashboard_template_opts = "".join(
        [f"<option value='{h(str(template['key']))}'>{h(str(template['name']))}</option>" for template in REPORT_TEMPLATE_LIBRARY]
    )
    report_save_path = with_space("/reports/new", active_space_id)
    can_share_reports = role_allows(role, "manager")
    intake_stat = (
        f"<a class=\"stat\" href=\"{h(with_space('/intake', active_space_id))}\"><span>Open Intake</span><strong>{intake_open}</strong></a>"
        if FEATURE_INTAKE_ENABLED
        else ""
    )

    return f"""
    <section id='report-studio' class='card maker-hero'>
      <h2>Dashboard + Reporting Studio</h2>
      <p>Most-used charts are pinned at the top so daily operations and impact reporting happen in one place.</p>
    </section>
    <section class='card'>
      <h3>Top Charts (Most Used)</h3>
      <p class='muted'>These charts are auto-picked from your saved report template usage patterns.</p>
      <div id='report-preview-grid' class='report-preview-grid'></div>
    </section>
    <section class='card'>
      <h3>Quick Report Builder</h3>
      <form method='post' action='{h(report_save_path)}' id='report-builder-form'>
        <input type='hidden' name='csrf_token' value='{{csrf}}' />
        <input type='hidden' name='config_json' id='report-config-json' />
        <input type='hidden' name='next' value='/dashboard?msg=Report%20template%20saved' />
        <label>Report Name <input name='name' id='report-name' aria-label='Report name' value='{h(dashboard_report_name)}' required /></label>
        <label>Description <textarea name='description' id='report-description' aria-label='Report description'>{h(dashboard_report_description)}</textarea></label>
        <label>Start from template
          <select id='report-template-select' aria-label='Start from report template'>
            <option value=''>Keep current</option>
            {dashboard_template_opts}
          </select>
        </label>
        <div class='inline-actions'>
          <button type='button' class='btn ghost' id='report-add-widget'>Add Chart</button>
          <label><input type='checkbox' name='is_shared' value='1' {'checked' if can_share_reports else ''} {'disabled' if not can_share_reports else ''} /> Shared with organization</label>
        </div>
        <div id='report-widget-editor' class='report-widget-editor'></div>
        <button type='submit'>Save Report Template</button>
      </form>
    </section>
    <section class=\"grid\">
      <a class=\"stat\" href=\"{h(with_space('/projects', active_space_id))}\"><span>Total Projects</span><strong>{total_projects}</strong></a>
      <a class=\"stat\" href=\"{h(with_space('/settings', active_space_id))}\"><span>Teams</span><strong>{total_teams}</strong></a>
      <a class=\"stat\" href=\"{h(with_space('/settings', active_space_id))}\"><span>Makerspaces</span><strong>{total_spaces}</strong></a>
      <a class=\"stat\" href=\"{h(with_space('/tasks?scope=team', active_space_id))}\"><span>Active Tasks</span><strong>{active_tasks}</strong></a>
      <a class=\"stat\" href=\"{h(with_space('/tasks?scope=week', active_space_id))}\"><span>Due Today</span><strong>{due_today}</strong></a>
      <a class=\"stat\" href=\"{h(with_space('/tasks?scope=team', active_space_id))}\"><span>Overdue</span><strong>{overdue}</strong></a>
      {intake_stat}
      <a class=\"stat\" href=\"{h(with_space('/partnerships', active_space_id))}\"><span>Follow-Ups (7d)</span><strong>{followups}</strong></a>
      <a class=\"stat\" href=\"{h(with_space('/assets', active_space_id))}\"><span>Maintenance Due (14d)</span><strong>{maintenance_due}</strong></a>
      <a class=\"stat\" href=\"{h(with_space('/consumables', active_space_id))}\"><span>Consumables Low/Out</span><strong>{consumables_low}</strong></a>
    </section>
    <section class=\"two\">
      <div class=\"card\">
        <h3>Portfolio Lanes</h3>
        <ul>{lane_html}</ul>
      </div>
      <div class=\"card\">
        <h3>Department Leader View</h3>
        <p>Use this dashboard to balance quality, throughput, and outward-facing impact.</p>
        <ul>
          <li>Track Ops vs outward ratio each week</li>
          <li>Watch staffing strain and after-hours spillover</li>
          <li>Escalate lane bottlenecks early</li>
        </ul>
        <div class='inline-actions'>
          <a class='btn' href='#report-studio'>Generate Reports</a>
          <a class='btn ghost' href='{h(with_space('/calendar', active_space_id))}'>Open Calendar Reality View</a>
        </div>
      </div>
      <div class="card">
        <h3>Team Workload</h3>
        <table><thead><tr><th>Team</th><th>Open Tasks</th></tr></thead><tbody>{team_rows}</tbody></table>
      </div>
      <div class="card">
        <h3>People Workload</h3>
        <table><thead><tr><th>Owner</th><th>Open</th><th>Overdue</th></tr></thead><tbody>{people_rows}</tbody></table>
      </div>
      {external_baseline}
    </section>
    <section class=\"card\">
      <h3>My Daily Focus</h3>
      <table>
        <thead><tr><th>Task</th><th>Project</th><th>Status</th><th>Priority</th><th>Due</th></tr></thead>
        <tbody>{my_focus_html}</tbody>
      </table>
    </section>
    <section class="card">
      <h3>Delegation Queue</h3>
      <p class="muted">Directly assign unowned work from the dashboard.</p>
      <table>
        <thead><tr><th>Task</th><th>Project</th><th>Priority</th><th>Due</th><th>Assign</th></tr></thead>
        <tbody>{unassigned_html}</tbody>
      </table>
    </section>
    <script type='application/json' id='report-builder-config'>{dashboard_editor_json}</script>
    """


def get_users_for_org(conn: sqlite3.Connection, org_id: int) -> List[sqlite3.Row]:
    return conn.execute(
        """
        SELECT u.id, u.name, u.email, m.role
        FROM memberships m
        JOIN users u ON u.id = m.user_id
        WHERE m.organization_id = ?
        ORDER BY u.name
        """,
        (org_id,),
    ).fetchall()


def get_spaces_for_org(conn: sqlite3.Connection, org_id: int) -> List[sqlite3.Row]:
    return conn.execute(
        "SELECT id, name, location, description FROM spaces WHERE organization_id = ? ORDER BY name",
        (org_id,),
    ).fetchall()


def get_teams_for_org(conn: sqlite3.Connection, org_id: int) -> List[sqlite3.Row]:
    return conn.execute(
        """
        SELECT t.id, t.name, t.focus_area, t.lead_user_id, u.name AS lead_name
        FROM teams t
        LEFT JOIN users u ON u.id = t.lead_user_id
        WHERE t.organization_id = ?
        ORDER BY t.name
        """,
        (org_id,),
    ).fetchall()


def title_entity_mapping(entity: str) -> Tuple[str, str]:
    mapping = {
        "tasks": ("tasks", "title"),
        "projects": ("projects", "name"),
        "intake": ("intake_requests", "title"),
        "assets": ("equipment_assets", "name"),
        "consumables": ("consumables", "name"),
        "partnerships": ("partnerships", "partner_name"),
        "teams": ("teams", "name"),
        "spaces": ("spaces", "name"),
    }
    return mapping.get(entity, ("", ""))


def title_options_for_entity(conn: sqlite3.Connection, org_id: int, entity: str, limit: int = 120) -> List[str]:
    table, column = title_entity_mapping(entity)
    if not table or not column:
        return []
    rows = conn.execute(
        f"""
        SELECT DISTINCT {column} AS value
        FROM {table}
        WHERE organization_id = ? AND COALESCE(TRIM({column}), '') != ''
        ORDER BY {column}
        LIMIT ?
        """,
        (org_id, max(1, limit)),
    ).fetchall()
    values = [str(row["value"]).strip() for row in rows if str(row["value"] or "").strip()]
    return values


def sanitize_title_for_role(
    conn: sqlite3.Connection,
    org_id: int,
    role: str,
    entity: str,
    proposed: Optional[str],
    current: Optional[str],
    max_len: int = 180,
    free_edit_min_role: str = "manager",
) -> str:
    candidate = str(proposed or "").strip()
    existing = str(current or "").strip()
    if not candidate:
        return existing or "Untitled"
    candidate = candidate[:max_len]
    if role_allows(role, free_edit_min_role):
        return candidate
    allowed = set(title_options_for_entity(conn, org_id, entity, limit=200))
    if candidate in allowed:
        return candidate
    return existing or (sorted(allowed)[0] if allowed else "Untitled")


def build_lookups(conn: sqlite3.Connection, org_id: int, role: str = "viewer") -> Dict[str, object]:
    users = conn.execute(
        """
        SELECT u.id, u.name, u.email
        FROM users u
        JOIN memberships m ON m.user_id = u.id
        WHERE m.organization_id = ? AND u.is_active = 1
        ORDER BY u.name
        """,
        (org_id,),
    ).fetchall()
    projects = conn.execute(
        "SELECT id, name FROM projects WHERE organization_id = ? AND deleted_at IS NULL ORDER BY name",
        (org_id,),
    ).fetchall()
    teams = conn.execute(
        "SELECT id, name FROM teams WHERE organization_id = ? ORDER BY name",
        (org_id,),
    ).fetchall()
    spaces = conn.execute(
        "SELECT id, name FROM spaces WHERE organization_id = ? ORDER BY name",
        (org_id,),
    ).fetchall()
    perms = {
        "task": {
            "can_edit": role_allows(role, "student"),
            "can_inline_title_edit": role_allows(role, "manager"),
            "can_title_select": role_allows(role, "student"),
            "can_delete": role_allows(role, str(DELETE_POLICY["task"]["min_role"])),
        },
        "project": {
            "can_edit": role_allows(role, "staff"),
            "can_inline_title_edit": role_allows(role, "manager"),
            "can_title_select": role_allows(role, "staff"),
            "can_delete": role_allows(role, str(DELETE_POLICY["project"]["min_role"])),
        },
        "intake": {
            "can_edit": role_allows(role, "staff"),
            "can_inline_title_edit": role_allows(role, "manager"),
            "can_title_select": role_allows(role, "staff"),
            "can_delete": role_allows(role, str(DELETE_POLICY["intake"]["min_role"])),
        },
        "asset": {
            "can_edit": role_allows(role, "staff"),
            "can_inline_title_edit": role_allows(role, "manager"),
            "can_title_select": role_allows(role, "staff"),
            "can_delete": role_allows(role, str(DELETE_POLICY["asset"]["min_role"])),
        },
        "consumable": {
            "can_edit": role_allows(role, "staff"),
            "can_inline_title_edit": role_allows(role, "manager"),
            "can_title_select": role_allows(role, "staff"),
            "can_delete": role_allows(role, str(DELETE_POLICY["consumable"]["min_role"])),
        },
        "partnership": {
            "can_edit": role_allows(role, "staff"),
            "can_inline_title_edit": role_allows(role, "manager"),
            "can_title_select": role_allows(role, "staff"),
            "can_delete": role_allows(role, str(DELETE_POLICY["partnership"]["min_role"])),
        },
        "team": {
            "can_edit": role_allows(role, "manager"),
            "can_inline_title_edit": role_allows(role, "manager"),
            "can_title_select": role_allows(role, "manager"),
        },
        "space": {
            "can_edit": role_allows(role, "manager"),
            "can_inline_title_edit": role_allows(role, "manager"),
            "can_title_select": role_allows(role, "manager"),
        },
    }
    payload = {
        "users": [{"id": row["id"], "name": row["name"], "email": row["email"]} for row in users],
        "projects": [{"id": row["id"], "name": row["name"]} for row in projects],
        "teams": [{"id": row["id"], "name": row["name"]} for row in teams],
        "spaces": [{"id": row["id"], "name": row["name"]} for row in spaces],
        "task_statuses": TASK_STATUSES,
        "project_statuses": PROJECT_STATUSES,
        "intake_statuses": INTAKE_STATUSES,
        "asset_statuses": ASSET_STATUSES,
        "consumable_statuses": CONSUMABLE_STATUSES,
        "partnership_stages": PARTNERSHIP_STAGES,
        "partnership_healths": ["Strong", "Medium", "At Risk"],
        "priorities": ["Low", "Medium", "High", "Critical"],
        "energies": ["Low", "Medium", "High"],
        "lanes": LANES,
        "permissions": perms,
        "title_options": {
            "tasks": title_options_for_entity(conn, org_id, "tasks"),
            "projects": title_options_for_entity(conn, org_id, "projects"),
            "intake": title_options_for_entity(conn, org_id, "intake"),
            "assets": title_options_for_entity(conn, org_id, "assets"),
            "consumables": title_options_for_entity(conn, org_id, "consumables"),
            "partnerships": title_options_for_entity(conn, org_id, "partnerships"),
            "teams": title_options_for_entity(conn, org_id, "teams"),
            "spaces": title_options_for_entity(conn, org_id, "spaces"),
        },
        "delete_policies": {
            key: {
                "ready_statuses": [str(status) for status in value.get("ready_statuses", [])],
                "status_field": str(value.get("status_field") or "status"),
            }
            for key, value in DELETE_POLICY.items()
        },
        "can_view_deleted": role_allows(role, "workspace_admin"),
    }
    if not FEATURE_INTAKE_ENABLED:
        perms.pop("intake", None)
        payload.pop("intake_statuses", None)
        title_opts = payload.get("title_options")
        if isinstance(title_opts, dict):
            title_opts.pop("intake", None)
    return payload


def kanban_header(title: str, count: int) -> str:
    color = KANBAN_COLORS.get(title, "#9aa4af")
    return f"<header class='kanban-col-head' style='--kanban-color:{color}'><h4>{h(title)}</h4><span>{count}</span></header>"


def board_mode_toggle(view_key: str, default_mode: str = "kanban") -> str:
    return f"""
    <section class="card board-mode-card">
      <div class="view-mode-toggle" data-view-key="{h(view_key)}" data-default-mode="{h(default_mode)}">
        <span class="muted">View mode</span>
        <button type="button" class="btn mode-btn" data-view-mode="kanban" aria-pressed="true">Kanban</button>
        <button type="button" class="btn ghost mode-btn" data-view-mode="list" aria-pressed="false">List</button>
      </div>
    </section>
    """


def split_rows_by_status(rows: Iterable[sqlite3.Row], statuses: List[str], key: str = "status") -> Dict[str, List[sqlite3.Row]]:
    grouped: Dict[str, List[sqlite3.Row]] = {status: [] for status in statuses}
    for row in rows:
        status = row[key] if row[key] in grouped else statuses[0]
        grouped[status].append(row)
    return grouped


def render_project_page(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    selected_team_id: Optional[int] = None,
    selected_space_id: Optional[int] = None,
) -> str:
    query = """
        SELECT p.*, u.name as owner_name, t.name AS team_name, s.name AS space_name
        FROM projects p
        LEFT JOIN users u ON u.id = p.owner_user_id
        LEFT JOIN teams t ON t.id = p.team_id
        LEFT JOIN spaces s ON s.id = p.space_id
        WHERE p.organization_id = ? AND p.deleted_at IS NULL
    """
    params: List[object] = [org_id]
    if selected_team_id:
        query += " AND p.team_id = ?"
        params.append(selected_team_id)
    if selected_space_id:
        query += " AND p.space_id = ?"
        params.append(selected_space_id)
    query += " ORDER BY p.updated_at DESC"
    projects = conn.execute(query, tuple(params)).fetchall()
    users = get_users_for_org(conn, org_id)
    teams = get_teams_for_org(conn, org_id)
    spaces = get_spaces_for_org(conn, org_id)
    grouped = split_rows_by_status(projects, PROJECT_STATUSES)

    user_opts = "".join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in users])
    team_opts = "".join([f"<option value='{row['id']}'>{h(row['name'])}</option>" for row in teams])
    space_opts = "".join([f"<option value='{row['id']}'>{h(row['name'])}</option>" for row in spaces])
    all_href = with_space("/projects", selected_space_id)
    project_team_filters = [
        f"<a class='btn {'active' if selected_team_id is None else ''}' href='{all_href}'>All Teams</a>"
    ]
    for team in teams:
        is_active = selected_team_id == int(team["id"])
        href = with_space(f"/projects?team_id={team['id']}", selected_space_id)
        project_team_filters.append(
            f"<a class='btn {'active' if is_active else ''}' href='{href}'>{h(team['name'])}</a>"
        )

    columns: List[str] = []
    for status in PROJECT_STATUSES:
        cards = grouped[status]
        card_chunks: List[str] = []
        for p in cards:
            progress = min(100, max(0, int(p["progress_pct"] or 0)))
            meta = parse_meta_json(p["meta_json"])
            attachments = [x for x in meta.get("attachments", []) if isinstance(x, str)]
            note = str(meta.get("note", ""))[:500]
            snippet = (p["description"] or "").strip()
            if len(snippet) > 110:
                snippet = snippet[:110].rstrip() + "..."
            attach_badge = f"<span class='pill soft'>+{len(attachments)} refs</span>" if attachments else ""
            card_chunks.append(
                f"""
                <article class='kanban-card interactive-card project-card'
                  draggable='true'
                  tabindex='0'
                  data-entity='project'
                  data-id='{p['id']}'
                  data-name='{h(p['name'])}'
                  data-description='{h(p['description'] or '')}'
                  data-lane='{h(p['lane'] or '')}'
                  data-status='{h(p['status'] or '')}'
                  data-priority='{h(p['priority'] or 'Medium')}'
                  data-owner-id='{h(p['owner_user_id'] or '')}'
                  data-team-id='{h(p['team_id'] or '')}'
                  data-space-id='{h(p['space_id'] or '')}'
                  data-start-date='{h(p['start_date'] or '')}'
                  data-due-date='{h(p['due_date'] or '')}'
                  data-progress-pct='{progress}'
                  data-tags='{h(p['tags'] or '')}'
                  data-note='{h(note)}'
                  data-attachments='{h(chr(10).join(attachments))}'>
                  <div class='card-topline'>
                    <h5 class='card-title-label'>{h(p['name'])}</h5>
                    <div class='inline'>
                      <select class='quick-status' data-entity='project' data-id='{p['id']}' aria-label='Status for {h(p["name"])}'>
                        {''.join([f"<option {'selected' if p['status'] == s else ''}>{h(s)}</option>" for s in PROJECT_STATUSES])}
                      </select>
                      <span class='pill'>{h(p['priority'])}</span>
                      {attach_badge}
                    </div>
                  </div>
                  <p class='muted meta-line-1'>{h(p['lane'])} · {h(p['team_name'] or 'No team')} · {h(p['space_name'] or 'No space')}</p>
                  <p class='muted meta-line-2'>Owner: {h(p['owner_name'] or '-')} · Due: {h(p['due_date'] or '-')}</p>
                  <p class='muted meta-line-3'>{h(snippet or 'No description yet.')}</p>
                  <div class='progress'><span style='width:{progress}%'></span></div>
                  <p class='card-hint'>Click to edit · Drag to move</p>
                </article>
                """
            )
        card_html = "".join(card_chunks) or "<p class='muted'>No projects in this status.</p>"
        columns.append(
            f"<section class='kanban-col' data-status='{h(status)}'>{kanban_header(status, len(cards))}<div class='kanban-col-body drop-zone' data-entity='project' data-status='{h(status)}'>{card_html}</div></section>"
        )
    project_rows = "".join(
        [
            f"""
            <tr>
              <td><button type='button' class='linkish list-open' data-list-entity='project' data-list-id='{p['id']}'>{h(p['name'])}</button></td>
              <td>
                <select class='quick-field list-quick-field' data-entity='project' data-id='{p['id']}' data-field='lane' aria-label='Project lane for {h(p["name"])}'>
                  {''.join([f"<option {'selected' if p['lane'] == lane else ''}>{h(lane)}</option>" for lane in LANES])}
                </select>
              </td>
              <td>
                <select class='quick-status list-quick-status' data-entity='project' data-id='{p['id']}' aria-label='Project status for {h(p["name"])}'>
                  {''.join([f"<option {'selected' if p['status'] == s else ''}>{h(s)}</option>" for s in PROJECT_STATUSES])}
                </select>
              </td>
              <td>
                <select class='quick-field list-quick-field' data-entity='project' data-id='{p['id']}' data-field='priority' aria-label='Project priority for {h(p["name"])}'>
                  {''.join([f"<option {'selected' if p['priority'] == v else ''}>{v}</option>" for v in ['Low','Medium','High','Critical']])}
                </select>
              </td>
              <td>
                <select class='quick-field list-quick-field' data-entity='project' data-id='{p['id']}' data-field='owner_user_id' aria-label='Project owner for {h(p["name"])}'>
                  <option value=''>Unassigned</option>
                  {''.join([f"<option value='{u['id']}' {'selected' if str(p['owner_user_id'] or '') == str(u['id']) else ''}>{h(u['name'])}</option>" for u in users])}
                </select>
              </td>
              <td>
                <select class='quick-field list-quick-field' data-entity='project' data-id='{p['id']}' data-field='team_id' aria-label='Project team for {h(p["name"])}'>
                  <option value=''>No team</option>
                  {''.join([f"<option value='{row['id']}' {'selected' if str(p['team_id'] or '') == str(row['id']) else ''}>{h(row['name'])}</option>" for row in teams])}
                </select>
              </td>
              <td>
                <select class='quick-field list-quick-field' data-entity='project' data-id='{p['id']}' data-field='space_id' aria-label='Project space for {h(p["name"])}'>
                  <option value=''>No space</option>
                  {''.join([f"<option value='{row['id']}' {'selected' if str(p['space_id'] or '') == str(row['id']) else ''}>{h(row['name'])}</option>" for row in spaces])}
                </select>
              </td>
              <td><input type='date' class='quick-field list-quick-field due-input' data-entity='project' data-id='{p['id']}' data-field='due_date' value='{h(p['due_date'] or '')}' aria-label='Project due date for {h(p["name"])}' /></td>
            </tr>
            """
            for p in projects[:220]
        ]
    ) or "<tr><td colspan='8'>No projects yet.</td></tr>"

    return f"""
    <section class=\"card maker-hero\">
      <h2>Makerspace Portfolio Board</h2>
      <p>Direct-edit project cards with drag-and-drop status control and shallow drill-down.</p>
      <div class='inline-actions'>{''.join(project_team_filters)}</div>
    </section>
    {board_mode_toggle("projects")}
    <section id='project-kanban' class='kanban-board' data-statuses='{"|".join(PROJECT_STATUSES)}' data-view-surface='projects' data-view-mode='kanban'>
      {''.join(columns)}
    </section>
    <section class='card board-list-surface' data-view-surface='projects' data-view-mode='list' hidden>
      <h3>Project List</h3>
      <table>
        <thead><tr><th>Project</th><th>Lane</th><th>Status</th><th>Priority</th><th>Owner</th><th>Team</th><th>Space</th><th>Due</th></tr></thead>
        <tbody>{project_rows}</tbody>
      </table>
    </section>
    <section class=\"two compact-top\">
      <div class=\"card\">
        <details>
          <summary>Quick Add Project</summary>
          <form method=\"post\" action=\"/projects/new\">
            <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
            <label>Name <input name=\"name\" required /></label>
            <label>Description <textarea name=\"description\"></textarea></label>
            <label>Lane
              <select name=\"lane\">{''.join([f'<option>{h(lane)}</option>' for lane in LANES])}</select>
            </label>
            <label>Status
              <select name=\"status\">{''.join([f'<option>{h(s)}</option>' for s in PROJECT_STATUSES])}</select>
            </label>
            <label>Priority
              <select name=\"priority\"><option>Low</option><option selected>Medium</option><option>High</option><option>Critical</option></select>
            </label>
            <label>Team <select name=\"team_id\"><option value=''>Unassigned</option>{team_opts}</select></label>
            <label>Space <select name=\"space_id\"><option value=''>Unassigned</option>{space_opts}</select></label>
            <label>Owner <select name=\"owner_user_id\"><option value=''>Unassigned</option>{user_opts}</select></label>
            <label>Start Date <input type=\"date\" name=\"start_date\" /></label>
            <label>Due Date <input type=\"date\" name=\"due_date\" /></label>
            <label>Progress % <input type=\"number\" min=\"0\" max=\"100\" name=\"progress_pct\" value=\"0\" /></label>
            <label>Tags <input name=\"tags\" placeholder=\"ops,school:SET\" /></label>
            <button type=\"submit\">Create Project</button>
          </form>
        </details>
      </div>
      <div class=\"card\">
        <h3>Data Operations</h3>
        <p>Import/export is centralized in Data Hub to keep execution views focused on live work.</p>
        <a class=\"btn\" href=\"{h(with_space('/data-hub', selected_space_id))}\">Open Data Hub</a>
      </div>
    </section>
    """


def render_task_page(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    selected_team_id: Optional[int] = None,
    selected_space_id: Optional[int] = None,
) -> str:
    my_count = query_scalar(
        conn,
        "SELECT COUNT(*) FROM tasks WHERE organization_id = ? AND deleted_at IS NULL AND assignee_user_id = ? AND status NOT IN ('Done', 'Cancelled')",
        (org_id, user_id),
    )
    week_count = query_scalar(
        conn,
        "SELECT COUNT(*) FROM tasks WHERE organization_id = ? AND deleted_at IS NULL AND assignee_user_id = ? AND status NOT IN ('Done', 'Cancelled') AND (due_date IS NULL OR due_date <= ?)",
        (org_id, user_id, (dt.date.today() + dt.timedelta(days=7)).isoformat()),
    )
    team_count = query_scalar(
        conn,
        "SELECT COUNT(*) FROM tasks WHERE organization_id = ? AND deleted_at IS NULL AND status NOT IN ('Done', 'Cancelled')",
        (org_id,),
    )
    default_scope = "my"
    if my_count < 5:
        default_scope = "week" if week_count >= 5 else "team"

    tasks = fetch_tasks(conn, org_id, user_id, scope=default_scope, team_id=selected_team_id, space_id=selected_space_id)
    grouped = split_rows_by_status(tasks, TASK_STATUSES)
    teams = get_teams_for_org(conn, org_id)
    team_filter_buttons = [
        f"<button type='button' class='btn team-filter-btn {'active' if selected_team_id is None else ''}' data-task-team=''>All Teams</button>"
    ]
    for team in teams:
        is_active = selected_team_id == int(team["id"])
        team_filter_buttons.append(
            f"<button type='button' class='btn team-filter-btn {'active' if is_active else ''}' data-task-team='{team['id']}'>{h(team['name'])}</button>"
        )

    columns: List[str] = []
    for status in TASK_STATUSES:
        col_tasks = grouped[status]
        card_chunks: List[str] = []
        for t in col_tasks:
            meta = parse_meta_json(t["meta_json"])
            attachments = [x for x in meta.get("attachments", []) if isinstance(x, str)]
            note = str(meta.get("note", ""))[:500]
            attach_badge = f"<span class='pill soft'>+{len(attachments)} refs</span>" if attachments else ""
            snippet = (t["description"] or "").strip()
            if len(snippet) > 100:
                snippet = snippet[:100].rstrip() + "..."
            card_chunks.append(
                f"""
                <article class='kanban-card interactive-card task-card'
                  draggable='true'
                  tabindex='0'
                  data-entity='task'
                  data-id='{t['id']}'
                  data-title='{h(t['title'])}'
                  data-description='{h(t['description'] or '')}'
                  data-status='{h(t['status'] or '')}'
                  data-priority='{h(t['priority'] or 'Medium')}'
                  data-assignee-id='{h(t['assignee_user_id'] or '')}'
                  data-project-id='{h(t['project_id'] or '')}'
                  data-team-id='{h(t['team_id'] or '')}'
                  data-space-id='{h(t['space_id'] or '')}'
                  data-due-date='{h(t['due_date'] or '')}'
                  data-energy='{h(t['energy'] or 'Medium')}'
                  data-estimate-hours='{h(t['estimate_hours'] or 0)}'
                  data-note='{h(note)}'
                  data-attachments='{h(chr(10).join(attachments))}'>
                  <div class='card-topline'>
                    <h5 class='card-title-label'>{h(t['title'])}</h5>
                    <div class='inline'>
                      <select class='quick-status' data-entity='task' data-id='{t['id']}' aria-label='Status for {h(t["title"])}'>
                        {''.join([f"<option {'selected' if t['status'] == s else ''}>{h(s)}</option>" for s in TASK_STATUSES])}
                      </select>
                      <span class='pill'>{h(t['priority'])}</span>
                      {attach_badge}
                    </div>
                  </div>
                  <p class='muted meta-line-1'>{h(t['project_name'] or 'No project')} · {h(t['assignee_name'] or 'Unassigned')}</p>
                  <p class='muted meta-line-2'>Due: {h(t['due_date'] or '-')} · Energy: {h(t['energy'] or '-')} · Team: {h(t['team_name'] or '-')}</p>
                  <p class='muted meta-line-3'>{h(snippet or 'No description provided.')}</p>
                  <p class='card-hint'>Click to edit · Drag to move</p>
                </article>
                """
            )
        cards = "".join(card_chunks) or "<p class='muted'>No tasks in this status.</p>"
        columns.append(
            f"<section class='kanban-col' data-status='{h(status)}'>{kanban_header(status, len(col_tasks))}<div class='kanban-col-body drop-zone' data-entity='task' data-status='{h(status)}'>{cards}</div></section>"
        )

    return f"""
    <section class=\"card maker-hero\">
      <h2>Execution Kanban</h2>
      <p>Drag tasks across statuses and click any card for full editable details in a pop-up editor.</p>
    </section>
    <section class=\"two compact-top\">
      <div class=\"card\">
        <h3>Board Scope</h3>
        <p class=\"muted\">My open: <strong>{my_count}</strong> | Week due: <strong>{week_count}</strong> | Team open: <strong>{team_count}</strong></p>
        <div class=\"inline-actions\">
          <button type=\"button\" class=\"btn scope-btn {'active' if default_scope == 'my' else ''}\" data-task-scope=\"my\" aria-pressed=\"{'true' if default_scope == 'my' else 'false'}\">My Day</button>
          <button type=\"button\" class=\"btn scope-btn {'active' if default_scope == 'week' else ''}\" data-task-scope=\"week\" aria-pressed=\"{'true' if default_scope == 'week' else 'false'}\">My Week</button>
          <button type=\"button\" class=\"btn scope-btn {'active' if default_scope == 'team' else ''}\" data-task-scope=\"team\" aria-pressed=\"{'true' if default_scope == 'team' else 'false'}\">Team</button>
        </div>
        <p class=\"muted\">Team filter</p>
        <div class=\"inline-actions\">
          {''.join(team_filter_buttons)}
        </div>
        <label for=\"task-search\">Search task board</label>
        <input id=\"task-search\" aria-label=\"Search task board\" placeholder=\"project, title, status...\" />
      </div>
      <div class=\"card\">
        <h3>Quick Add Task + Exports</h3>
        <p class=\"muted\">Use the top-level <strong>New Task</strong> button to open the quick-add editor from any page.</p>
        <p class=\"muted\">All exports are centralized in <strong>Data Hub</strong> to keep this view focused on live execution.</p>
      </div>
    </section>
    {board_mode_toggle("tasks")}
    <section id=\"task-kanban\" class='kanban-board' data-initial-scope=\"{default_scope}\" data-initial-team-id=\"{selected_team_id or ''}\" data-statuses='{"|".join(TASK_STATUSES)}' data-view-surface='tasks' data-view-mode='kanban'>
      {''.join(columns)}
    </section>
    <section class='card board-list-surface' data-view-surface='tasks' data-view-mode='list' hidden>
      <h3>Task List</h3>
      <table>
        <thead><tr><th>Task</th><th>Project</th><th>Status</th><th>Priority</th><th>Owner</th><th>Team</th><th>Space</th><th>Due</th></tr></thead>
        <tbody id='task-list-body'>
          <tr><td colspan='8'>Loading tasks...</td></tr>
        </tbody>
      </table>
    </section>
    """


def fetch_tasks(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    scope: str = "my",
    search: str = "",
    team_id: Optional[int] = None,
    space_id: Optional[int] = None,
) -> List[sqlite3.Row]:
    params: List[object] = [org_id]
    where = ["t.organization_id = ?", "t.deleted_at IS NULL"]

    if scope == "my":
        where.append("t.assignee_user_id = ?")
        params.append(user_id)
    elif scope == "week":
        where.append("t.assignee_user_id = ?")
        params.append(user_id)
        week_end = (dt.date.today() + dt.timedelta(days=7)).isoformat()
        where.append("(t.due_date IS NULL OR t.due_date <= ?)")
        params.append(week_end)

    if search:
        where.append("(LOWER(t.title) LIKE ? OR LOWER(COALESCE(p.name,'')) LIKE ? OR LOWER(t.status) LIKE ?)")
        needle = f"%{search.lower()}%"
        params.extend([needle, needle, needle])
    if team_id:
        where.append("t.team_id = ?")
        params.append(team_id)
    if space_id:
        where.append("t.space_id = ?")
        params.append(space_id)

    query = f"""
    SELECT t.*, p.name as project_name, u.name as assignee_name, tm.name AS team_name, sp.name AS space_name
    FROM tasks t
    LEFT JOIN projects p ON p.id = t.project_id
    LEFT JOIN users u ON u.id = t.assignee_user_id
    LEFT JOIN teams tm ON tm.id = t.team_id
    LEFT JOIN spaces sp ON sp.id = t.space_id
    WHERE {' AND '.join(where)}
    ORDER BY
      CASE t.priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 ELSE 4 END,
      COALESCE(t.due_date, '9999-12-31')
    LIMIT 300
    """
    return conn.execute(query, tuple(params)).fetchall()


def render_task_rows(tasks: Iterable[sqlite3.Row]) -> str:
    rows = []
    for t in tasks:
        rows.append(
            f"""
            <tr>
              <td>{h(t['title'])}</td>
              <td>{h(t['project_name'] or '-')}</td>
              <td>{h(t['assignee_name'] or '-')}</td>
              <td>{h(t['status'])}</td>
              <td>{h(t['priority'])}</td>
              <td>{h(t['due_date'] or '-')}</td>
              <td>{h(t['energy'] or '-')}</td>
              <td>
                <form method=\"post\" action=\"/tasks/update\" class=\"inline\">
                  <input type=\"hidden\" name=\"task_id\" value=\"{t['id']}\" />
                  <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
                  <select name=\"status\" aria-label=\"Update status for {h(t['title'])}\">
                    {''.join([f"<option {'selected' if t['status']==s else ''}>{s}</option>" for s in ['Todo','In Progress','Blocked','Done','Cancelled']])}
                  </select>
                  <button type=\"submit\" aria-label=\"Save status for {h(t['title'])}\">Save</button>
                </form>
              </td>
            </tr>
            """
        )
    return "".join(rows) or "<tr><td colspan='8'>No tasks match this filter.</td></tr>"


def render_agenda_page(conn: sqlite3.Connection, org_id: int, selected_agenda_id: Optional[int] = None) -> str:
    agendas = conn.execute(
        """
        SELECT a.id, a.title, a.meeting_date, a.notes, u.name AS owner_name,
               (SELECT COUNT(*) FROM meeting_items i WHERE i.agenda_id = a.id) AS total_items,
               (SELECT COUNT(*) FROM meeting_items i WHERE i.agenda_id = a.id AND i.status != 'Done') AS open_items
        FROM meeting_agendas a
        LEFT JOIN users u ON u.id = a.owner_user_id
        WHERE a.organization_id = ?
        ORDER BY a.meeting_date DESC, a.id DESC
        LIMIT 60
        """,
        (org_id,),
    ).fetchall()
    agenda_ids = {int(a["id"]) for a in agendas}
    selected_id = int(selected_agenda_id) if selected_agenda_id and int(selected_agenda_id) in agenda_ids else None
    if selected_id is None and agendas:
        selected_id = int(agendas[0]["id"])

    selected_agenda = next((a for a in agendas if int(a["id"]) == int(selected_id or 0)), None)
    items: List[sqlite3.Row] = []
    if selected_id is not None:
        items = conn.execute(
            """
            SELECT i.*, u.name AS owner_name
            FROM meeting_items i
            LEFT JOIN users u ON u.id = i.owner_user_id
            WHERE i.agenda_id = ?
            ORDER BY i.sort_order, i.id
            """,
            (selected_id,),
        ).fetchall()

    note_sql = """
        SELECT n.*, u.name AS author_name
        FROM meeting_note_sources n
        LEFT JOIN users u ON u.id = n.created_by
        WHERE n.organization_id = ?
    """
    note_params: List[object] = [org_id]
    if selected_id is not None:
        note_sql += " AND (n.linked_agenda_id = ? OR n.linked_agenda_id IS NULL)"
        note_sql += " ORDER BY CASE WHEN n.linked_agenda_id = ? THEN 0 ELSE 1 END, n.updated_at DESC"
        note_params.extend([selected_id, selected_id])
    else:
        note_sql += " ORDER BY n.updated_at DESC"
    note_sql += " LIMIT 80"
    note_sources = conn.execute(note_sql, tuple(note_params)).fetchall()

    agenda_opts = "".join(
        [
            f"<option value='{a['id']}' {'selected' if int(a['id']) == int(selected_id or 0) else ''}>{h(a['meeting_date'])} - {h(a['title'])}</option>"
            for a in agendas
        ]
    )
    item_rows = "".join(
        [
            f"""
            <tr>
              <td>{h(i['section'])}</td>
              <td>{h(i['title'])}</td>
              <td>{h(i['owner_name'] or '-')}</td>
              <td>
                <form method='post' action='/agenda/item/update' class='inline-form'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='item_id' value='{i['id']}' />
                  <select name='status' aria-label='Status for {h(i["title"])}'>
                    {''.join([f"<option {'selected' if i['status'] == s else ''}>{h(s)}</option>" for s in ['Open', 'In Progress', 'Done']])}
                  </select>
                  <input type='number' name='minutes_estimate' value='{h(i['minutes_estimate'] or 10)}' min='1' aria-label='Minutes for {h(i["title"])}' />
                  <button type='submit'>Save</button>
                </form>
              </td>
            </tr>
            """
            for i in items
        ]
    ) or "<tr><td colspan='4'>No agenda items yet.</td></tr>"
    note_rows = "".join(
        [
            f"""
            <article class='note-card'>
              <h4>{h(n['title'])}</h4>
              <p class='muted'>{h(n['source_type'])} · by {h(n['author_name'] or 'unknown')}</p>
              <p>{h((n['body'] or '')[:280])}{'…' if n['body'] and len(n['body']) > 280 else ''}</p>
              {"<p><a href='"+h(n['doc_url'])+"' target='_blank' rel='noreferrer'>Open Google Doc</a></p>" if n['doc_url'] else ''}
            </article>
            """
            for n in note_sources
        ]
    ) or "<p class='muted'>No note sources linked yet.</p>"

    meeting_rows = "".join(
        [
            f"""
            <tr>
              <td><a href='{h(with_space(f"/agenda?agenda_id={a['id']}"))}'>{h(a['meeting_date'])}</a></td>
              <td>{h(a['title'])}</td>
              <td>{h(a['owner_name'] or '-')}</td>
              <td>{h(a['open_items'])}/{h(a['total_items'])}</td>
            </tr>
            """
            for a in agendas
        ]
    ) or "<tr><td colspan='4'>No meetings recorded yet.</td></tr>"

    return f"""
    <section class='card maker-hero'>
      <h2>Meeting Operations Hub</h2>
      <p>Run recurring meetings (FTE weekly, student weekly, subcommittees), keep a decision-ready agenda, and preserve history.</p>
    </section>
    <section class="two">
      <div class="card">
        <h3>Create Meeting Record</h3>
        <form method="post" action="/agenda/new">
          <input type="hidden" name="csrf_token" value="{{csrf}}" />
          <label>Meeting Name <input name="title" required value="Weekly Makerspace Tactical Meeting" /></label>
          <label>Date <input type="date" name="meeting_date" required value="{dt.date.today().isoformat()}" /></label>
          <label>Context / Notes <textarea name="notes">Use lane WIP review and decision log discipline.</textarea></label>
          <button type="submit">Create Meeting</button>
        </form>
      </div>
      <div class="card">
        <h3>Meeting History</h3>
        <table>
          <thead><tr><th>Date</th><th>Meeting</th><th>Owner</th><th>Open/Total</th></tr></thead>
          <tbody>{meeting_rows}</tbody>
        </table>
      </div>
    </section>
    <section class="two">
      <div class="card">
        <h3>Active Meeting Agenda</h3>
        <p class='muted'>Now editing: <strong>{h((selected_agenda['meeting_date'] + " - " + selected_agenda['title']) if selected_agenda else 'None selected')}</strong></p>
        <form method="post" action="/agenda/item/new" class="inline-form">
          <input type="hidden" name="csrf_token" value="{{csrf}}" />
          <label>Meeting <select name="agenda_id">{agenda_opts}</select></label>
          <label>Section <input name="section" required placeholder="Metrics Pulse" /></label>
          <label>Item <input name="title" required /></label>
          <label>Owner <select name='owner_user_id'><option value=''>Unassigned</option>{''.join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in get_users_for_org(conn, org_id)])}</select></label>
          <label>Minutes <input type="number" name="minutes_estimate" value="10" min="1" /></label>
          <button type="submit">Add Item</button>
        </form>
        <table>
          <thead><tr><th>Section</th><th>Item</th><th>Owner</th><th>Status / Minutes</th></tr></thead>
          <tbody>{item_rows}</tbody>
        </table>
      </div>
      <div class="card">
        <h3>Google Docs Notes Integration</h3>
        <form method="post" action="/agenda/note/new">
          <input type="hidden" name="csrf_token" value="{{csrf}}" />
          <label>Title <input name="title" required placeholder="Weekly Ops Notes" /></label>
          <label>Link to Meeting <select name='agenda_id'><option value=''>General Notes</option>{agenda_opts}</select></label>
          <label>Google Doc URL <input name="doc_url" placeholder="https://docs.google.com/document/d/..." /></label>
          <label>Summary/Excerpt <textarea name="body" placeholder="Optional summary or pasted notes."></textarea></label>
          <button type="submit">Add Note Source</button>
        </form>
        <div class='notes-grid'>{note_rows}</div>
      </div>
    </section>
    <section class="card">
      <h3>Recommended Meeting Flow</h3>
      <ol>
        <li>Metrics pulse (reach, throughput, open risk)</li>
        <li>WIP and capacity by lane and makerspace</li>
        <li>Risks and blockers needing escalation</li>
        <li>Decisions with accountable owner and due date</li>
        <li>Upcoming events/workshops and onboarding needs</li>
      </ol>
    </section>
    """


def parse_google_csv(content: str) -> List[dict]:
    rows: List[dict] = []
    reader = csv.DictReader(io.StringIO(content))
    for raw in reader:
        title = raw.get("Subject") or raw.get("Title") or raw.get("Event Title") or raw.get("Summary") or "Untitled"

        start_raw = (
            raw.get("Start")
            or f"{raw.get('Start Date', '')} {raw.get('Start Time', '')}".strip()
            or raw.get("Start Date")
            or ""
        )
        end_raw = (
            raw.get("End")
            or f"{raw.get('End Date', '')} {raw.get('End Time', '')}".strip()
            or raw.get("End Date")
            or ""
        )
        start_at = parse_datetime(start_raw)
        end_at = parse_datetime(end_raw)
        if not start_at:
            continue
        if not end_at:
            start_dt = dt.datetime.fromisoformat(start_at)
            end_at = (start_dt + dt.timedelta(hours=1)).isoformat()

        description = raw.get("Description", "")
        location = raw.get("Location", "")
        attendees = raw.get("Attendees") or raw.get("Guests") or ""
        attendee_count = len([x for x in attendees.split(",") if x.strip()]) if attendees else None
        category = classify_calendar_event(title, description)
        rows.append(
            {
                "title": title,
                "start_at": start_at,
                "end_at": end_at,
                "description": description,
                "location": location,
                "attendees_count": attendee_count,
                "category": category,
                "source": "google_csv",
            }
        )
    return rows


def parse_ics(content: str) -> List[dict]:
    rows: List[dict] = []
    blocks = content.split("BEGIN:VEVENT")
    for block in blocks[1:]:
        title = "Untitled"
        description = ""
        location = ""
        start_raw = ""
        end_raw = ""
        for line in block.splitlines():
            line = line.strip()
            if line.startswith("SUMMARY:"):
                title = line.split(":", 1)[1].strip()
            elif line.startswith("DESCRIPTION:"):
                description = line.split(":", 1)[1].strip()
            elif line.startswith("LOCATION:"):
                location = line.split(":", 1)[1].strip()
            elif line.startswith("DTSTART"):
                start_raw = line.split(":", 1)[1].strip()
            elif line.startswith("DTEND"):
                end_raw = line.split(":", 1)[1].strip()

        def parse_ics_dt(value: str) -> Optional[str]:
            if not value:
                return None
            for fmt in ("%Y%m%dT%H%M%SZ", "%Y%m%dT%H%M%S", "%Y%m%d"):
                try:
                    parsed = dt.datetime.strptime(value, fmt)
                    if fmt == "%Y%m%d":
                        parsed = parsed.replace(hour=9)
                    return parsed.replace(tzinfo=dt.timezone.utc).isoformat()
                except ValueError:
                    continue
            return None

        start_at = parse_ics_dt(start_raw)
        end_at = parse_ics_dt(end_raw)
        if not start_at:
            continue
        if not end_at:
            end_at = (dt.datetime.fromisoformat(start_at) + dt.timedelta(hours=1)).isoformat()

        rows.append(
            {
                "title": title,
                "start_at": start_at,
                "end_at": end_at,
                "description": description,
                "location": location,
                "attendees_count": None,
                "category": classify_calendar_event(title, description),
                "source": "ics",
            }
        )
    return rows


def calendar_analytics(events: List[sqlite3.Row]) -> Dict[str, object]:
    category_hours: Dict[str, float] = {}
    weekday_hours: Dict[str, float] = {d: 0.0 for d in ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]}
    after_hours = 0.0
    weekend_hours = 0.0

    for row in events:
        try:
            start = dt.datetime.fromisoformat(row["start_at"])
            end = dt.datetime.fromisoformat(row["end_at"])
        except ValueError:
            continue
        hours = max(0.0, (end - start).total_seconds() / 3600.0)
        cat = row["category"] or "Other"
        category_hours[cat] = category_hours.get(cat, 0.0) + hours

        weekday = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][start.weekday()]
        weekday_hours[weekday] += hours

        if start.hour < 8 or end.hour >= 18:
            after_hours += hours
        if start.weekday() >= 5:
            weekend_hours += hours

    return {
        "category_hours": {k: round(v, 1) for k, v in sorted(category_hours.items(), key=lambda item: item[1], reverse=True)},
        "weekday_hours": {k: round(v, 1) for k, v in weekday_hours.items()},
        "after_hours": round(after_hours, 1),
        "weekend_hours": round(weekend_hours, 1),
        "event_count": len(events),
        "total_hours": round(sum(category_hours.values()), 1),
    }


def report_payload_empty(metric_key: str, note: str = "No data available yet.") -> Dict[str, object]:
    meta = report_metric_by_key(metric_key) or {}
    return {
        "key": metric_key,
        "name": str(meta.get("name") or metric_key.replace("_", " ").title()),
        "description": str(meta.get("description") or ""),
        "labels": [],
        "values": [],
        "unit": "count",
        "note": note,
    }


def report_payload(metric_key: str, labels: List[str], values: List[float], unit: str, note: str = "") -> Dict[str, object]:
    meta = report_metric_by_key(metric_key) or {}
    cleaned_labels = [str(label) for label in labels]
    cleaned_values = [round(float(value), 2) for value in values]
    return {
        "key": metric_key,
        "name": str(meta.get("name") or metric_key.replace("_", " ").title()),
        "description": str(meta.get("description") or ""),
        "labels": cleaned_labels,
        "values": cleaned_values,
        "unit": unit,
        "note": note,
    }


def month_label_from_key(month_key: str) -> str:
    try:
        parsed = dt.datetime.strptime(month_key + "-01", "%Y-%m-%d").date()
        return parsed.strftime("%b %Y")
    except ValueError:
        return month_key


def report_metric_payloads(
    conn: sqlite3.Connection,
    org_id: int,
    selected_space_id: Optional[int] = None,
) -> Dict[str, Dict[str, object]]:
    data: Dict[str, Dict[str, object]] = {}
    today = dt.date.today()
    space_name = ""
    if selected_space_id:
        row = conn.execute(
            "SELECT name FROM spaces WHERE id = ? AND organization_id = ?",
            (selected_space_id, org_id),
        ).fetchone()
        space_name = str(row["name"]) if row else ""

    # Tasks by status
    task_rows = conn.execute(
        f"""
        SELECT status, COUNT(*) AS c
        FROM tasks
        WHERE organization_id = ? AND deleted_at IS NULL {'AND space_id = ?' if selected_space_id else ''}
        GROUP BY status
        """,
        tuple([org_id] + ([selected_space_id] if selected_space_id else [])),
    ).fetchall()
    task_counts = {str(r["status"]): int(r["c"] or 0) for r in task_rows}
    task_labels = [status for status in TASK_STATUSES if task_counts.get(status, 0) > 0]
    for label in sorted(task_counts.keys()):
        if label not in task_labels:
            task_labels.append(label)
    data["tasks_by_status"] = report_payload(
        "tasks_by_status",
        task_labels,
        [task_counts.get(label, 0) for label in task_labels],
        unit="tasks",
    )

    # Projects by status
    project_rows = conn.execute(
        f"""
        SELECT status, COUNT(*) AS c
        FROM projects
        WHERE organization_id = ? AND deleted_at IS NULL {'AND space_id = ?' if selected_space_id else ''}
        GROUP BY status
        """,
        tuple([org_id] + ([selected_space_id] if selected_space_id else [])),
    ).fetchall()
    project_counts = {str(r["status"]): int(r["c"] or 0) for r in project_rows}
    project_labels = [status for status in PROJECT_STATUSES if project_counts.get(status, 0) > 0]
    for label in sorted(project_counts.keys()):
        if label not in project_labels:
            project_labels.append(label)
    data["projects_by_status"] = report_payload(
        "projects_by_status",
        project_labels,
        [project_counts.get(label, 0) for label in project_labels],
        unit="projects",
    )

    # Projects by lane
    lane_rows = conn.execute(
        f"""
        SELECT lane, COUNT(*) AS c
        FROM projects
        WHERE organization_id = ? AND deleted_at IS NULL {'AND space_id = ?' if selected_space_id else ''}
        GROUP BY lane
        """,
        tuple([org_id] + ([selected_space_id] if selected_space_id else [])),
    ).fetchall()
    lane_counts = {str(r["lane"]): int(r["c"] or 0) for r in lane_rows}
    lane_labels = [lane for lane in LANES if lane_counts.get(lane, 0) > 0]
    for label in sorted(lane_counts.keys()):
        if label not in lane_labels:
            lane_labels.append(label)
    data["projects_by_lane"] = report_payload(
        "projects_by_lane",
        lane_labels,
        [lane_counts.get(label, 0) for label in lane_labels],
        unit="projects",
    )

    # Intake by status
    intake_rows = conn.execute(
        """
        SELECT status, COUNT(*) AS c
        FROM intake_requests
        WHERE organization_id = ? AND deleted_at IS NULL
        GROUP BY status
        """,
        (org_id,),
    ).fetchall()
    intake_counts = {str(r["status"]): int(r["c"] or 0) for r in intake_rows}
    intake_labels = [status for status in INTAKE_STATUSES if intake_counts.get(status, 0) > 0]
    for label in sorted(intake_counts.keys()):
        if label not in intake_labels:
            intake_labels.append(label)
    data["intake_by_status"] = report_payload(
        "intake_by_status",
        intake_labels,
        [intake_counts.get(label, 0) for label in intake_labels],
        unit="requests",
    )

    # Intake score trend
    score_rows = conn.execute(
        """
        SELECT substr(created_at, 1, 7) AS month_key, AVG(score) AS avg_score
        FROM intake_requests
        WHERE organization_id = ? AND deleted_at IS NULL
        GROUP BY month_key
        ORDER BY month_key
        """,
        (org_id,),
    ).fetchall()
    score_labels = [month_label_from_key(str(r["month_key"])) for r in score_rows if r["month_key"]]
    score_values = [float(r["avg_score"] or 0.0) for r in score_rows if r["month_key"]]
    data["intake_score_by_month"] = report_payload(
        "intake_score_by_month",
        score_labels,
        score_values,
        unit="score",
    )

    # Task completion trend
    done_rows = conn.execute(
        f"""
        SELECT substr(updated_at, 1, 7) AS month_key, COUNT(*) AS done_count
        FROM tasks
        WHERE organization_id = ? AND deleted_at IS NULL AND status = 'Done' {'AND space_id = ?' if selected_space_id else ''}
        GROUP BY month_key
        ORDER BY month_key
        """,
        tuple([org_id] + ([selected_space_id] if selected_space_id else [])),
    ).fetchall()
    done_labels = [month_label_from_key(str(r["month_key"])) for r in done_rows if r["month_key"]]
    done_values = [float(r["done_count"] or 0) for r in done_rows if r["month_key"]]
    data["tasks_completed_by_month"] = report_payload(
        "tasks_completed_by_month",
        done_labels,
        done_values,
        unit="tasks",
    )

    # Calendar hours by category
    category_sql = """
        SELECT COALESCE(NULLIF(TRIM(category), ''), 'Other') AS cat,
               SUM(MAX((julianday(end_at) - julianday(start_at)) * 24.0, 0.0)) AS hours
        FROM calendar_events
        WHERE organization_id = ?
        GROUP BY cat
        ORDER BY hours DESC
    """
    if DB_BACKEND == "postgres":
        category_sql = """
            SELECT COALESCE(NULLIF(TRIM(category), ''), 'Other') AS cat,
                   SUM(GREATEST(EXTRACT(EPOCH FROM ((end_at)::timestamptz - (start_at)::timestamptz)) / 3600.0, 0.0)) AS hours
            FROM calendar_events
            WHERE organization_id = ?
            GROUP BY cat
            ORDER BY hours DESC
        """
    category_rows = conn.execute(category_sql, (org_id,)).fetchall()
    cat_labels = [str(r["cat"]) for r in category_rows]
    cat_values = [float(r["hours"] or 0.0) for r in category_rows]
    data["calendar_hours_by_category"] = report_payload(
        "calendar_hours_by_category",
        cat_labels,
        cat_values,
        unit="hours",
    )

    # Calendar hours by weekday
    weekday_sql = """
        SELECT strftime('%w', start_at) AS weekday_num,
               SUM(MAX((julianday(end_at) - julianday(start_at)) * 24.0, 0.0)) AS hours
        FROM calendar_events
        WHERE organization_id = ?
        GROUP BY weekday_num
    """
    if DB_BACKEND == "postgres":
        weekday_sql = """
            SELECT CAST(EXTRACT(DOW FROM (start_at)::timestamptz) AS TEXT) AS weekday_num,
                   SUM(GREATEST(EXTRACT(EPOCH FROM ((end_at)::timestamptz - (start_at)::timestamptz)) / 3600.0, 0.0)) AS hours
            FROM calendar_events
            WHERE organization_id = ?
            GROUP BY weekday_num
        """
    weekday_rows = conn.execute(weekday_sql, (org_id,)).fetchall()
    weekday_map = {"1": "Mon", "2": "Tue", "3": "Wed", "4": "Thu", "5": "Fri", "6": "Sat", "0": "Sun"}
    weekday_hours = {weekday_map.get(str(r["weekday_num"]), str(r["weekday_num"])): float(r["hours"] or 0.0) for r in weekday_rows}
    weekday_labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    data["calendar_hours_by_weekday"] = report_payload(
        "calendar_hours_by_weekday",
        weekday_labels,
        [weekday_hours.get(day, 0.0) for day in weekday_labels],
        unit="hours",
    )

    # Assets by status
    asset_sql = """
        SELECT status, COUNT(*) AS c
        FROM equipment_assets
        WHERE organization_id = ? AND deleted_at IS NULL
    """
    asset_params: List[object] = [org_id]
    if space_name:
        asset_sql += " AND space = ?"
        asset_params.append(space_name)
    asset_sql += " GROUP BY status"
    asset_rows = conn.execute(asset_sql, tuple(asset_params)).fetchall()
    asset_counts = {str(r["status"]): int(r["c"] or 0) for r in asset_rows}
    asset_labels = [status for status in ASSET_STATUSES if asset_counts.get(status, 0) > 0]
    for label in sorted(asset_counts.keys()):
        if label not in asset_labels:
            asset_labels.append(label)
    data["assets_by_status"] = report_payload(
        "assets_by_status",
        asset_labels,
        [asset_counts.get(label, 0) for label in asset_labels],
        unit="assets",
    )

    # Consumables low/out by space
    low_sql = """
        SELECT COALESCE(s.name, 'Unassigned') AS space_name, COUNT(*) AS c
        FROM consumables c
        LEFT JOIN spaces s ON s.id = c.space_id
        WHERE c.organization_id = ? AND c.deleted_at IS NULL
          AND (c.status IN ('Low','Out') OR c.quantity_on_hand <= c.reorder_point)
    """
    low_params: List[object] = [org_id]
    if selected_space_id is not None:
        low_sql += " AND c.space_id = ?"
        low_params.append(selected_space_id)
    low_sql += " GROUP BY COALESCE(s.name, 'Unassigned') ORDER BY c DESC, space_name"
    low_rows = conn.execute(low_sql, tuple(low_params)).fetchall()
    low_labels = [str(r["space_name"]) for r in low_rows]
    low_values = [float(r["c"] or 0) for r in low_rows]
    data["consumables_low_by_space"] = report_payload(
        "consumables_low_by_space",
        low_labels,
        low_values,
        unit="items",
    )

    # Partnerships by stage
    partner_rows = conn.execute(
        """
        SELECT stage, COUNT(*) AS c
        FROM partnerships
        WHERE organization_id = ? AND deleted_at IS NULL
        GROUP BY stage
        """,
        (org_id,),
    ).fetchall()
    partner_counts = {str(r["stage"]): int(r["c"] or 0) for r in partner_rows}
    partner_labels = [stage for stage in PARTNERSHIP_STAGES if partner_counts.get(stage, 0) > 0]
    for label in sorted(partner_counts.keys()):
        if label not in partner_labels:
            partner_labels.append(label)
    data["partnerships_by_stage"] = report_payload(
        "partnerships_by_stage",
        partner_labels,
        [partner_counts.get(label, 0) for label in partner_labels],
        unit="partnerships",
    )

    # Onboarding completion by role
    onboarding_rows = conn.execute(
        """
        SELECT COALESCE(NULLIF(TRIM(t.role_target), ''), 'Unspecified') AS role_name,
               COUNT(*) AS total_count,
               SUM(CASE WHEN a.status = 'Done' THEN 1 ELSE 0 END) AS done_count
        FROM onboarding_assignments a
        JOIN onboarding_templates t ON t.id = a.template_id
        WHERE a.organization_id = ?
        GROUP BY role_name
        ORDER BY role_name
        """,
        (org_id,),
    ).fetchall()
    onboard_labels = [str(r["role_name"]) for r in onboarding_rows]
    onboard_values = [
        round((float(r["done_count"] or 0.0) / float(r["total_count"] or 1.0)) * 100.0, 2)
        for r in onboarding_rows
    ]
    data["onboarding_completion_by_role"] = report_payload(
        "onboarding_completion_by_role",
        onboard_labels,
        onboard_values,
        unit="percent",
    )

    snapshot_rows = conn.execute(
        "SELECT key, payload_json FROM insight_snapshots WHERE organization_id = ?",
        (org_id,),
    ).fetchall()
    snapshots = {str(row["key"]): parse_meta_json(row["payload_json"]) for row in snapshot_rows}
    dep = snapshots.get("department_metrics", {})

    # Check-ins by space snapshot
    by_space = dep.get("checkins", {}).get("by_space", {}) if isinstance(dep, dict) else {}
    if isinstance(by_space, dict):
        labels = sorted([str(name) for name in by_space.keys()])
        values: List[float] = []
        for label in labels:
            raw = by_space.get(label, {})
            if isinstance(raw, dict):
                values.append(float(raw.get("checkins", 0) or 0))
            else:
                values.append(float(raw or 0))
        data["checkins_by_space_snapshot"] = report_payload(
            "checkins_by_space_snapshot",
            labels,
            values,
            unit="check-ins",
            note="Loaded from annual impact snapshot.",
        )
    else:
        data["checkins_by_space_snapshot"] = report_payload_empty(
            "checkins_by_space_snapshot",
            note="Load department impact snapshots to populate this metric.",
        )

    # Engagement by school snapshot
    school_rows = dep.get("school_reach", {}).get("schools", []) if isinstance(dep, dict) else []
    if isinstance(school_rows, list) and school_rows:
        labels = []
        values = []
        for row in school_rows:
            if not isinstance(row, dict):
                continue
            school = str(row.get("school") or "").strip()
            if not school:
                continue
            labels.append(school)
            values.append(float(row.get("interactions", 0) or 0))
        data["school_reach_interactions"] = report_payload(
            "school_reach_interactions",
            labels,
            values,
            unit="interactions",
            note="Loaded from annual impact snapshot.",
        )
    else:
        data["school_reach_interactions"] = report_payload_empty(
            "school_reach_interactions",
            note="Load department impact snapshots to populate this metric.",
        )

    # Internal vs outward-facing capacity snapshot
    allocation = dep.get("school_reach", {}).get("allocation_option_a", []) if isinstance(dep, dict) else []
    if isinstance(allocation, list) and allocation:
        internal = 0.0
        outward = 0.0
        for row in allocation:
            if not isinstance(row, dict):
                continue
            internal += float(row.get("internal_ops", 0) or 0)
            outward += float(row.get("outward_facing", 0) or 0)
        ratio_note = ""
        if outward > 0:
            ratio_note = f"Internal:Outward ratio is {round(internal / outward, 2)}:1."
        data["internal_vs_outward_snapshot"] = report_payload(
            "internal_vs_outward_snapshot",
            ["Internal Ops", "Outward Facing"],
            [internal, outward],
            unit="effort units",
            note=ratio_note or "Loaded from annual impact snapshot.",
        )
    else:
        data["internal_vs_outward_snapshot"] = report_payload_empty(
            "internal_vs_outward_snapshot",
            note="Load department impact snapshots to populate this metric.",
        )

    # Ensure every metric key exists for the editor and preview.
    for metric in REPORT_METRIC_LIBRARY:
        key = str(metric.get("key"))
        if key not in data:
            data[key] = report_payload_empty(key)
    return data


def render_calendar_page(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    selected_space_id: Optional[int] = None,
    view_mode: str = "week",
    anchor_date_value: str = "",
) -> str:
    if view_mode not in {"week", "month"}:
        view_mode = "week"
    anchor_date = parse_iso_date(anchor_date_value) or dt.date.today()
    current_week_start = week_start(anchor_date)
    month_first, month_last = month_bounds(anchor_date)
    if view_mode == "month":
        range_start = week_start(month_first)
        range_end = week_start(month_last) + dt.timedelta(days=6)
        period_label = anchor_date.strftime("%B %Y")
        prev_anchor = month_first - dt.timedelta(days=1)
        next_anchor = month_last + dt.timedelta(days=1)
    else:
        range_start = current_week_start
        range_end = current_week_start + dt.timedelta(days=6)
        period_label = f"{range_start.strftime('%b %d')} - {range_end.strftime('%b %d, %Y')}"
        prev_anchor = anchor_date - dt.timedelta(days=7)
        next_anchor = anchor_date + dt.timedelta(days=7)

    tz_name = user_timezone_name(conn, user_id)
    tzinfo = safe_timezone(tz_name)
    settings = load_calendar_sync_settings(conn, org_id, user_id)
    calendar_id = str(settings.get("calendar_id") or GCAL_DEFAULT_CALENDAR_ID or "primary")
    lookback_days = int(settings.get("lookback_days") or 30)
    lookahead_days = int(settings.get("lookahead_days") or 45)
    push_window_days = int(settings.get("push_window_days") or 30)
    last_pull = format_local_dt(settings.get("last_pull_at"), tzinfo, "Never")
    last_push = format_local_dt(settings.get("last_push_at"), tzinfo, "Never")

    events = conn.execute(
        "SELECT * FROM calendar_events WHERE organization_id = ? ORDER BY start_at DESC LIMIT 1800",
        (org_id,),
    ).fetchall()
    analytics = calendar_analytics(events)

    events_by_day: Dict[dt.date, List[Tuple[sqlite3.Row, dt.datetime, dt.datetime]]] = {}
    for row in events:
        start_local = localize_iso_datetime(row["start_at"], tzinfo)
        end_local = localize_iso_datetime(row["end_at"], tzinfo)
        if not start_local:
            continue
        if not end_local:
            end_local = start_local + dt.timedelta(hours=1)
        day = start_local.date()
        if range_start <= day <= range_end:
            events_by_day.setdefault(day, []).append((row, start_local, end_local))
    for values in events_by_day.values():
        values.sort(key=lambda item: item[1])

    task_query = """
        SELECT t.id, t.title, t.due_date, t.status, t.priority, u.name AS assignee_name
        FROM tasks t
        LEFT JOIN users u ON u.id = t.assignee_user_id
        WHERE t.organization_id = ? AND t.deleted_at IS NULL AND t.status NOT IN ('Done','Cancelled') AND t.due_date >= ? AND t.due_date <= ?
    """
    task_params: List[object] = [org_id, range_start.isoformat(), range_end.isoformat()]
    if selected_space_id:
        task_query += " AND t.space_id = ?"
        task_params.append(selected_space_id)
    task_query += """
        ORDER BY t.due_date, CASE t.priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 ELSE 4 END
        LIMIT 250
    """
    due_tasks_window = conn.execute(task_query, tuple(task_params)).fetchall()
    due_tasks_by_day: Dict[dt.date, List[sqlite3.Row]] = {}
    for task in due_tasks_window:
        due = parse_iso_date(task["due_date"])
        if due:
            due_tasks_by_day.setdefault(due, []).append(task)

    cat_rows = "".join(
        [
            f"<tr><td>{h(cat)}</td><td>{hours}</td><td><div class='bar'><span style='width:{min(100, int(hours * 2.5))}%'></span></div></td></tr>"
            for cat, hours in analytics["category_hours"].items()
        ]
    ) or "<tr><td colspan='3'>Import calendar data to visualize.</td></tr>"

    week_rows = "".join(
        [
            f"<tr><td>{h(day)}</td><td>{hours}</td><td><div class='bar'><span style='width:{min(100, int(hours * 4))}%'></span></div></td></tr>"
            for day, hours in analytics["weekday_hours"].items()
        ]
    )
    now = utcnow()
    next_two_weeks = (now + dt.timedelta(days=14)).isoformat()
    upcoming_events = conn.execute(
        """
        SELECT title, start_at, end_at, category, location, html_link
        FROM calendar_events
        WHERE organization_id = ? AND start_at >= ? AND start_at <= ?
        ORDER BY start_at ASC
        LIMIT 80
        """,
        (org_id, now.isoformat(), next_two_weeks),
    ).fetchall()
    event_rows = "".join(
        [
            (
                f"<tr><td>{h(format_local_dt(e['start_at'], tzinfo))}</td><td>{h(e['title'])}"
                + (f" <a href='{h(e['html_link'])}' target='_blank' rel='noopener noreferrer'>Open</a>" if e["html_link"] else "")
                + f"</td><td>{h(e['category'] or '-')}</td><td>{h(e['location'] or '-')}</td></tr>"
            )
            for e in upcoming_events
        ]
    ) or "<tr><td colspan='4'>No upcoming events in next 14 days.</td></tr>"
    due_query = """
        SELECT t.title, t.due_date, t.status, t.priority, u.name AS assignee_name
        FROM tasks t
        LEFT JOIN users u ON u.id = t.assignee_user_id
        WHERE t.organization_id = ? AND t.deleted_at IS NULL AND t.status NOT IN ('Done','Cancelled') AND t.due_date >= ? AND t.due_date <= ?
    """
    due_params: List[object] = [
        org_id,
        dt.date.today().isoformat(),
        (dt.date.today() + dt.timedelta(days=14)).isoformat(),
    ]
    if selected_space_id:
        due_query += " AND t.space_id = ?"
        due_params.append(selected_space_id)
    due_query += """
        ORDER BY t.due_date, CASE t.priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 ELSE 4 END
        LIMIT 80
    """
    due_tasks = conn.execute(due_query, tuple(due_params)).fetchall()
    due_rows = "".join(
        [
            f"<tr><td>{h(t['due_date'] or '-')}</td><td>{h(t['title'])}</td><td>{h(t['assignee_name'] or 'Unassigned')}</td><td>{h(t['status'])}</td><td>{h(t['priority'])}</td></tr>"
            for t in due_tasks
        ]
    ) or "<tr><td colspan='5'>No task due dates in next 14 days.</td></tr>"

    if view_mode == "week":
        day_cards: List[str] = []
        for i in range(7):
            day = range_start + dt.timedelta(days=i)
            rows = events_by_day.get(day, [])
            events_html = "".join(
                [
                    f"<li><span class='time'>{h(start.strftime('%I:%M %p').lstrip('0'))}</span> <span>{h(row['title'])}</span></li>"
                    for row, start, _end in rows[:14]
                ]
            ) or "<li class='muted'>No events</li>"
            tasks_html = "".join(
                [
                    f"""
                    <li class='calendar-task-chip' draggable='true' data-calendar-task-id='{task['id']}' data-calendar-task-title='{h(task['title'])}'>
                      <span class='pill soft'>{h(task['priority'])}</span> {h(task['title'])}
                    </li>
                    """
                    for task in due_tasks_by_day.get(day, [])[:10]
                ]
            ) or "<li class='muted'>No due tasks</li>"
            day_cards.append(
                f"""
                <article class='calendar-day-card' data-calendar-drop-day='{h(day.isoformat())}'>
                  <header>
                    <strong>{h(day.strftime('%a'))}</strong>
                    <span>{h(day.strftime('%b %d'))}</span>
                  </header>
                  <ul class='calendar-list'>{events_html}</ul>
                  <p class='muted mini'>Tasks due (drag to reschedule)</p>
                  <ul class='calendar-list tasks calendar-task-list'>{tasks_html}</ul>
                </article>
                """
            )
        calendar_surface = f"<div class='calendar-week-grid'>{''.join(day_cards)}</div>"
    else:
        month_cells: List[str] = []
        cursor = range_start
        while cursor <= range_end:
            in_month = cursor.month == anchor_date.month
            rows = events_by_day.get(cursor, [])
            tasks_today = due_tasks_by_day.get(cursor, [])
            top_items = "".join(
                [
                    f"<li>{h(start.strftime('%I:%M %p').lstrip('0'))} {h(row['title'])}</li>"
                    for row, start, _end in rows[:3]
                ]
            )
            task_items = "".join(
                [
                    f"""
                    <li class='calendar-task-chip' draggable='true' data-calendar-task-id='{task['id']}' data-calendar-task-title='{h(task['title'])}'>
                      <span class='pill soft'>{h(task['priority'])}</span> {h(task['title'])}
                    </li>
                    """
                    for task in tasks_today[:3]
                ]
            )
            count_text = f"{len(rows)} events" + (f", {len(tasks_today)} tasks" if tasks_today else "")
            month_cells.append(
                f"""
                <article class='calendar-month-cell {'current' if in_month else 'other'}' data-calendar-drop-day='{h(cursor.isoformat())}'>
                  <header><strong>{cursor.day}</strong><span>{h(count_text)}</span></header>
                  <ul class='calendar-list'>{top_items or "<li class='muted'>No events</li>"}</ul>
                  <ul class='calendar-list tasks calendar-task-list'>{task_items or "<li class='muted'>No due tasks</li>"}</ul>
                </article>
                """
            )
            cursor += dt.timedelta(days=1)
        weekday_heads = "".join([f"<span>{d}</span>" for d in ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]])
        calendar_surface = f"<div class='calendar-month-head'>{weekday_heads}</div><div class='calendar-month-grid'>{''.join(month_cells)}</div>"

    week_link = with_space(f"/calendar?view=week&date={anchor_date.isoformat()}", selected_space_id)
    month_link = with_space(f"/calendar?view=month&date={anchor_date.isoformat()}", selected_space_id)
    prev_link = with_space(f"/calendar?view={view_mode}&date={prev_anchor.isoformat()}", selected_space_id)
    next_link = with_space(f"/calendar?view={view_mode}&date={next_anchor.isoformat()}", selected_space_id)
    today_link = with_space(f"/calendar?view={view_mode}&date={dt.date.today().isoformat()}", selected_space_id)
    gcal_status = "Configured" if gcal_api_configured() else "Not configured"
    gcal_help = (
        "Set MAKERSPACE_GCAL_CLIENT_ID, MAKERSPACE_GCAL_CLIENT_SECRET, and MAKERSPACE_GCAL_REFRESH_TOKEN (or MAKERSPACE_GCAL_ACCESS_TOKEN)."
        if not gcal_api_configured()
        else "API credentials detected. Pull imports events. Push syncs due tasks to Google Calendar."
    )

    return f"""
    <section class=\"two\">
      <div class=\"card\">
        <h3>Calendar Views</h3>
        <p>Use week and month layouts to inspect current reality, then drill into analytics below.</p>
        <p class='muted'>Drag task chips between days to update due dates directly.</p>
        <div class='calendar-toolbar'>
          <div class='inline-actions'>
            <a class='btn {'active' if view_mode == 'week' else 'ghost'}' href='{h(week_link)}'>Week View</a>
            <a class='btn {'active' if view_mode == 'month' else 'ghost'}' href='{h(month_link)}'>Month View</a>
          </div>
          <div class='inline-actions'>
            <a class='btn ghost' href='{h(prev_link)}'>Previous</a>
            <a class='btn ghost' href='{h(today_link)}'>Today</a>
            <a class='btn ghost' href='{h(next_link)}'>Next</a>
          </div>
        </div>
        <p class='muted'>{h(period_label)} · timezone: {h(tz_name)}</p>
      </div>
      <div class=\"card\">
        <h3>Google Calendar (Two-Way Sync)</h3>
        <p>Status: <strong>{h(gcal_status)}</strong></p>
        <p class='muted'>{h(gcal_help)}</p>
        <form method=\"post\" action=\"/calendar/import\" enctype=\"multipart/form-data\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <input type=\"hidden\" name=\"view\" value=\"{h(view_mode)}\" />
          <input type=\"hidden\" name=\"date\" value=\"{h(anchor_date.isoformat())}\" />
          <label>Import file (CSV/ICS) <input type=\"file\" name=\"file\" accept=\".csv,.ics\" required /></label>
          <button type=\"submit\">Import Calendar File</button>
        </form>
        <hr />
        <form method='post' action='/calendar/gcal/pull' class='inline-form'>
          <input type='hidden' name='csrf_token' value='{{csrf}}' />
          <input type=\"hidden\" name=\"view\" value=\"{h(view_mode)}\" />
          <input type=\"hidden\" name=\"date\" value=\"{h(anchor_date.isoformat())}\" />
          <label>Calendar ID <input name='calendar_id' value='{h(calendar_id)}' required /></label>
          <label>Lookback days <input type='number' min='1' max='365' name='lookback_days' value='{lookback_days}' /></label>
          <label>Lookahead days <input type='number' min='1' max='365' name='lookahead_days' value='{lookahead_days}' /></label>
          <label>Push window days <input type='number' min='1' max='365' name='push_window_days' value='{push_window_days}' /></label>
          <button type='submit'>Pull from Google Calendar</button>
        </form>
        <form method='post' action='/calendar/gcal/push' class='inline-form'>
          <input type='hidden' name='csrf_token' value='{{csrf}}' />
          <input type=\"hidden\" name=\"view\" value=\"{h(view_mode)}\" />
          <input type=\"hidden\" name=\"date\" value=\"{h(anchor_date.isoformat())}\" />
          <input type='hidden' name='calendar_id' value='{h(calendar_id)}' />
          <input type='hidden' name='lookback_days' value='{lookback_days}' />
          <input type='hidden' name='lookahead_days' value='{lookahead_days}' />
          <input type='hidden' name='push_window_days' value='{push_window_days}' />
          <button type='submit'>Push Due Tasks to Google Calendar</button>
        </form>
        <p class='muted'>Last pull: {h(last_pull)} · Last push: {h(last_push)}</p>
      </div>
    </section>
    <section class='card'>
      <h3>{'Weekly Schedule View' if view_mode == 'week' else 'Monthly Schedule View'}</h3>
      {calendar_surface}
    </section>
    <section class=\"two\">
      <div class=\"card\">
        <h3>Analytics Summary</h3>
        <ul>
          <li>Total events analyzed: <strong>{analytics['event_count']}</strong></li>
          <li>Total scheduled hours: <strong>{analytics['total_hours']}</strong></li>
          <li>After-hours load: <strong>{analytics['after_hours']}h</strong></li>
          <li>Weekend load: <strong>{analytics['weekend_hours']}h</strong></li>
        </ul>
        <p><a class='btn' href='{h(with_space('/tasks?scope=week', selected_space_id))}'>Open Weekly Task Board</a></p>
      </div>
      <div class=\"card\">
        <h3>Hours by Category</h3>
        <table>
          <thead><tr><th>Category</th><th>Hours</th><th>Distribution</th></tr></thead>
          <tbody>{cat_rows}</tbody>
        </table>
      </div>
    </section>
    <section class=\"card\">
      <h3>Hours by Weekday</h3>
      <table>
        <thead><tr><th>Day</th><th>Hours</th><th>Distribution</th></tr></thead>
        <tbody>{week_rows}</tbody>
      </table>
    </section>
    <section class="two">
      <div class=\"card\">
        <h3>Upcoming Calendar (14 Days)</h3>
        <table>
          <thead><tr><th>Start</th><th>Event</th><th>Category</th><th>Location</th></tr></thead>
          <tbody>{event_rows}</tbody>
        </table>
      </div>
      <div class="card">
        <h3>Task Due Calendar (14 Days)</h3>
        <table>
          <thead><tr><th>Due</th><th>Task</th><th>Assignee</th><th>Status</th><th>Priority</th></tr></thead>
          <tbody>{due_rows}</tbody>
        </table>
      </div>
    </section>
    <section class=\"card\">
      <h3>Data Operations</h3>
      <p>Calendar import/export is managed in Data Hub.</p>
      <a class=\"btn\" href=\"{h(with_space('/data-hub', selected_space_id))}\">Open Data Hub</a>
    </section>
    """


def render_data_hub_page(conn: sqlite3.Connection, org_id: int) -> str:
    exports = [
        "projects",
        "tasks",
        "calendar_events",
        "intake_requests",
        "equipment_assets",
        "consumables",
        "partnerships",
        "spaces",
        "teams",
        "meeting_note_sources",
    ]
    export_buttons = "".join([f"<a class='btn' href='/export/{h(name)}.csv'>{h(name)}</a>" for name in exports])

    imports = [
        ("projects", "Projects"),
        ("tasks", "Tasks"),
        ("intake_requests", "Intake Requests"),
        ("equipment_assets", "Equipment Assets"),
        ("consumables", "Consumables"),
        ("partnerships", "Partnerships"),
        ("spaces", "Spaces"),
        ("teams", "Teams"),
    ]
    import_forms = "".join(
        [
            f"""
            <form method="post" action="/import/{table}.csv" enctype="multipart/form-data" class="inline-form">
              <input type="hidden" name="csrf_token" value="{{csrf}}" />
              <label>{h(label)} CSV <input type="file" name="file" accept=".csv" required /></label>
              <button type="submit">Import {h(label)}</button>
            </form>
            """
            for table, label in imports
        ]
    )
    calendar_import = """
      <form method="post" action="/calendar/import" enctype="multipart/form-data" class="inline-form">
        <input type="hidden" name="csrf_token" value="{{csrf}}" />
        <label>Calendar CSV/ICS <input type="file" name="file" accept=".csv,.ics" required /></label>
        <button type="submit">Import Calendar</button>
      </form>
    """

    email_rows = conn.execute(
        """
        SELECT recipient_email, subject, status, error_message, created_at, sent_at
        FROM email_messages
        WHERE organization_id = ?
        ORDER BY id DESC
        LIMIT 80
        """,
        (org_id,),
    ).fetchall()
    email_html = "".join(
        [
            f"<tr><td>{h(r['recipient_email'])}</td><td>{h(r['subject'])}</td><td>{h(r['status'])}</td><td>{h(r['created_at'])}</td><td>{h(r['sent_at'] or '-')}</td><td>{h(r['error_message'] or '-')}</td></tr>"
            for r in email_rows
        ]
    ) or "<tr><td colspan='6'>No notification emails logged yet.</td></tr>"

    return f"""
    <section class="card">
      <h2>Data Hub</h2>
      <p>Centralized import/export and delivery logs. Operational views stay focused on live execution.</p>
    </section>
    <section class="two">
      <div class="card">
        <h3>Export All Data</h3>
        <div class="inline-actions">{export_buttons}</div>
      </div>
      <div class="card">
        <h3>Import CSV Data</h3>
        <p class="muted">Use UTF-8 CSV headers matching each table schema.</p>
        {import_forms}
        <hr />
        <h4>Calendar Import</h4>
        {calendar_import}
      </div>
    </section>
    <section class="card">
      <h3>Email Delivery Log</h3>
      <table>
        <thead><tr><th>Recipient</th><th>Subject</th><th>Status</th><th>Created</th><th>Sent</th><th>Error</th></tr></thead>
        <tbody>{email_html}</tbody>
      </table>
      <p class="muted">Configure SMTP with <code>MAKERSPACE_SMTP_HOST</code>, <code>MAKERSPACE_SMTP_PORT</code>, <code>MAKERSPACE_SMTP_USER</code>, <code>MAKERSPACE_SMTP_PASSWORD</code>, <code>MAKERSPACE_SMTP_FROM</code>.</p>
    </section>
    """


def render_reports_page(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    selected_report_id: Optional[str],
    selected_space_id: Optional[int] = None,
    role: str = "viewer",
) -> str:
    saved = conn.execute(
        """
        SELECT r.*, u.name AS owner_name
        FROM report_templates r
        JOIN users u ON u.id = r.user_id
        WHERE r.organization_id = ? AND (r.user_id = ? OR r.is_shared = 1)
        ORDER BY r.updated_at DESC, r.created_at DESC
        """,
        (org_id, user_id),
    ).fetchall()
    selected = None
    selected_owner = ""
    if selected_report_id:
        selected = conn.execute(
            """
            SELECT r.*, u.name AS owner_name
            FROM report_templates r
            JOIN users u ON u.id = r.user_id
            WHERE r.id = ? AND r.organization_id = ?
            """,
            (selected_report_id, org_id),
        ).fetchone()
        if selected and not (int(selected["user_id"]) == int(user_id) or int(selected["is_shared"] or 0) == 1):
            selected = None
        elif selected:
            selected_owner = str(selected["owner_name"] or "")

    default_tpl = report_template_by_key("impact_report") or REPORT_TEMPLATE_LIBRARY[0]
    selected_template = default_tpl
    selected_name = str(default_tpl.get("name") or "Impact Report")
    selected_description = str(default_tpl.get("description") or "")
    selected_shared = True
    selected_config = report_config_from_payload({"widgets": default_tpl.get("widgets", [])})

    if selected:
        selected_name = str(selected["name"])
        selected_description = str(selected["description"] or "")
        selected_shared = bool(selected["is_shared"])
        selected_template = {
            "key": f"saved_{selected['id']}",
            "name": selected_name,
            "description": selected_description,
            "widgets": report_config_from_payload(parse_view_filters(selected["config_json"])).get("widgets", []),
        }
        selected_config = report_config_from_payload(parse_view_filters(selected["config_json"]))

    template_cards = "".join(
        [
            f"""
            <article class='template-card'>
              <h4>{idx + 1}. {h(str(template['name']))}</h4>
              <p class='muted'>{h(str(template.get('audience') or 'Team'))}</p>
              <p>{h(str(template.get('description') or ''))}</p>
              <p class='muted'>{len(sanitize_report_widgets(template.get('widgets')))} charts</p>
              <div class='inline-actions'>
                <form method='post' action='/reports/new' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='name' value='{h(str(template['name']))}' />
                  <input type='hidden' name='description' value='{h(str(template.get('description') or ''))}' />
                  <input type='hidden' name='template_key' value='{h(str(template['key']))}' />
                  <input type='hidden' name='is_shared' value='1' />
                  <button type='submit'>Save Template</button>
                </form>
                <button type='button' class='btn ghost report-template-load-btn' data-report-template-key='{h(str(template["key"]))}'>Load In Builder</button>
              </div>
            </article>
            """
            for idx, template in enumerate(REPORT_TEMPLATE_LIBRARY)
        ]
    )

    saved_rows = "".join(
        [
            (
                lambda href, can_manage, share_label: f"""
                <tr>
                  <td><a href='{h(href)}'>{h(row['name'])}</a></td>
                  <td>{h(row['owner_name'])}</td>
                  <td>{'Shared' if row['is_shared'] else 'Private'}</td>
                  <td>{h(row['updated_at'])}</td>
                  <td>
                    <form method='post' action='/reports/new' class='inline'>
                      <input type='hidden' name='csrf_token' value='{{csrf}}' />
                      <input type='hidden' name='name' value='{h(row['name'])} (Copy)' />
                      <input type='hidden' name='description' value='{h(row['description'] or '')}' />
                      <input type='hidden' name='config_json' value='{h(row['config_json'])}' />
                      <button type='submit' class='ghost'>Clone</button>
                    </form>
                    {(
                        f"<form method='post' action='/reports/visibility' class='inline'>"
                        f"<input type='hidden' name='csrf_token' value='{{{{csrf}}}}' />"
                        f"<input type='hidden' name='report_id' value='{row['id']}' />"
                        f"<input type='hidden' name='is_shared' value='{'0' if row['is_shared'] else '1'}' />"
                        f"<button type='submit' class='ghost'>{share_label}</button>"
                        f"</form>"
                        f"<form method='post' action='/reports/delete' class='inline'>"
                        f"<input type='hidden' name='csrf_token' value='{{{{csrf}}}}' />"
                        f"<input type='hidden' name='report_id' value='{row['id']}' />"
                        f"<button type='submit' class='ghost'>Delete</button>"
                        f"</form>"
                    ) if can_manage else ""}
                  </td>
                </tr>
                """
            )(
                with_space(f"/reports?report_id={row['id']}", selected_space_id),
                int(row["user_id"]) == int(user_id) or role_allows(role, "manager"),
                "Make Private" if int(row["is_shared"] or 0) == 1 else "Share",
            )
            for row in saved
        ]
    ) or "<tr><td colspan='5'>No saved report templates yet.</td></tr>"

    editor_config = report_editor_config(
        conn,
        org_id,
        sanitize_report_widgets(selected_config.get("widgets")),
        selected_name,
        selected_description,
        selected_space_id=selected_space_id,
    )
    editor_config["selected_template"]["key"] = str(selected_template.get("key") or "selected")
    editor_config_json = json.dumps(editor_config).replace("</", "<\\/")
    template_opts = "".join(
        [f"<option value='{h(str(template['key']))}'>{h(str(template['name']))}</option>" for template in REPORT_TEMPLATE_LIBRARY]
    )
    selected_meta = ""
    if selected:
        selected_meta = f"<p class='muted'>Loaded report: <strong>{h(selected_name)}</strong> by {h(selected_owner or 'Unknown')}</p>"

    return f"""
    <section class='card maker-hero'>
      <h2>Generate Reports</h2>
      <p>Build dashboards and impact summaries with reusable chart templates. Save private or shared report packs for your whole makerspace network.</p>
    </section>
    <section class='card'>
      <h3>Impact Report Template Library</h3>
      <p class='muted'>Based on your Makerspace impact summary structure plus public makerspace annual-report patterns (usage, school reach, capacity mix, reliability, and student progress).</p>
      <div class='template-grid'>{template_cards}</div>
    </section>
    <section class='card'>
      <h3>Impact Reporting Framework</h3>
      <ul>
        <li>Reach and utilization: check-ins, unique users, and school/unit distribution</li>
        <li>Learning outcomes: onboarding progress, certifications, and student delivery momentum</li>
        <li>Project and service delivery: throughput trend, queue health, and lane-level load</li>
        <li>Operations reliability: equipment uptime and consumable risk by space</li>
        <li>Capacity strategy: internal operations versus outward-facing impact mix</li>
      </ul>
      <p class='muted'>Use this baseline template as your annual impact pack, then clone and tailor role-specific report views for ops, student programs, and leadership updates.</p>
    </section>
    <section class='two report-builder-layout'>
      <div class='card'>
        <h3>Report Builder</h3>
        {selected_meta}
        <form method='post' action='/reports/new' id='report-builder-form'>
          <input type='hidden' name='csrf_token' value='{{csrf}}' />
          <input type='hidden' name='config_json' id='report-config-json' />
          <label>Report Name <input name='name' id='report-name' aria-label='Report name' value='{h(selected_name)}' required /></label>
          <label>Description <textarea name='description' id='report-description' aria-label='Report description'>{h(selected_description)}</textarea></label>
          <label>Start from template
            <select id='report-template-select' aria-label='Start from report template'>
              <option value=''>Keep current</option>
              {template_opts}
            </select>
          </label>
          <div class='inline-actions'>
            <button type='button' class='btn ghost' id='report-add-widget'>Add Chart</button>
            <label><input type='checkbox' name='is_shared' value='1' {'checked' if selected_shared else ''} {'disabled' if not role_allows(role, 'manager') else ''} /> Shared with organization</label>
          </div>
          <div id='report-widget-editor' class='report-widget-editor'></div>
          <p class='muted'>Choose metric + chart type for each block. Preview updates instantly.</p>
          <button type='submit'>Save Report Template</button>
        </form>
      </div>
      <div class='card'>
        <h3>Report Preview</h3>
        <p class='muted'>Drag-friendly charts are generated from live system data and snapshot imports.</p>
        <div id='report-preview-grid' class='report-preview-grid'></div>
      </div>
    </section>
    <section class='card'>
      <h3>Saved Report Templates</h3>
      <table>
        <thead><tr><th>Name</th><th>Owner</th><th>Visibility</th><th>Updated</th><th>Actions</th></tr></thead>
        <tbody>{saved_rows}</tbody>
      </table>
    </section>
    <script type='application/json' id='report-builder-config'>{editor_config_json}</script>
    """


def render_views_page(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    selected_view_id: Optional[str],
    selected_space_id: Optional[int] = None,
) -> str:
    view_templates = [
        template
        for template in VIEW_TEMPLATE_LIBRARY
        if FEATURE_INTAKE_ENABLED or str(template.get("entity")) != "intake"
    ]
    entity_labels = (
        VIEW_ENTITY_LABELS
        if FEATURE_INTAKE_ENABLED
        else {key: label for key, label in VIEW_ENTITY_LABELS.items() if key != "intake"}
    )
    status_options = (
        VIEW_STATUS_OPTIONS
        if FEATURE_INTAKE_ENABLED
        else {key: values for key, values in VIEW_STATUS_OPTIONS.items() if key != "intake"}
    )
    column_options = (
        VIEW_COLUMN_OPTIONS
        if FEATURE_INTAKE_ENABLED
        else {key: values for key, values in VIEW_COLUMN_OPTIONS.items() if key != "intake"}
    )

    saved = conn.execute(
        """
        SELECT v.*, u.name as owner_name
        FROM custom_views v
        JOIN users u ON u.id = v.user_id
        WHERE v.organization_id = ? AND (v.user_id = ? OR v.is_shared = 1)
        ORDER BY v.created_at DESC
        """,
        (org_id, user_id),
    ).fetchall()
    users = get_users_for_org(conn, org_id)
    teams = get_teams_for_org(conn, org_id)
    spaces = get_spaces_for_org(conn, org_id)

    selected = None
    preview_rows: List[List[str]] = []
    preview_headers: List[str] = []
    if selected_view_id:
        selected = conn.execute(
            "SELECT * FROM custom_views WHERE id = ? AND organization_id = ?",
            (selected_view_id, org_id),
        ).fetchone()
        if selected and (not FEATURE_INTAKE_ENABLED) and str(selected["entity"] or "") == "intake":
            selected = None
        if selected:
            preview_headers, preview_rows = preview_for_view(
                conn,
                org_id,
                user_id,
                selected,
                selected_space_id=selected_space_id,
            )

    saved_rows = "".join(
        [
            (
                lambda href: f"<tr><td><a href='{h(href)}'>{h(v['name'])}</a></td><td>{h(entity_labels.get(v['entity'], v['entity'].title()))}</td><td>{h(v['owner_name'])}</td><td>{'Shared' if v['is_shared'] else 'Private'}</td></tr>"
            )(with_space(f"/views?view_id={v['id']}", selected_space_id))
            for v in saved
        ]
    ) or "<tr><td colspan='4'>No saved views yet.</td></tr>"

    template_cards = "".join(
        [
            f"""
            <article class='template-card'>
              <h4>{idx + 1}. {h(str(template['name']))}</h4>
              <p class='muted'>{h(str(template['audience']))} · {h(entity_labels.get(str(template['entity']), str(template['entity']).title()))}</p>
              <p>{h(str(template['description']))}</p>
              <div class='inline-actions'>
                <form method='post' action='/views/new' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='name' value='{h(str(template['name']))}' />
                  <input type='hidden' name='entity' value='{h(str(template['entity']))}' />
                  <input type='hidden' name='template_key' value='{h(str(template['key']))}' />
                  <input type='hidden' name='filters_json' value='{h(json.dumps(template.get("filters", {})))}' />
                  <input type='hidden' name='columns_json' value='{h(json.dumps(template.get("columns", [])))}' />
                  <input type='hidden' name='is_shared' value='1' />
                  <button type='submit'>Add Template View</button>
                </form>
                <button type='button' class='btn ghost template-load-btn' data-template-key='{h(str(template["key"]))}'>Load In Editor</button>
              </div>
            </article>
            """
            for idx, template in enumerate(view_templates)
        ]
    )

    entity_opts = "".join(
        [f"<option value='{h(entity)}'>{h(label)}</option>" for entity, label in entity_labels.items()]
    )
    team_opts = "".join([f"<option value='{team['id']}'>{h(team['name'])}</option>" for team in teams])
    space_opts = "".join([f"<option value='{space['id']}'>{h(space['name'])}</option>" for space in spaces])
    owner_opts = "".join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in users])
    template_opts = "".join(
        [
            f"<option value='{h(str(template['key']))}'>{h(str(template['name']))} ({h(entity_labels.get(str(template['entity']), str(template['entity']).title()))})</option>"
            for template in view_templates
        ]
    )
    editor_config = {
        "status_options": status_options,
        "column_options": {
            entity: [{"key": key, "label": label} for key, label in options]
            for entity, options in column_options.items()
        },
        "default_columns": {entity: view_default_columns(entity) for entity in column_options},
        "templates": [
            {
                "key": str(template["key"]),
                "name": str(template["name"]),
                "entity": str(template["entity"]),
                "filters": template.get("filters", {}),
                "columns": template.get("columns", []),
            }
            for template in view_templates
        ],
    }
    editor_config_json = json.dumps(editor_config).replace("</", "<\\/")

    preview_html = ""
    if selected:
        head_cells = "".join([f"<th>{h(label)}</th>" for label in preview_headers]) if preview_headers else "<th>Data</th>"
        rows = "".join(
            [f"<tr>{''.join([f'<td>{h(cell)}</td>' for cell in row])}</tr>" for row in preview_rows]
        ) or f"<tr><td colspan='{max(1, len(preview_headers))}'>No rows match filters.</td></tr>"
        preview_html = f"""
        <section class=\"card\">
          <h3>Preview: {h(selected['name'])}</h3>
          <p class='muted'>{h(entity_labels.get(selected['entity'], selected['entity'].title()))} view</p>
          <table><thead><tr>{head_cells}</tr></thead><tbody>{rows}</tbody></table>
          <details>
            <summary>View JSON</summary>
            <p class='muted'><strong>Filters:</strong> <code>{h(selected['filters_json'] or '{}')}</code></p>
            <p class='muted'><strong>Columns:</strong> <code>{h(selected['columns_json'] or '[]')}</code></p>
          </details>
        </section>
        """

    return f"""
    <section class='card maker-hero'>
      <h2>Custom Views Studio</h2>
      <p>Build role-specific, space-aware views. Start from one of the {len(view_templates)} makerspace templates or design your own.</p>
    </section>
    <section class='card'>
      <h3>Template Library ({len(view_templates)})</h3>
      <div class='template-grid'>{template_cards}</div>
    </section>
    <section class=\"two\">
      <div class=\"card\">
        <h3>View Editor</h3>
        <form method=\"post\" action=\"/views/new\" id=\"view-editor-form\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <input type=\"hidden\" name=\"filters_json\" id=\"view-filters-json\" />
          <input type=\"hidden\" name=\"columns_json\" id=\"view-columns-json\" />
          <label>Name <input name=\"name\" id=\"view-name\" aria-label=\"View name\" required placeholder=\"My Weekly Planning\" /></label>
          <label>Entity
            <select name=\"entity\" id=\"view-entity\" aria-label=\"View entity\">{entity_opts}</select>
          </label>
          <label>Start from template
            <select name=\"template_key\" id=\"view-template-key\" aria-label=\"Start from template\">
              <option value=\"\">None</option>
              {template_opts}
            </select>
          </label>
          <div class='view-editor-grid'>
            <label>Task Scope
              <select name='scope' id='view-scope' aria-label='Task scope'>
                <option value='my'>My</option>
                <option value='week'>My Week</option>
                <option value='team' selected>Team</option>
              </select>
            </label>
            <label>Lane <select name='lane' id='view-lane' aria-label='Lane'><option value=''>Any</option>{''.join([f"<option>{h(l)}</option>" for l in LANES])}</select></label>
            <label>Team <select name='team_id' id='view-team-id' aria-label='Team'><option value=''>Any</option>{team_opts}</select></label>
            <label>Space <select name='space_id' id='view-space-id' aria-label='Space'><option value=''>Any</option>{space_opts}</select></label>
            <label>Owner / Assignee <select name='owner_user_id' id='view-owner-id' aria-label='Owner or assignee'><option value=''>Any</option>{owner_opts}</select></label>
            <label>Search <input name='search' id='view-search' aria-label='Search keyword' placeholder='keyword' /></label>
            <label>Due within days <input type='number' min='0' name='due_within_days' id='view-due-days' aria-label='Due within days' /></label>
            <label>Follow-up within days <input type='number' min='0' name='followup_within_days' id='view-followup-days' aria-label='Follow-up within days' /></label>
            <label>Maintenance within days <input type='number' min='0' name='maintenance_within_days' id='view-maint-days' aria-label='Maintenance within days' /></label>
            <label>Minimum score <input type='number' step='0.1' name='min_score' id='view-min-score' aria-label='Minimum score' /></label>
          </div>
          <div class='inline-actions'>
            <label><input type='checkbox' name='only_unassigned' id='view-only-unassigned' aria-label='Only unassigned' value='1' /> Only unassigned</label>
            <label><input type='checkbox' name='cert_required' id='view-cert-required' aria-label='Certification required' value='1' /> Certification required</label>
            <label><input type='checkbox' name='hide_completed' id='view-hide-completed' aria-label='Hide completed or closed' value='1' checked /> Hide completed/closed</label>
          </div>
          <h4>Status / Stage</h4>
          <div id='view-status-options' class='check-grid'></div>
          <h4>Priorities</h4>
          <div class='check-grid'>
            <label><input type='checkbox' name='priority_pick' value='Low' /> Low</label>
            <label><input type='checkbox' name='priority_pick' value='Medium' /> Medium</label>
            <label><input type='checkbox' name='priority_pick' value='High' /> High</label>
            <label><input type='checkbox' name='priority_pick' value='Critical' /> Critical</label>
          </div>
          <h4>Columns</h4>
          <div id='view-column-options' class='check-grid'></div>
          <label><input type=\"checkbox\" name=\"is_shared\" value=\"1\" /> Shared with organization</label>
          <p class='muted'>Filters and columns are generated automatically from these controls.</p>
          <button type=\"submit\">Save Custom View</button>
        </form>
      </div>
      <div class=\"card\">
        <h3>How Teams Use This</h3>
        <ul>
          <li>Students: daily/weekly personal execution boards</li>
          <li>Staff: lane-specific delivery and weekly prioritization</li>
          <li>Managers: delegation, blocked work, and follow-up control towers</li>
          <li>Ops leads: maintenance and certification readiness views</li>
        </ul>
        <p class='muted'>Every user can clone a template, adjust filters/columns, and save their own private or shared variation.</p>
      </div>
    </section>
    <section class=\"card\">
      <h3>Saved Views</h3>
      <table>
        <thead><tr><th>Name</th><th>Entity</th><th>Owner</th><th>Visibility</th></tr></thead>
        <tbody>{saved_rows}</tbody>
      </table>
    </section>
    {preview_html}
    <script type='application/json' id='view-editor-config'>{editor_config_json}</script>
    """


def preview_for_view(
    conn: sqlite3.Connection,
    org_id: int,
    user_id: int,
    view_row: sqlite3.Row,
    selected_space_id: Optional[int] = None,
) -> Tuple[List[str], List[List[str]]]:
    entity = str(view_row["entity"] or "tasks")
    filters = parse_view_filters(view_row["filters_json"])
    columns = parse_view_columns(entity, view_row["columns_json"])
    labels = view_column_label_map(entity)
    headers = [labels.get(col, col.replace("_", " ").title()) for col in columns]
    today = dt.date.today()

    if entity == "tasks":
        scope = str(filters.get("scope") or "team")
        search = str(filters.get("search") or "")
        team_id = view_int(filters.get("team_id"))
        scope_space_id = view_int(filters.get("space_id"), selected_space_id)
        rows = fetch_tasks(conn, org_id, user_id, scope=scope, search=search, team_id=team_id, space_id=scope_space_id)
        status_in = set(view_list(filters.get("status_in")))
        status_exclude = set(view_list(filters.get("status_exclude")))
        priority_in = set(view_list(filters.get("priority_in")))
        assignee_id = view_int(filters.get("assignee_user_id"))
        due_days = view_int(filters.get("due_within_days"))
        only_unassigned = view_bool(filters.get("only_unassigned"), False) is True
        out: List[List[str]] = []
        for r in rows:
            if status_in and str(r["status"]) not in status_in:
                continue
            if status_exclude and str(r["status"]) in status_exclude:
                continue
            if priority_in and str(r["priority"]) not in priority_in:
                continue
            if assignee_id is not None and int(r["assignee_user_id"] or 0) != assignee_id:
                continue
            if only_unassigned and r["assignee_user_id"] is not None:
                continue
            if not date_within_days(r["due_date"], due_days, today):
                continue
            out.append([stringify_view_cell(col, r[col] if col in r.keys() else None) for col in columns])
            if len(out) >= 80:
                break
        return headers, out

    if entity == "projects":
        rows = conn.execute(
            """
            SELECT p.*, u.name AS owner_name, tm.name AS team_name, sp.name AS space_name
            FROM projects p
            LEFT JOIN users u ON u.id = p.owner_user_id
            LEFT JOIN teams tm ON tm.id = p.team_id
            LEFT JOIN spaces sp ON sp.id = p.space_id
            WHERE p.organization_id = ? AND p.deleted_at IS NULL
            ORDER BY p.updated_at DESC
            LIMIT 300
            """,
            (org_id,),
        ).fetchall()
        status_in = set(view_list(filters.get("status_in")))
        status_exclude = set(view_list(filters.get("status_exclude")))
        priority_in = set(view_list(filters.get("priority_in")))
        lane = str(filters.get("lane") or "").strip()
        owner_id = view_int(filters.get("owner_user_id"))
        team_id = view_int(filters.get("team_id"))
        space_id = view_int(filters.get("space_id"), selected_space_id)
        due_days = view_int(filters.get("due_within_days"))
        search = str(filters.get("search") or "").strip().lower()
        out: List[List[str]] = []
        for r in rows:
            if status_in and str(r["status"]) not in status_in:
                continue
            if status_exclude and str(r["status"]) in status_exclude:
                continue
            if priority_in and str(r["priority"]) not in priority_in:
                continue
            if lane and str(r["lane"]) != lane:
                continue
            if owner_id is not None and int(r["owner_user_id"] or 0) != owner_id:
                continue
            if team_id is not None and int(r["team_id"] or 0) != team_id:
                continue
            if space_id is not None and int(r["space_id"] or 0) != space_id:
                continue
            if not date_within_days(r["due_date"], due_days, today):
                continue
            if search and search not in f"{r['name'] or ''} {r['description'] or ''}".lower():
                continue
            out.append([stringify_view_cell(col, r[col] if col in r.keys() else None) for col in columns])
            if len(out) >= 80:
                break
        return headers, out

    if entity == "intake":
        rows = conn.execute(
            """
            SELECT r.*, u.name AS owner_name
            FROM intake_requests r
            LEFT JOIN users u ON u.id = r.owner_user_id
            WHERE r.organization_id = ? AND r.deleted_at IS NULL
            ORDER BY r.score DESC, r.created_at DESC
            LIMIT 300
            """,
            (org_id,),
        ).fetchall()
        status_in = set(view_list(filters.get("status_in")))
        status_exclude = set(view_list(filters.get("status_exclude")))
        lane = str(filters.get("lane") or "").strip()
        owner_id = view_int(filters.get("owner_user_id"))
        min_score = view_float(filters.get("min_score"))
        search = str(filters.get("search") or "").strip().lower()
        out: List[List[str]] = []
        for r in rows:
            if status_in and str(r["status"]) not in status_in:
                continue
            if status_exclude and str(r["status"]) in status_exclude:
                continue
            if lane and str(r["lane"]) != lane:
                continue
            if owner_id is not None and int(r["owner_user_id"] or 0) != owner_id:
                continue
            if min_score is not None and float(r["score"] or 0.0) < min_score:
                continue
            if search and search not in f"{r['title'] or ''} {r['details'] or ''}".lower():
                continue
            out.append([stringify_view_cell(col, r[col] if col in r.keys() else None) for col in columns])
            if len(out) >= 80:
                break
        return headers, out

    if entity == "partnerships":
        rows = conn.execute(
            """
            SELECT p.*, u.name AS owner_name
            FROM partnerships p
            LEFT JOIN users u ON u.id = p.owner_user_id
            WHERE p.organization_id = ? AND p.deleted_at IS NULL
            ORDER BY COALESCE(p.next_followup, '9999-12-31')
            LIMIT 300
            """,
            (org_id,),
        ).fetchall()
        stage_in = set(view_list(filters.get("stage_in")) or view_list(filters.get("status_in")))
        stage_exclude = set(view_list(filters.get("status_exclude")))
        owner_id = view_int(filters.get("owner_user_id"))
        health_in = set(view_list(filters.get("health_in")))
        followup_days = view_int(filters.get("followup_within_days"))
        search = str(filters.get("search") or "").strip().lower()
        out: List[List[str]] = []
        for r in rows:
            if stage_in and str(r["stage"]) not in stage_in:
                continue
            if stage_exclude and str(r["stage"]) in stage_exclude:
                continue
            if owner_id is not None and int(r["owner_user_id"] or 0) != owner_id:
                continue
            if health_in and str(r["health"] or "") not in health_in:
                continue
            if not date_within_days(r["next_followup"], followup_days, today):
                continue
            if search and search not in f"{r['partner_name'] or ''} {r['school'] or ''}".lower():
                continue
            out.append([stringify_view_cell(col, r[col] if col in r.keys() else None) for col in columns])
            if len(out) >= 80:
                break
        return headers, out

    if entity == "assets":
        rows = conn.execute(
            """
            SELECT a.*, u.name AS owner_name
            FROM equipment_assets a
            LEFT JOIN users u ON u.id = a.owner_user_id
            WHERE a.organization_id = ? AND a.deleted_at IS NULL
            ORDER BY COALESCE(a.next_maintenance, '9999-12-31')
            LIMIT 300
            """,
            (org_id,),
        ).fetchall()
        status_in = set(view_list(filters.get("status_in")))
        status_exclude = set(view_list(filters.get("status_exclude")))
        owner_id = view_int(filters.get("owner_user_id"))
        cert_required = view_bool(filters.get("cert_required"))
        maintenance_days = view_int(filters.get("maintenance_within_days"))
        space_name = str(filters.get("space_name") or "").strip()
        search = str(filters.get("search") or "").strip().lower()
        if not space_name:
            space_id = view_int(filters.get("space_id"), selected_space_id)
            if space_id is not None:
                space_row = conn.execute(
                    "SELECT name FROM spaces WHERE id = ? AND organization_id = ?",
                    (space_id, org_id),
                ).fetchone()
                space_name = str(space_row["name"]) if space_row else ""
        out: List[List[str]] = []
        for r in rows:
            if status_in and str(r["status"]) not in status_in:
                continue
            if status_exclude and str(r["status"]) in status_exclude:
                continue
            if owner_id is not None and int(r["owner_user_id"] or 0) != owner_id:
                continue
            if cert_required is not None and bool(int(r["cert_required"] or 0)) != cert_required:
                continue
            if space_name and str(r["space"] or "") != space_name:
                continue
            if not date_within_days(r["next_maintenance"], maintenance_days, today):
                continue
            if search and search not in f"{r['name'] or ''} {r['asset_type'] or ''}".lower():
                continue
            out.append([stringify_view_cell(col, r[col] if col in r.keys() else None) for col in columns])
            if len(out) >= 80:
                break
        return headers, out

    if entity == "consumables":
        rows = conn.execute(
            """
            SELECT c.*, s.name AS space_name, u.name AS owner_name
            FROM consumables c
            LEFT JOIN spaces s ON s.id = c.space_id
            LEFT JOIN users u ON u.id = c.owner_user_id
            WHERE c.organization_id = ? AND c.deleted_at IS NULL
            ORDER BY CASE c.status WHEN 'Out' THEN 1 WHEN 'Low' THEN 2 ELSE 3 END, c.name
            LIMIT 300
            """,
            (org_id,),
        ).fetchall()
        status_in = set(view_list(filters.get("status_in")))
        status_exclude = set(view_list(filters.get("status_exclude")))
        owner_id = view_int(filters.get("owner_user_id"))
        min_qty = view_float(filters.get("min_qty"))
        search = str(filters.get("search") or "").strip().lower()
        space_name = str(filters.get("space_name") or "").strip()
        if not space_name:
            space_id = view_int(filters.get("space_id"), selected_space_id)
            if space_id is not None:
                space_row = conn.execute(
                    "SELECT name FROM spaces WHERE id = ? AND organization_id = ?",
                    (space_id, org_id),
                ).fetchone()
                space_name = str(space_row["name"]) if space_row else ""
        out: List[List[str]] = []
        for r in rows:
            if status_in and str(r["status"]) not in status_in:
                continue
            if status_exclude and str(r["status"]) in status_exclude:
                continue
            if owner_id is not None and int(r["owner_user_id"] or 0) != owner_id:
                continue
            if min_qty is not None and float(r["quantity_on_hand"] or 0.0) < min_qty:
                continue
            if space_name and str(r["space_name"] or "") != space_name:
                continue
            if search and search not in f"{r['name'] or ''} {r['category'] or ''}".lower():
                continue
            out.append([stringify_view_cell(col, r[col] if col in r.keys() else None) for col in columns])
            if len(out) >= 80:
                break
        return headers, out

    if entity == "onboarding":
        rows = conn.execute(
            """
            SELECT a.id, a.status, a.due_date, a.created_at, a.completed_at,
                   t.name AS template_name, t.task_title, t.role_target,
                   u.name AS assignee_name, a.assignee_user_id
            FROM onboarding_assignments a
            JOIN onboarding_templates t ON t.id = a.template_id
            JOIN users u ON u.id = a.assignee_user_id
            WHERE a.organization_id = ?
            ORDER BY a.created_at DESC
            LIMIT 300
            """,
            (org_id,),
        ).fetchall()
        status_in = set(view_list(filters.get("status_in")))
        status_exclude = set(view_list(filters.get("status_exclude")))
        assignee_id = view_int(filters.get("assignee_user_id"))
        due_days = view_int(filters.get("due_within_days"))
        role_target = str(filters.get("role_target") or "").strip().lower()
        search = str(filters.get("search") or "").strip().lower()
        out: List[List[str]] = []
        for r in rows:
            if status_in and str(r["status"]) not in status_in:
                continue
            if status_exclude and str(r["status"]) in status_exclude:
                continue
            if assignee_id is not None and int(r["assignee_user_id"] or 0) != assignee_id:
                continue
            if role_target and str(r["role_target"] or "").strip().lower() != role_target:
                continue
            if not date_within_days(r["due_date"], due_days, today):
                continue
            if search and search not in f"{r['task_title'] or ''} {r['assignee_name'] or ''}".lower():
                continue
            out.append([stringify_view_cell(col, r[col] if col in r.keys() else None) for col in columns])
            if len(out) >= 80:
                break
        return headers, out

    return [], []


def render_onboarding_page(conn: sqlite3.Connection, org_id: int) -> str:
    templates = conn.execute(
        "SELECT * FROM onboarding_templates WHERE organization_id = ? ORDER BY sequence",
        (org_id,),
    ).fetchall()
    assignments = conn.execute(
        """
        SELECT a.id, a.status, a.due_date, a.created_at, a.completed_at,
               a.notes, a.assignee_user_id,
               t.task_title, t.name as template_name, t.role_target, t.details, t.doc_url,
               u.name as assignee_name
        FROM onboarding_assignments a
        JOIN onboarding_templates t ON t.id = a.template_id
        JOIN users u ON u.id = a.assignee_user_id
        WHERE a.organization_id = ?
        ORDER BY a.created_at DESC
        LIMIT 200
        """,
        (org_id,),
    ).fetchall()
    users = get_users_for_org(conn, org_id)

    template_opts = "".join([f"<option value='{t['id']}'>{h(t['name'])}: {h(t['task_title'])}</option>" for t in templates])
    user_opts = "".join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in users])
    template_roles = sorted(
        {str(t["role_target"] or "").strip() for t in templates if str(t["role_target"] or "").strip()}
        | set(ONBOARDING_ROLE_TRACKS)
    )
    role_opts = "".join([f"<option>{h(role)}</option>" for role in template_roles])
    user_opts_with_selected = lambda selected: "".join(  # noqa: E731
        [
            f"<option value='{u['id']}' {'selected' if str(u['id']) == str(selected or '') else ''}>{h(u['name'])}</option>"
            for u in users
        ]
    )

    template_rows: List[str] = []
    for t in templates:
        role_select = "".join(
            [f"<option {'selected' if str(t['role_target'] or '') == role else ''}>{h(role)}</option>" for role in template_roles]
        )
        template_rows.append(
            f"""
            <tr>
              <td><input type='number' min='1' name='sequence' value='{h(t['sequence'])}' form='tpl-form-{t['id']}' aria-label='Sequence for {h(t["task_title"])}' /></td>
              <td><input name='name' value='{h(t['name'])}' form='tpl-form-{t['id']}' aria-label='Track for {h(t["task_title"])}' /></td>
              <td><select name='role_target' form='tpl-form-{t['id']}' aria-label='Role target for {h(t["task_title"])}'>{role_select}</select></td>
              <td><input name='task_title' value='{h(t['task_title'])}' form='tpl-form-{t['id']}' aria-label='Task title for template {h(t["name"])}' /></td>
              <td><input type='number' min='0' name='due_offset_days' value='{h(t['due_offset_days'])}' form='tpl-form-{t['id']}' aria-label='Due offset for {h(t["task_title"])}' /></td>
              <td><textarea name='details' form='tpl-form-{t['id']}' aria-label='Details for {h(t["task_title"])}'>{h(t['details'] or '')}</textarea></td>
              <td>
                <input name='doc_url' value='{h(t['doc_url'] or "")}' form='tpl-form-{t['id']}' aria-label='Doc URL for {h(t["task_title"])}' placeholder='https://docs.google.com/...' />
                {"<a class='btn ghost' target='_blank' rel='noreferrer' href='"+h(t['doc_url'])+"'>Open</a>" if t['doc_url'] else ""}
              </td>
              <td>
                <form id='tpl-form-{t['id']}' method='post' action='/onboarding/template/update' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='template_id' value='{t['id']}' />
                  <button type='submit'>Save</button>
                </form>
                <form method='post' action='/onboarding/template/delete' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='template_id' value='{t['id']}' />
                  <button type='submit' class='ghost'>Delete</button>
                </form>
              </td>
            </tr>
            """
        )
    template_rows_html = "".join(template_rows) or "<tr><td colspan='8'>No templates yet.</td></tr>"

    score_weights = {"Assigned": 4, "In Progress": 8, "Review": 12, "Done": 20}
    leaderboard: Dict[str, Dict[str, object]] = {}
    today = dt.date.today()
    for assignment in assignments:
        key = str(assignment["assignee_name"] or "Unknown")
        bucket = leaderboard.setdefault(
            key,
            {"total": 0, "done": 0, "points": 0, "overdue": 0},
        )
        bucket["total"] = int(bucket["total"]) + 1
        status = str(assignment["status"] or "Assigned")
        if status == "Done":
            bucket["done"] = int(bucket["done"]) + 1
        bucket["points"] = int(bucket["points"]) + score_weights.get(status, 0)
        due = parse_iso_date(assignment["due_date"])
        if due and due < today and status != "Done":
            bucket["overdue"] = int(bucket["overdue"]) + 1

    progress_cards = []
    for assignee, metrics in sorted(
        leaderboard.items(),
        key=lambda item: (-int(item[1]["points"]), int(item[1]["overdue"]), item[0].lower()),
    ):
        total = int(metrics["total"])
        done = int(metrics["done"])
        points = int(metrics["points"])
        overdue = int(metrics["overdue"])
        pct = int(round((done / total) * 100)) if total else 0
        badge = "Launch Ready" if points >= 120 else ("Builder" if points >= 80 else ("Rising" if points >= 40 else "Starter"))
        progress_cards.append(
            f"""
            <article class='template-card'>
              <h4>{h(assignee)}</h4>
              <p class='muted'>Checklist completion: <strong>{done}/{total}</strong> · {pct}%</p>
              <div class='progress'><span style='width:{pct}%'></span></div>
              <p class='muted'>Score: <strong>{points}</strong> · Badge: <strong>{badge}</strong> · Overdue: <strong>{overdue}</strong></p>
            </article>
            """
        )
    progress_html = "".join(progress_cards) or "<p class='muted'>Assign onboarding tasks to start progress tracking.</p>"

    checklist_rows = []
    for a in assignments:
        due = parse_iso_date(a["due_date"])
        overdue = bool(due and due < today and str(a["status"]) != "Done")
        checklist_rows.append(
            f"""
            <article class='kanban-card onboarding-check'>
              <div class='card-topline'>
                <h5>{h(a['task_title'])}</h5>
                <span class='pill {'status-overdue' if overdue else ''}'>{'Overdue' if overdue else h(a['status'])}</span>
              </div>
              <p class='muted'>{h(a['assignee_name'])} · {h(a['template_name'])} · {h(a['role_target'] or '-')}</p>
              <p class='muted'>Due {h(a['due_date'] or '-')}</p>
              <p class='muted'>{h((a['details'] or '')[:180])}</p>
              {"<p><a target='_blank' rel='noreferrer' href='"+h(a['doc_url'])+"'>Open onboarding guide</a></p>" if a['doc_url'] else ""}
              <form method='post' action='/onboarding/status' class='inline-form'>
                <input type='hidden' name='csrf_token' value='{{csrf}}' />
                <input type='hidden' name='assignment_id' value='{a['id']}' />
                <label class='sr-only' for='onboarding-status-{a['id']}'>Status</label>
                <select id='onboarding-status-{a['id']}' name='status' class='quick-status'>
                  {''.join([f"<option {'selected' if str(a['status']) == s else ''}>{h(s)}</option>" for s in ONBOARDING_STATUSES])}
                </select>
                <button type='submit'>Save</button>
              </form>
            </article>
            """
        )
    checklist_html = "".join(checklist_rows) or "<p class='muted'>No onboarding assignments yet.</p>"

    assignment_rows = "".join(
        [
            f"""
            <tr>
              <td>{h(a['assignee_name'])}</td>
              <td>{h(a['template_name'])}</td>
              <td>{h(a['task_title'])}</td>
              <td>
                <form method='post' action='/onboarding/assignment/update' class='inline-form'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='assignment_id' value='{a['id']}' />
                  <select name='status' aria-label='Status for {h(a["task_title"])}'>
                    {''.join([f"<option {'selected' if str(a['status']) == s else ''}>{h(s)}</option>" for s in ONBOARDING_STATUSES])}
                  </select>
                  <select name='assignee_user_id' aria-label='Owner for {h(a["task_title"])}'>
                    {user_opts_with_selected(a["assignee_user_id"])}
                  </select>
                  <input type='date' name='due_date' value='{h(a["due_date"] or "")}' aria-label='Due date for {h(a["task_title"])}' />
                  <input name='notes' value='{h(a["notes"] or "")}' placeholder='Notes' aria-label='Notes for {h(a["task_title"])}' />
                  <button type='submit'>Save</button>
                </form>
              </td>
              <td>{h(a['due_date'] or '-')}</td>
              <td>
                <form method='post' action='/onboarding/complete' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='assignment_id' value='{a['id']}' />
                  <button type='submit'>Mark Done</button>
                </form>
              </td>
            </tr>
            """
            for a in assignments
        ]
    ) or "<tr><td colspan='6'>No onboarding assignments yet.</td></tr>"

    return f"""
    <section class='card maker-hero'>
      <h2>Onboarding Command Board</h2>
      <p>Role-based checklists with progress scoring for Student Worker and FTE onboarding tracks.</p>
    </section>
    <section class=\"two\">
      <div class=\"card\">
        <h3>Assign Onboarding Task</h3>
        <form method=\"post\" action=\"/onboarding/assign\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <label>Template <select name=\"template_id\">{template_opts}</select></label>
          <label>Assignee <select name=\"assignee_user_id\">{user_opts}</select></label>
          <button type=\"submit\">Assign</button>
        </form>
      </div>
      <div class=\"card\">
        <h3>Create / Customize Template</h3>
        <form method='post' action='/onboarding/template/new'>
          <input type='hidden' name='csrf_token' value='{{csrf}}' />
          <label>Track Name <input name='name' value='Student Worker' required /></label>
          <label>Role Target <select name='role_target'>{role_opts}</select></label>
          <label>Checklist Item <input name='task_title' required placeholder='Complete makerspace safety orientation' /></label>
          <label>Details <textarea name='details' placeholder='What good completion looks like'></textarea></label>
          <label>Guide Doc URL <input name='doc_url' placeholder='https://docs.google.com/...' /></label>
          <label>Sequence <input type='number' min='1' name='sequence' value='10' /></label>
          <label>Due Offset (days) <input type='number' min='0' name='due_offset_days' value='7' /></label>
          <button type='submit'>Save Template</button>
        </form>
      </div>
      <div class=\"card\">
        <h3>Gamified Onboarding Model</h3>
        <ul>
          <li>Starter, Rising, Builder, and Launch Ready badges</li>
          <li>Points increase by status progression and completion</li>
          <li>Overdue checklist signals for manager follow-up</li>
          <li>Templates are fully configurable for each role track</li>
        </ul>
      </div>
    </section>
    <section class='card'>
      <h3>Progress Leaderboard</h3>
      <div class='template-grid'>{progress_html}</div>
    </section>
    <section class='card'>
      <h3>Checklist Board</h3>
      <div class='template-grid'>{checklist_html}</div>
    </section>
    <section class=\"card\">
      <h3>Onboarding Templates</h3>
      <table class='onboarding-template-table'><thead><tr><th>Seq</th><th>Track</th><th>Role</th><th>Task</th><th>Due Offset</th><th>Details</th><th>Guide</th><th>Actions</th></tr></thead><tbody>{template_rows_html}</tbody></table>
    </section>
    <section class=\"card\">
      <h3>Assignments</h3>
      <table class='onboarding-assignment-table'><thead><tr><th>User</th><th>Track</th><th>Task</th><th>Editable Fields</th><th>Due</th><th>Action</th></tr></thead><tbody>{assignment_rows}</tbody></table>
    </section>
    """


def render_spaces_page(conn: sqlite3.Connection, org_id: int) -> str:
    spaces = conn.execute(
        """
        SELECT s.*,
               (SELECT COUNT(*) FROM equipment_assets a WHERE a.organization_id = s.organization_id AND a.space = s.name) AS machine_count,
               (SELECT COUNT(*) FROM equipment_assets a WHERE a.organization_id = s.organization_id AND a.space = s.name AND a.status = 'Down') AS machine_down,
               (SELECT COUNT(*) FROM consumables c WHERE c.organization_id = s.organization_id AND c.space_id = s.id AND (c.status IN ('Low','Out') OR c.quantity_on_hand <= c.reorder_point)) AS consumables_low
        FROM spaces s
        WHERE s.organization_id = ?
        ORDER BY s.name
        """,
        (org_id,),
    ).fetchall()
    rows = "".join(
        [
            f"""
            <tr>
              <td>
                <input name='name' value='{h(space['name'])}' form='space-row-{space['id']}' />
              </td>
              <td>
                <input name='location' value='{h(space['location'] or '')}' form='space-row-{space['id']}' />
              </td>
              <td>{h(space['machine_count'])}</td>
              <td>{h(space['machine_down'])}</td>
              <td>{h(space['consumables_low'])}</td>
              <td>
                <form id='space-row-{space['id']}' method='post' action='/settings/spaces/update' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='space_id' value='{space['id']}' />
                  <input type='hidden' name='description' value='{h(space['description'] or '')}' />
                  <input type='hidden' name='next' value='/spaces' />
                  <button type='submit'>Save</button>
                </form>
                <a class='btn ghost' href='{h(with_space('/assets', int(space['id'])))}'>Machines</a>
                <a class='btn ghost' href='{h(with_space('/consumables', int(space['id'])))}'>Consumables</a>
              </td>
            </tr>
            """
            for space in spaces
        ]
    ) or "<tr><td colspan='6'>No spaces created yet.</td></tr>"

    return f"""
    <section class='card maker-hero'>
      <h2>Space Management Hub</h2>
      <p>Add spaces and manage resources by location: machines and consumables in one workflow.</p>
    </section>
    <section class='two'>
      <div class='card'>
        <h3>Add New Space</h3>
        <form method='post' action='/settings/spaces/new'>
          <input type='hidden' name='csrf_token' value='{{csrf}}' />
          <label>Name <input name='name' required placeholder='Makerspace Name' /></label>
          <label>Location <input name='location' placeholder='Building / floor' /></label>
          <label>Description <textarea name='description' placeholder='Primary functions, equipment, and support model'></textarea></label>
          <button type='submit'>Create Space</button>
        </form>
      </div>
      <div class='card'>
        <h3>Resource Workflows</h3>
        <ul>
          <li>Machines: maintenance state, downtime risk, and ownership</li>
          <li>Consumables: quantity, reorder thresholds, and stockout prevention</li>
          <li>Use the top bar space context to filter all operational views</li>
        </ul>
      </div>
    </section>
    <section class='card'>
      <h3>Space Resource Overview</h3>
      <table>
        <thead><tr><th>Space</th><th>Location</th><th>Machines</th><th>Down</th><th>Consumables Low/Out</th><th>Actions</th></tr></thead>
        <tbody>{rows}</tbody>
      </table>
    </section>
    """


def render_consumables_page(conn: sqlite3.Connection, org_id: int, selected_space_id: Optional[int] = None) -> str:
    rows_sql = """
        SELECT c.*, s.name AS space_name, u.name AS owner_name
        FROM consumables c
        LEFT JOIN spaces s ON s.id = c.space_id
        LEFT JOIN users u ON u.id = c.owner_user_id
        WHERE c.organization_id = ? AND c.deleted_at IS NULL
    """
    rows_params: List[object] = [org_id]
    if selected_space_id is not None:
        rows_sql += " AND c.space_id = ?"
        rows_params.append(selected_space_id)
    rows_sql += " ORDER BY CASE c.status WHEN 'Out' THEN 1 WHEN 'Low' THEN 2 ELSE 3 END, c.name LIMIT 300"
    rows = conn.execute(rows_sql, tuple(rows_params)).fetchall()
    users = get_users_for_org(conn, org_id)
    spaces = get_spaces_for_org(conn, org_id)
    owner_opts = "".join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in users])
    space_opts = "".join(
        [
            f"<option value='{space['id']}' {'selected' if selected_space_id and int(space['id']) == int(selected_space_id) else ''}>{h(space['name'])}</option>"
            for space in spaces
        ]
    )

    grouped = split_rows_by_status(rows, CONSUMABLE_STATUSES)
    row_html = "".join(
        [
            f"""
            <tr>
              <td><button type='button' class='linkish list-open' data-list-entity='consumable' data-list-id='{r['id']}'>{h(r['name'])}</button></td>
              <td>
                <select class='quick-field list-quick-field' data-entity='consumable' data-id='{r['id']}' data-field='space_id' aria-label='Consumable space for {h(r["name"])}'>
                  {''.join([f"<option value='{space['id']}' {'selected' if str(r['space_id'] or '') == str(space['id']) else ''}>{h(space['name'])}</option>" for space in spaces])}
                </select>
              </td>
              <td><input class='quick-field list-quick-field' data-entity='consumable' data-id='{r['id']}' data-field='category' value='{h(r['category'] or "")}' aria-label='Consumable category for {h(r["name"])}' /></td>
              <td><input type='number' step='0.01' min='0' class='quick-field list-quick-field' data-entity='consumable' data-id='{r['id']}' data-field='quantity_on_hand' value='{h(r['quantity_on_hand'])}' aria-label='Quantity on hand for {h(r["name"])}' /></td>
              <td><input type='number' step='0.01' min='0' class='quick-field list-quick-field' data-entity='consumable' data-id='{r['id']}' data-field='reorder_point' value='{h(r['reorder_point'])}' aria-label='Reorder point for {h(r["name"])}' /></td>
              <td>
                <select class='quick-status list-quick-status' data-entity='consumable' data-id='{r['id']}' aria-label='Consumable status for {h(r["name"])}'>
                  {''.join([f"<option {'selected' if r['status'] == s else ''}>{h(s)}</option>" for s in CONSUMABLE_STATUSES])}
                </select>
              </td>
              <td>
                <select class='quick-field list-quick-field' data-entity='consumable' data-id='{r['id']}' data-field='owner_user_id' aria-label='Consumable owner for {h(r["name"])}'>
                  <option value=''>Unassigned</option>
                  {''.join([f"<option value='{u['id']}' {'selected' if str(r['owner_user_id'] or '') == str(u['id']) else ''}>{h(u['name'])}</option>" for u in users])}
                </select>
              </td>
            </tr>
            """
            for r in rows[:180]
        ]
    ) or "<tr><td colspan='7'>No consumables tracked yet.</td></tr>"

    columns: List[str] = []
    for status in CONSUMABLE_STATUSES:
        cards = grouped[status]
        cards_html = "".join(
            [
                f"""
                <article class='kanban-card interactive-card consumable-card'
                  draggable='true'
                  tabindex='0'
                  data-entity='consumable'
                  data-id='{r['id']}'
                  data-name='{h(r['name'])}'
                  data-category='{h(r['category'] or '')}'
                  data-space-id='{h(r['space_id'] or '')}'
                  data-quantity-on-hand='{h(r['quantity_on_hand'])}'
                  data-unit='{h(r['unit'] or '')}'
                  data-reorder-point='{h(r['reorder_point'])}'
                  data-status='{h(r['status'])}'
                  data-owner-id='{h(r['owner_user_id'] or '')}'
                  data-notes='{h(r['notes'] or '')}'>
                  <div class='card-topline'>
                    <h5 class='card-title-label'>{h(r['name'])}</h5>
                    <div class='inline'>
                      <select class='quick-status' data-entity='consumable' data-id='{r['id']}' aria-label='Status for {h(r["name"])}'>
                        {''.join([f"<option {'selected' if r['status'] == s else ''}>{h(s)}</option>" for s in CONSUMABLE_STATUSES])}
                      </select>
                    </div>
                  </div>
                  <p class='muted meta-line-1'>{h(r['space_name'] or 'No space')} · {h(r['category'] or '-')}</p>
                  <p class='muted meta-line-2'>On hand: {h(r['quantity_on_hand'])} {h(r['unit'] or '')} · Reorder at {h(r['reorder_point'])}</p>
                  <p class='muted meta-line-3'>Owner: {h(r['owner_name'] or 'Unassigned')}</p>
                  <p class='card-hint'>Click to edit · Drag to move</p>
                </article>
                """
                for r in cards
            ]
        ) or "<p class='muted'>No items in this status.</p>"
        columns.append(
            f"<section class='kanban-col' data-status='{h(status)}'>{kanban_header(status, len(cards))}<div class='kanban-col-body drop-zone' data-entity='consumable' data-status='{h(status)}'>{cards_html}</div></section>"
        )

    return f"""
    <section class='card maker-hero'>
      <h2>Consumables Management Board</h2>
      <p>Track stock, prevent shortages, and assign ownership by space.</p>
    </section>
    {board_mode_toggle("consumables")}
    <section id='consumable-kanban' class='kanban-board' data-statuses='{"|".join(CONSUMABLE_STATUSES)}' data-view-surface='consumables' data-view-mode='kanban'>
      {''.join(columns)}
    </section>
    <section class='two'>
      <div class='card'>
        <details>
          <summary>Add Consumable</summary>
          <form method='post' action='/consumables/new'>
            <input type='hidden' name='csrf_token' value='{{csrf}}' />
            <label>Name <input name='name' required placeholder='PLA Filament Spools' /></label>
            <label>Category <input name='category' placeholder='3D Printing' /></label>
            <label>Space <select name='space_id' required><option value=''>Select space</option>{space_opts}</select></label>
            <label>Quantity on hand <input type='number' step='0.01' min='0' name='quantity_on_hand' value='0' /></label>
            <label>Unit <input name='unit' placeholder='spools / sheets / liters' /></label>
            <label>Reorder point <input type='number' step='0.01' min='0' name='reorder_point' value='0' /></label>
            <label>Status <select name='status'>{''.join([f"<option>{h(s)}</option>" for s in CONSUMABLE_STATUSES])}</select></label>
            <label>Owner <select name='owner_user_id'><option value=''>Unassigned</option>{owner_opts}</select></label>
            <label>Notes <textarea name='notes'></textarea></label>
            <button type='submit'>Add Consumable</button>
          </form>
        </details>
      </div>
      <div class='card'>
        <h3>Restocking Best Practice</h3>
        <ul>
          <li>Set reorder points by lead time + average weekly use</li>
          <li>Assign owner by space to avoid accountability gaps</li>
          <li>Use status + quantity for early stockout alerts</li>
        </ul>
      </div>
    </section>
    <section class='card board-list-surface' data-view-surface='consumables' data-view-mode='list' hidden>
      <h3>Consumables List View</h3>
      <table><thead><tr><th>Name</th><th>Space</th><th>Category</th><th>On Hand</th><th>Reorder Point</th><th>Status</th><th>Owner</th></tr></thead><tbody>{row_html}</tbody></table>
    </section>
    """


def render_intake_page(conn: sqlite3.Connection, org_id: int) -> str:
    rows = conn.execute(
        """
        SELECT r.*, u.name as owner_name
        FROM intake_requests r
        LEFT JOIN users u ON u.id = r.owner_user_id
        WHERE r.organization_id = ? AND r.deleted_at IS NULL
        ORDER BY r.score DESC, r.created_at DESC
        LIMIT 200
        """,
        (org_id,),
    ).fetchall()
    users = get_users_for_org(conn, org_id)
    projects = conn.execute(
        "SELECT id, name FROM projects WHERE organization_id = ? AND deleted_at IS NULL ORDER BY name",
        (org_id,),
    ).fetchall()
    spaces = get_spaces_for_org(conn, org_id)
    owner_opts = "".join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in users])
    project_opts = "".join([f"<option value='{p['id']}'>{h(p['name'])}</option>" for p in projects])
    space_opts = "".join([f"<option value='{s['id']}'>{h(s['name'])}</option>" for s in spaces])
    grouped = split_rows_by_status(rows, INTAKE_STATUSES)
    table_rows = "".join(
        [
            f"""
            <tr>
              <td><button type='button' class='linkish list-open' data-list-entity='intake' data-list-id='{r['id']}'>{h(r['title'])}</button></td>
              <td>
                <select class='quick-field list-quick-field' data-entity='intake' data-id='{r['id']}' data-field='lane' aria-label='Intake lane for {h(r["title"])}'>
                  {''.join([f"<option {'selected' if r['lane'] == lane else ''}>{h(lane)}</option>" for lane in LANES])}
                </select>
              </td>
              <td>
                <select class='quick-status list-quick-status' data-entity='intake' data-id='{r['id']}' aria-label='Intake status for {h(r["title"])}'>
                  {''.join([f"<option {'selected' if r['status'] == s else ''}>{h(s)}</option>" for s in INTAKE_STATUSES])}
                </select>
              </td>
              <td>{h(r['score'])}</td>
              <td>
                <select class='quick-field list-quick-field' data-entity='intake' data-id='{r['id']}' data-field='owner_user_id' aria-label='Intake owner for {h(r["title"])}'>
                  <option value=''>Unassigned</option>
                  {''.join([f"<option value='{u['id']}' {'selected' if str(r['owner_user_id'] or '') == str(u['id']) else ''}>{h(u['name'])}</option>" for u in users])}
                </select>
              </td>
            </tr>
            """
            for r in rows[:120]
        ]
    ) or "<tr><td colspan='5'>No requests yet.</td></tr>"
    conversion_rows = "".join(
        [
            f"""
            <tr>
              <td>{h(r['title'])}</td>
              <td>{h(r['status'])}</td>
              <td>{h(r['lane'])}</td>
              <td>{h(r['score'])}</td>
              <td>
                <form method='post' action='/intake/convert' class='inline-form'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='intake_id' value='{r['id']}' />
                  <label class='sr-only' for='convert-kind-{r["id"]}'>Convert To</label>
                  <select id='convert-kind-{r["id"]}' name='convert_to'>
                    <option value='task'>Task</option>
                    <option value='project'>Project</option>
                  </select>
                  <label class='sr-only' for='convert-project-{r["id"]}'>Target Project</label>
                  <select id='convert-project-{r["id"]}' name='project_id'>
                    <option value=''>Ops Project (auto)</option>
                    {project_opts}
                  </select>
                  <label class='sr-only' for='convert-space-{r["id"]}'>Space</label>
                  <select id='convert-space-{r["id"]}' name='space_id'>
                    <option value=''>Default space</option>
                    {space_opts}
                  </select>
                  <button type='submit'>Convert</button>
                </form>
              </td>
            </tr>
            """
            for r in rows
            if str(r["status"]) not in {"Done", "Rejected"}
        ][:120]
    ) or "<tr><td colspan='5'>No open intake items to convert.</td></tr>"
    columns: List[str] = []
    for status in INTAKE_STATUSES:
        cards = grouped[status]
        cards_html = "".join(
            [
                f"""
                <article class='kanban-card interactive-card intake-card'
                  draggable='true'
                  tabindex='0'
                  data-entity='intake'
                  data-id='{r['id']}'
                  data-title='{h(r['title'])}'
                  data-lane='{h(r['lane'])}'
                  data-urgency='{h(r['urgency'])}'
                  data-impact='{h(r['impact'])}'
                  data-effort='{h(r['effort'])}'
                  data-status='{h(r['status'])}'
                  data-owner-id='{h(r['owner_user_id'] or '')}'
                  data-details='{h(r['details'] or '')}'
                  data-requestor-name='{h(r['requestor_name'] or '')}'
                  data-requestor-email='{h(r['requestor_email'] or '')}'>
                  <div class='card-topline'>
                    <h5 class='card-title-label'>{h(r['title'])}</h5>
                    <div class='inline'>
                      <select class='quick-status' data-entity='intake' data-id='{r['id']}' aria-label='Status for {h(r["title"])}'>
                        {''.join([f"<option {'selected' if r['status'] == s else ''}>{h(s)}</option>" for s in INTAKE_STATUSES])}
                      </select>
                    </div>
                  </div>
                  <p class='muted meta-line-1'>{h(r['lane'])} · Owner: {h(r['owner_name'] or 'Unassigned')}</p>
                  <p class='muted meta-line-2'>Score: <strong>{h(r['score'])}</strong> · U/I/E: {h(r['urgency'])}/{h(r['impact'])}/{h(r['effort'])}</p>
                  <p class='card-hint'>Click to edit · Drag to move</p>
                </article>
                """
                for r in cards
            ]
        ) or "<p class='muted'>No intake items in this status.</p>"
        columns.append(
            f"<section class='kanban-col' data-status='{h(status)}'>{kanban_header(status, len(cards))}<div class='kanban-col-body drop-zone' data-entity='intake' data-status='{h(status)}'>{cards_html}</div></section>"
        )

    return f"""
    <section class=\"card maker-hero\">
      <h2>Intake Triage Board</h2>
      <p>Capture inbound requests, score/prioritize, then convert approved work into projects or tasks.</p>
    </section>
    {board_mode_toggle("intake")}
    <section id='intake-kanban' class='kanban-board' data-statuses='{"|".join(INTAKE_STATUSES)}' data-view-surface='intake' data-view-mode='kanban'>
      {''.join(columns)}
    </section>
    <section class=\"two\">
      <div class=\"card\">
        <details>
          <summary>New Intake Item</summary>
          <form method=\"post\" action=\"/intake/new\">
            <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
            <label>Request Title <input name=\"title\" required /></label>
            <label>Requestor Name <input name=\"requestor_name\" /></label>
            <label>Requestor Email <input type=\"email\" name=\"requestor_email\" /></label>
            <label>Lane <select name=\"lane\">{''.join([f'<option>{h(lane)}</option>' for lane in LANES])}</select></label>
            <label>Urgency (1-5) <input type=\"number\" min=\"1\" max=\"5\" name=\"urgency\" value=\"3\" /></label>
            <label>Impact (1-5) <input type=\"number\" min=\"1\" max=\"5\" name=\"impact\" value=\"3\" /></label>
            <label>Effort (1-5) <input type=\"number\" min=\"1\" max=\"5\" name=\"effort\" value=\"3\" /></label>
            <label>Owner <select name=\"owner_user_id\"><option value=''>Unassigned</option>{owner_opts}</select></label>
            <label>Details <textarea name=\"details\"></textarea></label>
            <button type=\"submit\">Create Intake Item</button>
          </form>
        </details>
      </div>
      <div class=\"card\">
        <h3>Scoring Formula</h3>
        <p><code>score = impact*2 + urgency*1.5 - effort*0.8</code></p>
        <p>Intake is the front door for work requests. Once approved, convert to a task/project and close the intake item.</p>
      </div>
    </section>
    <section class='card'>
      <h3>Intake Conversion Queue</h3>
      <table>
        <thead><tr><th>Request</th><th>Status</th><th>Lane</th><th>Score</th><th>Action</th></tr></thead>
        <tbody>{conversion_rows}</tbody>
      </table>
    </section>
    <section class=\"card board-list-surface\" data-view-surface='intake' data-view-mode='list' hidden>
      <h3>Intake List View</h3>
      <table><thead><tr><th>Title</th><th>Lane</th><th>Status</th><th>Score</th><th>Owner</th></tr></thead><tbody>{table_rows}</tbody></table>
    </section>
    """


def render_assets_page(conn: sqlite3.Connection, org_id: int, selected_space_name: str = "") -> str:
    rows_sql = """
        SELECT a.*, u.name as owner_name
        FROM equipment_assets a
        LEFT JOIN users u ON u.id = a.owner_user_id
        WHERE a.organization_id = ? AND a.deleted_at IS NULL
    """
    rows_params: List[object] = [org_id]
    if selected_space_name:
        rows_sql += " AND a.space = ?"
        rows_params.append(selected_space_name)
    rows_sql += " ORDER BY COALESCE(a.next_maintenance, '9999-12-31')"
    rows = conn.execute(rows_sql, tuple(rows_params)).fetchall()
    users = get_users_for_org(conn, org_id)
    spaces = get_spaces_for_org(conn, org_id)
    owner_opts = "".join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in users])
    grouped = split_rows_by_status(rows, ASSET_STATUSES)
    row_html = "".join(
        [
            f"""
            <tr>
              <td><button type='button' class='linkish list-open' data-list-entity='asset' data-list-id='{a['id']}'>{h(a['name'])}</button></td>
              <td>
                <select class='quick-field list-quick-field' data-entity='asset' data-id='{a['id']}' data-field='space' aria-label='Asset space for {h(a["name"])}'>
                  {''.join([f"<option {'selected' if str(a['space'] or '') == str(space['name']) else ''}>{h(space['name'])}</option>" for space in spaces])}
                </select>
              </td>
              <td><input class='quick-field list-quick-field' data-entity='asset' data-id='{a['id']}' data-field='asset_type' value='{h(a['asset_type'] or '')}' aria-label='Asset type for {h(a["name"])}' /></td>
              <td>
                <select class='quick-status list-quick-status' data-entity='asset' data-id='{a['id']}' aria-label='Asset status for {h(a["name"])}'>
                  {''.join([f"<option {'selected' if a['status'] == s else ''}>{h(s)}</option>" for s in ASSET_STATUSES])}
                </select>
              </td>
              <td><input type='date' class='quick-field list-quick-field due-input' data-entity='asset' data-id='{a['id']}' data-field='next_maintenance' value='{h(a['next_maintenance'] or '')}' aria-label='Next maintenance for {h(a["name"])}' /></td>
              <td>
                <select class='quick-field list-quick-field' data-entity='asset' data-id='{a['id']}' data-field='owner_user_id' aria-label='Asset owner for {h(a["name"])}'>
                  <option value=''>Unassigned</option>
                  {''.join([f"<option value='{u['id']}' {'selected' if str(a['owner_user_id'] or '') == str(u['id']) else ''}>{h(u['name'])}</option>" for u in users])}
                </select>
              </td>
            </tr>
            """
            for a in rows[:120]
        ]
    ) or "<tr><td colspan='6'>No assets tracked yet.</td></tr>"
    columns: List[str] = []
    for status in ASSET_STATUSES:
        cards = grouped[status]
        cards_html = "".join(
            [
                f"""
                <article class='kanban-card interactive-card asset-card'
                  draggable='true'
                  tabindex='0'
                  data-entity='asset'
                  data-id='{a['id']}'
                  data-name='{h(a['name'])}'
                  data-space='{h(a['space'])}'
                  data-asset-type='{h(a['asset_type'] or '')}'
                  data-status='{h(a['status'])}'
                  data-next-maintenance='{h(a['next_maintenance'] or '')}'
                  data-last-maintenance='{h(a['last_maintenance'] or '')}'
                  data-cert-required='{h(a['cert_required'])}'
                  data-cert-name='{h(a['cert_name'] or '')}'
                  data-owner-id='{h(a['owner_user_id'] or '')}'
                  data-notes='{h(a['notes'] or '')}'>
                  <div class='card-topline'>
                    <h5 class='card-title-label'>{h(a['name'])}</h5>
                    <div class='inline'>
                      <select class='quick-status' data-entity='asset' data-id='{a['id']}' aria-label='Status for {h(a["name"])}'>
                        {''.join([f"<option {'selected' if a['status'] == s else ''}>{h(s)}</option>" for s in ASSET_STATUSES])}
                      </select>
                    </div>
                  </div>
                  <p class='muted meta-line-1'>{h(a['space'])} · {h(a['asset_type'] or '-')}</p>
                  <p class='muted meta-line-2'>Owner: {h(a['owner_name'] or 'Unassigned')} · Next: {h(a['next_maintenance'] or '-')}</p>
                  <p class='card-hint'>Click to edit · Drag to move</p>
                </article>
                """
                for a in cards
            ]
        ) or "<p class='muted'>No assets in this status.</p>"
        columns.append(
            f"<section class='kanban-col' data-status='{h(status)}'>{kanban_header(status, len(cards))}<div class='kanban-col-body drop-zone' data-entity='asset' data-status='{h(status)}'>{cards_html}</div></section>"
        )

    return f"""
    <section class=\"card maker-hero\">
      <h2>Asset Operations Board</h2>
      <p>Track readiness, service state, and ownership with direct edits.</p>
    </section>
    {board_mode_toggle("assets")}
    <section id='asset-kanban' class='kanban-board' data-statuses='{"|".join(ASSET_STATUSES)}' data-view-surface='assets' data-view-mode='kanban'>
      {''.join(columns)}
    </section>
    <section class=\"two\">
      <div class=\"card\">
        <details>
          <summary>Add Asset</summary>
          <form method=\"post\" action=\"/assets/new\">
            <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
            <label>Asset Name <input name=\"name\" required /></label>
            <label>Space <input name=\"space\" required placeholder=\"MakerLab\" /></label>
            <label>Type <input name=\"asset_type\" placeholder=\"3D Printer\" /></label>
            <label>Status <select name=\"status\"><option>Operational</option><option>Needs Service</option><option>Down</option></select></label>
            <label>Last Maintenance <input type=\"date\" name=\"last_maintenance\" /></label>
            <label>Next Maintenance <input type=\"date\" name=\"next_maintenance\" /></label>
            <label><input type=\"checkbox\" name=\"cert_required\" value=\"1\" /> Certification required</label>
            <label>Certification Name <input name=\"cert_name\" placeholder=\"CNC Safety\" /></label>
            <label>Owner <select name=\"owner_user_id\"><option value=''>Unassigned</option>{owner_opts}</select></label>
            <button type=\"submit\">Add Asset</button>
          </form>
        </details>
      </div>
      <div class=\"card\">
        <h3>Practice</h3>
        <ul>
          <li>Link asset readiness to program planning</li>
          <li>Prevent downtime from hidden maintenance debt</li>
          <li>Gate risky tools behind completion records</li>
        </ul>
      </div>
    </section>
    <section class=\"card board-list-surface\" data-view-surface='assets' data-view-mode='list' hidden>
      <h3>Asset List View</h3>
      <table><thead><tr><th>Name</th><th>Space</th><th>Type</th><th>Status</th><th>Next Maintenance</th><th>Owner</th></tr></thead><tbody>{row_html}</tbody></table>
    </section>
    """


def render_partnership_page(conn: sqlite3.Connection, org_id: int) -> str:
    rows = conn.execute(
        """
        SELECT p.*, u.name as owner_name
        FROM partnerships p
        LEFT JOIN users u ON u.id = p.owner_user_id
        WHERE p.organization_id = ? AND p.deleted_at IS NULL
        ORDER BY COALESCE(p.next_followup, '9999-12-31')
        """,
        (org_id,),
    ).fetchall()
    users = get_users_for_org(conn, org_id)
    owner_opts = "".join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in users])
    grouped = split_rows_by_status(rows, PARTNERSHIP_STAGES, key="stage")
    rows_html = "".join(
        [
            f"""
            <tr>
              <td><button type='button' class='linkish list-open' data-list-entity='partnership' data-list-id='{p['id']}'>{h(p['partner_name'])}</button></td>
              <td><input class='quick-field list-quick-field' data-entity='partnership' data-id='{p['id']}' data-field='school' value='{h(p['school'] or "")}' aria-label='Partnership school for {h(p["partner_name"])}' /></td>
              <td>
                <select class='quick-status list-quick-status' data-entity='partnership' data-id='{p['id']}' aria-label='Partnership stage for {h(p["partner_name"])}'>
                  {''.join([f"<option {'selected' if p['stage'] == s else ''}>{h(s)}</option>" for s in PARTNERSHIP_STAGES])}
                </select>
              </td>
              <td>
                <select class='quick-field list-quick-field' data-entity='partnership' data-id='{p['id']}' data-field='health' aria-label='Partnership health for {h(p["partner_name"])}'>
                  {''.join([f"<option {'selected' if str(p['health'] or 'Medium') == level else ''}>{level}</option>" for level in ['Strong','Medium','At Risk']])}
                </select>
              </td>
              <td><input type='date' class='quick-field list-quick-field due-input' data-entity='partnership' data-id='{p['id']}' data-field='next_followup' value='{h(p['next_followup'] or "")}' aria-label='Next followup for {h(p["partner_name"])}' /></td>
              <td>
                <select class='quick-field list-quick-field' data-entity='partnership' data-id='{p['id']}' data-field='owner_user_id' aria-label='Partnership owner for {h(p["partner_name"])}'>
                  <option value=''>Unassigned</option>
                  {''.join([f"<option value='{u['id']}' {'selected' if str(p['owner_user_id'] or '') == str(u['id']) else ''}>{h(u['name'])}</option>" for u in users])}
                </select>
              </td>
            </tr>
            """
            for p in rows[:120]
        ]
    ) or "<tr><td colspan='6'>No partnerships tracked yet.</td></tr>"
    columns: List[str] = []
    for stage in PARTNERSHIP_STAGES:
        cards = grouped[stage]
        cards_html = "".join(
            [
                f"""
                <article class='kanban-card interactive-card partnership-card'
                  draggable='true'
                  tabindex='0'
                  data-entity='partnership'
                  data-id='{p['id']}'
                  data-partner-name='{h(p['partner_name'])}'
                  data-school='{h(p['school'] or '')}'
                  data-stage='{h(p['stage'])}'
                  data-health='{h(p['health'] or 'Medium')}'
                  data-last-contact='{h(p['last_contact'] or '')}'
                  data-next-followup='{h(p['next_followup'] or '')}'
                  data-owner-id='{h(p['owner_user_id'] or '')}'
                  data-notes='{h(p['notes'] or '')}'>
                  <div class='card-topline'>
                    <h5 class='card-title-label'>{h(p['partner_name'])}</h5>
                    <div class='inline'>
                      <select class='quick-status' data-entity='partnership' data-id='{p['id']}' aria-label='Stage for {h(p["partner_name"])}'>
                        {''.join([f"<option {'selected' if p['stage'] == s else ''}>{h(s)}</option>" for s in PARTNERSHIP_STAGES])}
                      </select>
                    </div>
                  </div>
                  <p class='muted meta-line-1'>{h(p['school'] or '-')} · {h(p['health'] or 'Medium')}</p>
                  <p class='muted meta-line-2'>Owner: {h(p['owner_name'] or 'Unassigned')} · Follow-up: {h(p['next_followup'] or '-')}</p>
                  <p class='card-hint'>Click to edit · Drag to move</p>
                </article>
                """
                for p in cards
            ]
        ) or "<p class='muted'>No partnerships in this stage.</p>"
        columns.append(
            f"<section class='kanban-col' data-status='{h(stage)}'>{kanban_header(stage, len(cards))}<div class='kanban-col-body drop-zone' data-entity='partnership' data-status='{h(stage)}'>{cards_html}</div></section>"
        )

    return f"""
    <section class=\"card maker-hero\">
      <h2>Partnership Pipeline Board</h2>
      <p>Keep follow-up ownership and stage movement visible across the team.</p>
    </section>
    {board_mode_toggle("partnerships")}
    <section id='partnership-kanban' class='kanban-board' data-statuses='{"|".join(PARTNERSHIP_STAGES)}' data-view-surface='partnerships' data-view-mode='kanban'>
      {''.join(columns)}
    </section>
    <section class=\"two\">
      <div class=\"card\">
        <details>
          <summary>Add Partnership</summary>
          <form method=\"post\" action=\"/partnerships/new\">
            <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
            <label>Partner Name <input name=\"partner_name\" required /></label>
            <label>School / Unit <input name=\"school\" placeholder=\"SET\" /></label>
            <label>Stage <select name=\"stage\"><option>Discovery</option><option>Active</option><option>Pilot</option><option>Dormant</option><option>Closed</option></select></label>
            <label>Health <select name=\"health\"><option>Strong</option><option>Medium</option><option>At Risk</option></select></label>
            <label>Last Contact <input type=\"date\" name=\"last_contact\" /></label>
            <label>Next Followup <input type=\"date\" name=\"next_followup\" /></label>
            <label>Owner <select name=\"owner_user_id\"><option value=''>Unassigned</option>{owner_opts}</select></label>
            <label>Notes <textarea name=\"notes\"></textarea></label>
            <button type=\"submit\">Add Partnership</button>
          </form>
        </details>
      </div>
      <div class=\"card\">
        <h3>Why It Matters</h3>
        <p>Repeat engagements are one of Makerspace’s strongest impact multipliers. Track follow-ups to preserve momentum.</p>
      </div>
    </section>
    <section class=\"card board-list-surface\" data-view-surface='partnerships' data-view-mode='list' hidden>
      <h3>Partnership List View</h3>
      <table><thead><tr><th>Partner</th><th>School</th><th>Stage</th><th>Health</th><th>Next Followup</th><th>Owner</th></tr></thead><tbody>{rows_html}</tbody></table>
    </section>
    """


def render_admin_page(
    conn: sqlite3.Connection,
    org_id: int,
    is_superuser: bool = False,
    can_provision_workspaces: bool = False,
) -> str:
    assignable_roles = assignable_membership_roles(can_assign_owner=can_provision_workspaces)
    users = conn.execute(
        """
        SELECT u.id, u.name, u.email, u.is_active, u.is_superuser, m.role
        FROM memberships m
        JOIN users u ON u.id = m.user_id
        WHERE m.organization_id = ?
        ORDER BY u.name
        """,
        (org_id,),
    ).fetchall()
    active_reassign_users = [u for u in users if int(u["is_active"] or 0) == 1]

    def reassign_options(exclude_user_id: int) -> str:
        opts = [
            f"<option value='{u['id']}'>{h(u['name'])}</option>"
            for u in active_reassign_users
            if int(u["id"]) != int(exclude_user_id)
        ]
        return "".join(opts)

    user_rows = "".join(
        [
            f"""
            <tr>
              <td>{h(u['name'])} {'<span class="pill">Super Admin</span>' if u['is_superuser'] else ''}</td>
              <td>{h(u['email'])}</td>
              <td>
                <form method='post' action='/admin/users/role' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='target_user_id' value='{u['id']}' />
                  <select name='role' aria-label='Role for {h(u["email"])}'>
                    {''.join([f"<option {'selected' if u['role'] == role else ''}>{role}</option>" for role in assignable_roles])}
                  </select>
                  <button type='submit'>Save</button>
                </form>
              </td>
              <td>{'Active' if u['is_active'] else 'Disabled'}</td>
              <td>
                <form method='post' action='/admin/users/toggle' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='target_user_id' value='{u['id']}' />
                  <input type='hidden' name='is_active' value='{'0' if u['is_active'] else '1'}' />
                  <button type='submit'>{'Disable' if u['is_active'] else 'Enable'}</button>
                </form>
                <form method='post' action='/admin/users/reset' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='target_user_id' value='{u['id']}' />
                  <button type='submit'>Reset Link</button>
                </form>
                <form method='post' action='/admin/users/delete' class='inline'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='target_user_id' value='{u['id']}' />
                  <select name='reassign_user_id' aria-label='Reassign items for {h(u["email"])}'>
                    {reassign_options(int(u['id']))}
                  </select>
                  <button type='submit' class='ghost'>Remove From Workspace</button>
                </form>
              </td>
            </tr>
            """
            for u in users
        ]
    )

    orgs = conn.execute(
        """
        SELECT o.id, o.name, o.slug, u.name AS owner_name, u.email AS owner_email
        FROM organizations o
        LEFT JOIN users u
          ON u.id = (
            SELECT m.user_id
            FROM memberships m
            WHERE m.organization_id = o.id AND m.role IN ('workspace_admin', 'owner')
            ORDER BY CASE WHEN m.role = 'workspace_admin' THEN 0 ELSE 1 END, m.created_at
            LIMIT 1
          )
        ORDER BY o.name
        """,
    ).fetchall()
    org_rows = "".join(
        [
            f"<li><strong>{h(o['name'])}</strong> ({h(o['slug'])})"
            + (f" · Admin: {h(o['owner_name'])} ({h(o['owner_email'])})" if o["owner_email"] else "")
            + "</li>"
            for o in orgs
        ]
    ) or "<li>No workspaces created yet.</li>"

    workspace_panel = f"""
      <div class=\"card\">
        <h3>Provision Workspaces</h3>
        <form method=\"post\" action=\"/admin/workspaces/new\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <label>Workspace / Department Name <input name=\"name\" required /></label>
          <label>Slug <input name=\"slug\" required placeholder=\"maker-network-east\" /></label>
          <label>Workspace Admin Name <input name=\"workspace_admin_name\" placeholder=\"Department Admin\" /></label>
          <label>Workspace Admin Email <input type=\"email\" name=\"workspace_admin_email\" placeholder=\"admin@department.edu\" /></label>
          <label>Workspace Admin Temporary Password <input type=\"text\" name=\"workspace_admin_password\" minlength=\"12\" placeholder=\"Optional (auto-generated if empty)\" /></label>
          <button type=\"submit\">Create Workspace</button>
        </form>
        <p class='muted'>Each non-superuser admin account can control one workspace only.</p>
        <ul>{org_rows}</ul>
        <hr />
        <h4>Delete Workspace (Owner Only)</h4>
        <p class='muted'>Type the workspace slug and choose reassignment owner before deleting.</p>
        <form method='post' action='/admin/workspaces/delete'>
          <input type='hidden' name='csrf_token' value='{{csrf}}' />
          <label>Workspace Slug <input name='slug' required placeholder='maker-network-east' /></label>
          <label>Confirm (type DELETE) <input name='confirm' required /></label>
          <button type='submit' class='ghost'>Delete Workspace</button>
        </form>
      </div>
    """ if can_provision_workspaces else f"""
      <div class=\"card\">
        <h3>Workspace Directory</h3>
        <p class='muted'>Workspace provisioning is restricted to owner-level admins.</p>
        <ul>{org_rows}</ul>
      </div>
    """

    cleanup_panel = """
    <section class="two">
      <div class="card">
        <h3>Data Cleanup: Single Item</h3>
        <p class='muted'>Use for removing known test records from one board/entity.</p>
        <form
          method="post"
          action="/admin/data/purge-item"
          data-purge-confirm="1"
          data-confirm-title="Confirm Permanent Item Purge"
          data-confirm-message="This will permanently delete one record and its related references where applicable."
          data-confirm-items="I verified the entity and item ID are correct||I understand this action cannot be undone||I understand this item will be permanently removed"
        >
          <input type="hidden" name="csrf_token" value="{{csrf}}" />
          <label>Entity
            <select name="entity">
              <option value="task">Task</option>
              <option value="project">Project</option>
              <option value="intake">Intake</option>
              <option value="asset">Asset</option>
              <option value="consumable">Consumable</option>
              <option value="partnership">Partnership</option>
            </select>
          </label>
          <label>Item ID <input type="number" min="1" name="item_id" required /></label>
          <button type="submit" class="ghost">Purge Item</button>
        </form>
      </div>
      <div class="card">
        <h3>Data Cleanup: Keyword Purge</h3>
        <p class='muted'>Deletes records across work tables that match a keyword (example: QA).</p>
        <form
          method="post"
          action="/admin/data/purge-keyword"
          data-purge-confirm="1"
          data-confirm-title="Confirm Keyword Purge"
          data-confirm-message="This can remove many records in one action. Use only for cleanup terms like QA/test."
          data-confirm-items="I verified this keyword is specific to test data||I understand this can delete multiple records||I understand this action cannot be undone"
        >
          <input type="hidden" name="csrf_token" value="{{csrf}}" />
          <label>Keyword <input name="keyword" required value="QA" /></label>
          <button type="submit" class="ghost">Purge Matching Data</button>
        </form>
      </div>
    </section>
    """

    audit_rows = conn.execute(
        """
        SELECT a.id, a.created_at, a.action, a.entity, a.entity_id, a.details, u.name AS actor_name
        FROM audit_log a
        LEFT JOIN users u ON u.id = a.user_id
        WHERE a.organization_id = ?
        ORDER BY a.id DESC
        LIMIT 220
        """,
        (org_id,),
    ).fetchall()
    audit_row_cells: List[str] = []
    for r in audit_rows:
        parsed = parse_audit_details(r["details"])
        can_rollback = isinstance(parsed.get("rollback"), dict)
        rollback_action = (
            "<form method='post' action='/admin/audit/rollback' class='inline'>"
            "<input type='hidden' name='csrf_token' value='{{csrf}}' />"
            f"<input type='hidden' name='audit_id' value='{r['id']}' />"
            "<button type='submit' class='ghost'>Rollback</button>"
            "</form>"
        ) if can_rollback else "<span class='muted'>View only</span>"
        audit_row_cells.append(
            f"""
            <tr>
              <td>{h(r['created_at'] or '-')}</td>
              <td>{h(r['actor_name'] or 'System')}</td>
              <td>{h(r['action'] or '-')}</td>
              <td>{h(r['entity'] or '-')} #{h(r['entity_id'] or '-')}</td>
              <td>{h(audit_details_summary(r['details']))}</td>
              <td>{rollback_action}</td>
            </tr>
            """
        )
    audit_row_html = "".join(audit_row_cells) or "<tr><td colspan='6'>No audit events recorded.</td></tr>"
    ledger_panel = f"""
    <section class="card">
      <h3>Audit Ledger</h3>
      <p class='muted'>Tracks database edits, delete workflow actions, and interface issue reports. Use rollback on rows that include a stored snapshot.</p>
      <table>
        <thead><tr><th>When</th><th>Actor</th><th>Action</th><th>Target</th><th>Summary</th><th>Rollback</th></tr></thead>
        <tbody>{audit_row_html}</tbody>
      </table>
    </section>
    """

    return f"""
    <section class=\"two\">
      <div class=\"card\">
        <h3>Add Team Account</h3>
        <form method=\"post\" action=\"/admin/users/new\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <label>Name <input name=\"name\" required /></label>
          <label>Email <input type=\"email\" name=\"email\" required /></label>
          <label>Temporary Password <input type=\"text\" name=\"password\" minlength=\"12\" /></label>
          <label>Role
            <select name=\"role\">
              {''.join([f"<option {'selected' if role == 'staff' else ''}>{role}</option>" for role in assignable_roles])}
            </select>
          </label>
          <button type=\"submit\">Create User</button>
        </form>
      </div>
      {workspace_panel}
    </section>
    <section class=\"card\">
      <h3>Account Provisioning Console</h3>
      <table><thead><tr><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th>Access</th></tr></thead><tbody>{user_rows}</tbody></table>
    </section>
    {cleanup_panel}
    {ledger_panel}
    """


def render_deleted_page(conn: sqlite3.Connection, org_id: int) -> str:
    sections: List[str] = []
    for entity_key in ["task", "project", "intake", "asset", "consumable", "partnership"]:
        policy = delete_policy_for_entity(entity_key)
        if not policy:
            continue
        rows = deleted_rows_for_entity(conn, org_id, entity_key, limit=180)
        row_html = "".join(
            [
                f"""
                <tr>
                  <td>{h(r['id'])}</td>
                  <td>{h(r['title'])}</td>
                  <td>{h(r['status'] or '-')}</td>
                  <td>{h(r['deleted_at'] or '-')}</td>
                  <td>{h(r['deleted_by_name'] or '-')}</td>
                  <td>
                    <form method='post' action='/deleted/restore' class='inline'>
                      <input type='hidden' name='csrf_token' value='{{csrf}}' />
                      <input type='hidden' name='entity' value='{entity_key}' />
                      <input type='hidden' name='item_id' value='{r['id']}' />
                      <button type='submit'>Restore</button>
                    </form>
                    <form
                      method='post'
                      action='/deleted/purge'
                      class='inline'
                      data-purge-confirm='1'
                      data-confirm-title='Confirm Trash Purge'
                      data-confirm-message='This permanently deletes {h(str(policy["label"]))} #{h(r["id"])} from the deleted queue.'
                      data-confirm-items='I verified this is the correct record||I understand this item cannot be restored after purge||I want to permanently remove this item'
                    >
                      <input type='hidden' name='csrf_token' value='{{csrf}}' />
                      <input type='hidden' name='entity' value='{entity_key}' />
                      <input type='hidden' name='item_id' value='{r['id']}' />
                      <button type='submit' class='ghost'>Purge</button>
                    </form>
                  </td>
                </tr>
                """
                for r in rows
            ]
        ) or "<tr><td colspan='6'>No deleted items.</td></tr>"
        sections.append(
            f"""
            <section class='card'>
              <h3>{h(str(policy['label']))} Trash</h3>
              <table>
                <thead><tr><th>ID</th><th>Title</th><th>Last Status</th><th>Deleted At</th><th>Deleted By</th><th>Actions</th></tr></thead>
                <tbody>{row_html}</tbody>
              </table>
            </section>
            """
        )
    return (
        "<section class='card maker-hero'><h2>Deleted Items Queue</h2><p>Soft-deleted records are hidden from normal boards until restored or purged by admin.</p></section>"
        + "".join(sections)
    )


def render_settings_page(
    conn: sqlite3.Connection,
    user_id: int,
    org_id: int,
    role: str,
    selected_space_id: Optional[int] = None,
) -> str:
    prefs = load_user_preferences(conn, user_id)
    profile = conn.execute("SELECT id, name, email, timezone, title FROM users WHERE id = ?", (user_id,)).fetchone()
    spaces = get_spaces_for_org(conn, org_id)
    teams = get_teams_for_org(conn, org_id)
    users = get_users_for_org(conn, org_id)
    recent_sessions = conn.execute(
        """
        SELECT id, created_at, last_seen_at, ip_address, user_agent
        FROM sessions
        WHERE user_id = ?
        ORDER BY created_at DESC
        LIMIT 10
        """,
        (user_id,),
    ).fetchall()

    fields = conn.execute(
        "SELECT entity, field_key, label, field_type, is_enabled FROM field_configs WHERE organization_id = ? ORDER BY entity, field_key",
        (org_id,),
    ).fetchall()
    field_rows = "".join(
        [
            f"<tr><td>{h(f['entity'])}</td><td>{h(f['field_key'])}</td><td>{h(f['label'])}</td><td>{h(f['field_type'])}</td><td>{'Yes' if f['is_enabled'] else 'No'}</td></tr>"
            for f in fields
        ]
    )
    session_rows = "".join(
        [
            f"<tr><td>{h(s['created_at'])}</td><td>{h(s['last_seen_at'] or '-')}</td><td>{h(s['ip_address'] or '-')}</td><td>{h((s['user_agent'] or '-')[:80])}</td></tr>"
            for s in recent_sessions
        ]
    ) or "<tr><td colspan='4'>No active sessions recorded.</td></tr>"
    space_rows = "".join(
        [
            f"""
            <tr>
              <td colspan='3'>
                <form method='post' action='/settings/spaces/update' class='inline-form'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='space_id' value='{space['id']}' />
                  <label>Name <input name='name' value='{h(space['name'])}' required /></label>
                  <label>Location <input name='location' value='{h(space['location'] or '')}' /></label>
                  <label>Description <input name='description' value='{h(space['description'] or '')}' /></label>
                  <button type='submit'>Save</button>
                </form>
                <form method='post' action='/settings/spaces/delete' class='inline-form'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='space_id' value='{space['id']}' />
                  <label>Move all work to
                    <select name='replacement_space_id'>
                      {''.join([f"<option value='{s['id']}'>{h(s['name'])}</option>" for s in spaces if int(s['id']) != int(space['id'])])}
                    </select>
                  </label>
                  <button type='submit' class='ghost'>Delete Space</button>
                </form>
              </td>
            </tr>
            """
            for space in spaces
        ]
    ) or "<tr><td colspan='3'>No makerspaces added yet.</td></tr>"
    team_rows = "".join(
        [
            f"""
            <tr>
              <td colspan='4'>
                <form method='post' action='/settings/teams/update' class='inline-form'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='team_id' value='{team['id']}' />
                  <label>Name <input name='name' value='{h(team['name'])}' required /></label>
                  <label>Focus <input name='focus_area' value='{h(team['focus_area'] or '')}' /></label>
                  <label>Lead
                    <select name='lead_user_id'>
                      <option value=''>Unassigned</option>
                      {''.join([f"<option value='{u['id']}' {'selected' if str(team['lead_user_id'] or '') == str(u['id']) else ''}>{h(u['name'])}</option>" for u in users])}
                    </select>
                  </label>
                  <button type='submit'>Save</button>
                </form>
                <form method='post' action='/settings/teams/delete' class='inline-form'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='team_id' value='{team['id']}' />
                  <label>Move all work to
                    <select name='replacement_team_id'>
                      <option value=''>No Team</option>
                      {''.join([f"<option value='{row['id']}'>{h(row['name'])}</option>" for row in teams if int(row['id']) != int(team['id'])])}
                    </select>
                  </label>
                  <button type='submit' class='ghost'>Delete Team</button>
                </form>
              </td>
            </tr>
            """
            for team in teams
        ]
    ) or "<tr><td colspan='4'>No teams added yet.</td></tr>"
    lead_opts = "".join([f"<option value='{u['id']}'>{h(u['name'])}</option>" for u in users])
    team_reassign_options = lambda current_id: "".join(  # noqa: E731
        [f"<option value='{t['id']}'>{h(t['name'])}</option>" for t in teams if int(t["id"]) != int(current_id)]
    )
    space_reassign_options = lambda current_id: "".join(  # noqa: E731
        [f"<option value='{s['id']}'>{h(s['name'])}</option>" for s in spaces if int(s["id"]) != int(current_id)]
    )
    primary_allowed, account_allowed = available_nav_items(role)
    nav_allowed = primary_allowed + account_allowed
    nav_allowed_keys = nav_keys(nav_allowed)
    role_defaults = load_role_nav_preference(conn, org_id, role, nav_allowed_keys)
    user_nav_raw = prefs.get("nav_visibility") if isinstance(prefs.get("nav_visibility"), list) else []
    user_nav_selected = sanitize_nav_key_selection(user_nav_raw, nav_allowed_keys, fallback=role_defaults)
    nav_rows = "".join(
        [
            f"<label><input type='checkbox' name='nav_{h(item['key'])}' value='1' {'checked' if item['key'] in user_nav_selected else ''} /> {h(item['label'])}</label>"
            for item in nav_allowed
        ]
    )
    role_nav_blocks: List[str] = []
    if role_allows(role, "workspace_admin"):
        for target_role in MEMBERSHIP_ROLE_OPTIONS:
            if target_role in {"workspace_admin", "owner"} and not role_allows(role, "owner"):
                continue
            role_primary, role_account = available_nav_items(target_role)
            role_items = role_primary + role_account
            role_item_keys = nav_keys(role_items)
            role_selected = load_role_nav_preference(conn, org_id, target_role, role_item_keys)
            role_checks = "".join(
                [
                    f"<label><input type='checkbox' name='role_nav_{h(item['key'])}' value='1' {'checked' if item['key'] in role_selected else ''} /> {h(item['label'])}</label>"
                    for item in role_items
                ]
            )
            role_nav_blocks.append(
                f"""
                <form method='post' action='/settings/nav-role/update' class='card'>
                  <input type='hidden' name='csrf_token' value='{{csrf}}' />
                  <input type='hidden' name='target_role' value='{h(target_role)}' />
                  <h4>Role Nav Default: {h(target_role)}</h4>
                  <div class='check-grid'>{role_checks}</div>
                  <button type='submit'>Save {h(target_role)} Defaults</button>
                </form>
                """
            )
    role_nav_panel = (
        "<section class='card'><h3>Role-Based Sidebar Defaults</h3><div class='template-grid'>"
        + "".join(role_nav_blocks)
        + "</div></section>"
        if role_nav_blocks
        else ""
    )

    return f"""
    <section class=\"two\">
      <div class=\"card\">
        <h3>My Account</h3>
        <form method=\"post\" action=\"/settings/profile\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <label>Name <input name=\"name\" value=\"{h(profile['name'])}\" required /></label>
          <label>Email <input type=\"email\" name=\"email\" value=\"{h(profile['email'])}\" required /></label>
          <label>Title <input name=\"title\" value=\"{h(profile['title'] or '')}\" /></label>
          <label>Timezone <input name=\"timezone\" value=\"{h(profile['timezone'] or 'America/New_York')}\" /></label>
          <button type=\"submit\">Update Profile</button>
        </form>
        <hr />
        <form method=\"post\" action=\"/settings/password\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <label>Current Password <input type=\"password\" name=\"current_password\" required /></label>
          <label>New Password <input type=\"password\" name=\"new_password\" minlength=\"12\" required /></label>
          <label>Confirm New Password <input type=\"password\" name=\"confirm_password\" minlength=\"12\" required /></label>
          <button type=\"submit\">Change Password</button>
        </form>
      </div>
      <div class=\"card\">
        <h3>Preferences</h3>
        <form method=\"post\" action=\"/settings/update\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <label>Default Task Scope
            <select name=\"default_task_scope\">
              <option {'selected' if prefs.get('default_task_scope') == 'my' else ''}>my</option>
              <option {'selected' if prefs.get('default_task_scope') == 'week' else ''}>week</option>
              <option {'selected' if prefs.get('default_task_scope') == 'team' else ''}>team</option>
            </select>
          </label>
          <label><input type=\"checkbox\" name=\"show_weekend_alert\" value=\"1\" {'checked' if prefs.get('show_weekend_alert') else ''} /> Show weekend load alert</label>
          <label><input type=\"checkbox\" name=\"dashboard_compact\" value=\"1\" {'checked' if prefs.get('dashboard_compact') else ''} /> Compact dashboard cards</label>
          <h4>Email Notifications</h4>
          <label><input type=\"checkbox\" name=\"email_task_updates\" value=\"1\" {'checked' if prefs.get('email_task_updates', True) else ''} /> Task assignment and task updates</label>
          <label><input type=\"checkbox\" name=\"email_project_updates\" value=\"1\" {'checked' if prefs.get('email_project_updates', True) else ''} /> Project updates</label>
          <label><input type=\"checkbox\" name=\"email_comments\" value=\"1\" {'checked' if prefs.get('email_comments', True) else ''} /> Comment activity on watched tasks/projects</label>
          <label><input type=\"checkbox\" name=\"email_mentions\" value=\"1\" {'checked' if prefs.get('email_mentions', True) else ''} /> @Mention alerts</label>
          <h4>Sidebar Visibility</h4>
          <p class='muted'>Choose which views appear in your left navigation.</p>
          <div class='check-grid'>{nav_rows}</div>
          <button type=\"submit\">Save Preferences</button>
        </form>
      </div>
    </section>
    <section class=\"two\">
      <div class=\"card\">
        <h3>Makerspaces</h3>
        <form method=\"post\" action=\"/settings/spaces/new\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <label>Name <input name=\"name\" required placeholder=\"Prototyping Studio\" /></label>
          <label>Location <input name=\"location\" placeholder=\"Engineering Floor 2\" /></label>
          <label>Description <textarea name=\"description\"></textarea></label>
          <button type=\"submit\">Add Makerspace</button>
        </form>
        <p class="muted">Rename spaces and update location in-line.</p>
        <table><thead><tr><th colspan="3">Existing Spaces</th></tr></thead><tbody>{space_rows}</tbody></table>
      </div>
      <div class=\"card\">
        <h3>Teams</h3>
        <form method=\"post\" action=\"/settings/teams/new\">
          <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
          <label>Name <input name=\"name\" required placeholder=\"Student Programs Team\" /></label>
          <label>Focus Area <input name=\"focus_area\" placeholder=\"Workshops and onboarding\" /></label>
          <label>Lead <select name=\"lead_user_id\"><option value=''>Unassigned</option>{lead_opts}</select></label>
          <button type=\"submit\">Add Team</button>
        </form>
        <p class="muted">Rename teams and reassign leads in-line.</p>
        <table><thead><tr><th colspan="4">Existing Teams</th></tr></thead><tbody>{team_rows}</tbody></table>
      </div>
    </section>
    <section class=\"two\">
      <div class=\"card\">
        <h3>Security Sessions</h3>
        <table><thead><tr><th>Created</th><th>Last Seen</th><th>IP</th><th>User Agent</th></tr></thead><tbody>{session_rows}</tbody></table>
      </div>
      <div class=\"card\">
        <h3>Data Portability</h3>
        <p>All import/export tools are centralized in Data Hub.</p>
        <a class=\"btn\" href=\"{h(with_space('/data-hub', selected_space_id))}\">Open Data Hub</a>
      </div>
    </section>
    <section class=\"card\">
      <h3>Field Configuration (Advanced)</h3>
      <form method=\"post\" action=\"/settings/field/new\" class=\"inline-form\">
        <input type=\"hidden\" name=\"csrf_token\" value=\"{{csrf}}\" />
        <label>Entity <select name=\"entity\"><option>projects</option><option>tasks</option><option>intake</option></select></label>
        <label>Field Key <input name=\"field_key\" required placeholder=\"custom_code\" /></label>
        <label>Label <input name=\"label\" required /></label>
        <label>Type <select name=\"field_type\"><option>text</option><option>number</option><option>date</option><option>select</option></select></label>
        <button type=\"submit\">Add Field</button>
      </form>
      <table><thead><tr><th>Entity</th><th>Key</th><th>Label</th><th>Type</th><th>Enabled</th></tr></thead><tbody>{field_rows}</tbody></table>
    </section>
    {role_nav_panel}
    """


def entity_columns(entity: str) -> List[str]:
    mapping = {
        "projects": [
            "id",
            "organization_id",
            "name",
            "description",
            "lane",
            "status",
            "priority",
            "owner_user_id",
            "start_date",
            "due_date",
            "tags",
            "meta_json",
            "created_by",
            "created_at",
            "updated_at",
            "team_id",
            "space_id",
            "progress_pct",
            "deleted_at",
            "deleted_by_user_id",
        ],
        "tasks": [
            "id",
            "organization_id",
            "project_id",
            "title",
            "description",
            "status",
            "priority",
            "assignee_user_id",
            "reporter_user_id",
            "due_date",
            "planned_week",
            "energy",
            "estimate_hours",
            "meta_json",
            "created_at",
            "updated_at",
            "team_id",
            "space_id",
            "deleted_at",
            "deleted_by_user_id",
        ],
        "calendar_events": [
            "id",
            "organization_id",
            "user_id",
            "source",
            "title",
            "start_at",
            "end_at",
            "attendees_count",
            "location",
            "description",
            "category",
            "energy_score",
            "created_at",
        ],
        "intake_requests": [
            "id",
            "organization_id",
            "title",
            "requestor_name",
            "requestor_email",
            "lane",
            "urgency",
            "impact",
            "effort",
            "score",
            "status",
            "owner_user_id",
            "details",
            "meta_json",
            "created_at",
            "updated_at",
            "deleted_at",
            "deleted_by_user_id",
        ],
        "equipment_assets": [
            "id",
            "organization_id",
            "name",
            "space",
            "asset_type",
            "last_maintenance",
            "next_maintenance",
            "cert_required",
            "cert_name",
            "status",
            "owner_user_id",
            "notes",
            "created_at",
            "updated_at",
            "deleted_at",
            "deleted_by_user_id",
        ],
        "consumables": [
            "id",
            "organization_id",
            "space_id",
            "name",
            "category",
            "quantity_on_hand",
            "unit",
            "reorder_point",
            "status",
            "owner_user_id",
            "notes",
            "created_at",
            "updated_at",
            "deleted_at",
            "deleted_by_user_id",
        ],
        "partnerships": [
            "id",
            "organization_id",
            "partner_name",
            "school",
            "stage",
            "last_contact",
            "next_followup",
            "owner_user_id",
            "health",
            "notes",
            "created_at",
            "updated_at",
            "deleted_at",
            "deleted_by_user_id",
        ],
        "spaces": [
            "id",
            "organization_id",
            "name",
            "location",
            "description",
            "created_by",
            "created_at",
        ],
        "teams": [
            "id",
            "organization_id",
            "name",
            "focus_area",
            "lead_user_id",
            "created_at",
        ],
        "meeting_note_sources": [
            "id",
            "organization_id",
            "title",
            "source_type",
            "doc_url",
            "body",
            "linked_agenda_id",
            "created_by",
            "created_at",
            "updated_at",
        ],
    }
    return mapping.get(entity, [])


def export_csv(conn: sqlite3.Connection, org_id: int, entity: str) -> Response:
    cols = entity_columns(entity)
    if not cols:
        return Response("Unknown export entity", status="404 Not Found")
    rows = conn.execute(
        f"SELECT {', '.join(cols)} FROM {entity} WHERE organization_id = ? ORDER BY id",
        (org_id,),
    ).fetchall()
    buf = io.StringIO()
    writer = csv.DictWriter(buf, fieldnames=cols)
    writer.writeheader()
    for row in rows:
        writer.writerow({col: row[col] for col in cols})
    headers = [("Content-Disposition", f"attachment; filename={entity}.csv")]
    return Response(buf.getvalue(), headers=headers, content_type="text/csv; charset=utf-8")


def import_csv(conn: sqlite3.Connection, org_id: int, entity: str, file_obj: cgi.FieldStorage) -> Tuple[bool, str]:
    cols = entity_columns(entity)
    if not cols:
        return False, "Unknown import entity"
    content = file_obj.file.read().decode("utf-8", errors="ignore")
    reader = csv.DictReader(io.StringIO(content))
    allowed = [c for c in cols if c not in {"id", "created_at", "updated_at", "organization_id"}]
    inserted = 0
    skipped_invalid = 0

    for row in reader:
        values = {k: row.get(k) for k in allowed}
        now = iso()
        values["organization_id"] = org_id
        if "created_at" in cols:
            values["created_at"] = now
        if "updated_at" in cols:
            values["updated_at"] = now
        insert_cols = [k for k in values.keys() if k in cols and values[k] not in (None, "")]
        if not insert_cols:
            skipped_invalid += 1
            continue
        placeholders = ", ".join(["?" for _ in insert_cols])
        sql = f"INSERT INTO {entity} ({', '.join(insert_cols)}) VALUES ({placeholders})"
        try:
            conn.execute(sql, tuple(values[k] for k in insert_cols))
            inserted += 1
        except sqlite3.IntegrityError:
            skipped_invalid += 1

    if skipped_invalid:
        return True, f"Imported {inserted} rows into {entity}; skipped {skipped_invalid} invalid rows"
    return True, f"Imported {inserted} rows into {entity}"


def fill_csrf(content: str, csrf_token: str) -> str:
    """Fill csrf placeholders used by server-rendered templates."""
    return content.replace("{{csrf}}", h(csrf_token))


def app(environ, start_response):
    """WSGI entrypoint.

    Route dispatch is intentionally explicit (`if req.path == ...`) rather than framework-based
    so the project stays lightweight and easy to host in constrained environments.
    """
    req = Request(environ)

    if req.path == "/website":
        return redirect("/website/").wsgi(start_response)
    if req.path.startswith("/website/"):
        rel = req.path.replace("/website/", "", 1).strip("/")
        if not rel:
            rel = "index.html"
        website_file = (WEBSITE_DIR / rel).resolve()
        # Security decision: enforce website sandbox to prevent path traversal.
        if WEBSITE_DIR.resolve() not in website_file.parents and website_file != WEBSITE_DIR.resolve():
            return Response("Not found", status="404 Not Found").wsgi(start_response)
        # Support extension-less wiki routes (e.g. /website/wiki/getting-started).
        if not website_file.exists() and "." not in Path(rel).name:
            html_fallback = (WEBSITE_DIR / f"{rel}.html").resolve()
            if WEBSITE_DIR.resolve() in html_fallback.parents and html_fallback.exists() and html_fallback.is_file():
                website_file = html_fallback
            elif (WEBSITE_DIR / rel).resolve().is_dir():
                # Keep canonical trailing slash for directory routes.
                return redirect(f"/website/{rel}/").wsgi(start_response)
        if website_file.is_dir():
            website_file = website_file / "index.html"
        if not website_file.exists() or not website_file.is_file():
            return Response("Not found", status="404 Not Found").wsgi(start_response)
        served_name = website_file.name.lower()
        mime = "text/plain; charset=utf-8"
        if served_name.endswith(".html"):
            mime = "text/html; charset=utf-8"
        elif served_name.endswith(".css"):
            mime = "text/css; charset=utf-8"
        elif served_name.endswith(".js"):
            mime = "application/javascript; charset=utf-8"
        elif served_name.endswith(".json"):
            mime = "application/json; charset=utf-8"
        elif served_name.endswith(".svg"):
            mime = "image/svg+xml"
        elif served_name.endswith(".md"):
            mime = "text/markdown; charset=utf-8"
        return Response(website_file.read_text(encoding="utf-8"), content_type=mime).wsgi(start_response)

    if req.path.startswith("/static/"):
        rel = req.path.replace("/static/", "", 1)
        static_file = STATIC_DIR / rel
        if not static_file.exists() or not static_file.is_file():
            return Response("Not found", status="404 Not Found").wsgi(start_response)
        mime = "text/plain"
        if rel.endswith(".css"):
            mime = "text/css; charset=utf-8"
        elif rel.endswith(".js"):
            mime = "application/javascript; charset=utf-8"
        elif rel.endswith(".svg"):
            mime = "image/svg+xml"
        return Response(static_file.read_text(), content_type=mime).wsgi(start_response)

    if req.path == "/healthz":
        return Response("ok", content_type="text/plain").wsgi(start_response)
    if req.path == "/readyz":
        # Readiness checks include DB reachability to catch locked/corrupt startup states.
        try:
            ensure_bootstrap()
            probe = db_connect()
            probe.execute("SELECT 1").fetchone()
            probe.close()
            return Response("ready", content_type="text/plain").wsgi(start_response)
        except Exception as exc:
            return Response(
                f"not-ready: {h(str(exc))}",
                status="503 Service Unavailable",
                content_type="text/plain",
            ).wsgi(start_response)

    try:
        ensure_bootstrap()
    except Exception as exc:
        body = f"<h1>503 Service Unavailable</h1><p>Database bootstrap failed: {h(str(exc))}</p>"
        return Response(body, status="503 Service Unavailable").wsgi(start_response)

    conn = db_connect()
    ctx = get_auth_context(conn, req)
    notice = req.query.get("msg", "")

    try:
        # Public auth routes
        if req.path == "/login" and req.method == "GET":
            return Response(render_login(req, error=notice)).wsgi(start_response)

        if req.path == "/login" and req.method == "POST":
            ip = req.environ.get("REMOTE_ADDR", "unknown")
            if not enforce_rate_limit(ip):
                return Response(render_login(req, "Too many login attempts. Try again later."), status="429 Too Many Requests").wsgi(start_response)

            email = req.form.get("email", "").strip().lower()
            password = req.form.get("password", "")
            user = conn.execute(
                "SELECT * FROM users WHERE email = ? AND is_active = 1", (email,)
            ).fetchone()
            valid_password = False
            if user:
                try:
                    valid_password = verify_password(
                        password,
                        str(user["password_hash"] or ""),
                        str(user["password_salt"] or ""),
                    )
                except Exception:
                    valid_password = False
            if not user or not valid_password:
                return Response(render_login(req, "Invalid credentials.")).wsgi(start_response)

            raw_session, _csrf = create_session(
                conn,
                user["id"],
                req.environ.get("REMOTE_ADDR", ""),
                req.environ.get("HTTP_USER_AGENT", ""),
            )
            conn.commit()
            cookie_session = set_cookie("session_token", raw_session, max_age=SESSION_DAYS * 24 * 3600)
            return redirect("/dashboard", cookies=[cookie_session]).wsgi(start_response)

        if req.path == "/forgot-password" and req.method == "GET":
            return Response(render_forgot_password(req, message=notice)).wsgi(start_response)

        if req.path == "/forgot-password" and req.method == "POST":
            email = req.form.get("email", "").strip().lower()
            user = conn.execute("SELECT id FROM users WHERE email = ? AND is_active = 1", (email,)).fetchone()
            if not user:
                return Response(
                    render_forgot_password(
                        req,
                        "If the account exists, a reset link is now available through your admin.",
                    )
                ).wsgi(start_response)
            token, _expires = create_password_reset(conn, user["id"], created_by=None, hours=24)
            conn.commit()
            reset_link = f"/reset-password?token={token}"
            msg = quote(f"Reset link (share securely): {reset_link}")
            return redirect(f"/forgot-password?msg={msg}").wsgi(start_response)

        if req.path == "/reset-password" and req.method == "GET":
            token = req.query.get("token", "")
            reset = verify_reset_token(conn, token) if token else None
            if not reset:
                return Response(render_login(req, "Reset link is invalid or expired.")).wsgi(start_response)
            return Response(render_reset_password(req, token)).wsgi(start_response)

        if req.path == "/reset-password" and req.method == "POST":
            token = req.form.get("token", "")
            password = req.form.get("password", "")
            confirm = req.form.get("password_confirm", "")
            if password != confirm or len(password) < 12:
                return Response(render_reset_password(req, token, "Passwords must match and be at least 12 characters.")).wsgi(start_response)
            reset = verify_reset_token(conn, token)
            if not reset:
                return Response(render_login(req, "Reset link is invalid or expired.")).wsgi(start_response)
            pw_hash, pw_salt = hash_password(password)
            conn.execute(
                "UPDATE users SET password_hash = ?, password_salt = ? WHERE id = ?",
                (pw_hash, pw_salt, reset["user_id"]),
            )
            conn.execute(
                "UPDATE password_resets SET used_at = ? WHERE id = ?",
                (iso(), reset["id"]),
            )
            conn.execute("DELETE FROM sessions WHERE user_id = ?", (reset["user_id"],))
            conn.commit()
            return redirect("/login?msg=Password%20updated.%20Please%20sign%20in.").wsgi(start_response)

        auth_required = require_auth(ctx)
        if auth_required:
            return auth_required.wsgi(start_response)

        if req.method == "POST" and not validate_csrf(req, ctx):
            return Response("<h1>400 Bad Request</h1><p>CSRF token mismatch.</p>", status="400 Bad Request").wsgi(start_response)

        user = ctx["user"]
        org = ctx["active_org"]
        user_id = int(user["id"])
        org_id = int(org["organization_id"])
        csrf_token = ctx.get("csrf", "")
        spaces = get_spaces_for_org(conn, org_id)
        space_ids = {int(s["id"]) for s in spaces}
        selected_space_id = to_int(req.query.get("space_id"))
        if selected_space_id is None:
            selected_space_id = to_int(req.form.get("active_space_id"))
        # Reject unknown space ids from query/form to avoid cross-space leakage via crafted URLs.
        if selected_space_id not in space_ids:
            selected_space_id = None
        active_space = next((s for s in spaces if int(s["id"]) == int(selected_space_id or 0)), None)
        ctx["spaces"] = spaces
        ctx["active_space_id"] = selected_space_id
        ctx["active_space"] = active_space
        user_prefs = load_user_preferences(conn, user_id)
        nav_primary_items, nav_account_items, effective_nav_keys = visible_nav_for_user(
            conn,
            org_id,
            str(ctx.get("role") or "viewer"),
            user_prefs,
        )
        ctx["user_prefs"] = user_prefs
        ctx["nav_primary_items"] = nav_primary_items
        ctx["nav_account_items"] = nav_account_items
        ctx["nav_visible_keys"] = effective_nav_keys
        scoped = lambda path: with_space(path, selected_space_id)

        if req.path == "/":
            return redirect(scoped("/dashboard")).wsgi(start_response)

        if (not FEATURE_INTAKE_ENABLED) and req.path == "/intake":
            content = """
            <section class='card maker-hero'>
              <h2>Intake Is Disabled</h2>
              <p>The intake module has been removed from this workspace configuration.</p>
              <a class='btn' href='/dashboard'>Return to Dashboard</a>
            </section>
            """
            page = render_layout("Intake Disabled", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if (not FEATURE_INTAKE_ENABLED) and (
            req.path.startswith("/intake/") or req.path == "/api/intake/save"
        ):
            if req.path.startswith("/api/"):
                return json_response({"ok": False, "error": "intake_disabled"}, status="410 Gone").wsgi(start_response)
            return redirect(scoped("/dashboard?msg=Intake%20feature%20is%20disabled")).wsgi(start_response)

        if req.path == "/logout" and req.method == "POST":
            token = req.cookies.get("session_token", "")
            if token:
                conn.execute("DELETE FROM sessions WHERE token_hash = ?", (token_hash(token),))
                conn.commit()
            return redirect("/login", cookies=[clear_cookie("session_token"), clear_cookie("active_org")]).wsgi(start_response)

        if req.path == "/dashboard":
            content = build_dashboard(
                conn,
                org_id,
                user_id,
                active_space_id=selected_space_id,
                active_space_name=active_space["name"] if active_space else "",
                role=str(ctx.get("role") or "viewer"),
            )
            page = render_layout("Dashboard", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/projects":
            team_id = to_int(req.query.get("team_id"))
            content = render_project_page(conn, org_id, user_id, selected_team_id=team_id, selected_space_id=selected_space_id)
            page = render_layout("Projects", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/projects/new" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            name = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "projects",
                form.get("name"),
                None,
                free_edit_min_role="manager",
            )
            status = form.get("status", "Planned")
            if status not in PROJECT_STATUSES:
                status = "Planned"
            lane = form.get("lane", LANES[0])
            if lane not in LANES:
                lane = LANES[0]
            priority = form.get("priority", "Medium")
            if priority not in {"Low", "Medium", "High", "Critical"}:
                priority = "Medium"
            cursor = conn.execute(
                """
                INSERT INTO projects
                (organization_id, name, description, lane, status, priority, owner_user_id, start_date, due_date, tags, meta_json, created_by, created_at, updated_at, team_id, space_id, progress_pct)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    name,
                    form.get("description", ""),
                    lane,
                    status,
                    priority,
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id")),
                    parse_date(form.get("start_date", "")),
                    parse_date(form.get("due_date", "")),
                    form.get("tags", ""),
                    "{}",
                    user_id,
                    iso(),
                    iso(),
                    int(form["team_id"]) if form.get("team_id") else None,
                    int(form["space_id"]) if form.get("space_id") else None,
                    int(form.get("progress_pct", "0") or 0),
                ),
            )
            project_id = int(cursor.lastrowid)
            created_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM projects WHERE id = ? AND organization_id = ?",
                    (project_id, org_id),
                ).fetchone()
            )
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "project_created",
                "projects",
                project_id,
                None,
                created_snapshot,
                f"Project created: {name}",
            )
            ensure_item_watchers_seeded(conn, org_id, "project", project_id, user_id)
            notify_entity_watchers(
                conn=conn,
                org_id=org_id,
                entity="project",
                entity_id=project_id,
                actor_user_id=user_id,
                actor_name=str(user["name"]),
                actor_email=str(user["email"]),
                title=name,
                summary="A new project was created.",
                preference_key="email_project_updates",
            )
            conn.commit()
            return redirect(scoped("/projects?msg=Project%20created")).wsgi(start_response)

        if req.path == "/projects/update" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            current = conn.execute(
                "SELECT id, name, status, owner_user_id FROM projects WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (form.get("project_id"), org_id),
            ).fetchone()
            if not current:
                return redirect(scoped("/projects?msg=Project%20not%20found")).wsgi(start_response)
            next_status = form.get("status", "Planned")
            if next_status not in PROJECT_STATUSES:
                next_status = "Planned"
            progress_pct = to_int(form.get("progress_pct"), 0) or 0
            progress_pct = max(0, min(100, progress_pct))
            conn.execute(
                "UPDATE projects SET status = ?, progress_pct = ?, updated_at = ? WHERE id = ? AND organization_id = ?",
                (
                    next_status,
                    progress_pct,
                    iso(),
                    current["id"],
                    org_id,
                ),
            )
            ensure_item_watchers_seeded(conn, org_id, "project", int(current["id"]), user_id)
            notify_entity_watchers(
                conn=conn,
                org_id=org_id,
                entity="project",
                entity_id=int(current["id"]),
                actor_user_id=user_id,
                actor_name=str(user["name"]),
                actor_email=str(user["email"]),
                title=str(current["name"] or f"Project #{current['id']}"),
                summary=f"Project status changed to {next_status}.",
                preference_key="email_project_updates",
            )
            conn.commit()
            return redirect(scoped("/projects?msg=Project%20updated")).wsgi(start_response)

        if req.path == "/tasks":
            team_id = to_int(req.query.get("team_id"))
            content = render_task_page(conn, org_id, user_id, selected_team_id=team_id, selected_space_id=selected_space_id)
            page = render_layout("Tasks", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/tasks/new" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            status = form.get("status", "Todo")
            if status not in TASK_STATUSES:
                status = "Todo"
            priority = form.get("priority", "Medium")
            if priority not in {"Low", "Medium", "High", "Critical"}:
                priority = "Medium"
            assignee_id = normalize_org_user_id(conn, org_id, form.get("assignee_user_id"))
            project_id, space_id, relation_error = resolve_task_project_and_space(
                conn,
                org_id,
                user_id,
                form.get("project_id"),
                to_int(form.get("space_id"), selected_space_id),
            )
            if relation_error == "invalid_project":
                return redirect(scoped("/tasks?msg=Select%20a%20valid%20project")).wsgi(start_response)
            if relation_error == "missing_space":
                return redirect(scoped("/tasks?msg=Create%20a%20makerspace%20before%20adding%20tasks")).wsgi(start_response)
            cursor = conn.execute(
                """
                INSERT INTO tasks
                (organization_id, project_id, title, description, status, priority, assignee_user_id, reporter_user_id, due_date, planned_week, energy, estimate_hours, meta_json, created_at, updated_at, team_id, space_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    project_id,
                    form.get("title", "Untitled Task"),
                    form.get("description", ""),
                    status,
                    priority,
                    assignee_id,
                    user_id,
                    parse_date(form.get("due_date", "")),
                    dt.date.today().isocalendar()[1],
                    form.get("energy", "Medium"),
                    float(form.get("estimate_hours", "0") or 0),
                    "{}",
                    iso(),
                    iso(),
                    int(form["team_id"]) if form.get("team_id") else None,
                    space_id,
                ),
            )
            new_task_id = int(cursor.lastrowid)
            created_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM tasks WHERE id = ? AND organization_id = ?",
                    (new_task_id, org_id),
                ).fetchone()
            )
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "task_created",
                "tasks",
                new_task_id,
                None,
                created_snapshot,
                f"Task created: {form.get('title', '')}",
            )
            ensure_item_watchers_seeded(conn, org_id, "task", new_task_id, user_id)
            notify_task_assignment(
                conn=conn,
                org_id=org_id,
                task_id=new_task_id,
                actor_name=user["name"],
                actor_email=user["email"],
                task_title=form.get("title", "Untitled Task"),
                task_status=status,
                assignee_id=assignee_id,
            )
            conn.commit()
            return redirect(scoped("/tasks?msg=Task%20created")).wsgi(start_response)

        if req.path == "/tasks/update" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            current = conn.execute(
                "SELECT id, title, status, assignee_user_id FROM tasks WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (form.get("task_id"), org_id),
            ).fetchone()
            if not current:
                return redirect(scoped("/tasks?msg=Task%20not%20found")).wsgi(start_response)
            next_status = form.get("status", "Todo")
            if next_status not in TASK_STATUSES:
                next_status = str(current["status"] or "Todo")
            conn.execute(
                "UPDATE tasks SET status = ?, updated_at = ? WHERE id = ? AND organization_id = ?",
                (next_status, iso(), form.get("task_id"), org_id),
            )
            if next_status != current["status"]:
                notify_task_assignment(
                    conn=conn,
                    org_id=org_id,
                    task_id=int(current["id"]),
                    actor_name=user["name"],
                    actor_email=user["email"],
                    task_title=current["title"],
                    task_status=next_status,
                    assignee_id=to_int(str(current["assignee_user_id"]) if current["assignee_user_id"] else None),
                )
                ensure_item_watchers_seeded(conn, org_id, "task", int(current["id"]), user_id)
                notify_entity_watchers(
                    conn=conn,
                    org_id=org_id,
                    entity="task",
                    entity_id=int(current["id"]),
                    actor_user_id=user_id,
                    actor_name=str(user["name"]),
                    actor_email=str(user["email"]),
                    title=str(current["title"] or f"Task #{current['id']}"),
                    summary=f"Task status changed to {next_status}.",
                    skip_user_ids=[to_int(current["assignee_user_id"])] if to_int(current["assignee_user_id"]) is not None else None,
                    preference_key="email_task_updates",
                )
            conn.commit()
            return redirect(scoped("/tasks?msg=Task%20updated")).wsgi(start_response)

        if req.path == "/tasks/delegate" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            task = conn.execute(
                "SELECT id, title, status FROM tasks WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (form.get("task_id"), org_id),
            ).fetchone()
            if not task:
                return redirect(scoped("/dashboard?msg=Task%20not%20found")).wsgi(start_response)
            assignee_id = normalize_org_user_id(conn, org_id, form.get("assignee_user_id"))
            conn.execute(
                "UPDATE tasks SET assignee_user_id = ?, updated_at = ? WHERE id = ? AND organization_id = ?",
                (assignee_id, iso(), task["id"], org_id),
            )
            notify_task_assignment(
                conn=conn,
                org_id=org_id,
                task_id=int(task["id"]),
                actor_name=user["name"],
                actor_email=user["email"],
                task_title=task["title"],
                task_status=task["status"],
                assignee_id=assignee_id,
            )
            ensure_item_watchers_seeded(conn, org_id, "task", int(task["id"]), user_id)
            notify_entity_watchers(
                conn=conn,
                org_id=org_id,
                entity="task",
                entity_id=int(task["id"]),
                actor_user_id=user_id,
                actor_name=str(user["name"]),
                actor_email=str(user["email"]),
                title=str(task["title"] or f"Task #{task['id']}"),
                summary="Task assignee was updated.",
                skip_user_ids=[int(assignee_id)] if assignee_id is not None else None,
                preference_key="email_task_updates",
            )
            conn.commit()
            return redirect(scoped("/dashboard?msg=Task%20delegated")).wsgi(start_response)

        if req.path == "/api/lookups":
            return json_response(build_lookups(conn, org_id, role=str(ctx.get("role") or "viewer"))).wsgi(start_response)

        if req.path == "/api/activity":
            limit = to_int(req.query.get("limit"), 40) or 40
            limit = max(10, min(200, limit))
            role = str(ctx.get("role") or "viewer")
            if role_allows(role, "workspace_admin"):
                rows = conn.execute(
                    """
                    SELECT em.id, em.subject, em.status, em.error_message, em.related_entity, em.related_id,
                           em.created_at, em.sent_at, em.recipient_email, em.body,
                           u.name AS recipient_name
                    FROM email_messages em
                    LEFT JOIN users u ON u.id = em.recipient_user_id
                    WHERE em.organization_id = ?
                    ORDER BY em.id DESC
                    LIMIT ?
                    """,
                    (org_id, limit),
                ).fetchall()
            else:
                rows = conn.execute(
                    """
                    SELECT em.id, em.subject, em.status, em.error_message, em.related_entity, em.related_id,
                           em.created_at, em.sent_at, em.recipient_email, em.body,
                           u.name AS recipient_name
                    FROM email_messages em
                    LEFT JOIN users u ON u.id = em.recipient_user_id
                    WHERE em.organization_id = ?
                      AND (em.recipient_user_id = ? OR LOWER(em.recipient_email) = LOWER(?))
                    ORDER BY em.id DESC
                    LIMIT ?
                    """,
                    (org_id, user_id, user["email"], limit),
                ).fetchall()
            return json_response(
                {
                    "ok": True,
                    "items": [
                        {
                            "id": row["id"],
                            "subject": row["subject"],
                            "status": row["status"],
                            "error_message": row["error_message"] or "",
                            "related_entity": row["related_entity"] or "",
                            "related_id": row["related_id"] or "",
                            "created_at": row["created_at"],
                            "sent_at": row["sent_at"] or "",
                            "recipient_name": row["recipient_name"] or "",
                            "recipient_email": row["recipient_email"] or "",
                            "preview": str(row["body"] or "")[:220],
                        }
                        for row in rows
                    ],
                }
            ).wsgi(start_response)

        if req.path == "/api/interface/log" and req.method == "POST":
            gate = require_role(ctx, "viewer")
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            action = str(req.form.get("action") or "ui_event").strip().lower()[:64]
            entity_id = str(req.form.get("board_key") or req.form.get("context") or "").strip()[:120]
            payload_raw = str(req.form.get("payload_json") or "").strip()
            payload: object = {}
            if payload_raw:
                try:
                    parsed = json.loads(payload_raw)
                    payload = parsed if isinstance(parsed, (dict, list, str, int, float, bool)) else str(parsed)
                except Exception:
                    payload = payload_raw[:2400]
            details = json.dumps(
                {
                    "source": "interface",
                    "summary": str(req.form.get("summary") or action or "interface event")[:220],
                    "path": req.form.get("path") or req.path,
                    "payload": payload,
                },
                ensure_ascii=True,
            )[:14000]
            log_action(
                conn,
                org_id,
                user_id,
                action or "ui_event",
                "interface",
                entity_id or None,
                details,
            )
            conn.commit()
            return json_response({"ok": True}).wsgi(start_response)

        if req.path == "/api/comments":
            entity = str(req.query.get("entity") or "").strip().lower()
            item_id = to_int(req.query.get("item_id"))
            if item_id is None or not comment_table_for_entity(entity):
                return json_response({"ok": False, "error": "invalid_target"}, status="400 Bad Request").wsgi(start_response)
            if not comment_target_exists(conn, org_id, entity, item_id):
                return json_response({"ok": False, "error": "not_found"}, status="404 Not Found").wsgi(start_response)
            rows = load_item_comments(conn, org_id, entity, item_id, limit=250)
            return json_response(
                {
                    "ok": True,
                    "comments": [
                        {
                            "id": row["id"],
                            "body": row["body"],
                            "author_user_id": row["author_user_id"],
                            "author_name": row["author_name"] or "Unknown",
                            "created_at": row["created_at"],
                        }
                        for row in rows
                    ],
                }
            ).wsgi(start_response)

        if req.path == "/api/comments/add" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            entity = str(req.form.get("entity") or "").strip().lower()
            item_id = to_int(req.form.get("item_id"))
            body = str(req.form.get("body") or "").strip()
            if item_id is None or not comment_table_for_entity(entity):
                return json_response({"ok": False, "error": "invalid_target"}, status="400 Bad Request").wsgi(start_response)
            if not body:
                return json_response({"ok": False, "error": "comment_required"}, status="400 Bad Request").wsgi(start_response)
            if len(body) > 4000:
                body = body[:4000]
            if not comment_target_exists(conn, org_id, entity, item_id):
                return json_response({"ok": False, "error": "not_found"}, status="404 Not Found").wsgi(start_response)
            cursor = conn.execute(
                """
                INSERT INTO item_comments (organization_id, entity, entity_id, author_user_id, body, created_at)
                VALUES (?, ?, ?, ?, ?, ?)
                """,
                (org_id, entity, item_id, user_id, body, iso()),
            )
            comment_id = int(cursor.lastrowid)
            notify_comment_mentions_and_watchers(
                conn=conn,
                org_id=org_id,
                entity=entity,
                item_id=item_id,
                actor_user_id=user_id,
                actor_name=str(user["name"]),
                actor_email=str(user["email"]),
                comment_body=body,
            )
            conn.commit()
            row = conn.execute(
                """
                SELECT c.id, c.body, c.created_at, c.author_user_id, u.name AS author_name
                FROM item_comments c
                LEFT JOIN users u ON u.id = c.author_user_id
                WHERE c.id = ? AND c.organization_id = ?
                """,
                (comment_id, org_id),
            ).fetchone()
            return json_response(
                {
                    "ok": True,
                    "comment": {
                        "id": row["id"],
                        "body": row["body"],
                        "author_user_id": row["author_user_id"],
                        "author_name": row["author_name"] or "Unknown",
                        "created_at": row["created_at"],
                    },
                }
            ).wsgi(start_response)

        if req.path == "/api/tasks/create" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            title = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "tasks",
                form.get("title"),
                None,
                free_edit_min_role="manager",
            )
            status = form.get("status", "Todo")
            if status not in TASK_STATUSES:
                status = "Todo"
            priority = form.get("priority", "Medium")
            if priority not in {"Low", "Medium", "High", "Critical"}:
                priority = "Medium"
            energy = form.get("energy", "Medium")
            if energy not in {"Low", "Medium", "High"}:
                energy = "Medium"
            assignee_id = normalize_org_user_id(conn, org_id, form.get("assignee_user_id"))
            project_id, space_id, relation_error = resolve_task_project_and_space(
                conn,
                org_id,
                user_id,
                form.get("project_id"),
                to_int(form.get("space_id"), selected_space_id),
            )
            if relation_error == "invalid_project":
                return json_response({"ok": False, "error": "invalid_project"}, status="400 Bad Request").wsgi(start_response)
            if relation_error == "missing_space":
                return json_response({"ok": False, "error": "missing_space"}, status="400 Bad Request").wsgi(start_response)

            meta: Dict[str, object] = {}
            attachments = lines_to_items(form.get("attachments"))
            if attachments:
                meta["attachments"] = attachments
            note = (form.get("note") or "").strip()
            if note:
                meta["note"] = note[:1500]
            extra_json = (form.get("extra_json") or "").strip()
            if extra_json:
                try:
                    extra_obj = json.loads(extra_json)
                    if isinstance(extra_obj, dict):
                        meta["extra"] = extra_obj
                except json.JSONDecodeError:
                    pass

            cursor = conn.execute(
                """
                INSERT INTO tasks
                (organization_id, project_id, title, description, status, priority, assignee_user_id, reporter_user_id, due_date, planned_week, energy, estimate_hours, meta_json, created_at, updated_at, team_id, space_id)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    project_id,
                    title,
                    form.get("description", "").strip(),
                    status,
                    priority,
                    assignee_id,
                    user_id,
                    parse_date(form.get("due_date", "")),
                    dt.date.today().isocalendar()[1],
                    energy,
                    to_float(form.get("estimate_hours"), 0.0),
                    json.dumps(meta),
                    iso(),
                    iso(),
                    to_int(form.get("team_id")),
                    space_id,
                ),
            )
            task_id = int(cursor.lastrowid)
            created_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM tasks WHERE id = ? AND organization_id = ?",
                    (task_id, org_id),
                ).fetchone()
            )
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "task_created",
                "tasks",
                task_id,
                None,
                created_snapshot,
                f"Task created: {title}",
            )
            ensure_item_watchers_seeded(conn, org_id, "task", task_id, user_id)
            notify_task_assignment(
                conn=conn,
                org_id=org_id,
                task_id=task_id,
                actor_name=user["name"],
                actor_email=user["email"],
                task_title=title,
                task_status=status,
                assignee_id=assignee_id,
            )
            conn.commit()
            return json_response({"ok": True, "task_id": task_id}).wsgi(start_response)

        if req.path == "/api/tasks/save" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            task_id = to_int(form.get("task_id"))
            current = conn.execute(
                "SELECT * FROM tasks WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (task_id, org_id),
            ).fetchone()
            if not current:
                return json_response({"ok": False, "error": "not_found"}, status="404 Not Found").wsgi(start_response)
            before_snapshot = snapshot_row(current)

            def val(key: str, existing: object) -> object:
                return form[key] if key in form else existing

            meta = parse_meta_json(current["meta_json"])
            if "attachments" in form:
                attachments = lines_to_items(form.get("attachments"))
                if attachments:
                    meta["attachments"] = attachments
                else:
                    meta.pop("attachments", None)
            if "note" in form:
                note = (form.get("note") or "").strip()
                if note:
                    meta["note"] = note[:1500]
                else:
                    meta.pop("note", None)
            if "extra_json" in form:
                extra_json = (form.get("extra_json") or "").strip()
                if extra_json:
                    try:
                        extra_obj = json.loads(extra_json)
                        if isinstance(extra_obj, dict):
                            meta["extra"] = extra_obj
                    except json.JSONDecodeError:
                        pass
                else:
                    meta.pop("extra", None)

            status = str(val("status", current["status"]))
            if status not in TASK_STATUSES:
                status = str(current["status"])
            priority = str(val("priority", current["priority"]))
            if priority not in {"Low", "Medium", "High", "Critical"}:
                priority = str(current["priority"] or "Medium")
            energy = str(val("energy", current["energy"] or "Medium"))
            if energy not in {"Low", "Medium", "High"}:
                energy = str(current["energy"] or "Medium")
            assignee_id = normalize_org_user_id(
                conn,
                org_id,
                val("assignee_user_id", current["assignee_user_id"]),
                fallback=to_int(current["assignee_user_id"]),
            )

            due_date = current["due_date"]
            if "due_date" in form:
                due_date = parse_date(form.get("due_date", ""))
            title = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "tasks",
                val("title", current["title"]),
                current["title"],
                free_edit_min_role="manager",
            )
            project_id, space_id, relation_error = resolve_task_project_and_space(
                conn,
                org_id,
                user_id,
                val("project_id", current["project_id"]),
                val("space_id", current["space_id"] if current["space_id"] is not None else selected_space_id),
            )
            if relation_error == "invalid_project":
                return json_response({"ok": False, "error": "invalid_project"}, status="400 Bad Request").wsgi(start_response)
            if relation_error == "missing_space":
                return json_response({"ok": False, "error": "missing_space"}, status="400 Bad Request").wsgi(start_response)

            conn.execute(
                """
                UPDATE tasks
                SET title = ?, description = ?, status = ?, priority = ?, assignee_user_id = ?, project_id = ?,
                    due_date = ?, energy = ?, estimate_hours = ?, team_id = ?, space_id = ?, meta_json = ?, updated_at = ?
                WHERE id = ? AND organization_id = ?
                """,
                (
                    title,
                    str(val("description", current["description"] or ""))[:5000],
                    status,
                    priority,
                    assignee_id,
                    project_id,
                    due_date,
                    energy,
                    to_float(val("estimate_hours", current["estimate_hours"] or 0.0), float(current["estimate_hours"] or 0.0)),
                    to_int(val("team_id", current["team_id"])),
                    space_id,
                    json.dumps(meta),
                    iso(),
                    task_id,
                    org_id,
                ),
            )
            after_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM tasks WHERE id = ? AND organization_id = ?",
                    (task_id, org_id),
                ).fetchone()
            )
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "task_saved",
                "tasks",
                task_id or 0,
                before_snapshot,
                after_snapshot,
                f"Task updated: {title}",
            )
            ensure_item_watchers_seeded(conn, org_id, "task", int(task_id or 0), user_id)
            status_changed = status != str(current["status"] or "")
            old_assignee_id = to_int(current["assignee_user_id"])
            assignee_changed = assignee_id != old_assignee_id
            if status != current["status"] or assignee_id != to_int(current["assignee_user_id"]):
                notify_task_assignment(
                    conn=conn,
                    org_id=org_id,
                    task_id=int(task_id or 0),
                    actor_name=user["name"],
                    actor_email=user["email"],
                    task_title=title,
                    task_status=status,
                    assignee_id=assignee_id,
                )
            if before_snapshot != after_snapshot:
                changed_fields: List[str] = []
                if status_changed:
                    changed_fields.append(f"status -> {status}")
                if assignee_changed:
                    changed_fields.append("assignee changed")
                if title != str(current["title"] or ""):
                    changed_fields.append("title updated")
                if to_int(project_id) != to_int(current["project_id"]):
                    changed_fields.append("project updated")
                summary = "Task was updated."
                if changed_fields:
                    summary = f"Task was updated ({', '.join(changed_fields[:4])})."
                skip_ids: List[int] = []
                if assignee_changed and assignee_id is not None:
                    skip_ids.append(int(assignee_id))
                notify_entity_watchers(
                    conn=conn,
                    org_id=org_id,
                    entity="task",
                    entity_id=int(task_id or 0),
                    actor_user_id=user_id,
                    actor_name=str(user["name"]),
                    actor_email=str(user["email"]),
                    title=title,
                    summary=summary,
                    skip_user_ids=skip_ids,
                    preference_key="email_task_updates",
                )
            conn.commit()
            return json_response({"ok": True, "task_id": task_id, "status": status}).wsgi(start_response)

        if req.path == "/api/projects/save" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            project_id = to_int(form.get("project_id"))
            current = conn.execute(
                "SELECT * FROM projects WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (project_id, org_id),
            ).fetchone()
            if not current:
                return json_response({"ok": False, "error": "not_found"}, status="404 Not Found").wsgi(start_response)
            before_snapshot = snapshot_row(current)

            def pval(key: str, existing: object) -> object:
                return form[key] if key in form else existing

            meta = parse_meta_json(current["meta_json"])
            if "attachments" in form:
                attachments = lines_to_items(form.get("attachments"))
                if attachments:
                    meta["attachments"] = attachments
                else:
                    meta.pop("attachments", None)
            if "note" in form:
                note = (form.get("note") or "").strip()
                if note:
                    meta["note"] = note[:1500]
                else:
                    meta.pop("note", None)
            if "extra_json" in form:
                extra_json = (form.get("extra_json") or "").strip()
                if extra_json:
                    try:
                        extra_obj = json.loads(extra_json)
                        if isinstance(extra_obj, dict):
                            meta["extra"] = extra_obj
                    except json.JSONDecodeError:
                        pass
                else:
                    meta.pop("extra", None)

            status = str(pval("status", current["status"]))
            if status not in PROJECT_STATUSES:
                status = str(current["status"])
            lane = str(pval("lane", current["lane"]))
            if lane not in LANES:
                lane = str(current["lane"] or LANES[0])
            priority = str(pval("priority", current["priority"]))
            if priority not in {"Low", "Medium", "High", "Critical"}:
                priority = str(current["priority"] or "Medium")
            owner_user_id = normalize_org_user_id(
                conn,
                org_id,
                pval("owner_user_id", current["owner_user_id"]),
                fallback=to_int(current["owner_user_id"]),
            )

            due_date = current["due_date"]
            if "due_date" in form:
                due_date = parse_date(form.get("due_date", ""))
            start_date = current["start_date"]
            if "start_date" in form:
                start_date = parse_date(form.get("start_date", ""))

            progress_pct = to_int(pval("progress_pct", current["progress_pct"]), int(current["progress_pct"] or 0)) or 0
            progress_pct = max(0, min(100, progress_pct))
            name = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "projects",
                pval("name", current["name"]),
                current["name"],
                free_edit_min_role="manager",
            )

            conn.execute(
                """
                UPDATE projects
                SET name = ?, description = ?, lane = ?, status = ?, priority = ?, owner_user_id = ?,
                    start_date = ?, due_date = ?, tags = ?, team_id = ?, space_id = ?, progress_pct = ?, meta_json = ?, updated_at = ?
                WHERE id = ? AND organization_id = ?
                """,
                (
                    name,
                    str(pval("description", current["description"] or ""))[:5000],
                    lane,
                    status,
                    priority,
                    owner_user_id,
                    start_date,
                    due_date,
                    str(pval("tags", current["tags"] or ""))[:500],
                    to_int(pval("team_id", current["team_id"])),
                    to_int(pval("space_id", current["space_id"])),
                    progress_pct,
                    json.dumps(meta),
                    iso(),
                    project_id,
                    org_id,
                ),
            )
            after_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM projects WHERE id = ? AND organization_id = ?",
                    (project_id, org_id),
                ).fetchone()
            )
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "project_saved",
                "projects",
                project_id or 0,
                before_snapshot,
                after_snapshot,
                f"Project updated: {name}",
            )
            ensure_item_watchers_seeded(conn, org_id, "project", int(project_id or 0), user_id)
            if before_snapshot != after_snapshot:
                changed_fields: List[str] = []
                if status != str(current["status"] or ""):
                    changed_fields.append(f"status -> {status}")
                if owner_user_id != to_int(current["owner_user_id"]):
                    changed_fields.append("owner changed")
                if progress_pct != int(current["progress_pct"] or 0):
                    changed_fields.append(f"progress {progress_pct}%")
                if name != str(current["name"] or ""):
                    changed_fields.append("name updated")
                summary = "Project was updated."
                if changed_fields:
                    summary = f"Project was updated ({', '.join(changed_fields[:4])})."
                notify_entity_watchers(
                    conn=conn,
                    org_id=org_id,
                    entity="project",
                    entity_id=int(project_id or 0),
                    actor_user_id=user_id,
                    actor_name=str(user["name"]),
                    actor_email=str(user["email"]),
                    title=name,
                    summary=summary,
                    preference_key="email_project_updates",
                )
            conn.commit()
            return json_response({"ok": True, "project_id": project_id, "status": status, "progress_pct": progress_pct}).wsgi(start_response)

        if req.path == "/api/tasks":
            scope = req.query.get("scope", "my")
            search = req.query.get("search", "")
            team_id = to_int(req.query.get("team_id"))
            rows = fetch_tasks(
                conn,
                org_id,
                user_id,
                scope=scope,
                search=search,
                team_id=team_id,
                space_id=selected_space_id,
            )
            data = [
                (
                    lambda meta: {
                        "id": r["id"],
                        "title": r["title"],
                        "description": r["description"],
                        "project": r["project_name"],
                        "project_id": r["project_id"],
                        "assignee": r["assignee_name"],
                        "assignee_user_id": r["assignee_user_id"],
                        "team": r["team_name"],
                        "team_id": r["team_id"],
                        "space": r["space_name"],
                        "space_id": r["space_id"],
                        "status": r["status"],
                        "priority": r["priority"],
                        "due_date": r["due_date"],
                        "energy": r["energy"],
                        "estimate_hours": r["estimate_hours"],
                        "attachments": [x for x in meta.get("attachments", []) if isinstance(x, str)],
                        "note": str(meta.get("note", "")),
                        "extra": meta.get("extra", {}),
                    }
                )(parse_meta_json(r["meta_json"]))
                for r in rows
            ]
            return json_response({"tasks": data}).wsgi(start_response)

        if req.path == "/agenda":
            selected_agenda_id = to_int(req.query.get("agenda_id"))
            content = render_agenda_page(conn, org_id, selected_agenda_id=selected_agenda_id)
            page = render_layout("Meeting Agenda", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/agenda/new" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            conn.execute(
                "INSERT INTO meeting_agendas (organization_id, title, meeting_date, owner_user_id, notes, created_at) VALUES (?, ?, ?, ?, ?, ?)",
                (
                    org_id,
                    form.get("title", "Weekly Meeting"),
                    parse_date(form.get("meeting_date", "")) or dt.date.today().isoformat(),
                    user_id,
                    form.get("notes", ""),
                    iso(),
                ),
            )
            conn.commit()
            return redirect(scoped("/agenda?msg=Agenda%20created")).wsgi(start_response)

        if req.path == "/agenda/item/new" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            agenda_id = to_int(form.get("agenda_id"))
            if agenda_id is None:
                return redirect(scoped("/agenda?msg=Select%20an%20agenda%20before%20adding%20items")).wsgi(start_response)
            agenda = conn.execute(
                "SELECT id FROM meeting_agendas WHERE id = ? AND organization_id = ?",
                (agenda_id, org_id),
            ).fetchone()
            if not agenda:
                return redirect(scoped("/agenda?msg=Agenda%20not%20found")).wsgi(start_response)
            conn.execute(
                """
                INSERT INTO meeting_items
                (agenda_id, section, title, owner_user_id, status, minutes_estimate, sort_order, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    agenda_id,
                    form.get("section", "General"),
                    form.get("title", "Untitled Item"),
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id"), fallback=user_id),
                    "Open",
                    int(form.get("minutes_estimate", "10") or 10),
                    999,
                    iso(),
                ),
            )
            conn.commit()
            return redirect(scoped(f"/agenda?agenda_id={agenda_id}&msg=Agenda%20item%20added")).wsgi(start_response)

        if req.path == "/agenda/item/update" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            item_id = to_int(form.get("item_id"))
            if item_id is None:
                return redirect(scoped("/agenda?msg=Agenda%20item%20not%20found")).wsgi(start_response)
            target = conn.execute(
                """
                SELECT i.id, i.agenda_id
                FROM meeting_items i
                JOIN meeting_agendas a ON a.id = i.agenda_id
                WHERE i.id = ? AND a.organization_id = ?
                """,
                (item_id, org_id),
            ).fetchone()
            if not target:
                return redirect(scoped("/agenda?msg=Agenda%20item%20not%20found")).wsgi(start_response)
            status = str(form.get("status") or "Open").strip()
            if status not in {"Open", "In Progress", "Done"}:
                status = "Open"
            minutes_estimate = max(1, to_int(form.get("minutes_estimate"), 10) or 10)
            conn.execute(
                "UPDATE meeting_items SET status = ?, minutes_estimate = ? WHERE id = ?",
                (status, minutes_estimate, item_id),
            )
            conn.commit()
            return redirect(scoped(f"/agenda?agenda_id={target['agenda_id']}&msg=Agenda%20item%20updated")).wsgi(start_response)

        if req.path == "/agenda/note/new" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            linked_agenda_id = to_int(form.get("agenda_id"))
            if linked_agenda_id is not None:
                agenda = conn.execute(
                    "SELECT id FROM meeting_agendas WHERE id = ? AND organization_id = ?",
                    (linked_agenda_id, org_id),
                ).fetchone()
                if not agenda:
                    return redirect(scoped("/agenda?msg=Agenda%20not%20found%20for%20note%20link")).wsgi(start_response)
            conn.execute(
                """
                INSERT INTO meeting_note_sources
                (organization_id, title, source_type, doc_url, body, linked_agenda_id, created_by, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    form.get("title", "Meeting Notes"),
                    "google_doc" if form.get("doc_url") else "manual_note",
                    form.get("doc_url", ""),
                    form.get("body", ""),
                    linked_agenda_id,
                    user_id,
                    iso(),
                    iso(),
                ),
            )
            conn.commit()
            return redirect(scoped("/agenda?msg=Note%20source%20added")).wsgi(start_response)

        if req.path == "/calendar":
            view_mode = (req.query.get("view") or "week").strip().lower()
            date_value = (req.query.get("date") or "").strip()
            content = render_calendar_page(
                conn,
                org_id,
                user_id,
                selected_space_id=selected_space_id,
                view_mode=view_mode,
                anchor_date_value=date_value,
            )
            page = render_layout("Calendar Analytics", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/calendar/import" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            view_mode = (req.form.get("view") or "week").strip().lower()
            if view_mode not in {"week", "month"}:
                view_mode = "week"
            date_value = parse_date(req.form.get("date", "")) or dt.date.today().isoformat()
            base_redirect = f"/calendar?view={quote(view_mode)}&date={quote(date_value)}"
            file = req.files.get("file")
            if file is None:
                return redirect(scoped(f"{base_redirect}&msg=No%20file%20uploaded")).wsgi(start_response)
            raw = file.file.read().decode("utf-8", errors="ignore")
            filename = (file.filename or "").lower()
            if filename.endswith(".ics"):
                parsed = parse_ics(raw)
            else:
                parsed = parse_google_csv(raw)

            for event in parsed:
                conn.execute(
                    """
                    INSERT INTO calendar_events
                    (organization_id, user_id, source, title, start_at, end_at, attendees_count, location, description, category, energy_score, created_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        org_id,
                        user_id,
                        event["source"],
                        event["title"],
                        event["start_at"],
                        event["end_at"],
                        event["attendees_count"],
                        event["location"],
                        event["description"],
                        event["category"],
                        None,
                        iso(),
                    ),
                )
            conn.commit()
            return redirect(scoped(f"{base_redirect}&msg=Imported%20{len(parsed)}%20events")).wsgi(start_response)

        if req.path == "/calendar/gcal/pull" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            view_mode = (req.form.get("view") or "week").strip().lower()
            if view_mode not in {"week", "month"}:
                view_mode = "week"
            date_value = parse_date(req.form.get("date", "")) or dt.date.today().isoformat()
            base_redirect = f"/calendar?view={quote(view_mode)}&date={quote(date_value)}"
            calendar_id = (req.form.get("calendar_id") or GCAL_DEFAULT_CALENDAR_ID or "primary").strip()
            lookback_days = clamp_int(req.form.get("lookback_days"), 30, 1, 365)
            lookahead_days = clamp_int(req.form.get("lookahead_days"), 45, 1, 365)
            push_window_days = clamp_int(req.form.get("push_window_days"), 30, 1, 365)
            inserted, updated, error = pull_google_calendar_events(
                conn,
                org_id=org_id,
                user_id=user_id,
                calendar_id=calendar_id,
                lookback_days=lookback_days,
                lookahead_days=lookahead_days,
            )
            save_calendar_sync_settings(
                conn,
                org_id=org_id,
                user_id=user_id,
                calendar_id=calendar_id,
                lookback_days=lookback_days,
                lookahead_days=lookahead_days,
                push_window_days=push_window_days,
                touch_pull=(error == ""),
            )
            conn.commit()
            if error:
                return redirect(scoped(f"{base_redirect}&msg={quote('Google pull failed: ' + error[:220])}")).wsgi(start_response)
            msg = f"Google pull complete: {inserted} imported, {updated} updated"
            return redirect(scoped(f"{base_redirect}&msg={quote(msg)}")).wsgi(start_response)

        if req.path == "/calendar/gcal/push" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            view_mode = (req.form.get("view") or "week").strip().lower()
            if view_mode not in {"week", "month"}:
                view_mode = "week"
            date_value = parse_date(req.form.get("date", "")) or dt.date.today().isoformat()
            base_redirect = f"/calendar?view={quote(view_mode)}&date={quote(date_value)}"
            calendar_id = (req.form.get("calendar_id") or GCAL_DEFAULT_CALENDAR_ID or "primary").strip()
            lookback_days = clamp_int(req.form.get("lookback_days"), 30, 1, 365)
            lookahead_days = clamp_int(req.form.get("lookahead_days"), 45, 1, 365)
            push_window_days = clamp_int(req.form.get("push_window_days"), 30, 1, 365)
            created, updated, skipped, error = push_tasks_to_google_calendar(
                conn,
                org_id=org_id,
                user_id=user_id,
                calendar_id=calendar_id,
                push_window_days=push_window_days,
                selected_space_id=selected_space_id,
            )
            save_calendar_sync_settings(
                conn,
                org_id=org_id,
                user_id=user_id,
                calendar_id=calendar_id,
                lookback_days=lookback_days,
                lookahead_days=lookahead_days,
                push_window_days=push_window_days,
                touch_push=(error == ""),
            )
            conn.commit()
            if error and created == 0 and updated == 0:
                return redirect(scoped(f"{base_redirect}&msg={quote('Google push failed: ' + error[:220])}")).wsgi(start_response)
            msg = f"Google push complete: {created} created, {updated} updated, {skipped} skipped"
            if error:
                msg += f" ({error[:120]})"
            return redirect(scoped(f"{base_redirect}&msg={quote(msg)}")).wsgi(start_response)

        if req.path == "/reports":
            report_id = req.query.get("report_id")
            content = render_reports_page(
                conn,
                org_id,
                user_id,
                report_id,
                selected_space_id=selected_space_id,
                role=str(ctx.get("role") or "viewer"),
            )
            page = render_layout("Generate Reports", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/reports/new" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            template_key = (form.get("template_key") or "").strip()
            template = report_template_by_key(template_key) if template_key else None

            name = (form.get("name") or "").strip()
            if not name and template:
                name = str(template.get("name") or "Untitled Report")
            if not name:
                name = "Untitled Report"
            name = name[:120]

            description = (form.get("description") or "").strip()[:800]
            if not description and template:
                description = str(template.get("description") or "")

            raw_config = (form.get("config_json") or "").strip()
            config: Dict[str, object]
            if raw_config:
                try:
                    parsed_config = json.loads(raw_config)
                except json.JSONDecodeError:
                    parsed_config = {}
                config = report_config_from_payload(parsed_config)
            elif template:
                config = report_config_from_payload({"widgets": template.get("widgets", [])})
            else:
                config = {"widgets": []}

            if not sanitize_report_widgets(config.get("widgets")):
                fallback = report_template_by_key("impact_report") or REPORT_TEMPLATE_LIBRARY[0]
                config = report_config_from_payload({"widgets": fallback.get("widgets", [])})

            can_share = role_allows(str(ctx.get("role") or "viewer"), "manager")
            is_shared = 1 if can_share and form.get("is_shared") == "1" else 0
            cursor = conn.execute(
                """
                INSERT INTO report_templates
                (organization_id, user_id, name, description, config_json, is_shared, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    user_id,
                    name,
                    description,
                    report_config_json(config),
                    is_shared,
                    iso(),
                    iso(),
                ),
            )
            new_id = int(cursor.lastrowid)
            log_action(conn, org_id, user_id, "report_template_created", "report_templates", str(new_id), name)
            conn.commit()
            next_path = str(form.get("next") or "").strip()
            if next_path.startswith("/dashboard"):
                return redirect(scoped("/dashboard?msg=Report%20template%20saved")).wsgi(start_response)
            return redirect(scoped(f"/reports?report_id={new_id}&msg=Report%20template%20saved")).wsgi(start_response)

        if req.path == "/reports/visibility" and req.method == "POST":
            report_id = to_int(req.form.get("report_id"))
            target = conn.execute(
                "SELECT id, user_id, is_shared FROM report_templates WHERE id = ? AND organization_id = ?",
                (report_id, org_id),
            ).fetchone()
            if not target:
                return redirect(scoped("/reports?msg=Report%20template%20not%20found")).wsgi(start_response)
            if not (int(target["user_id"]) == int(user_id) or role_allows(str(ctx.get("role") or "viewer"), "manager")):
                return Response("<h1>403 Forbidden</h1>", status="403 Forbidden").wsgi(start_response)
            new_shared = 1 if req.form.get("is_shared") == "1" else 0
            conn.execute(
                "UPDATE report_templates SET is_shared = ?, updated_at = ? WHERE id = ? AND organization_id = ?",
                (new_shared, iso(), report_id, org_id),
            )
            conn.commit()
            msg = "Report template shared" if new_shared else "Report template is now private"
            return redirect(scoped(f"/reports?report_id={report_id}&msg={quote(msg)}")).wsgi(start_response)

        if req.path == "/reports/delete" and req.method == "POST":
            report_id = to_int(req.form.get("report_id"))
            target = conn.execute(
                "SELECT id, user_id, name FROM report_templates WHERE id = ? AND organization_id = ?",
                (report_id, org_id),
            ).fetchone()
            if not target:
                return redirect(scoped("/reports?msg=Report%20template%20not%20found")).wsgi(start_response)
            if not (int(target["user_id"]) == int(user_id) or role_allows(str(ctx.get("role") or "viewer"), "manager")):
                return Response("<h1>403 Forbidden</h1>", status="403 Forbidden").wsgi(start_response)
            conn.execute("DELETE FROM report_templates WHERE id = ? AND organization_id = ?", (report_id, org_id))
            log_action(conn, org_id, user_id, "report_template_deleted", "report_templates", str(report_id), str(target["name"]))
            conn.commit()
            return redirect(scoped("/reports?msg=Report%20template%20deleted")).wsgi(start_response)

        if req.path == "/views":
            content = render_views_page(conn, org_id, user_id, req.query.get("view_id"), selected_space_id=selected_space_id)
            page = render_layout("Custom Views", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/views/new" and req.method == "POST":
            form = req.form
            template_key = (form.get("template_key") or "").strip()
            template = view_template_by_key(template_key) if template_key else None
            if template and (not FEATURE_INTAKE_ENABLED) and str(template.get("entity") or "") == "intake":
                template = None
            entity = (form.get("entity") or str(template.get("entity")) if template else "tasks").strip().lower()
            if (not FEATURE_INTAKE_ENABLED) and entity == "intake":
                entity = "tasks"
            allowed_entities = VIEW_ENTITY_LABELS if FEATURE_INTAKE_ENABLED else {k: v for k, v in VIEW_ENTITY_LABELS.items() if k != "intake"}
            if entity not in allowed_entities:
                entity = "tasks"

            name = (form.get("name") or "").strip()
            if not name and template:
                name = str(template.get("name") or "Untitled View")
            if not name:
                name = "Untitled View"

            filters_json = (form.get("filters_json") or "").strip()
            columns_json = (form.get("columns_json") or "").strip()
            if not filters_json and template:
                filters_json = json.dumps(template.get("filters", {}))
            if not columns_json and template:
                columns_json = json.dumps(template.get("columns", []))
            if not filters_json:
                fallback_filters: Dict[str, object] = {}
                if form.get("scope"):
                    fallback_filters["scope"] = form.get("scope")
                if form.get("lane"):
                    fallback_filters["lane"] = form.get("lane")
                if form.get("team_id"):
                    fallback_filters["team_id"] = to_int(form.get("team_id"))
                if form.get("space_id"):
                    fallback_filters["space_id"] = to_int(form.get("space_id"))
                if form.get("search"):
                    fallback_filters["search"] = form.get("search", "").strip()
                if form.get("due_within_days"):
                    fallback_filters["due_within_days"] = to_int(form.get("due_within_days"))
                if form.get("followup_within_days"):
                    fallback_filters["followup_within_days"] = to_int(form.get("followup_within_days"))
                if form.get("maintenance_within_days"):
                    fallback_filters["maintenance_within_days"] = to_int(form.get("maintenance_within_days"))
                if form.get("min_score"):
                    fallback_filters["min_score"] = to_float(form.get("min_score"))
                if form.get("owner_user_id"):
                    if entity in {"tasks", "onboarding"}:
                        fallback_filters["assignee_user_id"] = to_int(form.get("owner_user_id"))
                    else:
                        fallback_filters["owner_user_id"] = to_int(form.get("owner_user_id"))
                if form.get("only_unassigned") == "1":
                    fallback_filters["only_unassigned"] = True
                if form.get("cert_required") == "1":
                    fallback_filters["cert_required"] = True
                if form.get("hide_completed") == "1":
                    if entity == "tasks":
                        fallback_filters["status_exclude"] = ["Done", "Cancelled"]
                    elif entity == "projects":
                        fallback_filters["status_exclude"] = ["Complete"]
                    elif entity == "partnerships":
                        fallback_filters["status_exclude"] = ["Closed"]
                    elif entity == "onboarding":
                        fallback_filters["status_exclude"] = ["Done"]
                filters_json = json.dumps(fallback_filters)
            if not columns_json:
                columns_json = json.dumps(view_default_columns(entity))

            try:
                parsed_filters = json.loads(filters_json)
                parsed_columns = json.loads(columns_json)
            except json.JSONDecodeError:
                return redirect(scoped("/views?msg=Filters%20and%20columns%20must%20be%20valid%20JSON")).wsgi(start_response)
            if not isinstance(parsed_filters, dict):
                parsed_filters = {}
            if not isinstance(parsed_columns, list):
                parsed_columns = []
            allowed_columns = {key for key, _label in VIEW_COLUMN_OPTIONS.get(entity, [])}
            cleaned_columns = [str(c) for c in parsed_columns if str(c) in allowed_columns]
            if not cleaned_columns:
                cleaned_columns = view_default_columns(entity)

            conn.execute(
                """
                INSERT INTO custom_views
                (organization_id, user_id, name, entity, filters_json, columns_json, is_shared, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    user_id,
                    name,
                    entity,
                    json.dumps(parsed_filters),
                    json.dumps(cleaned_columns),
                    1 if form.get("is_shared") == "1" else 0,
                    iso(),
                ),
            )
            conn.commit()
            return redirect(scoped("/views?msg=View%20saved")).wsgi(start_response)

        if req.path == "/onboarding":
            content = render_onboarding_page(conn, org_id)
            page = render_layout("Onboarding", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/onboarding/assign" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            tpl = conn.execute(
                "SELECT * FROM onboarding_templates WHERE id = ? AND organization_id = ?",
                (form.get("template_id"), org_id),
            ).fetchone()
            if tpl:
                assignee_user_id = normalize_org_user_id(conn, org_id, form.get("assignee_user_id"))
                if assignee_user_id is None:
                    return redirect(scoped("/onboarding?msg=Assignee%20must%20be%20an%20active%20workspace%20member")).wsgi(start_response)
                due = dt.date.today() + dt.timedelta(days=int(tpl["due_offset_days"]))
                conn.execute(
                    """
                    INSERT INTO onboarding_assignments
                    (organization_id, template_id, assignee_user_id, status, due_date, notes, created_at, completed_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        org_id,
                        tpl["id"],
                        assignee_user_id,
                        "Assigned",
                        due.isoformat(),
                        "",
                        iso(),
                        None,
                    ),
                )
                conn.commit()
            return redirect(scoped("/onboarding?msg=Assignment%20created")).wsgi(start_response)

        if req.path == "/onboarding/status" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            next_status = str(form.get("status", "Assigned"))
            if next_status not in ONBOARDING_STATUSES:
                next_status = "Assigned"
            completed_at = iso() if next_status == "Done" else None
            conn.execute(
                "UPDATE onboarding_assignments SET status = ?, completed_at = ? WHERE id = ? AND organization_id = ?",
                (next_status, completed_at, form.get("assignment_id"), org_id),
            )
            conn.commit()
            return redirect(scoped("/onboarding?msg=Onboarding%20status%20updated")).wsgi(start_response)

        if req.path == "/onboarding/complete" and req.method == "POST":
            gate = require_role(ctx, "student")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            conn.execute(
                "UPDATE onboarding_assignments SET status = 'Done', completed_at = ? WHERE id = ? AND organization_id = ?",
                (iso(), form.get("assignment_id"), org_id),
            )
            conn.commit()
            return redirect(scoped("/onboarding?msg=Assignment%20completed")).wsgi(start_response)

        if req.path == "/onboarding/template/new" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            role_target = str(form.get("role_target", "Student Worker")).strip()
            if not role_target:
                role_target = "Student Worker"
            conn.execute(
                """
                INSERT INTO onboarding_templates
                (organization_id, name, role_target, task_title, details, doc_url, sequence, due_offset_days, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    str(form.get("name", "Onboarding")).strip() or "Onboarding",
                    role_target,
                    str(form.get("task_title", "Checklist item")).strip() or "Checklist item",
                    str(form.get("details", "")).strip(),
                    str(form.get("doc_url", "")).strip(),
                    max(1, to_int(form.get("sequence", "10")) or 10),
                    max(0, to_int(form.get("due_offset_days", "7")) or 7),
                    iso(),
                ),
            )
            conn.commit()
            return redirect(scoped("/onboarding?msg=Template%20saved")).wsgi(start_response)

        if req.path == "/onboarding/template/update" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            template_id = to_int(form.get("template_id"))
            if template_id is None:
                return redirect(scoped("/onboarding?msg=Template%20not%20found")).wsgi(start_response)
            current = conn.execute(
                "SELECT id FROM onboarding_templates WHERE id = ? AND organization_id = ?",
                (template_id, org_id),
            ).fetchone()
            if not current:
                return redirect(scoped("/onboarding?msg=Template%20not%20found")).wsgi(start_response)
            conn.execute(
                """
                UPDATE onboarding_templates
                SET name = ?, role_target = ?, task_title = ?, details = ?, doc_url = ?, sequence = ?, due_offset_days = ?
                WHERE id = ? AND organization_id = ?
                """,
                (
                    str(form.get("name", "Onboarding")).strip() or "Onboarding",
                    str(form.get("role_target", "Student Worker")).strip() or "Student Worker",
                    str(form.get("task_title", "Checklist item")).strip() or "Checklist item",
                    str(form.get("details", "")).strip(),
                    str(form.get("doc_url", "")).strip(),
                    max(1, to_int(form.get("sequence"), 1) or 1),
                    max(0, to_int(form.get("due_offset_days"), 0) or 0),
                    template_id,
                    org_id,
                ),
            )
            conn.commit()
            return redirect(scoped("/onboarding?msg=Template%20updated")).wsgi(start_response)

        if req.path == "/onboarding/template/delete" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            template_id = to_int(req.form.get("template_id"))
            if template_id is not None:
                conn.execute(
                    "DELETE FROM onboarding_templates WHERE id = ? AND organization_id = ?",
                    (template_id, org_id),
                )
                conn.commit()
            return redirect(scoped("/onboarding?msg=Template%20deleted")).wsgi(start_response)

        if req.path == "/onboarding/assignment/update" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            assignment_id = to_int(form.get("assignment_id"))
            if assignment_id is None:
                return redirect(scoped("/onboarding?msg=Assignment%20not%20found")).wsgi(start_response)
            current = conn.execute(
                "SELECT completed_at, assignee_user_id FROM onboarding_assignments WHERE id = ? AND organization_id = ?",
                (assignment_id, org_id),
            ).fetchone()
            if not current:
                return redirect(scoped("/onboarding?msg=Assignment%20not%20found")).wsgi(start_response)
            status_value = str(form.get("status", "Assigned"))
            if status_value not in ONBOARDING_STATUSES:
                status_value = "Assigned"
            completed_at = current["completed_at"]
            if status_value == "Done" and not completed_at:
                completed_at = iso()
            if status_value != "Done":
                completed_at = None
            assignee_user_id = normalize_org_user_id(
                conn,
                org_id,
                form.get("assignee_user_id"),
                fallback=to_int(current["assignee_user_id"]),
            )
            conn.execute(
                """
                UPDATE onboarding_assignments
                SET status = ?, assignee_user_id = ?, due_date = ?, notes = ?, completed_at = ?
                WHERE id = ? AND organization_id = ?
                """,
                (
                    status_value,
                    assignee_user_id,
                    parse_date(form.get("due_date", "")),
                    str(form.get("notes", "")).strip(),
                    completed_at,
                    assignment_id,
                    org_id,
                ),
            )
            conn.commit()
            return redirect(scoped("/onboarding?msg=Assignment%20updated")).wsgi(start_response)

        if req.path == "/spaces":
            content = render_spaces_page(conn, org_id)
            page = render_layout("Spaces", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/intake":
            content = render_intake_page(conn, org_id)
            page = render_layout("Intake", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/intake/new" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            urgency = int(form.get("urgency", "3") or 3)
            impact = int(form.get("impact", "3") or 3)
            effort = int(form.get("effort", "3") or 3)
            score = intake_score(urgency, impact, effort)
            lane = form.get("lane", LANES[0])
            if lane not in LANES:
                lane = LANES[0]
            title = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "intake",
                form.get("title"),
                None,
                free_edit_min_role="manager",
            )
            conn.execute(
                """
                INSERT INTO intake_requests
                (organization_id, title, requestor_name, requestor_email, lane, urgency, impact, effort, score, status, owner_user_id, details, meta_json, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    title,
                    form.get("requestor_name", ""),
                    form.get("requestor_email", ""),
                    lane,
                    urgency,
                    impact,
                    effort,
                    score,
                    "Triage",
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id")),
                    form.get("details", ""),
                    "{}",
                    iso(),
                    iso(),
                ),
            )
            conn.commit()
            return redirect(scoped("/intake?msg=Intake%20request%20created")).wsgi(start_response)

        if req.path == "/intake/convert" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            intake_id = to_int(form.get("intake_id"))
            if intake_id is None:
                return redirect(scoped("/intake?msg=Intake%20item%20not%20found")).wsgi(start_response)
            intake = conn.execute(
                "SELECT * FROM intake_requests WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (intake_id, org_id),
            ).fetchone()
            if not intake:
                return redirect(scoped("/intake?msg=Intake%20item%20not%20found")).wsgi(start_response)
            if str(intake["status"] or "") in {"Done", "Rejected"}:
                return redirect(scoped("/intake?msg=Only%20open%20intake%20items%20can%20be%20converted")).wsgi(start_response)

            convert_to = str(form.get("convert_to") or "task").strip().lower()
            if convert_to not in {"task", "project"}:
                convert_to = "task"

            owner_user_id = normalize_org_user_id(
                conn,
                org_id,
                intake["owner_user_id"],
                fallback=to_int(intake["owner_user_id"]),
            )
            lane = str(intake["lane"] or LANES[0])
            if lane not in LANES:
                lane = LANES[0]
            score = to_float(str(intake["score"] or 0), 0.0)
            priority = "Critical" if score >= 12 else ("High" if score >= 8 else ("Medium" if score >= 4 else "Low"))
            project_id: Optional[int] = None
            space_id: Optional[int] = None
            created_entity = ""
            created_id: Optional[int] = None

            if convert_to == "project":
                space_id = default_space_id_for_org(conn, org_id, preferred_space_id=to_int(form.get("space_id")))
                cursor = conn.execute(
                    """
                    INSERT INTO projects
                    (organization_id, name, description, lane, status, priority, owner_user_id, start_date, due_date, tags, meta_json, created_by, created_at, updated_at, team_id, space_id, progress_pct)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        org_id,
                        str(intake["title"] or "Intake Project"),
                        str(intake["details"] or ""),
                        lane,
                        "Planned",
                        priority,
                        owner_user_id,
                        dt.date.today().isoformat(),
                        None,
                        "from_intake",
                        "{}",
                        user_id,
                        iso(),
                        iso(),
                        None,
                        space_id,
                        0,
                    ),
                )
                created_id = int(cursor.lastrowid)
                created_entity = "project"
            else:
                project_id, space_id, relation_error = resolve_task_project_and_space(
                    conn,
                    org_id,
                    user_id,
                    form.get("project_id"),
                    to_int(form.get("space_id"), selected_space_id),
                )
                if relation_error == "invalid_project":
                    return redirect(scoped("/intake?msg=Select%20a%20valid%20target%20project")).wsgi(start_response)
                if relation_error == "missing_space":
                    return redirect(scoped("/intake?msg=Create%20a%20makerspace%20before%20converting")).wsgi(start_response)
                cursor = conn.execute(
                    """
                    INSERT INTO tasks
                    (organization_id, project_id, title, description, status, priority, assignee_user_id, reporter_user_id, due_date, planned_week, energy, estimate_hours, meta_json, created_at, updated_at, team_id, space_id)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        org_id,
                        project_id,
                        str(intake["title"] or "Intake Task"),
                        "\n\n".join(
                            [
                                str(intake["details"] or "").strip(),
                                f"Requestor: {intake['requestor_name'] or '-'} ({intake['requestor_email'] or '-'})",
                            ]
                        ).strip(),
                        "Todo",
                        priority,
                        owner_user_id,
                        user_id,
                        None,
                        dt.date.today().isocalendar()[1],
                        "Medium",
                        1.0,
                        json.dumps({"source": "intake", "intake_id": intake_id}),
                        iso(),
                        iso(),
                        None,
                        space_id,
                    ),
                )
                created_id = int(cursor.lastrowid)
                created_entity = "task"

            intake_meta = parse_meta_json(intake["meta_json"])
            intake_meta["converted_to"] = {"entity": created_entity, "id": created_id, "at": iso()}
            conn.execute(
                "UPDATE intake_requests SET status = 'Done', meta_json = ?, updated_at = ? WHERE id = ? AND organization_id = ?",
                (json.dumps(intake_meta), iso(), intake_id, org_id),
            )
            log_action(
                conn,
                org_id,
                user_id,
                "intake_converted",
                "intake_requests",
                str(intake_id),
                f"{created_entity}:{created_id}",
            )
            conn.commit()
            return redirect(scoped(f"/intake?msg=Intake%20converted%20to%20{quote(created_entity)}%20#{created_id}")).wsgi(start_response)

        if req.path == "/api/intake/save" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            intake_id = to_int(form.get("intake_id"))
            current = conn.execute(
                "SELECT * FROM intake_requests WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (intake_id, org_id),
            ).fetchone()
            if not current:
                return json_response({"ok": False, "error": "not_found"}, status="404 Not Found").wsgi(start_response)
            before_snapshot = snapshot_row(current)

            status = form.get("status", current["status"])
            if status not in INTAKE_STATUSES:
                status = current["status"]
            lane = form.get("lane", current["lane"])
            if lane not in LANES:
                lane = current["lane"]
            urgency = to_int(form.get("urgency"), int(current["urgency"] or 3)) or 3
            impact = to_int(form.get("impact"), int(current["impact"] or 3)) or 3
            effort = to_int(form.get("effort"), int(current["effort"] or 3)) or 3
            urgency = max(1, min(5, urgency))
            impact = max(1, min(5, impact))
            effort = max(1, min(5, effort))
            score = intake_score(urgency, impact, effort)
            title = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "intake",
                form.get("title", current["title"]),
                current["title"],
                free_edit_min_role="manager",
            )

            conn.execute(
                """
                UPDATE intake_requests
                SET title = ?, lane = ?, urgency = ?, impact = ?, effort = ?, score = ?, status = ?, owner_user_id = ?, details = ?, requestor_name = ?, requestor_email = ?, updated_at = ?
                WHERE id = ? AND organization_id = ?
                """,
                (
                    title,
                    lane,
                    urgency,
                    impact,
                    effort,
                    score,
                    status,
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id"), fallback=to_int(current["owner_user_id"])),
                    form.get("details", current["details"] or ""),
                    form.get("requestor_name", current["requestor_name"] or ""),
                    form.get("requestor_email", current["requestor_email"] or ""),
                    iso(),
                    intake_id,
                    org_id,
                ),
            )
            after_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM intake_requests WHERE id = ? AND organization_id = ?",
                    (intake_id, org_id),
                ).fetchone()
            )
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "intake_saved",
                "intake_requests",
                intake_id or 0,
                before_snapshot,
                after_snapshot,
                f"Intake updated: {title}",
            )
            conn.commit()
            return json_response({"ok": True, "status": status, "score": score}).wsgi(start_response)

        if req.path == "/assets":
            content = render_assets_page(conn, org_id, selected_space_name=active_space["name"] if active_space else "")
            page = render_layout("Assets", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/consumables":
            content = render_consumables_page(conn, org_id, selected_space_id=selected_space_id)
            page = render_layout("Consumables", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/assets/new" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            status = form.get("status", "Operational")
            if status not in ASSET_STATUSES:
                status = "Operational"
            name = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "assets",
                form.get("name"),
                None,
                free_edit_min_role="manager",
            )
            conn.execute(
                """
                INSERT INTO equipment_assets
                (organization_id, name, space, asset_type, last_maintenance, next_maintenance, cert_required, cert_name, status, owner_user_id, notes, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    name,
                    form.get("space", "Unknown Space"),
                    form.get("asset_type", ""),
                    parse_date(form.get("last_maintenance", "")),
                    parse_date(form.get("next_maintenance", "")),
                    1 if form.get("cert_required") == "1" else 0,
                    form.get("cert_name", ""),
                    status,
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id")),
                    form.get("notes", ""),
                    iso(),
                    iso(),
                ),
            )
            conn.commit()
            return redirect(scoped("/assets?msg=Asset%20added")).wsgi(start_response)

        if req.path == "/consumables/new" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            status = form.get("status", "In Stock")
            if status not in CONSUMABLE_STATUSES:
                status = "In Stock"
            space_id = to_int(form.get("space_id"))
            if not space_id:
                return redirect(scoped("/consumables?msg=Space%20location%20is%20required")).wsgi(start_response)
            valid_space = conn.execute(
                "SELECT id FROM spaces WHERE id = ? AND organization_id = ?",
                (space_id, org_id),
            ).fetchone()
            if not valid_space:
                return redirect(scoped("/consumables?msg=Select%20a%20valid%20space%20location")).wsgi(start_response)
            name = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "consumables",
                form.get("name"),
                None,
                free_edit_min_role="manager",
            )
            conn.execute(
                """
                INSERT INTO consumables
                (organization_id, space_id, name, category, quantity_on_hand, unit, reorder_point, status, owner_user_id, notes, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    space_id,
                    name,
                    form.get("category", ""),
                    to_float(form.get("quantity_on_hand"), 0.0),
                    form.get("unit", ""),
                    to_float(form.get("reorder_point"), 0.0),
                    status,
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id")),
                    form.get("notes", ""),
                    iso(),
                    iso(),
                ),
            )
            conn.commit()
            return redirect(scoped("/consumables?msg=Consumable%20added")).wsgi(start_response)

        if req.path == "/api/assets/save" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            asset_id = to_int(form.get("asset_id"))
            current = conn.execute(
                "SELECT * FROM equipment_assets WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (asset_id, org_id),
            ).fetchone()
            if not current:
                return json_response({"ok": False, "error": "not_found"}, status="404 Not Found").wsgi(start_response)
            before_snapshot = snapshot_row(current)
            status = form.get("status", current["status"])
            if status not in ASSET_STATUSES:
                status = current["status"]
            name = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "assets",
                form.get("name", current["name"]),
                current["name"],
                free_edit_min_role="manager",
            )

            conn.execute(
                """
                UPDATE equipment_assets
                SET name = ?, space = ?, asset_type = ?, status = ?, last_maintenance = ?, next_maintenance = ?, cert_required = ?, cert_name = ?, owner_user_id = ?, notes = ?, updated_at = ?
                WHERE id = ? AND organization_id = ?
                """,
                (
                    name,
                    form.get("space", current["space"]),
                    form.get("asset_type", current["asset_type"] or ""),
                    status,
                    parse_date(form.get("last_maintenance", current["last_maintenance"] or "")),
                    parse_date(form.get("next_maintenance", current["next_maintenance"] or "")),
                    1 if form.get("cert_required", str(current["cert_required"])) in {"1", "true", "True", "on"} else 0,
                    form.get("cert_name", current["cert_name"] or ""),
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id"), fallback=to_int(current["owner_user_id"])),
                    form.get("notes", current["notes"] or ""),
                    iso(),
                    asset_id,
                    org_id,
                ),
            )
            after_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM equipment_assets WHERE id = ? AND organization_id = ?",
                    (asset_id, org_id),
                ).fetchone()
            )
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "asset_saved",
                "equipment_assets",
                asset_id or 0,
                before_snapshot,
                after_snapshot,
                f"Asset updated: {name}",
            )
            conn.commit()
            return json_response({"ok": True, "status": status}).wsgi(start_response)

        if req.path == "/api/consumables/save" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            consumable_id = to_int(form.get("consumable_id"))
            current = conn.execute(
                "SELECT * FROM consumables WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (consumable_id, org_id),
            ).fetchone()
            if not current:
                return json_response({"ok": False, "error": "not_found"}, status="404 Not Found").wsgi(start_response)
            before_snapshot = snapshot_row(current)

            status = form.get("status", current["status"])
            if status not in CONSUMABLE_STATUSES:
                status = current["status"]
            space_id = to_int(form.get("space_id"), current["space_id"])
            if not space_id:
                return json_response({"ok": False, "error": "space_required"}, status="400 Bad Request").wsgi(start_response)
            valid_space = conn.execute(
                "SELECT id FROM spaces WHERE id = ? AND organization_id = ?",
                (space_id, org_id),
            ).fetchone()
            if not valid_space:
                return json_response({"ok": False, "error": "invalid_space"}, status="400 Bad Request").wsgi(start_response)
            name = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "consumables",
                form.get("name", current["name"]),
                current["name"],
                free_edit_min_role="manager",
            )
            conn.execute(
                """
                UPDATE consumables
                SET name = ?, category = ?, space_id = ?, quantity_on_hand = ?, unit = ?, reorder_point = ?, status = ?, owner_user_id = ?, notes = ?, updated_at = ?
                WHERE id = ? AND organization_id = ?
                """,
                (
                    name,
                    form.get("category", current["category"] or ""),
                    space_id,
                    to_float(form.get("quantity_on_hand"), float(current["quantity_on_hand"] or 0.0)),
                    form.get("unit", current["unit"] or ""),
                    to_float(form.get("reorder_point"), float(current["reorder_point"] or 0.0)),
                    status,
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id"), fallback=to_int(current["owner_user_id"])),
                    form.get("notes", current["notes"] or ""),
                    iso(),
                    consumable_id,
                    org_id,
                ),
            )
            after_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM consumables WHERE id = ? AND organization_id = ?",
                    (consumable_id, org_id),
                ).fetchone()
            )
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "consumable_saved",
                "consumables",
                consumable_id or 0,
                before_snapshot,
                after_snapshot,
                f"Consumable updated: {name}",
            )
            conn.commit()
            return json_response({"ok": True, "status": status}).wsgi(start_response)

        if req.path == "/partnerships":
            content = render_partnership_page(conn, org_id)
            page = render_layout("Partnerships", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/partnerships/new" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            stage = form.get("stage", "Discovery")
            if stage not in PARTNERSHIP_STAGES:
                stage = "Discovery"
            health = form.get("health", "Medium")
            if health not in {"Strong", "Medium", "At Risk"}:
                health = "Medium"
            partner_name = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "partnerships",
                form.get("partner_name"),
                None,
                free_edit_min_role="manager",
            )
            conn.execute(
                """
                INSERT INTO partnerships
                (organization_id, partner_name, school, stage, last_contact, next_followup, owner_user_id, health, notes, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    org_id,
                    partner_name,
                    form.get("school", ""),
                    stage,
                    parse_date(form.get("last_contact", "")),
                    parse_date(form.get("next_followup", "")),
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id")),
                    health,
                    form.get("notes", ""),
                    iso(),
                    iso(),
                ),
            )
            conn.commit()
            return redirect(scoped("/partnerships?msg=Partnership%20added")).wsgi(start_response)

        if req.path == "/data-hub":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            content = render_data_hub_page(conn, org_id)
            page = render_layout("Data Hub", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/api/partnerships/save" and req.method == "POST":
            gate = require_role(ctx, "staff")
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            form = req.form
            role = str(ctx.get("role") or "viewer")
            partnership_id = to_int(form.get("partnership_id"))
            current = conn.execute(
                "SELECT * FROM partnerships WHERE id = ? AND organization_id = ? AND deleted_at IS NULL",
                (partnership_id, org_id),
            ).fetchone()
            if not current:
                return json_response({"ok": False, "error": "not_found"}, status="404 Not Found").wsgi(start_response)
            before_snapshot = snapshot_row(current)
            stage = form.get("stage", current["stage"])
            if stage not in PARTNERSHIP_STAGES:
                stage = current["stage"]
            health = form.get("health", current["health"] or "Medium")
            if health not in {"Strong", "Medium", "At Risk"}:
                health = current["health"] or "Medium"
            partner_name = sanitize_title_for_role(
                conn,
                org_id,
                role,
                "partnerships",
                form.get("partner_name", current["partner_name"]),
                current["partner_name"],
                free_edit_min_role="manager",
            )

            conn.execute(
                """
                UPDATE partnerships
                SET partner_name = ?, school = ?, stage = ?, last_contact = ?, next_followup = ?, owner_user_id = ?, health = ?, notes = ?, updated_at = ?
                WHERE id = ? AND organization_id = ?
                """,
                (
                    partner_name,
                    form.get("school", current["school"] or ""),
                    stage,
                    parse_date(form.get("last_contact", current["last_contact"] or "")),
                    parse_date(form.get("next_followup", current["next_followup"] or "")),
                    normalize_org_user_id(conn, org_id, form.get("owner_user_id"), fallback=to_int(current["owner_user_id"])),
                    health,
                    form.get("notes", current["notes"] or ""),
                    iso(),
                    partnership_id,
                    org_id,
                ),
            )
            after_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM partnerships WHERE id = ? AND organization_id = ?",
                    (partnership_id, org_id),
                ).fetchone()
            )
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "partnership_saved",
                "partnerships",
                partnership_id or 0,
                before_snapshot,
                after_snapshot,
                f"Partnership updated: {partner_name}",
            )
            conn.commit()
            return json_response({"ok": True, "status": stage}).wsgi(start_response)

        if req.path == "/api/items/delete" and req.method == "POST":
            form = req.form
            entity = str(form.get("entity") or "").strip().lower()
            policy = delete_policy_for_entity(entity)
            if not policy:
                return json_response({"ok": False, "error": "invalid_entity"}, status="400 Bad Request").wsgi(start_response)
            gate = require_role(ctx, str(policy.get("min_role") or "staff"))
            if gate:
                return json_response({"ok": False, "error": "forbidden"}, status="403 Forbidden").wsgi(start_response)
            item_id = to_int(form.get("id") or form.get("item_id"))
            if item_id is None:
                return json_response({"ok": False, "error": "invalid_item"}, status="400 Bad Request").wsgi(start_response)
            ok, reason = entity_soft_delete(conn, org_id, user_id, entity, item_id)
            if not ok:
                status_code = "400 Bad Request"
                payload: Dict[str, object] = {"ok": False, "error": reason}
                if reason in {"not_found"}:
                    status_code = "404 Not Found"
                if reason == "already_deleted":
                    status_code = "409 Conflict"
                if reason.startswith("status_required:"):
                    required = [x for x in reason.split(":", 1)[1].split("|") if x]
                    payload = {"ok": False, "error": "status_required", "required_statuses": required}
                    status_code = "422 Unprocessable Entity"
                return json_response(payload, status=status_code).wsgi(start_response)
            conn.commit()
            return json_response({"ok": True}).wsgi(start_response)

        if req.path == "/deleted":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            content = render_deleted_page(conn, org_id)
            page = render_layout("Deleted Items", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/deleted/restore" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            entity = str(req.form.get("entity") or "").strip().lower()
            item_id = to_int(req.form.get("item_id"))
            if item_id is None:
                return redirect(scoped("/deleted?msg=Invalid%20item%20id")).wsgi(start_response)
            ok, reason = restore_soft_deleted_entity(conn, org_id, user_id, entity, item_id)
            if not ok:
                return redirect(scoped(f"/deleted?msg={quote(reason)}")).wsgi(start_response)
            conn.commit()
            return redirect(scoped("/deleted?msg=Item%20restored")).wsgi(start_response)

        if req.path == "/deleted/purge" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            entity = str(req.form.get("entity") or "").strip().lower()
            item_id = to_int(req.form.get("item_id"))
            if item_id is None:
                return redirect(scoped("/deleted?msg=Invalid%20item%20id")).wsgi(start_response)
            ok, reason = purge_soft_deleted_entity(conn, org_id, user_id, entity, item_id)
            if not ok:
                return redirect(scoped(f"/deleted?msg={quote(reason)}")).wsgi(start_response)
            conn.commit()
            return redirect(scoped("/deleted?msg=Item%20purged")).wsgi(start_response)

        if req.path == "/admin/users":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            content = render_admin_page(
                conn,
                org_id,
                is_superuser=bool(user.get("is_superuser")),
                can_provision_workspaces=role_allows(str(ctx.get("role") or ""), "owner"),
            )
            page = render_layout("Admin", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/admin/users/new" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            actor_role = str(ctx.get("role") or "").strip().lower()
            target_role = parse_membership_role(form.get("role"), default="staff")
            if target_role in {"workspace_admin", "owner"} and not role_allows(actor_role, "owner"):
                return redirect("/admin/users?msg=Only%20owner-level%20admins%20can%20assign%20workspace-admin%20or%20owner%20roles").wsgi(start_response)
            email = form.get("email", "").lower().strip()
            existing = conn.execute("SELECT id FROM users WHERE email = ?", (email,)).fetchone()
            if existing:
                return redirect("/admin/users?msg=Email%20already%20exists").wsgi(start_response)

            password = form.get("password", "").strip() or secrets.token_urlsafe(12)
            if len(password) < 12:
                return redirect("/admin/users?msg=Password%20must%20be%20at%20least%2012%20characters").wsgi(start_response)

            pw_hash, pw_salt = hash_password(password)
            conn.execute(
                "INSERT INTO users (email, name, password_hash, password_salt, is_active, is_superuser, created_at) VALUES (?, ?, ?, ?, 1, 0, ?)",
                (email, form.get("name", "New User"), pw_hash, pw_salt, iso()),
            )
            user_row = conn.execute("SELECT id FROM users WHERE email = ?", (email,)).fetchone()
            conn.execute(
                "INSERT INTO memberships (user_id, organization_id, role, created_at) VALUES (?, ?, ?, ?)",
                (user_row["id"], org_id, target_role, iso()),
            )
            conn.commit()
            msg = quote(f"User created. Temporary password: {password}")
            return redirect(f"/admin/users?msg={msg}").wsgi(start_response)

        if req.path == "/admin/users/role" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            actor_role = str(ctx.get("role") or "").strip().lower()
            target_user_id = to_int(form.get("target_user_id"))
            next_role = parse_membership_role(form.get("role"), default="staff")
            if target_user_id is None:
                return redirect("/admin/users?msg=User%20not%20found").wsgi(start_response)
            can_manage_target, reason = can_admin_manage_user(conn, org_id, user_id, actor_role, target_user_id)
            if not can_manage_target:
                return redirect(f"/admin/users?msg={quote(reason)}").wsgi(start_response)
            if next_role in {"workspace_admin", "owner"} and not role_allows(actor_role, "owner"):
                return redirect("/admin/users?msg=Only%20owner-level%20admins%20can%20assign%20workspace-admin%20or%20owner%20roles").wsgi(start_response)
            if ROLE_RANK.get(next_role, 0) > ROLE_RANK.get(actor_role, 0) and not bool(user.get("is_superuser")):
                return redirect("/admin/users?msg=Cannot%20assign%20a%20role%20higher%20than%20your%20own").wsgi(start_response)
            if is_workspace_admin_role(next_role) and not can_manage_workspace_admin_role(conn, target_user_id, org_id):
                return redirect("/admin/users?msg=That%20admin%20account%20already%20controls%20another%20workspace").wsgi(start_response)
            conn.execute(
                "UPDATE memberships SET role = ? WHERE organization_id = ? AND user_id = ?",
                (next_role, org_id, target_user_id),
            )
            conn.commit()
            return redirect("/admin/users?msg=Role%20updated").wsgi(start_response)

        if req.path == "/admin/users/toggle" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            target_id = int(req.form.get("target_user_id", "0") or 0)
            is_active = 1 if req.form.get("is_active") == "1" else 0
            if target_id == user_id and is_active == 0:
                return redirect("/admin/users?msg=Cannot%20disable%20your%20own%20account").wsgi(start_response)
            actor_role = str(ctx.get("role") or "").strip().lower()
            can_manage_target, reason = can_admin_manage_user(conn, org_id, user_id, actor_role, target_id)
            if not can_manage_target:
                return redirect(f"/admin/users?msg={quote(reason)}").wsgi(start_response)
            conn.execute("UPDATE users SET is_active = ? WHERE id = ?", (is_active, target_id))
            if not is_active:
                conn.execute("DELETE FROM sessions WHERE user_id = ?", (target_id,))
            conn.commit()
            return redirect("/admin/users?msg=Account%20status%20updated").wsgi(start_response)

        if req.path == "/admin/users/reset" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            target_id = int(req.form.get("target_user_id", "0") or 0)
            actor_role = str(ctx.get("role") or "").strip().lower()
            can_manage_target, reason = can_admin_manage_user(conn, org_id, user_id, actor_role, target_id)
            if not can_manage_target:
                return redirect(f"/admin/users?msg={quote(reason)}").wsgi(start_response)
            target = conn.execute("SELECT id, email FROM users WHERE id = ?", (target_id,)).fetchone()
            if not target:
                return redirect("/admin/users?msg=User%20not%20found").wsgi(start_response)
            token, _expires = create_password_reset(conn, target["id"], created_by=user_id, hours=24)
            conn.commit()
            reset_link = f"/reset-password?token={token}"
            return redirect(f"/admin/users?msg={quote('Reset link for '+target['email']+': '+reset_link)}").wsgi(start_response)

        if req.path == "/admin/users/delete" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            target_id = to_int(form.get("target_user_id"))
            replacement_id = to_int(form.get("reassign_user_id"))
            if target_id is None:
                return redirect("/admin/users?msg=User%20not%20found").wsgi(start_response)
            if target_id == user_id:
                return redirect("/admin/users?msg=Cannot%20remove%20your%20own%20workspace%20membership").wsgi(start_response)
            actor_role = str(ctx.get("role") or "").strip().lower()
            can_manage_target, reason = can_admin_manage_user(conn, org_id, user_id, actor_role, target_id)
            if not can_manage_target:
                return redirect(f"/admin/users?msg={quote(reason)}").wsgi(start_response)
            if replacement_id is None or int(replacement_id) == int(target_id):
                return redirect("/admin/users?msg=Choose%20a%20valid%20reassignment%20owner").wsgi(start_response)
            replacement_ok = conn.execute(
                """
                SELECT 1
                FROM memberships m
                JOIN users u ON u.id = m.user_id
                WHERE m.organization_id = ? AND m.user_id = ? AND u.is_active = 1
                LIMIT 1
                """,
                (org_id, replacement_id),
            ).fetchone()
            if not replacement_ok:
                return redirect("/admin/users?msg=Replacement%20user%20must%20be%20active%20in%20this%20workspace").wsgi(start_response)

            conn.execute(
                "UPDATE projects SET owner_user_id = ? WHERE organization_id = ? AND owner_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute(
                "UPDATE tasks SET assignee_user_id = ? WHERE organization_id = ? AND assignee_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute(
                "UPDATE tasks SET reporter_user_id = ? WHERE organization_id = ? AND reporter_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute(
                "UPDATE intake_requests SET owner_user_id = ? WHERE organization_id = ? AND owner_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute(
                "UPDATE equipment_assets SET owner_user_id = ? WHERE organization_id = ? AND owner_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute(
                "UPDATE consumables SET owner_user_id = ? WHERE organization_id = ? AND owner_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute(
                "UPDATE partnerships SET owner_user_id = ? WHERE organization_id = ? AND owner_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute(
                "UPDATE meeting_agendas SET owner_user_id = ? WHERE organization_id = ? AND owner_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute(
                "UPDATE onboarding_assignments SET assignee_user_id = ? WHERE organization_id = ? AND assignee_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute(
                "UPDATE teams SET lead_user_id = ? WHERE organization_id = ? AND lead_user_id = ?",
                (replacement_id, org_id, target_id),
            )
            conn.execute("DELETE FROM team_members WHERE user_id = ?", (target_id,))
            conn.execute("DELETE FROM memberships WHERE organization_id = ? AND user_id = ?", (org_id, target_id))
            remaining = conn.execute("SELECT COUNT(*) AS c FROM memberships WHERE user_id = ?", (target_id,)).fetchone()
            if int(remaining["c"] or 0) == 0:
                conn.execute("DELETE FROM sessions WHERE user_id = ?", (target_id,))
                conn.execute("UPDATE users SET is_active = 0 WHERE id = ?", (target_id,))
            conn.commit()
            return redirect("/admin/users?msg=User%20removed%20from%20workspace%20and%20work%20reassigned").wsgi(start_response)

        if req.path == "/admin/data/purge-item" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            entity = str(req.form.get("entity") or "").strip().lower()
            item_id = to_int(req.form.get("item_id"))
            policy = delete_policy_for_entity(entity)
            if not policy or item_id is None:
                return redirect("/admin/users?msg=Invalid%20entity%20or%20item%20id").wsgi(start_response)
            table = str(policy["table"])
            before_snapshot = snapshot_row(
                conn.execute(
                    f"SELECT * FROM {table} WHERE id = ? AND organization_id = ?",
                    (item_id, org_id),
                ).fetchone()
            )
            deleted = conn.execute(
                f"DELETE FROM {table} WHERE id = ? AND organization_id = ?",
                (item_id, org_id),
            ).rowcount
            if int(deleted or 0) == 0:
                return redirect("/admin/users?msg=Item%20not%20found").wsgi(start_response)
            log_change_with_rollback(
                conn,
                org_id,
                user_id,
                "item_purged_admin",
                table,
                item_id,
                before_snapshot,
                None,
                f"Admin purge: {policy['label']} #{item_id}",
                source="admin",
            )
            conn.commit()
            return redirect("/admin/users?msg=Item%20purged").wsgi(start_response)

        if req.path == "/admin/data/purge-keyword" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            keyword = str(req.form.get("keyword") or "").strip()
            if len(keyword) < 2:
                return redirect("/admin/users?msg=Keyword%20must%20be%20at%20least%202%20characters").wsgi(start_response)
            counts = purge_keyword_test_data(conn, org_id, keyword)
            summary = ", ".join([f"{table}:{count}" for table, count in counts.items() if int(count or 0) > 0]) or "No matches"
            log_action(
                conn,
                org_id,
                user_id,
                "admin_keyword_purge",
                "cleanup",
                keyword,
                json.dumps({"source": "admin", "summary": f"Keyword purge: {keyword}", "payload": counts}, ensure_ascii=True)[:4000],
            )
            conn.commit()
            return redirect(f"/admin/users?msg={quote('Keyword purge complete: ' + summary)}").wsgi(start_response)

        if req.path == "/admin/audit/rollback" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            audit_id = to_int(req.form.get("audit_id"))
            if audit_id is None:
                return redirect("/admin/users?msg=Audit%20entry%20id%20is%20required").wsgi(start_response)
            ok, message = rollback_audit_entry(conn, org_id, user_id, audit_id)
            if not ok:
                return redirect(f"/admin/users?msg={quote(message)}").wsgi(start_response)
            conn.commit()
            return redirect("/admin/users?msg=Rollback%20applied").wsgi(start_response)

        if req.path in {"/admin/workspaces/new", "/admin/orgs/new"} and req.method == "POST":
            gate = require_role(ctx, "owner")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            is_super = bool(user.get("is_superuser"))
            slug = form.get("slug", "").strip().lower().replace(" ", "-")
            if not slug:
                return redirect("/admin/users?msg=Slug%20required").wsgi(start_response)
            existing = conn.execute("SELECT id FROM organizations WHERE slug = ?", (slug,)).fetchone()
            if existing:
                return redirect("/admin/users?msg=Slug%20already%20exists").wsgi(start_response)
            admin_email = (form.get("workspace_admin_email") or "").strip().lower()
            admin_name = (form.get("workspace_admin_name") or "").strip()
            admin_password = (form.get("workspace_admin_password") or "").strip()
            workspace_admin_id: Optional[int] = None
            temp_password_message = ""

            if admin_email:
                existing_admin = conn.execute("SELECT id, name FROM users WHERE email = ?", (admin_email,)).fetchone()
                if existing_admin:
                    workspace_admin_id = int(existing_admin["id"])
                    if not can_manage_workspace_admin_role(conn, workspace_admin_id, -1):
                        return redirect("/admin/users?msg=Selected%20workspace%20admin%20already%20manages%20another%20workspace").wsgi(start_response)
                else:
                    if admin_password and len(admin_password) < 12:
                        return redirect("/admin/users?msg=Workspace%20admin%20password%20must%20be%20at%20least%2012%20characters").wsgi(start_response)
                    if not admin_password:
                        admin_password = secrets.token_urlsafe(12)
                    pw_hash, pw_salt = hash_password(admin_password)
                    conn.execute(
                        "INSERT INTO users (email, name, password_hash, password_salt, is_active, is_superuser, created_at) VALUES (?, ?, ?, ?, 1, 0, ?)",
                        (admin_email, admin_name or "Workspace Admin", pw_hash, pw_salt, iso()),
                    )
                    workspace_admin_id = int(conn.execute("SELECT id FROM users WHERE email = ?", (admin_email,)).fetchone()["id"])
                    temp_password_message = f" Workspace admin temporary password: {admin_password}"
            elif is_super:
                workspace_admin_id = user_id
            else:
                return redirect("/admin/users?msg=Provide%20a%20workspace%20admin%20email").wsgi(start_response)

            conn.execute(
                "INSERT INTO organizations (name, slug, created_at) VALUES (?, ?, ?)",
                (form.get("name", "New Department"), slug, iso()),
            )
            new_org = conn.execute("SELECT id FROM organizations WHERE slug = ?", (slug,)).fetchone()
            new_org_id = int(new_org["id"])
            conn.execute(
                "INSERT OR IGNORE INTO memberships (user_id, organization_id, role, created_at) VALUES (?, ?, 'workspace_admin', ?)",
                (workspace_admin_id, new_org_id, iso()),
            )
            if is_super:
                conn.execute(
                    "INSERT OR IGNORE INTO memberships (user_id, organization_id, role, created_at) VALUES (?, ?, 'owner', ?)",
                    (user_id, new_org_id, iso()),
                )
            ensure_default_view_templates(conn, new_org_id, workspace_admin_id)
            ensure_default_report_templates(conn, new_org_id, workspace_admin_id)
            conn.commit()
            msg = f"Workspace created for {slug}.{temp_password_message}"
            return redirect(f"/admin/users?msg={quote(msg)}").wsgi(start_response)

        if req.path in {"/admin/workspaces/delete", "/admin/orgs/delete"} and req.method == "POST":
            gate = require_role(ctx, "owner")
            if gate:
                return gate.wsgi(start_response)
            slug = str(req.form.get("slug") or "").strip().lower()
            confirm = str(req.form.get("confirm") or "").strip().upper()
            if not slug:
                return redirect("/admin/users?msg=Workspace%20slug%20required").wsgi(start_response)
            if confirm != "DELETE":
                return redirect("/admin/users?msg=Type%20DELETE%20to%20confirm").wsgi(start_response)
            target = conn.execute("SELECT id, slug FROM organizations WHERE slug = ?", (slug,)).fetchone()
            if not target:
                return redirect("/admin/users?msg=Workspace%20not%20found").wsgi(start_response)
            target_org_id = int(target["id"])
            conn.execute("DELETE FROM organizations WHERE id = ?", (target_org_id,))
            conn.commit()
            if target_org_id == org_id:
                next_org = conn.execute(
                    "SELECT organization_id FROM memberships WHERE user_id = ? ORDER BY created_at LIMIT 1",
                    (user_id,),
                ).fetchone()
                if next_org:
                    return redirect(f"/dashboard?org_id={next_org['organization_id']}&msg=Workspace%20deleted").wsgi(start_response)
                return redirect("/login?msg=Workspace%20deleted.%20No%20remaining%20workspace%20access", cookies=[clear_cookie("session_token"), clear_cookie("active_org")]).wsgi(start_response)
            return redirect("/admin/users?msg=Workspace%20deleted").wsgi(start_response)

        if req.path == "/settings":
            content = render_settings_page(
                conn,
                user_id,
                org_id,
                role=str(ctx.get("role") or "viewer"),
                selected_space_id=selected_space_id,
            )
            page = render_layout("Settings", fill_csrf(content, csrf_token), req, ctx, notice)
            return Response(page).wsgi(start_response)

        if req.path == "/settings/update" and req.method == "POST":
            form = req.form
            prefs = load_user_preferences(conn, user_id)
            prefs["default_task_scope"] = form.get("default_task_scope", "my")
            prefs["show_weekend_alert"] = form.get("show_weekend_alert") == "1"
            prefs["dashboard_compact"] = form.get("dashboard_compact") == "1"
            prefs["email_task_updates"] = form.get("email_task_updates") == "1"
            prefs["email_project_updates"] = form.get("email_project_updates") == "1"
            prefs["email_comments"] = form.get("email_comments") == "1"
            prefs["email_mentions"] = form.get("email_mentions") == "1"
            actor_role = str(ctx.get("role") or "viewer")
            nav_primary, nav_account = available_nav_items(actor_role)
            allowed = nav_keys(nav_primary + nav_account)
            selected = [key for key in allowed if form.get(f"nav_{key}") == "1"]
            role_default = load_role_nav_preference(conn, org_id, actor_role, allowed)
            prefs["nav_visibility"] = sanitize_nav_key_selection(selected, allowed, fallback=role_default)
            save_user_preferences(conn, user_id, prefs)
            conn.commit()
            return redirect(scoped("/settings?msg=Preferences%20saved")).wsgi(start_response)

        if req.path == "/settings/nav-role/update" and req.method == "POST":
            gate = require_role(ctx, "workspace_admin")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            actor_role = str(ctx.get("role") or "viewer")
            target_role = parse_membership_role(form.get("target_role"), default="staff")
            if target_role in {"workspace_admin", "owner"} and not role_allows(actor_role, "owner"):
                return redirect(scoped("/settings?msg=Only%20owner-level%20admins%20can%20edit%20workspace-admin%20or%20owner%20defaults")).wsgi(start_response)
            role_primary, role_account = available_nav_items(target_role)
            allowed = nav_keys(role_primary + role_account)
            selected = [key for key in allowed if form.get(f"role_nav_{key}") == "1"]
            cleaned = sanitize_nav_key_selection(selected, allowed, fallback=allowed)
            before_snapshot = snapshot_row(
                conn.execute(
                    "SELECT * FROM role_nav_preferences WHERE organization_id = ? AND role = ?",
                    (org_id, target_role),
                ).fetchone()
            )
            save_role_nav_preference(conn, org_id, target_role, cleaned, user_id)
            after_row = conn.execute(
                "SELECT * FROM role_nav_preferences WHERE organization_id = ? AND role = ?",
                (org_id, target_role),
            ).fetchone()
            after_snapshot = snapshot_row(after_row)
            row_id = to_int(str(after_row["id"])) if after_row else to_int(str(before_snapshot.get("id") if before_snapshot else ""))
            if row_id is not None:
                log_change_with_rollback(
                    conn,
                    org_id,
                    user_id,
                    "role_nav_saved",
                    "role_nav_preferences",
                    row_id,
                    before_snapshot,
                    after_snapshot,
                    f"Role nav defaults updated: {target_role}",
                    source="settings",
                )
            conn.commit()
            return redirect(scoped("/settings?msg=Role%20navigation%20defaults%20saved")).wsgi(start_response)

        if req.path == "/settings/profile" and req.method == "POST":
            form = req.form
            email = form.get("email", "").strip().lower()
            existing = conn.execute(
                "SELECT id FROM users WHERE email = ? AND id != ?",
                (email, user_id),
            ).fetchone()
            if existing:
                return redirect(scoped("/settings?msg=Email%20already%20in%20use")).wsgi(start_response)
            conn.execute(
                "UPDATE users SET name = ?, email = ?, title = ?, timezone = ? WHERE id = ?",
                (
                    form.get("name", ""),
                    email,
                    form.get("title", ""),
                    form.get("timezone", ""),
                    user_id,
                ),
            )
            conn.commit()
            return redirect(scoped("/settings?msg=Profile%20updated")).wsgi(start_response)

        if req.path == "/settings/password" and req.method == "POST":
            form = req.form
            current = form.get("current_password", "")
            new_pw = form.get("new_password", "")
            confirm = form.get("confirm_password", "")
            user_row = conn.execute(
                "SELECT password_hash, password_salt FROM users WHERE id = ?",
                (user_id,),
            ).fetchone()
            if not user_row or not verify_password(current, user_row["password_hash"], user_row["password_salt"]):
                return redirect(scoped("/settings?msg=Current%20password%20is%20incorrect")).wsgi(start_response)
            if new_pw != confirm or len(new_pw) < 12:
                return redirect(scoped("/settings?msg=New%20password%20must%20match%20and%20be%2012%2B%20chars")).wsgi(start_response)
            pw_hash, pw_salt = hash_password(new_pw)
            conn.execute(
                "UPDATE users SET password_hash = ?, password_salt = ? WHERE id = ?",
                (pw_hash, pw_salt, user_id),
            )
            conn.execute("DELETE FROM sessions WHERE user_id = ? AND token_hash != ?", (user_id, token_hash(req.cookies.get("session_token", ""))))
            conn.commit()
            return redirect(scoped("/settings?msg=Password%20updated")).wsgi(start_response)

        if req.path == "/settings/spaces/new" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            try:
                conn.execute(
                    "INSERT INTO spaces (organization_id, name, location, description, created_by, created_at) VALUES (?, ?, ?, ?, ?, ?)",
                    (org_id, form.get("name", ""), form.get("location", ""), form.get("description", ""), user_id, iso()),
                )
                conn.commit()
                return redirect(scoped("/settings?msg=Makerspace%20added")).wsgi(start_response)
            except sqlite3.IntegrityError:
                return redirect(scoped("/settings?msg=Makerspace%20name%20already%20exists")).wsgi(start_response)

        if req.path == "/settings/spaces/update" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            next_path = str(form.get("next", "/settings") or "/settings").strip()
            if not next_path.startswith("/"):
                next_path = "/settings"
            space_id = to_int(form.get("space_id"))
            current = conn.execute(
                "SELECT * FROM spaces WHERE id = ? AND organization_id = ?",
                (space_id, org_id),
            ).fetchone()
            if not current:
                return redirect(scoped(f"{next_path}?msg=Makerspace%20not%20found")).wsgi(start_response)
            before_snapshot = snapshot_row(current)
            name = sanitize_title_for_role(
                conn,
                org_id,
                str(ctx.get("role") or "viewer"),
                "spaces",
                form.get("name"),
                current["name"],
                free_edit_min_role="manager",
            )
            try:
                conn.execute(
                    "UPDATE spaces SET name = ?, location = ?, description = ? WHERE id = ? AND organization_id = ?",
                    (
                        name,
                        form.get("location", ""),
                        form.get("description", ""),
                        space_id,
                        org_id,
                    ),
                )
                after_snapshot = snapshot_row(
                    conn.execute(
                        "SELECT * FROM spaces WHERE id = ? AND organization_id = ?",
                        (space_id, org_id),
                    ).fetchone()
                )
                log_change_with_rollback(
                    conn,
                    org_id,
                    user_id,
                    "space_saved",
                    "spaces",
                    space_id or 0,
                    before_snapshot,
                    after_snapshot,
                    f"Makerspace updated: {name}",
                    source="settings",
                )
                conn.commit()
                return redirect(scoped(f"{next_path}?msg=Makerspace%20updated")).wsgi(start_response)
            except sqlite3.IntegrityError:
                return redirect(scoped(f"{next_path}?msg=Makerspace%20name%20already%20exists")).wsgi(start_response)

        if req.path == "/settings/spaces/delete" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            space_id = to_int(form.get("space_id"))
            replacement_space_id = to_int(form.get("replacement_space_id"))
            if space_id is None or replacement_space_id is None or int(space_id) == int(replacement_space_id):
                return redirect(scoped("/settings?msg=Select%20a%20different%20replacement%20space")).wsgi(start_response)
            current = conn.execute(
                "SELECT id, name FROM spaces WHERE id = ? AND organization_id = ?",
                (space_id, org_id),
            ).fetchone()
            replacement = conn.execute(
                "SELECT id, name FROM spaces WHERE id = ? AND organization_id = ?",
                (replacement_space_id, org_id),
            ).fetchone()
            if not current or not replacement:
                return redirect(scoped("/settings?msg=Invalid%20space%20selection")).wsgi(start_response)
            conn.execute(
                "UPDATE projects SET space_id = ? WHERE organization_id = ? AND space_id = ?",
                (replacement_space_id, org_id, space_id),
            )
            conn.execute(
                "UPDATE tasks SET space_id = ? WHERE organization_id = ? AND space_id = ?",
                (replacement_space_id, org_id, space_id),
            )
            conn.execute(
                "UPDATE consumables SET space_id = ? WHERE organization_id = ? AND space_id = ?",
                (replacement_space_id, org_id, space_id),
            )
            conn.execute(
                "UPDATE equipment_assets SET space = ? WHERE organization_id = ? AND space = ?",
                (replacement["name"], org_id, current["name"]),
            )
            conn.execute("DELETE FROM spaces WHERE id = ? AND organization_id = ?", (space_id, org_id))
            conn.commit()
            return redirect(scoped("/settings?msg=Makerspace%20deleted%20and%20work%20reassigned")).wsgi(start_response)

        if req.path == "/settings/teams/new" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            try:
                conn.execute(
                    "INSERT INTO teams (organization_id, name, focus_area, lead_user_id, created_at) VALUES (?, ?, ?, ?, ?)",
                    (
                        org_id,
                        form.get("name", ""),
                        form.get("focus_area", ""),
                        int(form["lead_user_id"]) if form.get("lead_user_id") else None,
                        iso(),
                    ),
                )
                team_id = conn.execute("SELECT last_insert_rowid() AS id").fetchone()["id"]
                if form.get("lead_user_id"):
                    conn.execute(
                        "INSERT OR IGNORE INTO team_members (team_id, user_id, role, created_at) VALUES (?, ?, 'lead', ?)",
                        (team_id, int(form["lead_user_id"]), iso()),
                    )
                conn.commit()
                return redirect(scoped("/settings?msg=Team%20added")).wsgi(start_response)
            except sqlite3.IntegrityError:
                return redirect(scoped("/settings?msg=Team%20name%20already%20exists")).wsgi(start_response)

        if req.path == "/settings/teams/update" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            team_id = to_int(form.get("team_id"))
            current = conn.execute(
                "SELECT * FROM teams WHERE id = ? AND organization_id = ?",
                (team_id, org_id),
            ).fetchone()
            if not current:
                return redirect(scoped("/settings?msg=Team%20not%20found")).wsgi(start_response)
            before_snapshot = snapshot_row(current)
            name = sanitize_title_for_role(
                conn,
                org_id,
                str(ctx.get("role") or "viewer"),
                "teams",
                form.get("name"),
                current["name"],
                free_edit_min_role="manager",
            )
            lead_user_id = to_int(form.get("lead_user_id"))
            try:
                conn.execute(
                    "UPDATE teams SET name = ?, focus_area = ?, lead_user_id = ? WHERE id = ? AND organization_id = ?",
                    (
                        name,
                        form.get("focus_area", ""),
                        lead_user_id,
                        team_id,
                        org_id,
                    ),
                )
                if lead_user_id:
                    conn.execute(
                        "INSERT OR IGNORE INTO team_members (team_id, user_id, role, created_at) VALUES (?, ?, 'lead', ?)",
                        (team_id, lead_user_id, iso()),
                    )
                after_snapshot = snapshot_row(
                    conn.execute(
                        "SELECT * FROM teams WHERE id = ? AND organization_id = ?",
                        (team_id, org_id),
                    ).fetchone()
                )
                log_change_with_rollback(
                    conn,
                    org_id,
                    user_id,
                    "team_saved",
                    "teams",
                    team_id or 0,
                    before_snapshot,
                    after_snapshot,
                    f"Team updated: {name}",
                    source="settings",
                )
                conn.commit()
                return redirect(scoped("/settings?msg=Team%20updated")).wsgi(start_response)
            except sqlite3.IntegrityError:
                return redirect(scoped("/settings?msg=Team%20name%20already%20exists")).wsgi(start_response)

        if req.path == "/settings/teams/delete" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            team_id = to_int(form.get("team_id"))
            replacement_team_id = to_int(form.get("replacement_team_id"))
            current = conn.execute(
                "SELECT id FROM teams WHERE id = ? AND organization_id = ?",
                (team_id, org_id),
            ).fetchone()
            if not current:
                return redirect(scoped("/settings?msg=Team%20not%20found")).wsgi(start_response)
            if replacement_team_id is not None:
                replacement = conn.execute(
                    "SELECT id FROM teams WHERE id = ? AND organization_id = ?",
                    (replacement_team_id, org_id),
                ).fetchone()
                if not replacement or int(replacement_team_id) == int(team_id or 0):
                    return redirect(scoped("/settings?msg=Invalid%20replacement%20team")).wsgi(start_response)
            conn.execute(
                "UPDATE projects SET team_id = ? WHERE organization_id = ? AND team_id = ?",
                (replacement_team_id, org_id, team_id),
            )
            conn.execute(
                "UPDATE tasks SET team_id = ? WHERE organization_id = ? AND team_id = ?",
                (replacement_team_id, org_id, team_id),
            )
            conn.execute("DELETE FROM teams WHERE id = ? AND organization_id = ?", (team_id, org_id))
            conn.commit()
            return redirect(scoped("/settings?msg=Team%20deleted%20and%20work%20reassigned")).wsgi(start_response)

        if req.path == "/settings/field/new" and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            form = req.form
            try:
                conn.execute(
                    """
                    INSERT INTO field_configs
                    (organization_id, entity, field_key, label, field_type, is_required, is_enabled, created_at)
                    VALUES (?, ?, ?, ?, ?, 0, 1, ?)
                    """,
                    (
                        org_id,
                        form.get("entity", "projects"),
                        form.get("field_key", "").strip(),
                        form.get("label", "Custom Field"),
                        form.get("field_type", "text"),
                        iso(),
                    ),
                )
                conn.commit()
                return redirect(scoped("/settings?msg=Field%20added")).wsgi(start_response)
            except sqlite3.IntegrityError:
                return redirect(scoped("/settings?msg=Field%20already%20exists")).wsgi(start_response)

        if req.path.startswith("/export/"):
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            entity = req.path.replace("/export/", "")
            if entity.endswith(".csv"):
                entity = entity[:-4]
            return export_csv(conn, org_id, entity).wsgi(start_response)

        if req.path.startswith("/import/") and req.method == "POST":
            gate = require_role(ctx, "manager")
            if gate:
                return gate.wsgi(start_response)
            entity = req.path.replace("/import/", "")
            if entity.endswith(".csv"):
                entity = entity[:-4]
            file = req.files.get("file")
            if file is None:
                return redirect(scoped("/data-hub?msg=No%20file%20selected")).wsgi(start_response)
            ok, message = import_csv(conn, org_id, entity, file)
            if ok:
                conn.commit()
            return redirect(scoped(f"/data-hub?msg={quote(message)}")).wsgi(start_response)

        return Response("<h1>404 Not Found</h1>", status="404 Not Found").wsgi(start_response)
    except Exception:
        traceback.print_exc()
        return Response("<h1>500 Internal Server Error</h1><p>An unexpected server error occurred.</p>", status="500 Internal Server Error").wsgi(start_response)
    finally:
        conn.close()


def run() -> None:
    ensure_bootstrap()
    server_mode = "threaded" if WSGI_THREADED else "single-threaded"
    print(
        f"{APP_NAME} running on http://{HOST}:{PORT} (db={DB_PATH}, mode={server_mode}, journal={DB_JOURNAL_MODE}, sync={DB_SYNCHRONOUS})"
    )
    if WSGI_THREADED:
        server = make_server(HOST, PORT, app, server_class=ThreadedWSGIServer)
    else:
        server = make_server(HOST, PORT, app)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Shutting down")


if __name__ == "__main__":
    run()
