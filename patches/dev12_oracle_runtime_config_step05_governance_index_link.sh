#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - << 'PY'
from pathlib import Path

path = Path("docs/governance/index.md")
text = path.read_text(encoding="utf-8")

marker = "GOV_OracleRequired_Runtime_Config_Checklist_v051_r1.md"

block = """
## OracleRequired – Runtime configuration checklist (v0.51.x)

- **GOV_OracleRequired_Runtime_Config_Checklist_v051_r1.md** – runtime
  configuration checklist for OracleRequired in v0.51.x. To be used:
  - vor Deployments / größeren Upgrades,
  - vor/nach wichtigen Governance-Entscheidungen,
  - nach Änderungen an Oracle-/Health-Config.
  Stellt sicher, dass:
  - der PSM nie ohne gültigen Oracle-Pricefeed betrieben wird
    (`PSM_ORACLE_MISSING` bleibt ein expliziter Fail-Mode, kein Normalzustand),
  - BuybackVault-Strict-Mode-Buybacks nur mit konfiguriertem und gesundem
    Health-Modul laufen (`BUYBACK_ORACLE_REQUIRED` /
    `BUYBACK_ORACLE_UNHEALTHY` als Schutz, nicht als Dauerzustand).
"""

if marker not in text:
    if not text.endswith("\n"):
        text += "\n"
    text += block.lstrip("\\n") + "\\n"
    path.write_text(text, encoding="utf-8")
    print("OracleRequired runtime config checklist section appended to governance index.")
else:
    print("OracleRequired runtime config checklist section already present; no changes made.")
PY

echo "[DEV-12] $(date -u +"%Y-%m-%dT%H:%M:%SZ") link OracleRequired runtime config checklist from governance index (v0.51)" >> logs/project.log
echo "== DEV-12 step05: governance index updated with OracleRequired runtime config checklist link =="
