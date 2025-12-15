#!/usr/bin/env bash
set -euo pipefail

FILE="docs/indexer/indexer_buybackvault.md"

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found (run from repo root)"
  exit 1
fi

python3 - << 'PY'
from pathlib import Path
import textwrap

path = Path("docs/indexer/indexer_buybackvault.md")
text = path.read_text(encoding="utf-8")

block = """
## OracleRequired telemetry (Phase B preview)

Indexers that track the BuybackVault SHOULD treat oracle-related
reason codes as first-class observability signals:

- `PSM_ORACLE_MISSING`
- `BUYBACK_ORACLE_REQUIRED`
- `BUYBACK_ORACLE_UNHEALTHY`

At minimum, indexer pipelines SHOULD:
- store these reason codes explicitly alongside the transaction/event,
- derive a boolean flag such as `oracle_required_blocked = true`
  whenever a buyback is rejected due to an OracleRequired condition,
- expose this flag and the underlying reason code to monitoring /
  dashboards and reporting.

This guidance is a Phase B preview and is aligned with:
- `docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md`
- `docs/integrations/index.md` (OracleRequired telemetry section)
- the Architect's OracleRequired Operations Bundle.
"""

marker = "## OracleRequired telemetry (Phase B preview)"
if marker not in text:
    if not text.endswith("\\n"):
        text += "\\n"
    text += block.lstrip("\\n") + "\\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired telemetry section appended to indexer_buybackvault.")
else:
    print("OracleRequired telemetry section already present; no changes made.")
PY

from datetime import datetime, timezone
ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
with open("logs/project.log", "a", encoding="utf-8") as f:
    f.write(f"[DEV-11] {ts} add OracleRequired telemetry note to indexer buybackvault doc (PhaseB preview)\n")

print("== DEV-11 PhaseB step07: indexer_buybackvault telemetry note added ==")
