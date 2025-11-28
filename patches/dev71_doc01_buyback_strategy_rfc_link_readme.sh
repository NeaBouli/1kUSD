#!/usr/bin/env bash
set -euo pipefail

FILE="README.md"
LOG_FILE="logs/project.log"

echo "== DEV71 DOC01: link BuybackVault Strategy RFC from README =="

python3 - <<'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text()

snippet = """### BuybackVault Strategy RFC (DEV-71)

- Forward-Design für zukünftige Buyback-Strategien (Multi-Asset, Policy-Module).
- Dokumentiert in: `docs/architecture/buybackvault_strategy_rfc.md`
  (Baseline v0.51.0, Design-Entwurf für v0.52+).

"""

# Wenn der Link schon existiert, nichts tun (idempotent)
if "buybackvault_strategy_rfc.md" in text:
    print("Strategy RFC link already present in README; no change.")
else:
    lines = text.splitlines(keepends=True)
    insert_index = None

    # Versuche, eine sinnvolle Stelle zu finden (erste Referenz zu BuybackVault oder Economic Layer)
    for i, line in enumerate(lines):
        if "BuybackVault" in line or "Economic Layer" in line:
            insert_index = i + 1
            break

    if insert_index is None:
        # Keine passende Stelle gefunden → am Ende anhängen
        print("No BuybackVault/Economic Layer section found; appending snippet at end of README.")
        if not text.endswith("\n"):
            text += "\n"
        text = text + "\n" + snippet + "\n"
    else:
        print(f"Inserting Strategy RFC snippet after line {insert_index}.")
        lines.insert(insert_index, "\n" + snippet + "\n")
        text = "".join(lines)

    path.write_text(text)
    print("✓ Strategy RFC snippet written/updated in README.md")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-71] ${timestamp} README: linked BuybackVault Strategy RFC (docs/architecture/buybackvault_strategy_rfc.md)." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV71 DOC01: done =="
