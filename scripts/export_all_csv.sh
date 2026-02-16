#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
OUT_DIR="${OUT_DIR:-./exports}"
mkdir -p "$OUT_DIR"

for entity in projects tasks calendar_events intake_requests equipment_assets partnerships; do
  curl -sS "$BASE_URL/export/$entity.csv" -o "$OUT_DIR/$entity.csv"
  echo "Exported $entity.csv"
done
