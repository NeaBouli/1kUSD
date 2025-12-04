#!/bin/bash
set -e

echo "== DEV-9 34: run local dev CI smoketest (forge + mkdocs + release status) =="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 1) Forge Tests (optional, falls forge vorhanden)
if command -v forge >/dev/null 2>&1; then
  echo "-- forge test (may take a while) --"
  forge test
else
  echo "forge not found in PATH, skipping forge test."
fi

# 2) MkDocs Build (optional, falls mkdocs vorhanden)
if command -v mkdocs >/dev/null 2>&1; then
  echo "-- mkdocs build --"
  mkdocs build
else
  echo "mkdocs not found in PATH, skipping mkdocs build."
fi

# 3) Release Status Check (falls Script existiert)
if [ -x "scripts/check_release_status.sh" ]; then
  echo "-- scripts/check_release_status.sh --"
  scripts/check_release_status.sh
else
  if [ -f "scripts/check_release_status.sh" ]; then
    echo "scripts/check_release_status.sh exists but is not executable, skipping."
  else
    echo "scripts/check_release_status.sh not found, skipping."
  fi
fi

# 4) Log-Eintrag
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 34] ${timestamp} Ran local dev CI smoketest (forge test, mkdocs build, release status where available)" >> "$LOG_FILE"

echo "== DEV-9 34 done =="
