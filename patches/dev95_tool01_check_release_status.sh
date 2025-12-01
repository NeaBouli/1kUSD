#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

LOG_FILE="logs/project.log"
SCRIPT="scripts/check_release_status.sh"

mkdir -p scripts

cat > "$SCRIPT" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

# Simple local helper to verify that key status/report files exist
# and are non-empty before cutting a release tag.
#
# Scope:
# - Read-only checks
# - No network calls
# - No codegen / builds

cd "$(dirname "$0")/.."

STATUS=0

check_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    echo "[MISSING] $path"
    STATUS=1
  elif [ ! -s "$path" ]; then
    echo "[EMPTY]   $path"
    STATUS=1
  else
    echo "[OK]      $path"
  fi
}

echo "== 1kUSD Release Status Check =="
echo

# Core Economic Layer / BuybackVault / Strategy reports
check_file "docs/reports/PROJECT_STATUS_EconomicLayer_v051.md"
check_file "docs/reports/DEV60-72_BuybackVault_EconomicLayer.md"
check_file "docs/reports/DEV74-76_StrategyEnforcement_Report.md"
check_file "docs/reports/DEV87_Governance_Handover_v051.md"
check_file "docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md"

# CI / Docs build report (DEV-93)
check_file "docs/reports/DEV93_CI_Docs_Build_Report.md"

echo
if [ "$STATUS" -eq 0 ]; then
  echo "All required status/report files are present and non-empty."
  echo "You can safely proceed to create a release tag (from this perspective)."
else
  echo "Some required status/report files are missing or empty."
  echo "Please fix them before creating a release tag."
fi

exit "$STATUS"
SH

chmod +x "$SCRIPT"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-95] ${timestamp} Infra: added scripts/check_release_status.sh for local release status checks." >> "$LOG_FILE"

echo "✓ scripts/check_release_status.sh written"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV95 TOOL01: done =="
