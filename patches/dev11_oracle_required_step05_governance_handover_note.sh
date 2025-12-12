#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PY'
from pathlib import Path

path = Path("docs/reports/DEV87_Governance_Handover_v051.md")
if not path.exists():
    raise SystemExit("DEV87_Governance_Handover_v051.md not found – aborting")

text = path.read_text(encoding="utf-8")

marker = "## OracleRequired (DEV-49) – Governance constraints"
if marker in text:
    raise SystemExit("OracleRequired governance block already present, nothing to do")

block = f"""
## OracleRequired (DEV-49) – Governance constraints

Mit DEV-49 wurde die Oracle-Pflicht als **Root-Safety-Layer** im Protokoll verankert.
Für die Governance (DEV-87) ergeben sich daraus folgende verbindliche Leitplanken:

- **Kein „oraclefreier“ Betrieb**  
  - PSM ohne gesetztes Oracle ist kein legaler Konfigurationszustand.  
    → Erwartetes Verhalten: `PSM_ORACLE_MISSING` und blockierte Swaps.
  - BuybackVault im Strict Mode ohne konfiguriertes Health-Modul ist ebenfalls
    kein legaler Zustand.  
    → Erwartetes Verhalten: `BUYBACK_ORACLE_REQUIRED`.

- **Legacy-Profile nur mit Oracle**  
  - „Legacy“/Kompatibilitäts-Profile dürfen nur verwendet werden, wenn ein Oracle
    existiert und das Gate bewusst deaktiviert ist.
  - „No Oracle + Legacy“ ist als **illegaler Governance-Status** zu dokumentieren
    und in UI/Runbooks zu verbieten.

- **Priorisierung in Runbooks und Operator-Guides**  
  - Reason Codes `BUYBACK_ORACLE_REQUIRED` und `PSM_ORACLE_MISSING` sind als
    erstklassige Signale in zukünftigen Operator-Guides und Dashboards zu
    behandeln (gleichrangig mit Treasury-Caps und Pause-Zuständen).
  - Jede Governance-Änderung an Oracle- oder Gate-Parametern muss explizit in
    den Change-Logs erfasst werden (inkl. Motivation und erwarteter Wirkung).

- **Verknüpfung mit DEV-11**  
  - Alle weiteren DEV-11-Phasen (A02/A03, Phase B/C) bauen auf dieser
    OracleRequired-Semantik auf. Governance-Entscheidungen, die davon abweichen,
    gelten als architektonischer Bruch und müssen im Zweifel verworfen oder
    über einen expliziten „Exception-Prozess“ behandelt werden.

Dieser Abschnitt dient als Brücke zwischen DEV-49 (OracleRequired), DEV-11
(Buyback-/PSM-Safety) und DEV-87 (Governance-Handover v0.51) und macht klar,
dass Oracles ab v0.51 nicht mehr optional, sondern **konstitutiver Bestandteil**
des 1kUSD-Protokolls sind.
"""

if not text.endswith("\\n"):
    text += "\\n"
text += block.lstrip("\\n") + "\\n"

path.write_text(text, encoding="utf-8")
PY

echo "[DEV-11] $(date -u +\"%Y-%m-%dT%H:%M:%SZ\") add OracleRequired governance constraints note to DEV87 handover" >> logs/project.log

echo "== DEV11 step05: governance handover updated with OracleRequired constraints =="
