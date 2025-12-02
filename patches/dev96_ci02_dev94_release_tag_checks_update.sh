#!/usr/bin/env bash
set -euo pipefail

echo "== DEV96 CI02: update DEV94 release tag checks plan with release-status workflow =="

LOG_FILE="logs/project.log"

# Wir aktualisieren beide DEV94-Plan-Dateien, falls vorhanden
FILES=(
  "docs/logs/DEV94_Infra_Release_Tag_Checks_Plan.md"
  "docs/logs/DEV94_Release_Tag_Checks_Plan.md"
)

SNIPPET_MARKER="### Update DEV-96: release-status Workflow umgesetzt"

read_file() {
  local path="$1"
  if [ -f "$path" ]; then
    cat "$path"
    return 0
  else
    return 1
  fi
}

for FILE in "${FILES[@]}"; do
  if [ ! -f "$FILE" ]; then
    echo "Skipping $FILE (not found)."
    continue
  fi

  echo "Processing $FILE ..."

  TEXT="$(read_file "$FILE" || true)"

  if printf '%s' "$TEXT" | grep -q "$SNIPPET_MARKER"; then
    echo "  -> DEV-96 update already present in $FILE; no change."
    continue
  fi

  cat >> "$FILE" <<'MD'

### Update DEV-96: release-status Workflow umgesetzt

- Der Plan für **Release-Tag-Checks** wurde mit **DEV-96** teilweise
  operativ gemacht:
  - Neuer Workflow: `.github/workflows/release-status.yml`
  - Trigger: `push` auf Tags `v0.51.*` und `v0.52.*`
  - Aktion: `scripts/check_release_status.sh`
    - prüft u.a.:
      - `docs/reports/PROJECT_STATUS_EconomicLayer_v051.md`
      - `docs/reports/DEV60-72_BuybackVault_EconomicLayer.md`
      - `docs/reports/DEV74-76_StrategyEnforcement_Report.md`
      - `docs/reports/DEV87_Governance_Handover_v051.md`
      - `docs/reports/DEV89_Dev7_Sync_EconomicLayer_Security.md`
      - `docs/reports/DEV93_CI_Docs_Build_Report.md`
- Damit ist ein erster, praktischer Check für Release-Tags etabliert:
  - Tags werden nur „grün“, wenn die zentralen Status-/Report-Files
    existieren und nicht leer sind.
- Weitere Ausbaustufen aus diesem Plan bleiben bewusst **separate Tickets**:
  - Feiner granulare Checks für künftige Versionen (z.B. v0.53+).
  - Erweiterte Integrationen mit zusätzlichen Reports / neuen Modulen.
MD

  echo "  -> DEV-96 update appended to $FILE"
done

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-96] ${timestamp} CI: documented release-status workflow in DEV94 release tag checks plans." >> "$LOG_FILE"

echo "✓ DEV-96 update written to DEV94 plan files (where present)"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV96 CI02: done =="
