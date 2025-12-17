#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("docs/indexer/indexer_psm.md")

if path.exists():
    text = path.read_text(encoding="utf-8")
else:
    # Minimaler Skeleton, falls der PSM-Indexer-Guide noch nicht existiert
    path.parent.mkdir(parents=True, exist_ok=True)
    text = "# PSM indexer guide\n\nThis document describes how an indexer can\ntrack PegStabilityModule (PSM) activity for the 1kUSD system.\n"

block = """
## OracleRequired telemetry (Phase B preview)

This document is part of the OracleRequired observability effort
(DEV-11 Phase B). Indexers SHOULD treat oracle-related failures as
first-class signals, not as generic errors.

### PSM_ORACLE_MISSING

When PSM operations revert with the `PSM_ORACLE_MISSING` reason:

- Decode the revert reason and store it explicitly, e.g.:
  - `reason_code = "PSM_ORACLE_MISSING"`
  - `oracle_required_blocked = true`
- Derive metrics such as:
  - count of `PSM_ORACLE_MISSING` events per time window,
  - per-caller / per-route breakdowns (where applicable).
- Use these metrics as inputs for dashboards and alerts, so that:
  - running the PSM without a valid oracle pricefeed is visible
    immediately,
  - governance / operations can correlate incidents with config changes.

### References

- `DEV11_PhaseB_Telemetry_TestPlan_r1.md`
- `ARCHITECT_OracleRequired_Telemetry_Status_v051_r1.md`
- `docs/integrations/index.md` (OracleRequired telemetry section)
"""

marker = "## OracleRequired telemetry (Phase B preview)"
if marker not in text:
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\n") + "\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired telemetry section appended to indexer_psm.md.")
else:
    print("OracleRequired telemetry section already present; no changes made.")
PY

echo "[DEV-11] $(date -u +"%Y-%m-%dT%H:%M:%SZ") add OracleRequired telemetry section to indexer_psm (PhaseB preview)" >> logs/project.log
echo "== DEV-11 PhaseB step08: indexer_psm updated with telemetry note r1 =="
