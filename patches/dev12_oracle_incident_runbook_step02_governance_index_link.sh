#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("docs/governance/index.md")
text = path.read_text(encoding="utf-8")

block = """
## OracleRequired – Incident Handling (v0.51.x)

- **GOV_OracleRequired_Incident_Runbook_v051_r1.md** – operational runbook for
  handling OracleRequired-related incidents (`PSM_ORACLE_MISSING`,
  `BUYBACK_ORACLE_REQUIRED`, `BUYBACK_ORACLE_UNHEALTHY`), aligned with:
  - `ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
  - `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`
  - `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`
  - `GOV_Oracle_PSM_Governance_v051_r1.md`
"""

marker = "## OracleRequired – Incident Handling (v0.51.x)"
if marker not in text:
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\\n") + "\\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired incident runbook section appended to governance index.")
else:
    print("OracleRequired incident runbook section already present; no changes made.")
PY

echo "[DEV-12] $(date -u +"%Y-%m-%dT%H:%M:%SZ") link OracleRequired incident runbook from governance index (v0.51)" >> logs/project.log
echo "== DEV-12 step02: governance index updated with OracleRequired incident runbook link =="
