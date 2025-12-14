#!/usr/bin/env bash
set -euo pipefail

FILE="docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md"

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found (run from repo root)" >&2
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

path = Path("docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md")
text = path.read_text(encoding="utf-8")

block = """
## Phase B – Telemetry tests (OracleRequired)

- Align Solidity/Foundry coverage with `DEV11_PhaseB_Telemetry_TestPlan_r1.md`.
- Treat oracle-related reason codes (e.g. `PSM_ORACLE_MISSING`,
  `BUYBACK_ORACLE_REQUIRED`, `BUYBACK_ORACLE_UNHEALTHY`) as
  first-class observability signals, not as business logic.
- Keep A03 rolling-window boundary tests **explicitly parked**
  for a later hardening wave (DEV-11 Phase C or similar), as
  agreed with the architect.
"""

marker = "## Phase B – Telemetry tests (OracleRequired)"
if marker in text:
    print("Phase B telemetry backlog note already present; no changes made.")
else:
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\n") + "\n"
    path.write_text(text, encoding="utf-8")
    print("Phase B telemetry backlog note appended to DEV11 implementation backlog.")
PY

# Log-Eintrag
echo "[DEV-11] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add PhaseB telemetry backlog note (r1)" >> logs/project.log
echo "== DEV-11 PhaseB step05: Implementation backlog updated with telemetry note r1 =="
