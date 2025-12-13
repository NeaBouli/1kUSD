#!/usr/bin/env bash
set -euo pipefail

# DEV-94 gate step02: append OracleRequired release gate block to scripts/check_release_status.sh
cd "$(dirname "$0")/.."

python3 << 'PY'
from pathlib import Path

path = Path("scripts/check_release_status.sh")
text = path.read_text(encoding="utf-8")

marker = "# OracleRequired release gate (r1)"
if marker in text:
    print("OracleRequired release gate block already present.")
else:
    block = """
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
  else
    echo "[OK] OracleRequired release gate: report present: $path"
  fi
done

if [ "$missing_oracle_reports" -ne 0 ]; then
  echo "[ERROR] OracleRequired release gate failed." >&2
  exit 1
fi

"""
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\n")
    path.write_text(text, encoding="utf-8")
    print("OracleRequired gate block appended to scripts/check_release_status.sh")
PY

echo "[DEV-94] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add OracleRequired gate block to check_release_status.sh (r1)" >> logs/project.log

echo "== DEV-94 gate step02: OracleRequired gate block appended to scripts/check_release_status.sh =="
