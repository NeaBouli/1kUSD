#!/usr/bin/env bash
set -euo pipefail

echo "== DEV94 CI01: add release-status CI workflow =="

WORKFLOW=".github/workflows/release-status.yml"
LOG_FILE="logs/project.log"

mkdir -p "$(dirname "$WORKFLOW")"

cat > "$WORKFLOW" <<'YAML'
name: Release Status Check

on:
  push:
    tags:
      - "v0.51.*"

jobs:
  release-status:
    name: Run release status script for v0.51.x tags
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run release status check
        run: |
          chmod +x scripts/check_release_status.sh
          scripts/check_release_status.sh
YAML

echo "✓ release-status.yml written to ${WORKFLOW}"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-94] ${timestamp} CI: added release-status workflow (runs scripts/check_release_status.sh on v0.51.* tags)." >> "$LOG_FILE"

echo "✓ Log updated at $LOG_FILE"
echo "== DEV94 CI01: done =="
