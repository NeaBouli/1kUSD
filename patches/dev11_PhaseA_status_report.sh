#!/usr/bin/env bash
set -euo pipefail

# Run from repo root
cd "$(dirname "$0")/.."

echo "== DEV-11 Phase A: adding buyback safety status report =="

# 1) Phase-A Status Report anlegen
cat <<'DOC' > docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md
# DEV-11 Phase A – Buyback Safety Status (A01–A03)

> Scope: This document summarizes the Phase A work of DEV-11 on the BuybackVault
> (A01 Per-Op Cap, A02 Oracle/Health Gate, A03 Rolling Window Cap) and how it
> fits into the Economic Layer v0.51 safety architecture.

## 1. Scope & Objectives

Phase A of DEV-11 focuses on strengthening the treasury safety around buybacks
without breaking the existing Economic Layer v0.51 behaviour.

The objectives were:

- Add a **per-operation cap** on treasury usage (A01).
- Introduce a configurable **oracle/health gate** (A02) that can block buybacks
  when the oracle layer or Guardian reports unhealthy conditions.
- Add a **rolling window cap** (A03) that limits cumulative buybacks over a
  configurable time window.

All three layers are **configurable** and can be set to a neutral mode that
reproduces the v0.51 baseline behaviour.

## 2. Safety Layers in BuybackVault

### 2.1 A01 – Per-Operation Treasury Cap

**Purpose:** Limit the maximum treasury share that can be deployed in a single
buyback operation.

**Key elements:**

- Storage:
  - `uint256 public maxBuybackSharePerOpBps;`  
    (basis points relative to the reference treasury value)
- Governance:
  - DAO-only setter with bounds checks and event.
- Enforcement:
  - Applied in both buyback paths:
    - `executeBuybackPSM(...)`
    - `executeBuyback(...)`
  - If the operation would exceed the configured per-op share:
    - Revert with `BuybackPerOpTreasuryCapExceeded()`.

**Testing:**

- Setter bounds and DAO-only access.
- Buyback within cap succeeds.
- Buyback above cap reverts.
- Regression tests ensure legacy flows remain intact when the cap is neutral.

### 2.2 A02 – Oracle / Health Gate

**Purpose:** Prevent buybacks when the oracle / Guardian stack reports an
unhealthy state, while remaining **configurable** and backwards compatible.

**Key elements:**

- Central hook:
  - Private function `_checkOracleHealthGate()` called from both buyback paths.
- Configuration:
  - Module address for oracle/health evaluation.
  - Enforcement flag that controls whether the gate is active or passive.
- Behaviour:
  - In *legacy / passive* mode, the hook is a no-op (or logs only) and
    buybacks behave as in v0.51.
  - In *strict* mode, the hook queries the external health/oracle module and
    Guardian stop signals:
    - If oracle health is bad → revert with `BUYBACK_ORACLE_UNHEALTHY`.
    - If Guardian has activated a global stop → revert with `BUYBACK_GUARDIAN_STOP`.

**Design constraints:**

- BuybackVault does **not** implement its own oracle logic; it is a consumer of
  the existing oracle/watcher/Guardian stack.
- Enforcement is fully governed by configuration (module + flag), so operators
  can explicitly choose when to turn strict mode on.

### 2.3 A03 – Rolling Window Treasury Cap

**Purpose:** Limit the cumulative treasury share deployed into buybacks over a
configurable time window, protecting against many small operations that sum up
to excessive usage.

**Key elements:**

- Storage:
  - Window start timestamp.
  - Accumulator of treasury usage within the current window.
  - Configurable window duration.
  - Configurable window cap in bps (relative to treasury reference value).
- Accounting:
  - On each buyback:
    - If the current time is outside the active window → reset window start and
      accumulator.
    - Add the effective buyback size to the accumulator.
- Enforcement:
  - If the accumulator would exceed the configured window cap:
    - Revert with a dedicated rolling-window cap violation (see telemetry docs).
- Interaction with A01:
  - A01 limits each individual shot.
  - A03 limits the series of shots over the window duration.

**Testing:**

- Window reset semantics (new day / new window).
- Accumulation and enforcement once the window cap is reached.
- Combined operation with A01 where both caps are respected.

## 3. Configuration Modes & v0.51 Compatibility

A key requirement was that Phase A must **not** silently change behaviour for
existing deployments unless governance explicitly opts in.

### 3.1 Legacy-Compatible Mode

In this mode, the system behaves as close as possible to v0.51:

- Per-op cap:
  - `maxBuybackSharePerOpBps = 0` (or an effectively “unlimited” setting).
- Rolling window:
  - Window cap set to `0` or a configuration that does not bind.
  - Window duration can be left at a neutral value.
- Oracle/health gate:
  - Enforcement flag disabled.
  - Hook acts as a no-op (no additional reverts).

Result:

- Buybacks follow the original v0.51 semantics, with the new layers
  effectively dormant.

### 3.2 Phase-A Strict Mode (Example Concept)

In a strict configuration, governance enables all three safety layers:

- A01:
  - `maxBuybackSharePerOpBps` set to a conservative share per operation.
- A03:
  - Window duration set (e.g. 24h or similar policy-driven interval).
  - Window cap set to a conservative cumulative treasury share.
- A02:
  - Oracle/health module configured and reachable.
  - Enforcement flag turned on so that unhealthy oracle / Guardian stop states
    block buybacks with clear reason codes.

Exact numeric values for these parameters are **governance decisions** and will
be defined in the governance parameter playbook, not in this status report.

## 4. Telemetry & Reason Codes

Phase A introduces and uses reason codes that allow external observers and
indexers to understand why a buyback was prevented.

Examples (see `DEV11_Telemetry_Events_Outline_r1.md` for full details):

- Per-op cap violations (A01).
- Rolling window cap violations (A03).
- Oracle health violations (A02).
- Guardian stop enforced (A02).

These reason codes are emitted via events and can be consumed by monitoring and
indexing infrastructure to:

- Alert operators.
- Explain UI-level error messages.
- Provide audit trails over time.

## 5. Intended Consumers of This Document

This status report is intended for:

- System architects and protocol designers (to see how A01–A03 fit together).
- Governance and risk teams (as high-level reference for parameter decisions).
- Release engineering (to know which safety layers exist in v0.51+).
- Auditors and external reviewers (for a concise overview of Phase A scope).

Detailed parameter recommendations and integration/telemetry guidelines will be
maintained in:

- Governance playbooks (for concrete parameter profiles).
- Integration and indexer guides (for event/telemetry handling).
DOC

# 2) REPORTS_INDEX um den neuen Report ergänzen
python - <<'PYEOF'
from pathlib import Path

path = Path("docs/reports/REPORTS_INDEX.md")
text = path.read_text()

line = "- [DEV-11 Phase A – Buyback Safety Status](DEV11_PhaseA_BuybackSafety_Status_r1.md)\n"

if "DEV-11 Phase A – Buyback Safety Status" not in text:
    text = text.rstrip() + "\n\n" + line
    path.write_text(text)
PYEOF

# 3) Log-Eintrag
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') DEV-11 PhaseA: add buyback safety status report" >> logs/project.log

echo "== DEV-11 Phase A status report written; running mkdocs =="
mkdocs build
echo "== DEV-11 Phase A status report done =="
