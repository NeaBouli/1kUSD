#!/usr/bin/env bash
set -euo pipefail

REL_DIR="docs/releases"
REL_FILE="${REL_DIR}/v0.51.0_buybackvault.md"
LOG_FILE="logs/project.log"

echo "== DEV68 REL01: write v0.51.0 BuybackVault release notes =="

mkdir -p "$REL_DIR"

cat <<'MD' > "$REL_FILE"
# 1kUSD v0.51.0 – BuybackVault & Economic Layer consolidation

## Scope

This release consolidates the **Economic Layer** work from v0.50.0 with the new
**BuybackVault** module:

- DEV-60…DEV-67: BuybackVault core, PSM-based execution, safety/guardian gating,
  on-chain events and regression tests.
- Governance & parameter docs wired into the documentation and README.
- Telemetry hooks for BuybackVault documented for the indexer layer.

## Contracts & Modules

- `contracts/core/BuybackVault.sol`
  - Holds treasury 1kUSD (stable) and target asset for buybacks.
  - Enforced **DAO-only** control for funding, withdrawals and buyback execution.
  - Gated by `ISafetyAutomata.isPaused(bytes32 moduleId)` to respect global
    pause rules (Guardian/Safety layer).
  - Executes buybacks via `PegStabilityModule`:
    - Uses `swapFrom1kUSD` to convert 1kUSD to the configured asset.
    - Emits `BuybackExecuted(recipient, stableIn, assetOut)` on success.
  - Additional events:
    - `StableFunded(dao, amount)`
    - `StableWithdrawn(recipient, amount)`
    - `AssetWithdrawn(recipient, amount)`

## Safety & Errors

BuybackVault enforces a strict error model:

- `NOT_DAO()` – any non-DAO caller is rejected for sensitive operations.
- `ZERO_ADDRESS()` – prevents sending funds to the zero address.
- `PAUSED()` – module is paused by Safety/Guardian.
- `INVALID_AMOUNT()` – zero-amount buybacks are rejected.
- `INSUFFICIENT_BALANCE()` – vault does not hold enough stable for the request.

These errors are covered by regression tests in `foundry/test/BuybackVault.t.sol`.

## Tests

Foundry regression coverage (selected):

- `foundry/test/BuybackVault.t.sol:BuybackVaultTest`
  - Constructor guards (zero addresses).
  - DAO-only access for funding, withdrawals and buyback execution.
  - Pause propagation via Safety stub.
  - Event emission tests (topics-based) for:
    - `StableFunded`
    - `StableWithdrawn`
    - `AssetWithdrawn`
    - `BuybackExecuted`
- Economic Layer suites remain green:
  - `PSMRegression_Flows`
  - `PSMRegression_Fees`
  - `PSMRegression_Spreads`
  - `PSMRegression_Limits`
  - `OracleRegression_Health`
  - `OracleRegression_Watcher`

All 63 tests in the Economic Layer + BuybackVault stack are currently passing.

## Documentation

This release wires BuybackVault into the docs:

- Architecture:
  - `docs/architecture/buybackvault_plan.md`
  - `docs/architecture/buybackvault_execution.md`
- Governance & parameters:
  - `docs/governance/parameter_playbook.md`
  - `docs/governance/parameter_howto.md`
- Telemetry:
  - BuybackVault section linked from the main `README.md` pointing to the
    indexer/telemetry specification.

## Intended use

- DAO funds BuybackVault with surplus 1kUSD.
- DAO triggers parameterised buybacks via PSM to support secondary-market
  liquidity and long-term supply management.
- Guardian/Safety layer can pause the module in case of market stress or
  oracle/PSM anomalies.

This release marks **completion of BuybackVault Stage A–C** and prepares the
ground for future extensions (multi-asset support, strategy scheduling,
advanced telemetry and policy-driven buyback rules).
MD

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-68] ${timestamp} Release v0.51.0: BuybackVault Stage A–C (PSM execution, events, telemetry docs) consolidated with Economic Layer." >> "$LOG_FILE"

echo "✓ v0.51.0 BuybackVault release notes written to $REL_FILE"
echo "✓ Log updated at $LOG_FILE"
echo "== DEV68 REL01: done =="
