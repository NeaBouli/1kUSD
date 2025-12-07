#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# DEV-11 A02: Backlog-Update (Enforcement Status)
cat <<'MD' >> docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md

#### DEV-11 A02 – Enforcement wiring status (Phase A)

- [x] BuybackVault is now wired to an external oracle health module via:
  - `oracleHealthModule` (address) and `oracleHealthGateEnforced` (bool) state.
  - `setOracleHealthGateConfig(address newModule, bool newEnforced)` (DAO-only) with a ZERO_ADDRESS guard when enabling enforcement.
- [x] `_checkOracleHealthGate()` now:
  - short-circuits when `oracleHealthGateEnforced == false` (v0.51 behaviour preserved),
  - otherwise queries the external module and reverts with typed errors mirroring
    `BUYBACK_ORACLE_UNHEALTHY` and `BUYBACK_GUARDIAN_STOP` semantics.
- [ ] Dedicated BuybackVault tests for all enforcement modes (disabled / healthy / unhealthy / guardian-stop) – to be added in a follow-up DEV-11 A02 patch.

MD

# DEV-11 A02: Telemetry-Outline-Update
cat <<'MD' >> docs/dev/DEV11_Telemetry_Events_Outline_r1.md

### DEV-11 A02 – Oracle / Health gate enforcement usage

- The BuybackVault oracle/health gate now actively drives control flow when `oracleHealthGateEnforced == true`.
- On unhealthy oracle state, buybacks revert with the `BUYBACK_ORACLE_UNHEALTHY` reason.
- On guardian stop / global buyback halt, buybacks revert with the `BUYBACK_GUARDIAN_STOP` reason.
- When `oracleHealthGateEnforced == false`, these codes remain dormant and v0.51 behaviour is preserved.

MD

# Log-Eintrag
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ') DEV-11 A02 backlog: document oracle/health gate enforcement status" >> logs/project.log

echo "== DEV-11 A02 backlog enforcement doc update =="
mkdocs build
echo "== DEV-11 A02 backlog enforcement doc done =="
