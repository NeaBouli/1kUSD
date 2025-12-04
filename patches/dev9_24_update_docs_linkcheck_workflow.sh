#!/bin/bash
set -e

echo "== DEV-9 24: update docs-linkcheck workflow to use LINKCHECK_CONFIG =="

# 1) Sicherstellen, dass Workflow-Verzeichnis existiert
mkdir -p .github/workflows

# 2) docs-linkcheck Workflow überschreiben (weiterhin nur workflow_dispatch)
cat <<'YML' > .github/workflows/docs-linkcheck.yml
name: Docs Linkcheck

on:
  workflow_dispatch:

jobs:
  linkcheck:
    name: Run docs linkcheck (manual)
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run lychee link checker on docs/
        uses: lycheeverse/lychee-action@v2
        with:
          args: --config tooling/LINKCHECK_CONFIG.json --no-progress --max-concurrency 4 docs
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
YML

# 3) Log-Eintrag
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 24] ${timestamp} Updated docs-linkcheck workflow to use LINKCHECK_CONFIG" >> "$LOG_FILE"

echo "== DEV-9 24 done =="
