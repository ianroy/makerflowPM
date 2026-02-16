#!/usr/bin/env python3
"""Fast health smoke test for local/dev CI.

Design choice:
- Use in-process WSGI calls (no real HTTP server needed) for deterministic, low-cost checks.
"""

import io
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.server import app, ensure_bootstrap


def run_request(path="/healthz", method="GET", body=b""):
    """Execute a minimal WSGI request against the app callable."""
    status_holder = {}

    def start_response(status, headers):
        status_holder["status"] = status
        status_holder["headers"] = headers

    environ = {
        "REQUEST_METHOD": method,
        "PATH_INFO": path,
        "QUERY_STRING": "",
        "wsgi.input": io.BytesIO(body),
        "CONTENT_LENGTH": str(len(body)),
        "CONTENT_TYPE": "application/x-www-form-urlencoded",
        "REMOTE_ADDR": "127.0.0.1",
        "HTTP_USER_AGENT": "smoke-test",
    }

    chunks = app(environ, start_response)
    payload = b"".join(chunks)
    return status_holder["status"], payload.decode("utf-8", errors="ignore")


if __name__ == "__main__":
    ensure_bootstrap()
    status, body = run_request("/healthz")
    assert status.startswith("200"), f"health failed: {status}"
    assert "ok" in body.lower(), "health payload missing"
    print("SMOKE_OK")
