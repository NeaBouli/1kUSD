#!/usr/bin/env bash
set -euo pipefail

echo "== DEV96 CI01: add release status CI workflow =="

WORKFLOW=".github/workflows/release-status.yml"
LOG_FILE="logs/project.log"

mkdir -p .github/workflows

cat > "$WORKFLOW" <<'YAML'
name: Release Status

on:
  push:
    tags:
      - "v0.51.*"
      - "v0.52.*"

jobs:
  release-status:
    name: Check release status reports
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Make release status script executable
        run: chmod +x scripts/check_release_status.sh

      - name: Run release status check
        run: ./scripts/check_release_status.sh
YAML

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-96] ${timestamp} CI: added release-status workflow to run scripts/check_release_status.sh on release tags." >> "$LOG_FILE"

echo "✓ ${WORKFLOW} written"
echo "✓ Log updated at ${LOG_FILE}"
echo "== DEV96 CI01: done =="
