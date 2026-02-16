#!/usr/bin/env bash
set -euo pipefail

# Full release validation and cleanup pipeline.
# Runs documentation checks, UI/usability/a11y/security tests, 10-user simulations,
# then removes QA/SIM/SAMPLE data and refreshes website-generated metadata.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "[1/10] Documentation audit"
python3 scripts/documentation_audit.py

echo "[2/10] Smoke test"
python3 scripts/smoke_test.py

echo "[3/10] Usability test"
python3 scripts/usability_test.py

echo "[4/10] Accessibility audit"
python3 scripts/accessibility_audit.py

echo "[5/10] Comprehensive feature + security simulation"
python3 scripts/comprehensive_feature_security_test.py

echo "[6/10] 10-user collaboration simulation"
python3 scripts/collaboration_simulation.py

echo "[7/10] Cleanup QA/SIM/SAMPLE data"
python3 scripts/test_data_cleanup.py
python3 scripts/test_data_cleanup.py --dry-run

echo "[8/10] Re-sync website/wiki generated metadata"
python3 scripts/sync_website_content.py

echo "[9/10] Reset data to clean release baseline"
python3 scripts/reset_release_state.py

echo "[10/10] Release preflight complete"
echo "Ready for packaging and GitHub push: https://github.com/ianroy/makerflowPM"
