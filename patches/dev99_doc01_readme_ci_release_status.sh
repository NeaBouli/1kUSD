#!/usr/bin/env bash
set -euo pipefail

README="README.md"
LOG_FILE="logs/project.log"

if [ ! -f "$README" ]; then
  echo "ERROR: $README not found. Run from repo root."
  exit 1
fi

# Sicherstellen, dass das Log-File existiert
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

python3 - <<'PY'
from pathlib import Path

path = Path("README.md")
text = path.read_text()

marker = "## CI & Release Status (v0.51.x)"

if marker in text:
    print("CI & Release Status section already present; no change.")
else:
    snippet = """
## CI & Release Status (v0.51.x)

- **Docs Build CI**
  - Workflow: \`.github/workflows/docs-build.yml\`
  - Aktion: \`mkdocs build\` auf \`push\` / \`pull_request\` nach \`main\`.
  - Sichtbar über den \"Docs Build\"-Badge im \`README.md\`.

- **Release Status Check (v0.51.x-Tags)**
  - Workflow: \`.github/workflows/release-status.yml\`
  - Trigger: \`push\` auf Tags vom Muster \`v0.51.*\`.
  - Führt \`scripts/check_release_status.sh\` aus, das sicherstellt, dass zentrale
    Status-/Report-Dateien existieren und nicht leer sind:
    - \`docs/reports/PROJECT_STATUS_EconomicLayer_v051.md\`
    - \`docs/reports/DEV60-72_BuybackVault_EconomicLayer.md\`
    - \`docs/reports/DEV74-76_StrategyEnforcement_Report.md\`
    - \`docs/reports/DEV87_Governance_Handover_v051.md\`
    - \`docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md\`
    - \`docs/reports/DEV93_CI_Docs_Build_Report.md\`.

- **Manueller Release-Flow**
  - Release-Tags für \`v0.51.x\` werden bewusst **manuell** gesetzt.
  - Vor einem Tag kann lokal \`scripts/check_release_status.sh\` ausgeführt werden.
  - Details siehe:
    - \`docs/logs/RELEASE_TAGGING_GUIDE_v0.51.x.md\`
    - \`docs/reports/DEV93_CI_Docs_Build_Report.md\`
    - \`docs/reports/DEV94_Release_Status_Workflow_Report.md\`.
"""

    lines = text.splitlines(keepends=True)
    insert_idx = None

    # Versuche, nach einem Security-/Risk-Block einzuhängen, falls vorhanden
    for i, line in enumerate(lines):
        if "## Security & Risk" in line:
            insert_idx = i + 1
            break

    if insert_idx is None:
        # Fallback: am Ende anhängen
        new_text = text.rstrip() + "\n\n" + snippet.lstrip("\n") + "\n"
        print("Appended CI & Release Status section at end of README.")
    else:
        lines.insert(insert_idx, "\n" + snippet.lstrip("\n") + "\n")
        new_text = "".join(lines)
        print(f"Inserted CI & Release Status section after line {insert_idx}.")

    path.write_text(new_text)
PY

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-99] ${timestamp} README: added CI & Release Status section (v0.51.x)." >> "$LOG_FILE"

echo "✓ README CI & Release Status section updated"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV99 DOC01: done =="
