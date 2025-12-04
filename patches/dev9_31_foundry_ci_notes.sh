#!/bin/bash
set -e

echo "== DEV-9 31: document Foundry version rollout in DEV9 docs =="

FOUND_CI_PLAN="docs/dev/DEV9_Foundry_CI_Plan.md"
BACKLOG_FILE="docs/dev/DEV9_Backlog.md"
LOG_FILE="logs/project.log"

if [ ! -f "$FOUND_CI_PLAN" ]; then
  echo "File $FOUND_CI_PLAN not found, aborting."
  exit 1
fi

if [ ! -f "$BACKLOG_FILE" ]; then
  echo "File $BACKLOG_FILE not found, aborting."
  exit 1
fi

# 1) Abschnitt in DEV9_Foundry_CI_Plan.md anhängen (falls noch nicht vorhanden)
if grep -q "DEV-9 30 – Foundry version rollout" "$FOUND_CI_PLAN"; then
  echo "Foundry version rollout section already present in DEV9_Foundry_CI_Plan.md, nothing to do."
else
  cat <<'EOD' >> "$FOUND_CI_PLAN"

---

## DEV-9 30 – Foundry version rollout

To keep Foundry CI behaviour consistent across workflows, DEV-9 30 introduced
a canonical Foundry toolchain version and rolled it out to all relevant
workflows.

**Canonical source:**

- `.github/workflows/foundry.yml`
  - The version configured here is treated as the single source of truth.

**Rollout targets:**

- `.github/workflows/buybackvault-strategy-guard.yml`
- `.github/workflows/forge-ci.yml`
- `.github/workflows/foundry-test.yml`

A helper script (`patches/dev9_30_foundry_version_rollout.sh`) synchronises
the `version:` field in any workflow that uses `foundry-rs/foundry-toolchain`
with the canonical value from `foundry.yml`.

### Operational notes

- When changing the Foundry version, update **only** `foundry.yml` first.
- Then re-run the rollout script to propagate the version to other workflows.
- This keeps CI deterministic and avoids drift between different Foundry-based
  jobs.

Future hardening (e.g. cache tuning, matrix cleanups) should build on this
canonical version model rather than introducing ad-hoc pins.
EOD
fi

# 2) DEV9_Backlog.md "Recent updates" Abschnitt ergänzen
if grep -q "DEV-9 30 – Foundry version rollout" "$BACKLOG_FILE"; then
  echo "Backlog entry for DEV-9 30 already present, nothing to do."
else
  cat <<'EOD' >> "$BACKLOG_FILE"

- **DEV-9 30 – Foundry version rollout**
  - Introduced a canonical Foundry toolchain version in `.github/workflows/foundry.yml`.
  - Rolled this version out to other Foundry-based workflows
    (`buybackvault-strategy-guard.yml`, `forge-ci.yml`, `foundry-test.yml`)
    via `patches/dev9_30_foundry_version_rollout.sh`.
EOD
fi

# 3) Log-Eintrag
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 31] ${timestamp} Documented Foundry version rollout in DEV9_Foundry_CI_Plan.md and DEV9_Backlog.md" >> "$LOG_FILE"

echo "== DEV-9 31 done =="
