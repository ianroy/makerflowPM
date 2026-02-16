#!/usr/bin/env python3
"""Sync generated data for the public MakerFlow Website and wiki.

This script is intended to be run after meaningful product updates so that:
- `MakerFlow Website/data/updates.json` reflects current release history.
- `MakerFlow Website/data/file_map.json` reflects the current package file inventory.

Design rationale:
- Keep generated website content deterministic and local-file based (no external APIs).
- Provide open-source-friendly discoverability for contributors and reviewers.
"""

from __future__ import annotations

import datetime as dt
import json
import os
import subprocess
from pathlib import Path
from typing import Dict, Iterable, List

REPO_ROOT = Path(__file__).resolve().parent.parent
WEBSITE_DATA_DIR = REPO_ROOT / "MakerFlow Website" / "data"

EXCLUDED_DIR_NAMES = {
    ".git",
    ".venv",
    "__pycache__",
    ".mypy_cache",
    ".pytest_cache",
}

EXCLUDED_FILE_NAMES = {
    ".DS_Store",
}

EXCLUDED_PREFIXES = (
    "tmp/",
    "analysis_outputs/",
    "data/backups/",
    ".codex_work/",
)

EXCLUDED_EXACT_PATHS = {
    "data/bdi_ops.db",
}

PATH_DESCRIPTIONS: Dict[str, str] = {
    "app/server.py": "Main WSGI backend: routes, rendering, business logic, auth, and data access.",
    "app/static/app.js": "Progressive frontend behavior: inline editing, drag/drop, modal editors, and board UX.",
    "app/static/style.css": "Application design system and layout styles.",
    "scripts/deploy_production.sh": "One-command production deployment to Linux VM (systemd + nginx + TLS).",
    "scripts/sync_website_content.py": "Generates website release feed and file map data.",
    "README.md": "Project overview, local run instructions, and deployment commands.",
}


def should_skip(relative_path: str, parts: Iterable[str]) -> bool:
    if relative_path in EXCLUDED_EXACT_PATHS:
        return True
    if any(part in EXCLUDED_DIR_NAMES for part in parts):
        return True
    if any(relative_path.startswith(prefix) for prefix in EXCLUDED_PREFIXES):
        return True
    if Path(relative_path).name in EXCLUDED_FILE_NAMES:
        return True
    return False


def categorize_path(relative_path: str) -> str:
    if relative_path.startswith("app/"):
        return "Application Code"
    if relative_path.startswith("scripts/"):
        return "Automation Script"
    if relative_path.startswith("docs/"):
        return "Project Documentation"
    if relative_path.startswith("MakerFlow Website/"):
        return "Website and Wiki"
    if relative_path.startswith("data/"):
        return "Data and Storage"
    return "Project Root"


def describe_path(relative_path: str) -> str:
    if relative_path in PATH_DESCRIPTIONS:
        return PATH_DESCRIPTIONS[relative_path]
    suffix = Path(relative_path).suffix.lower()
    if suffix == ".py":
        return "Python source file."
    if suffix in {".js", ".css", ".html", ".svg"}:
        return "Frontend web asset."
    if suffix in {".md", ".txt"}:
        return "Documentation/content file."
    if suffix in {".json", ".csv", ".ics"}:
        return "Data/configuration file."
    if suffix == ".sh":
        return "Shell automation script."
    return "Project file."


def collect_file_map() -> Dict[str, object]:
    files: List[Dict[str, object]] = []
    directories = set()

    for root, dirnames, filenames in os.walk(REPO_ROOT):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIR_NAMES]
        root_path = Path(root)
        for filename in filenames:
            full_path = root_path / filename
            relative = full_path.relative_to(REPO_ROOT).as_posix()
            parts = Path(relative).parts
            if should_skip(relative, parts):
                continue
            directories.add(str(Path(relative).parent.as_posix()))
            files.append(
                {
                    "path": relative,
                    "category": categorize_path(relative),
                    "description": describe_path(relative),
                    "size_bytes": full_path.stat().st_size,
                }
            )

    files.sort(key=lambda item: str(item["path"]))
    return {
        "generated_at": dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat(),
        "stats": {
            "file_count": len(files),
            "directory_count": len(directories),
        },
        "files": files,
    }


def collect_release_updates() -> Dict[str, object]:
    default_entry = [
        {
            "date": dt.date.today().isoformat(),
            "summary": "No git history available yet. Add commits to generate release feed entries.",
        }
    ]
    try:
        completed = subprocess.run(
            [
                "git",
                "-C",
                str(REPO_ROOT),
                "log",
                "--date=short",
                "--pretty=format:%h|%ad|%s",
                "-n",
                "40",
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if completed.returncode != 0:
            raise RuntimeError(completed.stderr.strip() or "git log failed")
        lines = [line.strip() for line in completed.stdout.splitlines() if line.strip()]
        entries = []
        for line in lines:
            parts = line.split("|", 2)
            if len(parts) != 3:
                continue
            commit_id, commit_date, subject = parts
            entries.append({"date": commit_date, "summary": f"{subject} ({commit_id})"})
        if not entries:
            entries = default_entry
    except Exception:
        entries = default_entry

    return {
        "generated_at": dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat(),
        "entries": entries,
    }


def write_json(path: Path, payload: Dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=True) + "\n", encoding="utf-8")


def main() -> None:
    file_map_payload = collect_file_map()
    updates_payload = collect_release_updates()
    write_json(WEBSITE_DATA_DIR / "file_map.json", file_map_payload)
    write_json(WEBSITE_DATA_DIR / "updates.json", updates_payload)
    print(
        "Website sync complete:",
        f"{file_map_payload['stats']['file_count']} files indexed,",
        f"{len(updates_payload['entries'])} release entries generated.",
    )


if __name__ == "__main__":
    main()
