#!/usr/bin/env bash
set -euo pipefail

README="README.md"
LOG_FILE="logs/project.log"

echo "== DEV69 ARCH02: link Economic Layer overview from README =="

python3 - <<'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text()

marker = "Economic Layer overview (PSM + Oracle + BuybackVault)"

# Idempotent: falls der Block schon existiert, nichts tun
if marker in text:
    print("Economic Layer overview already linked in README, no change.")
else:
    block = """
### Economic Layer overview (PSM + Oracle + BuybackVault)

For a high-level map of the PSM, Oracle stack, Guardian and BuybackVault modules, see:

- `docs/architecture/economic_layer_overview.md`

"""

    anchor = "BuybackVault telemetry"
    idx = text.find(anchor)
    if idx == -1:
        # Fallback: ans Ende des README anhängen
        if not text.endswith("\n"):
            text += "\n"
        text = text + "\n" + block.lstrip("\n")
        print("✓ Economic Layer overview block appended at end of README.")
    else:
        # Nach der Zeile mit 'BuybackVault telemetry' einfügen
        line_end = text.find("\n", idx)
        if line_end == -1:
            line_end = len(text)
        insert_pos = line_end + 1
        text = text[:insert_pos] + "\n" + block.lstrip("\n") + text[insert_pos:]
        print("✓ Economic Layer overview block inserted after BuybackVault telemetry section.")

    path.write_text(text)
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-69] ${timestamp} README: linked Economic Layer overview doc from root README." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV69 ARCH02: done =="
