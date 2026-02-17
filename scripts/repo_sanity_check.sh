#!/usr/bin/env bash
set -euo pipefail

# Fast repository hygiene checks that catch merge residue and shell syntax regressions.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "SANITY 1/2: unresolved merge markers"
if git grep -nE '^(<<<<<<<|=======|>>>>>>>)' -- . >/tmp/makerflow-merge-markers.txt; then
  echo "ERROR: unresolved merge markers found:"
  cat /tmp/makerflow-merge-markers.txt
  exit 1
fi

echo "SANITY 2/2: shell syntax"
bash -n run_flask.sh
bash -n scripts/*.sh

echo "REPO_SANITY_OK"
