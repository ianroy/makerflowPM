#!/usr/bin/env python3
"""Documentation and release metadata audit for MakerFlow PM.

This script validates that launch-facing docs are aligned with:
- canonical site: https://makerflow.org
- canonical repository: https://github.com/ianroy/makerflowPM
- CC BY-SA licensing presence
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "analysis_outputs" / "documentation_audit.json"

TARGETS = [
    ROOT / "README.md",
    ROOT / "docs" / "ARCHITECTURE.md",
    ROOT / "docs" / "CONTRIBUTING.md",
    ROOT / "docs" / "DATA_MODEL.md",
    ROOT / "docs" / "DECISIONS.md",
    ROOT / "docs" / "DEPLOYMENT.md",
    ROOT / "docs" / "LICENSE.md",
    ROOT / "docs" / "SECURITY.md",
    ROOT / "docs" / "TESTING.md",
    ROOT / "MakerFlow Website" / "index.html",
    ROOT / "MakerFlow Website" / "wiki" / "index.html",
    ROOT / "MakerFlow Website" / "wiki" / "getting-started.html",
    ROOT / "MakerFlow Website" / "wiki" / "deployment.html",
    ROOT / "scripts" / "deploy_production.sh",
]

FORBIDDEN_PATTERNS: Dict[str, str] = {
    r"/Users/": "Contains machine-specific absolute path.",
    r"Codex/": "Contains machine-specific workspace path.",
    r"ianroy@gmail\.com": "Contains personal bootstrap email.",
    r"makerflow\.yourdomain\.edu": "Contains placeholder domain not suitable for launch docs.",
}

REQUIRED_SNIPPETS: Dict[Path, List[str]] = {
    ROOT / "README.md": [
        "https://github.com/ianroy/makerflowPM",
        "https://makerflow.org",
        "CC BY-SA 4.0",
    ],
    ROOT / "docs" / "DEPLOYMENT.md": [
        "makerflow.org",
    ],
    ROOT / "MakerFlow Website" / "wiki" / "deployment.html": [
        "makerflow.org",
        "github.com/ianroy/makerflowPM",
    ],
    ROOT / "MakerFlow Website" / "wiki" / "index.html": [
        "CC BY-SA 4.0",
    ],
}


def main() -> int:
    findings: List[Dict[str, str]] = []
    checked_files: List[str] = []

    for path in TARGETS:
        if not path.exists():
            findings.append({"file": str(path.relative_to(ROOT)), "issue": "Missing required file"})
            continue

        checked_files.append(str(path.relative_to(ROOT)))
        text = path.read_text(encoding="utf-8", errors="ignore")

        for pattern, reason in FORBIDDEN_PATTERNS.items():
            if re.search(pattern, text, flags=re.IGNORECASE):
                findings.append(
                    {
                        "file": str(path.relative_to(ROOT)),
                        "issue": reason,
                        "pattern": pattern,
                    }
                )

        required = REQUIRED_SNIPPETS.get(path, [])
        for token in required:
            if token not in text:
                findings.append(
                    {
                        "file": str(path.relative_to(ROOT)),
                        "issue": f"Missing required content: {token}",
                    }
                )

    for must_exist in (ROOT / "LICENSE", ROOT / "docs" / "LICENSE.md"):
        if not must_exist.exists():
            findings.append({"file": str(must_exist.relative_to(ROOT)), "issue": "Required license file is missing"})

    report = {
        "checked_files": checked_files,
        "checked_count": len(checked_files),
        "finding_count": len(findings),
        "findings": findings,
        "status": "pass" if not findings else "fail",
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")

    print(f"DOCUMENTATION_AUDIT {report['status'].upper()} findings={report['finding_count']} output={OUT}")
    if findings:
        for item in findings:
            print(f"- {item['file']}: {item['issue']}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
