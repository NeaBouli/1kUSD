#!/bin/bash
set -e

echo "== DEV-9 32: add Foundry CI cache & matrix plan (docs-only) =="

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

# 1) Abschnitt im Foundry CI Plan ergänzen
if grep -q "Foundry CI – cache & matrix plan (DEV-9 32" "$FOUND_CI_PLAN"; then
  echo "Foundry CI cache & matrix plan section already present, nothing to do."
else
  cat <<'EOD' >> "$FOUND_CI_PLAN"

---

## Foundry CI – cache & matrix plan (DEV-9 32, docs-only)

This section defines how DEV-9 intends to evolve Foundry-related CI
(cache and matrix behaviour) **without** changing workflows yet.

### Goals

- keep test runtimes reasonable and predictable,
- avoid flakiness due to toolchain drift or inconsistent caching,
- minimise redundant jobs while preserving useful coverage,
- keep the setup easy to understand for future DEV roles and auditors.

### Current state (r2)

- A canonical Foundry toolchain version is defined in:
  - `.github/workflows/foundry.yml`
- Other workflows using `foundry-rs/foundry-toolchain` are pinned to the same
  version via:
  - `patches/dev9_30_foundry_version_rollout.sh`
- Caching and matrix definitions are still in their original, pre-hardening
  state.

### Planned approach (future DEV-9 tickets)

1. **Cache strategy (docs first)**

   DEV-9 will:

   - document which directories/files are candidates for caching
     (e.g. toolchain installs, build artefacts, test outputs),
   - define simple rules for when cache keys should change
     (e.g. Foundry version bumps, major dependency changes),
   - ensure that any future cache configuration is:
     - deterministic,
     - easy to invalidate,
     - clearly tied to the canonical Foundry version.

   No cache-related YAML changes are active yet.

2. **Matrix simplification**

   DEV-9 will:

   - review existing Foundry-related jobs and matrices,
   - identify redundant or overlapping combinations,
   - propose a reduced set that still covers:
     - mainnet-style scenarios,
     - regression suites,
     - BuybackVault strategy guard specifics.

   Any reduction will be documented first, then implemented in a dedicated
   DEV-9 ticket (Zone B, with explicit Architect/Owner approval).

3. **Rollout process**

   When changes move beyond documentation:

   - each change will be backed by:
     - a DEV-9 ticket (e.g. DEV-9 3X),
     - an update in `DEV9_Backlog.md`,
     - a short note in `DEV9_Foundry_CI_Plan.md`,
   - YAML changes will be kept minimal and reversible,
   - before/after behaviour will be described in commit messages and reports.

This section is intentionally descriptive only. It does not introduce any
active CI changes beyond what is already live in r2.
EOD
fi

# 2) Backlog-Eintrag ergänzen
if grep -q "DEV-9 32 – Foundry CI cache & matrix plan" "$BACKLOG_FILE"; then
  echo "Backlog entry for DEV-9 32 already present, nothing to do."
else
  cat <<'EOD' >> "$BACKLOG_FILE"

- **DEV-9 32 – Foundry CI cache & matrix plan (docs-only)**
  - Added a documented plan for future Foundry CI cache and matrix tuning
    in `DEV9_Foundry_CI_Plan.md`.
  - No YAML changes yet; any future cache/matrix adjustments will be
    implemented under separate DEV-9 tickets (Zone B) with explicit
    Architect/Owner approval.
EOD
fi

# 3) Log-Eintrag
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 32] ${timestamp} Added Foundry CI cache & matrix plan to DEV9_Foundry_CI_Plan.md and DEV9_Backlog.md" >> "$LOG_FILE"

echo "== DEV-9 32 done =="
