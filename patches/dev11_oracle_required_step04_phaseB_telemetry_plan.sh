#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PY'
from pathlib import Path

path = Path("docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md")

if not path.exists():
    # Minimaler Fallback, falls das File umbenannt/verschoben wurde
    bootstrap = """# DEV-11 Phase B – Telemetry & Test Plan (r1)

Dieses Dokument beschreibt die Telemetrie-, Logging- und Alerting-Strategie für
BuybackVault, PSM und Oracle-Layer im Rahmen von DEV-11 Phase B.
"""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(bootstrap, encoding="utf-8")

text = path.read_text(encoding="utf-8")

marker = "## OracleRequired telemetry and alerts"
if marker in text:
    raise SystemExit("OracleRequired telemetry block already present, nothing to do")

block = f"""
## OracleRequired telemetry and alerts

DEV-49 hebt Oracles explizit auf die Root-Safety-Ebene. Für Phase B gilt daher:

> **Kein Oracle ⇒ kein legaler Betrieb von PSM und BuybackVault.**

Die Telemetrie muss diese Tatsache explizit und priorisiert abbilden.

### Beobachtete Reason Codes (erste Klasse)

Folgende Reason Codes sind für Telemetrie und Alerting als **erstklassige Signale**
zu behandeln:

- `BUYBACK_ORACLE_REQUIRED`  
  → BuybackVault Strict Mode fordert ein Health-Modul, aber kein Oracle-Health-Gate
    ist konfiguriert. Systemzustand ist *illegal*, nicht nur „suboptimal“.
- `BUYBACK_ORACLE_UNHEALTHY`  
  → Oracle ist gesetzt, aber als ungesund markiert (Health-Gate schlägt an).
- `PSM_ORACLE_MISSING`  
  → PSM ist aktiv, aber kein Oracle gesetzt. Jeder Flow (Mint/Redeem) muss hart
    revertieren, bis ein Oracle vorhanden ist.

Diese Signale sind in späteren Dashboards (Indexer/Observer) als eigenständige
Statusflächen zu führen, nicht nur als „normale Fehler“.

### Invarianten für Telemetrie-Auswertung

Für die Telemetrie-Auswertung gelten u. a. folgende Invarianten:

1. **Kein PSM-Flow ohne Oracle**  
   - Jede Beobachtung eines PSM-Swaps bei gleichzeitig fehlendem Oracle wäre ein
     harter Architekturbruch und muss als „critical bug“ gewertet werden.
2. **Kein Buyback ohne Oracle-Gate im Strict Mode**  
   - Wenn `oracleHealthGateEnforced == true` und `healthModule == address(0)` ist,
     muss jeder Buyback mit `BUYBACK_ORACLE_REQUIRED` scheitern.
3. **Keine „stillen Degradationsmodi“**  
   - Es darf keinen Modus geben, in dem die Telemetrie „ok“ zeigt, obwohl einer
     der oben genannten Reason Codes aktiv ist.

### Testplan-Erweiterung für Phase B

Phase B soll sicherstellen, dass Telemetrie und Monitoring diese
OracleRequired-Semantik korrekt widerspiegeln. Beispielsweise:

- Simulation eines Buybacks ohne konfiguriertes Oracle-Gate  
  → Erwartet: Revert mit `BUYBACK_ORACLE_REQUIRED`, Telemetrie-Event / Log-Record
    mit diesem Reason Code.
- Simulation eines PSM-Mints ohne Oracle  
  → Erwartet: Revert mit `PSM_ORACLE_MISSING`, Telemetrie-Event / Log-Record mit
    diesem Reason Code.
- Simulation eines „normalen“ Betriebs mit gesundem Oracle  
  → Erwartet: keine OracleRequired-Reason Codes im normalen Steady-State, nur
    im Fehler- oder Umschaltfall (Pause/Unpause, Config-Änderungen).

Diese Punkte sind als verbindlicher Rahmen für künftige Indexer- und
Observer-Implementierungen zu verstehen. Spätere DEV-Phasen (StrategyEnforcement,
UI/Operator-Dashboards) bauen auf derselben Semantik auf.
"""

if not text.endswith("\n"):
    text += "\n"
text += block.lstrip("\n") + "\n"

path.write_text(text, encoding="utf-8")
PY

echo "[DEV-11] $(date -u +"%Y-%m-%dT%H:%M:%SZ") extend PhaseB telemetry test plan with OracleRequired signals and invariants" >> logs/project.log

echo "== DEV11 step04: PhaseB telemetry/test plan extended with OracleRequired =="
