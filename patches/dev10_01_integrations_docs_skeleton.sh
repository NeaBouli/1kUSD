#!/bin/bash
set -e

echo "== DEV-10 01: create integrations docs skeleton =="

INTEGRATIONS_DIR="docs/integrations"
mkdir -p "$INTEGRATIONS_DIR"

# 1) docs/integrations/index.md
cat <<'EOD' > "${INTEGRATIONS_DIR}/index.md"
# Integrations & Developer Guides (DEV-10)

This section collects integration guides and developer-facing documentation
for the 1kUSD Economic Core.

It is aimed at:

- dApp developers
- wallet / exchange integrators
- off-chain indexer and monitoring teams

## Available / planned guides

- **PSM Integration Guide**  
  How to integrate with the Peg Stability Module (PSM) for swaps, limits and
  fee-aware flows.
  See: `psm_integration_guide.md`

- **Oracle Aggregator Guide**  
  How to read prices, handle stale/diff health checks, and consume oracle data
  safely off-chain.
  See: `oracle_aggregator_guide.md`

- **Guardian & Safety Events**  
  How to observe guardian- and safety-related events and wire alerting /
  monitoring.
  See: `guardian_and_safety_events.md`

- **BuybackVault Observer Guide**  
  How to consume BuybackVault-related events from an observer perspective
  (no governance control).
  See: `buybackvault_observer_guide.md`

For deep architectural details, see the core architecture documents and
governance / status reports in the `docs/architecture/` and `docs/reports/`
sections.
EOD

# 2) docs/integrations/psm_integration_guide.md
cat <<'EOD' > "${INTEGRATIONS_DIR}/psm_integration_guide.md"
# PSM Integration Guide (skeleton)

> Status: DEV-10 skeleton – content to be filled in later.

## 1. Overview

This document will describe how external integrators can safely interact with
the Peg Stability Module (PSM) to swap collateral assets to and from 1kUSD.

It will focus on:

- public contract interfaces (functions / events),
- typical swap flows,
- limits, fees and spreads,
- failure modes and how to handle them off-chain.

## 2. Core functions & events (TODO)

_TODO: List and describe the most relevant public functions and events for
the PSM from an integrator perspective._

## 3. Typical flow: collateral ↔ 1kUSD (TODO)

_TODO: Describe end-to-end example flows (happy path and edge cases) for
swapping collateral assets into 1kUSD and back._

## 4. Integration checklist (TODO)

_TODO: Provide a short checklist for integrators (validation, monitoring,
error handling)._
EOD

# 3) docs/integrations/oracle_aggregator_guide.md
cat <<'EOD' > "${INTEGRATIONS_DIR}/oracle_aggregator_guide.md"
# Oracle Aggregator Integration Guide (skeleton)

> Status: DEV-10 skeleton – content to be filled in later.

## 1. Reading prices

_TODO: Explain how to read prices from the Oracle Aggregator, including the
expected units, decimals and reference assets._

## 2. Health checks: stale / diff (TODO)

_TODO: Describe how the stale and diff checks work conceptually and how
integrators should react when health checks fail._

## 3. Integration patterns (TODO)

_TODO: Provide example patterns for consuming oracle data from off-chain
services, indexers or monitoring systems._
EOD

# 4) docs/integrations/guardian_and_safety_events.md
cat <<'EOD' > "${INTEGRATIONS_DIR}/guardian_and_safety_events.md"
# Guardian & Safety Events Guide (skeleton)

> Status: DEV-10 skeleton – content to be filled in later.

## 1. Key events (TODO)

_TODO: Enumerate and describe the most important guardian / safety /
emergency-related events that external observers should monitor._

## 2. Emergency / pause flows (read-only view) (TODO)

_TODO: Describe how emergency or pause flows are reflected in events and
state, from the perspective of an external observer (no governance control)._

## 3. Wiring alerts (TODO)

_TODO: Provide guidance on how to wire alerts (e.g. via indexer, log
processing, monitoring systems) based on guardian and safety events._
EOD

# 5) docs/integrations/buybackvault_observer_guide.md
cat <<'EOD' > "${INTEGRATIONS_DIR}/buybackvault_observer_guide.md"
# BuybackVault Observer Guide (skeleton)

> Status: DEV-10 skeleton – content to be filled in later.

## 1. What the BuybackVault does (observer view) (TODO)

_TODO: Provide a high-level description of the BuybackVault from the
perspective of an external observer (not a governance actor)._

## 2. Important events to monitor (TODO)

_TODO: List and describe the key events related to BuybackVault funding,
withdrawals and buyback executions._

## 3. Example monitoring use cases (TODO)

_TODO: Provide example scenarios for how an indexer / monitoring stack could
track BuybackVault activity and derive useful metrics._
EOD

# 6) docs/index.md um Integrations-Abschnitt ergänzen (idempotent)
INDEX_FILE="docs/index.md"

if [ ! -f "$INDEX_FILE" ]; then
  echo "docs/index.md not found, aborting."
  exit 1
fi

if grep -q "Integrations & Developer Guides (DEV-10)" "$INDEX_FILE"; then
  echo "Integrations section already present in docs/index.md, nothing to do."
else
  cat <<'EOD' >> "$INDEX_FILE"

---

## Integrations & Developer Guides (DEV-10)

This section is maintained by DEV-10 and focuses on how external builders
integrate with the 1kUSD Economic Core.

- **Integrations index**  
  High-level entry point for all integration-focused documentation.  
  See: `integrations/index.md`

- **Planned guides**  
  - PSM Integration Guide  
  - Oracle Aggregator Integration Guide  
  - Guardian & Safety Events Guide  
  - BuybackVault Observer Guide
EOD
fi

# 7) Log-Eintrag
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-10 01] ${timestamp} Created initial integrations docs skeleton and index" >> "$LOG_FILE"

echo "== DEV-10 01 done =="
