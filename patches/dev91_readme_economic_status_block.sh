#!/usr/bin/env bash
set -euo pipefail

echo "== DEV91 DOC01: add Economic Layer + StrategyEnforcement status block to README =="

README="README.md"
LOG_FILE="logs/project.log"

if [ ! -f "$README" ]; then
  echo "ERROR: $README not found" >&2
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text()

marker = "### Economic Layer status (v0.51.0 + StrategyEnforcement Phase-1 preview)"

if marker in text:
    print("Status block already present; no change.")
else:
    snippet = """### Economic Layer status (v0.51.0 + StrategyEnforcement Phase-1 preview)

- **Baseline**: Economic Layer v0.51.0 (PSM, Oracles, Guardian, BuybackVault) is stable and green.
- **Strategy layer**: BuybackVault strategy config is live; StrategyEnforcement Phase-1 guard is implemented but **opt-in** via the `strategiesEnforced` flag.
- **Behaviour**: As long as `strategiesEnforced == false`, runtime behaviour remains identical to the v0.51.0 baseline.
- **Docs / reports**:
  - \`docs/reports/PROJECT_STATUS_EconomicLayer_v051.md\`
  - \`docs/reports/DEV60-72_BuybackVault_EconomicLayer.md\`
  - \`docs/reports/DEV74-76_StrategyEnforcement_Report.md\`

Enabling StrategyEnforcement is a DAO/governance decision and should be coupled with monitoring (indexer dashboards) and an explicit parameter decision.
"""

    lines = text.splitlines(keepends=True)
    insert_idx = None

    # Bevorzugt: direkt vor der "Security & Risk"-Sektion einfügen
    for i, line in enumerate(lines):
        if "## Security & Risk" in line:
            insert_idx = i
            break

    if insert_idx is None:
        print("Anchor '## Security & Risk' not found; appending status block at end of README.")
        if not text.endswith("\n"):
            text += "\n"
        text = text + "\n" + snippet + "\n"
    else:
        print(f"Inserting status block before line {insert_idx} (Security & Risk section).")
        lines.insert(insert_idx, "\n" + snippet + "\n")
        text = "".join(lines)

    path.write_text(text)
    print("✓ Economic Layer status block added to README.md")
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-91] ${timestamp} Docs: add Economic Layer + StrategyEnforcement status block to README." >> "$LOG_FILE"

echo "✓ Log updated at $LOG_FILE"
echo "== DEV91 DOC01: done =="
