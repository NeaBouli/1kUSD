#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# DEV-11 A03: Backlog-Status aktualisieren
python - <<'PYEOF'
from pathlib import Path

backlog = Path("docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md")
text = backlog.read_text()

snippet = """
## DEV-11 A03 – Rolling Window Cap Enforcement (Status Update)

Status: **implemented in BuybackVault (Phase A)**

The BuybackVault now tracks cumulative buyback volume over a configurable rolling window
(`rollingWindowDuration` + `rollingWindowCapBps`) and enforces the cap in both
`executeBuyback` and `executeBuybackPSM`. When the cap would be exceeded, the call
reverts and the window accumulator is advanced to the current timestamp.

This keeps the per-operation cap (A01) and the oracle/health gate (A02) in place, while
adding a second dimension of protection against repeated buybacks in a short period of
time.
"""

if snippet.strip() not in text:
    backlog.write_text(text.rstrip() + "\n\n" + snippet)
PYEOF

# DEV-11 A03: Telemetry-Outline leicht ergänzen (falls A03-Anchor existiert)
python - <<'PYEOF'
from pathlib import Path

telemetry = Path("docs/dev/DEV11_Telemetry_Events_Outline_r1.md")
text = telemetry.read_text()

anchor = "### A03 – Rolling Window Cap"
if anchor in text and "window cap breach" not in text:
    insert = """
The rolling window enforcement in BuybackVault emits a distinct reason code when a
buyback would exceed the configured window cap. This allows indexers and operators
to distinguish between per-operation cap failures (A01) and cumulative window
violations (A03).
"""
    idx = text.index(anchor) + len(anchor)
    telemetry.write_text(text[:idx] + "\\n\\n" + insert + text[idx:])
PYEOF

# DEV-11 A03 Log-Eintrag
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') DEV-11 A03 backlog_enforce: document rolling window enforcement in backlog + telemetry" >> logs/project.log

echo "== DEV-11 A03 backlog_enforce doc update =="

mkdocs build

echo "== DEV-11 A03 backlog_enforce doc done =="
