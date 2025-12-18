#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("docs/indexer/index.md")
text = path.read_text(encoding="utf-8")

block = """
## PSM indexer – OracleRequired telemetry (Phase B preview)

- **indexer_psm.md** – notes for indexers on how to treat
  `PSM_ORACLE_MISSING` as a first-class observability signal for the
  PegStabilityModule. Part of DEV-11 Phase B telemetry preview and
  aligned with:
  - `DEV11_PhaseB_Telemetry_TestPlan_r1.md`
  - `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`
  - `docs/integrations/index.md` (OracleRequired telemetry section)
"""

marker = "## PSM indexer – OracleRequired telemetry (Phase B preview)"
if marker not in text:
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\\n") + "\\n"
    path.write_text(text, encoding="utf-8")
    print("PSM indexer OracleRequired telemetry section appended to docs/indexer/index.md.")
else:
    print("PSM indexer OracleRequired telemetry section already present; no changes made.")
PY

echo "[DEV-11] $(date -u +"%Y-%m-%dT%H:%M:%SZ") link PSM OracleRequired telemetry note from indexer index (PhaseB preview)" >> logs/project.log
echo "== DEV-11 PhaseB step09: indexer index updated with PSM telemetry link r1 =="
