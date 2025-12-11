#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

REPORT="docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md"

if [ ! -f "$REPORT" ]; then
  echo "report $REPORT not found" >&2
  exit 1
fi

python - << 'PY'
from pathlib import Path

path = Path("docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md")
text = path.read_text(encoding="utf-8")

anchor = "## OracleRequired – Handshake mit DEV-49"

if anchor in text:
    raise SystemExit("OracleRequired section already present, nothing to do")

snippet = f"""

{anchor}

Kurzfassung:

- DEV-49 hebt das Oracle-Thema von „optional/nice to have“ auf eine harte Systeminvariante.
- DEV-11 Phase A/B baut ab jetzt explizit auf dieser Bedingung auf (BuybackVault A02/A03, PSM-Flows).
- OracleRequired ist damit fester Teil der Sicherheitsannahmen von Phase A (A01–A03) und der folgenden Phasen.
- Details siehe:
  - ARCHITECT_BULLETIN_OracleRequired_Impact_v2
  - DEV11_OracleRequired_Handshake_r1
"""

path.write_text(text.rstrip() + snippet + "\n", encoding="utf-8")
PY

echo "[DEV-11] $(date -u +"%Y-%m-%dT%H:%M:%SZ") extend DEV11 PhaseA status with OracleRequired alignment note" >> logs/project.log

echo "== DEV11 step02: PhaseA status extended with OracleRequired note =="
