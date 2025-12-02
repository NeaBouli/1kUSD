#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="docs/logs/DEV79_Infra_MkDocs_Nav_StrategyRisk.md"
LOG_FILE="logs/project.log"

if [ ! -f "$FILE" ]; then
  echo "ERROR: $FILE not found. Aborting."
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

path = Path("docs/logs/DEV79_Infra_MkDocs_Nav_StrategyRisk.md")
text = path.read_text()

marker = "### Update DEV-98: Security & Risk nav live"

if marker in text:
    print("DEV-98 update already present in DEV79 MkDocs nav notes; no change.")
else:
    snippet = """
### Update DEV-98: Security & Risk nav live

- Der in diesem Dokument geplante Menüpunkt **„Security & Risk“** ist nun in
  `mkdocs.yml` umgesetzt:
  - Eintrag unter `nav:` als eigener Block **„Security & Risk“**.
  - Verlinkt u.a.:
    - `security/audit_plan.md`
    - `security/bug_bounty.md`
    - `risk/proof_of_reserves_spec.md`
    - `risk/collateral_risk_profile.md`
    - `risk/emergency_depeg_runbook.md`
    - `testing/stress_test_suite_plan.md`
- Damit ist der sichtbare Einstiegspunkt für Strategy/Security/Risk-Dokumente
  auf der Docs-Seite hergestellt.
- Weitere Navigationserweiterungen (z.B. feinere Unterpunkte oder zusätzliche
  Reports) bleiben für spätere Patches offen.
"""

    if not text.endswith("\n"):
        text += "\n"
    text = text + "\n" + snippet.lstrip("\n") + "\n"
    path.write_text(text)
    print("✓ DEV-98 update section appended to DEV79 MkDocs nav notes.")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-98] ${timestamp} MkDocs: documented Security & Risk nav in DEV79 MkDocs nav notes." >> "$LOG_FILE"

echo "✓ Log updated at $LOG_FILE"
echo "== DEV98 DOC02: done =="
