# Attack Trees — Compact
**Status:** Spec (no code). **Language:** EN.

## A) Steal Vault Funds
Goal → Move assets out of Vault
 ├─ Bypass Vault auth (withdraw) [blocked: Timelock-only path]
 ├─ Reentrancy via PSM deposit/withdraw [blocked: CEI + nonReentrant]
 ├─ Decimal/fee-on-transfer trick to drain [mitigate: normalization + adapters]
 └─ Governance spend abuse [blocked: Timelock delay + approvals + buffer policy]

## B) Inflate 1kUSD Supply
Goal → Mint without matching collateral
 ├─ Mint path other than PSM [blocked: ROLE_MINTER only modules]
 ├─ Oracle manipulation to overmint [mitigate: sanity, deviation, pause]
 └─ Rate-limit bypass for flood mint [mitigate: shared limiter]

## C) Break Peg (>1%)
Goal → Sustained deviation
 ├─ Oracle stale/deviation [mitigate: guards + pause mint]
 ├─ Liquidity starvation in Vault [mitigate: caps rebalancing; fees]
 └─ UI/RPC outage [mitigate: multi-RPC; degraded mode; arbitrage via PSM remains]
