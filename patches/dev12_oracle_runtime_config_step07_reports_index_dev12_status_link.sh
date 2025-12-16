#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("docs/reports/REPORTS_INDEX.md")
text = path.read_text(encoding="utf-8")

block = """
### DEV-12 – Oracle governance toolkit status (v0.51.x)

- DEV12_Oracle_Governance_Toolkit_Status_v051_r1.md – status report for the
  OracleRequired governance & operations toolkit in v0.51.x. Summarizes how:
  - ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md
  - ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md
  - GOV_Oracle_PSM_Governance_v051_r1.md
  - GOV_OracleRequired_Incident_Runbook_v051_r1.md
  - GOV_OracleRequired_Runtime_Config_Checklist_v051_r1.md
  - RELEASE_TAGGING_GUIDE_v0.51.x.md
  - the OracleRequired docs gate in scripts/check_release_status.sh
  fit together as one coherent governance toolkit.
"""

marker = "### DEV-12 – Oracle governance toolkit status (v0.51.x)"
if marker not in text:
    if not text.endswith("\\n"):
        text += "\\n"
    text += block.lstrip("\\n") + "\\n"
    path.write_text(text, encoding="utf-8")
    print("DEV-12 Oracle governance toolkit status section appended to REPORTS_INDEX.md.")
else:
    print("DEV-12 Oracle governance toolkit status section already present; no changes made.")
PY

echo "[DEV-12] $(date -u +"%Y-%m-%dT%H:%M:%SZ") link DEV-12 Oracle governance toolkit status report from REPORTS_INDEX (v0.51)" >> logs/project.log
echo "== DEV-12 step07: REPORTS_INDEX updated with DEV-12 governance toolkit status link =="
