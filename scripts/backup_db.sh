#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DB_PATH="${BDI_DB_PATH:-$BASE_DIR/data/bdi_ops.db}"
BACKUP_DIR="${BACKUP_DIR:-$BASE_DIR/data/backups}"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"
cp "$DB_PATH" "$BACKUP_DIR/bdi_ops-$STAMP.db"

# Keep latest 30 backups
ls -1t "$BACKUP_DIR"/bdi_ops-*.db | tail -n +31 | xargs -I{} rm -f "{}"

echo "Backup created: $BACKUP_DIR/bdi_ops-$STAMP.db"
