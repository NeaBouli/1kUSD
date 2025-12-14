#!/usr/bin/env bash
set -euo pipefail

FILE="docs/integrations/index.md"

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found (run from repo root)" >&2
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

path = Path("docs/integrations/index.md")
text = path.read_text(encoding="utf-8")

block = """
## OracleRequired telemetry (Phase B preview)

For indexer / integration work related to OracleRequired safety:

- Treat oracle-related reason codes as **first-class observability signals**:
  - `PSM_ORACLE_MISSING`
  - `BUYBACK_ORACLE_REQUIRED`
  - `BUYBACK_ORACLE_UNHEALTHY`
- Align dashboards, alerts and incident playbooks with:
  - `docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md`
  - `docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md`
  - the Architect OracleRequired bundle:
    - `docs/reports/ARCHITECT_OracleRequired_OperationsBundle_v051_r1.md`
    - `docs/reports/ARCHITECT_BULLETIN_Oracle_Safety_Clarifications_2025-12.md`

Phase B focuses on **signals and visibility**; actual indexer
implementations can evolve independently, as long as they expose
these reason codes and events in a consistent way.
"""

marker = "## OracleRequired telemetry (Phase B preview)"
if marker in text:
    print("OracleRequired telemetry section already present; no changes made.")
else:
    if not text.endswith("\\n"):
        text += "\\n"
    text += block.lstrip("\\n") + "\\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired telemetry section appended to integrations index.")
PY

from datetime import datetime, timezone
ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
with open("logs/project.log", "a", encoding="utf-8") as f:
    f.write(f"[DEV-11] {ts} add OracleRequired telemetry note to integrations index (PhaseB preview)\\n")

echo "== DEV-11 PhaseB step06: integrations index updated with OracleRequired telemetry note =="
