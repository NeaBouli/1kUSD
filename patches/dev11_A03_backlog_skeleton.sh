#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-11 A03: append backlog skeleton for rolling window cap =="

# Append A03 backlog skeleton to DEV11 implementation backlog
cat <<'EOB' >> docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md

---

### DEV-11 A03 – Rolling window cap on cumulative buybacks

**Goal:** Limit the *cumulative* buyback volume over a rolling time window (e.g. 24h),
to prevent aggressive drain of the buyback treasury even if single-transaction caps
(DEV-11 A01) are respected.

**Implementation sketch (Solidity track):**

- Add accounting for cumulative buyback volume over a configurable window (e.g. 24h):
  - Track total stable spent for buybacks within the active window.
  - Track window start timestamp and reset / roll forward when the window elapses.
- Introduce DAO-only configuration for:
  - `maxBuybackSharePerWindowBps` (or similar) – percentage of the buyback treasury usable within one window.
  - `buybackWindowSeconds` – window length in seconds (e.g. 86400).
- Enforce the window cap in buyback execution paths:
  - Before executing a buyback, compute the *post-trade* cumulative volume for the current window.
  - If the cap would be exceeded, revert with a dedicated reason / error code and emit a telemetry event.
- Emit indexer-friendly events for:
  - Window cap updates (parameters).
  - Window reset / rollover.
  - Window cap breaches / prevented operations.
- Tests (Foundry):
  - Happy path: multiple buybacks within the window that stay below the cap.
  - Failure path: buyback that would exceed the window cap reverts with the expected reason.
  - Boundary cases:
    - Exactly at the cap.
    - Just after the window elapses (reset / new window).
    - Changing window parameters via DAO while a window is active.
- Non-goals:
  - No changes to core PSM logic.
  - No changes to oracle aggregation or guardian rules beyond using already exposed health / status signals.

EOB

# Append DEV-11 A03 log entry
cat <<'EOL' >> logs/project.log
[DEV-11 A03] Added backlog skeleton for rolling window cap on cumulative buybacks (Solidity track planning only, no contracts changed yet).
EOL

echo "== DEV-11 A03 backlog skeleton done =="
