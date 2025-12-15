#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("docs/reports/REPORTS_INDEX.md")
text = path.read_text(encoding="utf-8")

block = """
### OracleRequired – Incident handling (v0.51.x)

- GOV_OracleRequired_Incident_Runbook_v051_r1.md – Governance/operations runbook
  for handling OracleRequired-related incidents (PSM_ORACLE_MISSING,
  BUYBACK_ORACLE_REQUIRED, BUYBACK_ORACLE_UNHEALTHY). Aligned with:
  - ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md
  - ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md
  - GOV_Oracle_PSM_Governance_v051_r1.md
"""

marker = "### OracleRequired – Incident handling (v0.51.x)"
if marker not in text:
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\n") + "\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired incident runbook section appended to REPORTS_INDEX.md.")
else:
    print("OracleRequired incident runbook section already present; no changes made.")
PY

echo "[DEV-12] $(date -u +"%Y-%m-%dT%H:%M:%SZ") link OracleRequired incident runbook from REPORTS_INDEX (v0.51)" >> logs/project.log
echo "== DEV-12 step03: REPORTS_INDEX updated with OracleRequired incident runbook link =="
