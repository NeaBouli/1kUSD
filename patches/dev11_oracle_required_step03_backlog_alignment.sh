#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# 1) DEV11_Implementation_Backlog_SolidityTrack_r1.md erweitern
python - << 'PY'
from pathlib import Path

path = Path("docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md")

if not path.exists():
    # Falls das File aus irgendeinem Grund fehlt, legen wir ein minimalistisches Grundgerüst an.
    bootstrap = """# DEV-11 Implementation Backlog – Solidity Track (r1)

Dieses Dokument sammelt die offenen und abgeschlossenen Punkte für die
Solidity-Implementierung im Rahmen von DEV-11 (BuybackVault / Strategy / Safety).

"""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(bootstrap, encoding="utf-8")

text = path.read_text(encoding="utf-8")

marker = "## OracleRequired follow-ups (post-DEV-49)"
if marker in text:
    raise SystemExit("OracleRequired follow-ups block already present, nothing to do")

block = f"""
## OracleRequired follow-ups (post-DEV-49)

Diese Punkte bauen explizit auf DEV-49 (OracleRequired) und den Handshake-Report
DEV11_OracleRequired_Handshake_r1 auf. Sie sind für alle weiteren DEV-11-Phasen
(A02 Enforcement, A03 Window-Caps, Phase B/C Strategy) verbindlicher Rahmen.

- [x] Handshake-Report DEV11_OracleRequired_Handshake_r1 erstellt und im REPORTS_INDEX verlinkt.
- [x] PhaseA-Status-Report mit OracleRequired-Precondition ergänzt (BuybackVault + PSM).
- [ ] A02-Testmatrix erweitern: explizite Coverage für BUYBACK_ORACLE_REQUIRED als harte Precondition
      vor jeder Buyback-Operation (inkl. Negativfälle „kein Oracle“ / „Gate enforced ohne Modul“).
- [ ] A03-Rolling-Window-Tests vorbereiten: zusätzliche Szenarien unter OracleRequired (Window voll,
      Oracle unhealthy, Oracle fehlend) – zunächst als „Nice-to-have“ markiert, siehe Park-Notiz.
- [ ] StrategyEnforcement-Phase(n) im Plan nachziehen: OracleRequired als Root-Check verankern
      (keine „oraclefreien“ Degradationsmodi, kein Fallback auf magische 1.0-Preise).
- [ ] Telemetry-/Monitoring-Backlog prüfen: Reason-Codes BUYBACK_ORACLE_REQUIRED und PSM_ORACLE_MISSING
      als erstklassige Signale in zukünftigen Dashboards/Alerts einplanen.
"""

if not text.endswith("\n"):
    text += "\n"
text += block.lstrip("\n") + "\n"

path.write_text(text, encoding="utf-8")
PY

# 2) Log-Eintrag
echo "[DEV-11] $(date -u +"%Y-%m-%dT%H:%M:%SZ") extend DEV11 implementation backlog with OracleRequired follow-ups (post-DEV-49)" >> logs/project.log

echo "== DEV11 step03: implementation backlog aligned with OracleRequired =="
