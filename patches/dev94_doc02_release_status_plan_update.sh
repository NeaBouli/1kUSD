#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="logs/project.log"
FILE1="docs/logs/DEV94_Infra_Release_Tag_Checks_Plan.md"
FILE2="docs/logs/DEV94_Release_Tag_Checks_Plan.md"

for f in "$FILE1" "$FILE2"; do
  if [ ! -f "$f" ]; then
    echo "Error: $f not found – cannot append DEV-94 update."
    exit 1
  fi
done

python3 - <<'PY'
from pathlib import Path

files = [
    Path("docs/logs/DEV94_Infra_Release_Tag_Checks_Plan.md"),
    Path("docs/logs/DEV94_Release_Tag_Checks_Plan.md"),
]

marker = "### Update DEV-94: release-status.yml umgesetzt"

snippet = f"""
{marker}

- Die in diesem Plan skizzierten Release-Tag-Checks wurden mit **DEV-94**
  konkretisiert und technisch umgesetzt:
  - Neuer Workflow: `.github/workflows/release-status.yml`
  - Trigger: `push` auf Tags vom Muster `v0.51.*`
  - Ausführung: `scripts/check_release_status.sh`
- Das Script `scripts/check_release_status.sh` prüft, ob zentrale Status- und
  Report-Files existieren und nicht leer sind:
  - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
  - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
  - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
  - `docs/reports/DEV87_Governance_Handover_v051.md`
  - `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
  - `docs/reports/DEV93_CI_Docs_Build_Report.md`
- Details sind im Report
  `docs/reports/DEV94_Release_Status_Workflow_Report.md`
  dokumentiert (Scope, Tag-Pattern, Grenzen, mögliche Erweiterungen).
- Der Plan in dieser Datei bleibt als konzeptioneller Rahmen bestehen;
  DEV-94 markiert die erste konkrete CI-Umsetzung für die v0.51.x-Release-Linie.
"""

for path in files:
    text = path.read_text()
    if marker in text:
        print(f"DEV-94 update already present in {path}; no change.")
        continue

    if not text.endswith("\n"):
        text += "\n"
    text = text + "\n" + snippet.lstrip("\n") + "\n"
    path.write_text(text)
    print(f"✓ DEV-94 update section appended to {path}")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-94] ${timestamp} CI: documented release-status.yml in DEV94 release-tag plans." >> "$LOG_FILE"

echo "✓ DEV-94 plan updates written to:"
echo "  - $FILE1"
echo "  - $FILE2"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV94 DOC02: done =="
