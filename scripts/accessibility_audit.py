#!/usr/bin/env python3
"""Basic accessibility audit (no external deps), including contrast and structure checks.

Design choice:
- Keep this script dependency-light so accessibility regressions are easy to catch in local and CI.
"""

import io
import json
import os
import re
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urlencode

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.server import app, ensure_bootstrap

DEFAULT_ADMIN_EMAIL = os.environ.get("BDI_ADMIN_EMAIL", "admin@makerflow.local").strip().lower()
DEFAULT_ADMIN_PASSWORD = os.environ.get("BDI_ADMIN_PASSWORD", "ChangeMeNow!2026")


def hex_to_rgb(value):
    value = value.strip().lstrip("#")
    return tuple(int(value[i : i + 2], 16) / 255.0 for i in (0, 2, 4))


def luminance(rgb):
    def chan(c):
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4

    r, g, b = [chan(c) for c in rgb]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast_ratio(hex1, hex2):
    l1 = luminance(hex_to_rgb(hex1))
    l2 = luminance(hex_to_rgb(hex2))
    lighter, darker = max(l1, l2), min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


class PageAuditParser(HTMLParser):
    """Collect structural accessibility signals from server-rendered HTML."""
    def __init__(self):
        super().__init__()
        self.h1_count = 0
        self.main_id = False
        self.skip_link = False
        self.nav_has_label = False
        self.tables = 0
        self.theads = 0
        self.current_label_depth = 0
        self.controls_missing_label = 0
        self.label_for = set()
        self.control_ids = set()
        self.pending_controls = []
        self.focusable = 0

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "h1":
            self.h1_count += 1
        if tag == "main" and attrs.get("id") == "main-content":
            self.main_id = True
        if tag == "a" and "skip-link" in attrs.get("class", ""):
            self.skip_link = True
        if tag == "nav" and attrs.get("aria-label"):
            self.nav_has_label = True
        if tag == "table":
            self.tables += 1
        if tag == "thead":
            self.theads += 1
        if tag == "label":
            self.current_label_depth += 1
            if attrs.get("for"):
                self.label_for.add(attrs["for"])
        if tag in {"input", "select", "textarea"}:
            if attrs.get("type") == "hidden":
                return
            if attrs.get("aria-label") or attrs.get("aria-labelledby"):
                return
            cid = attrs.get("id")
            if cid:
                self.control_ids.add(cid)
                self.pending_controls.append(cid)
            elif self.current_label_depth == 0:
                self.controls_missing_label += 1
        if tag in {"a", "button", "input", "select", "textarea"}:
            self.focusable += 1

    def handle_endtag(self, tag):
        if tag == "label" and self.current_label_depth > 0:
            self.current_label_depth -= 1


def check_page(name, html):
    p = PageAuditParser()
    p.feed(html)

    issues = []
    if p.h1_count != 1:
        issues.append(f"Expected 1 h1, found {p.h1_count}")
    if not p.main_id:
        issues.append("Missing main landmark id='main-content'")
    if not p.skip_link:
        issues.append("Missing skip link")
    if not p.nav_has_label:
        issues.append("Navigation missing aria-label")
    if p.tables > 0 and p.theads < p.tables:
        issues.append("One or more tables missing thead")

    labelled_controls = len(p.label_for.intersection(p.control_ids))
    potentially_unlabelled = max(0, len(p.pending_controls) - labelled_controls)
    if p.controls_missing_label > 0:
        issues.append(f"{p.controls_missing_label} form controls are outside labels and without id/for")
    if potentially_unlabelled > 0:
        issues.append(f"{potentially_unlabelled} controls may be missing explicit label mapping")

    return {
        "page": name,
        "focusable_elements": p.focusable,
        "issues": issues,
    }


class WSGIClient:
    """Cookie-aware in-process client reused across audit pages."""
    def __init__(self):
        self.cookies = {}

    def _cookie_header(self):
        if not self.cookies:
            return ""
        return "; ".join([f"{k}={v}" for k, v in self.cookies.items()])

    def request(self, path, method="GET", data=None):
        data = data or {}
        body = urlencode(data).encode("utf-8") if method == "POST" else b""

        environ = {
            "REQUEST_METHOD": method,
            "PATH_INFO": path,
            "QUERY_STRING": "",
            "wsgi.input": io.BytesIO(body),
            "CONTENT_LENGTH": str(len(body)),
            "CONTENT_TYPE": "application/x-www-form-urlencoded",
            "REMOTE_ADDR": "127.0.0.1",
            "HTTP_USER_AGENT": "a11y-audit",
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


def main():
    ensure_bootstrap()
    client = WSGIClient()

    client.request("/login")
    status, _, _ = client.request(
        "/login", method="POST", data={"email": DEFAULT_ADMIN_EMAIL, "password": DEFAULT_ADMIN_PASSWORD}
    )
    assert status.startswith("302"), "Login failed for audit"

    pages = [
        "/dashboard",
        "/reports",
        "/projects",
        "/tasks",
        "/agenda",
        "/calendar",
        "/views",
        "/onboarding",
        "/intake",
        "/assets",
        "/partnerships",
        "/admin/users",
        "/settings",
    ]

    page_results = []
    for page in pages:
        status, _, html = client.request(page)
        if not status.startswith("200"):
            page_results.append({"page": page, "issues": [f"HTTP {status}"]})
            continue
        page_results.append(check_page(page, html))

    contrast_checks = {
        "text_on_card": contrast_ratio("#1f2722", "#ffffff"),
        "muted_on_card": contrast_ratio("#57635a", "#ffffff"),
        "brand_on_card": contrast_ratio("#0f6b4d", "#ffffff"),
        "white_on_brand": contrast_ratio("#ffffff", "#0f6b4d"),
    }

    contrast_issues = []
    for key, ratio in contrast_checks.items():
        if ratio < 4.5:
            contrast_issues.append(f"{key} fails AA normal text ({ratio:.2f})")

    report = {
        "pages": page_results,
        "contrast": {k: round(v, 2) for k, v in contrast_checks.items()},
        "contrast_issues": contrast_issues,
        "total_page_issues": sum(len(p.get("issues", [])) for p in page_results),
    }

    out = ROOT / "analysis_outputs"
    out.mkdir(exist_ok=True)
    target = out / "accessibility_audit.json"
    target.write_text(json.dumps(report, indent=2))

    print("A11Y_AUDIT_COMPLETE", target)
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
