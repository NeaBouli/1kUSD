#!/usr/bin/env bash
set -euo pipefail

# DEV-94 gate step04: rewrite check_release_status.sh with OracleRequired gate
cd "$(dirname "$0")/.."

cat << 'SH' > scripts/check_release_status.sh
#!/usr/bin/env bash
set -euo pipefail

echo "== 1kUSD Release Status Check =="

# Base status / report files that MUST exist for v0.51.x
BASE_REPORTS="
docs/reports/PROJECT_STATUS_EconomicLayer_v051.md
docs/reports/DEV60-72_BuybackVault_EconomicLayer.md
docs/reports/DEV74-76_StrategyEnforcement_Report.md
docs/reports/DEV87_Governance_Handover_v051.md
docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md
docs/reports/DEV93_CI_Docs_Build_Report.md
"

missing_base_reports=0

for path in $BASE_REPORTS; do
  if [ ! -s "$path" ]; then
    echo "[ERROR] Missing or empty status/report file: $path" >&2
    missing_base_reports=1
  else
    printf "[OK]      %s\n" "$path"
  fi
done

if [ "$missing_base_reports" -ne 0 ]; then
  echo "[ERROR] Base release status check failed." >&2
  exit 1
fi

echo
echo "All required status/report files are present and non-empty."

# ----------------------------------------------------------------------
# OracleRequired release gate (r1)
# DEV-94: v0.51+ releases MUST have the OracleRequired docs bundle present
# This gate is intentionally text-only and does not perform on-chain checks.
# ----------------------------------------------------------------------

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
  else
    echo "[OK] OracleRequired release gate: report present: $path"
  fi
done

if [ "$missing_oracle_reports" -ne 0 ]; then
  echo "[ERROR] OracleRequired release gate failed." >&2
  exit 1
fi

echo
echo "You can safely proceed to create a v0.51+ release tag from this perspective (status + OracleRequired docs)."
SH

chmod +x scripts/check_release_status.sh

echo "[DEV-94] $(date -u +"%Y-%m-%dT%H:%M:%SZ") rewrite check_release_status.sh with OracleRequired gate (r1)" >> logs/project.log

echo "== DEV-94 gate step04: check_release_status.sh rewritten with OracleRequired gate =="
