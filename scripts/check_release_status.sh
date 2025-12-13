
# OracleRequired release gate (r1)
# DEV-94: v0.51+ releases MUST have the OracleRequired docs bundle present
# This gate is intentionally text-only and does not perform on-chain checks.

ORACLE_REQUIRED_REPORTS="
docs/reports/ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md
docs/reports/DEV94_Release_Status_Workflow_Report.md
docs/reports/BLOCK_DEV49_DEV11_OracleRequired_Block_r1.md
docs/reports/DEV11_OracleRequired_Handshake_r1.md
docs/governance/GOV_Oracle_PSM_Governance_v051_r1.md
"

missing_oracle_reports=0

for path in $ORACLE_REQUIRED_REPORTS; do
  if [ ! -s "$path" ]; then
    echo "[ERROR] OracleRequired release gate: missing or empty report: $path" >&2
    missing_oracle_reports=1
  else:
    echo "[OK] OracleRequired release gate: report present: $path"
  fi
done

if [ "$missing_oracle_reports" -ne 0 ]; then
  echo "[ERROR] OracleRequired release gate failed." >&2
  exit 1
fi

\n#!/usr/bin/env bash
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
