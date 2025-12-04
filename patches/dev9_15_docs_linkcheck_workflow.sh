#!/bin/bash
set -e

echo "== DEV-9 15: Add docs-linkcheck CI workflow =="

# 1) Ensure workflows directory exists
mkdir -p .github/workflows

# 2) Write docs-linkcheck workflow (manual trigger only)
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

      # Minimal linkcheck using lychee-action.
      # This is a first non-blocking step and only runs when manually dispatched.
      - name: Run lychee link checker on docs/
        uses: lycheeverse/lychee-action@v2
        with:
          args: --no-progress --max-concurrency 4 docs
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
YML

# 3) Log message
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 15] ${timestamp} Added manual docs-linkcheck workflow (docs-linkcheck.yml)" >> "$LOG_FILE"

echo "== DEV-9 15 done =="
