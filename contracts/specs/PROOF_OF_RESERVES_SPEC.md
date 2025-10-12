# Proof of Reserves (PoR) — Views & Reconciliation

**Scope:** Public views and indexer-facing rules to verify that circulating 1kUSD is backed by on-chain reserves.  
**Status:** Spec (no code). **Language:** EN.

---

## 1. Objectives
- Provide deterministic, on-chain **views** for reserve amounts per asset and totals.
- Define **reconciliation rules** between on-chain events and indexer aggregates.
- Convey **finality & staleness** hints for off-chain consumers.

---

## 2. On-Chain Views (Read-Only)
- `getReserveAssets() -> address[]` (approved assets)
- `getRawBalance(asset) -> uint256` (token decimals)
- `getNormalizedBalance(asset) -> uint256` (18 decimals)
- `getTotalNormalized() -> uint256` (sum of all assets, 18 decimals)
- `getTotalUSD() -> string` *(optional view using Oracle median; advisory only)*
- `getLastUpdate(asset) -> uint256` (last deposit/withdraw timestamp per asset)

**Notes:** USD conversion uses OracleAggregator median/decimals; consumers must handle staleness/deviation.

---

## 3. Event-Driven Reconciliation
Indexers reconstruct balances by folding events in block order:
1. Start at 0 for each `asset`.
2. For `Deposit` and `SystemDeposit`: add `amount`.
3. For `Withdraw`: subtract `amount`.
4. Cross-check against `getRawBalance(asset)` per block or at fixed intervals.

**Drift handling:** if indexer balance != contract `getRawBalance(asset)`, mark **reconciliation required** and refetch from chain state.

---

## 4. Finality & Staleness
- Provide `finalityMark` out-of-band (indexer) or `lastUpdate(asset)` for each asset.
- Consumers should treat PoR as **safe** only when:
  - Oracle data within `maxAgeSec`, and
  - indexer has seen `k` confirmations (chain-policy dependent).

---

## 5. Supply vs Reserves Check
Define a public helper (off-chain or view) for dashboards:
- `getCoverageRatio() -> { totalUSD, supply, ratioBps }`
  - `supply` from 1kUSD token totalSupply (18 decimals).
  - `totalUSD` from normalized balances × oracle USD prices.
  - `ratioBps = floor(totalUSD / supply * 10000)`.

**Policy:** Alerts if `ratioBps < 10000` (undercoverage) or if any single asset exceeds its cap.

---

## 6. Error & Edge Cases
- `ASSET_UNKNOWN` (queried asset not approved)
- Decimals change on token contract (should revert and require governance action)
- Oracle stale or deviating — PoR returns still valid in native units; USD view flagged with health=false.

---

## 7. Telemetry
Expose counters for:
- `reservesUpdated{asset}` (on Deposit/Withdraw)
- `reconciliations{ok,drift}`
- `oracleHealth{ok,stale,deviating}` (from OracleAggregator)

---

## 8. Testing Guidance
- Deterministic replay of event streams vs. contract balances.
- Simulate reorgs: ensure idempotence after re-fetching from canonical chain.
- Cross-asset decimal diversity (6/18) in sums and USD conversion precision.
