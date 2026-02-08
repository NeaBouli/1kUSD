# Error Catalog (v2)
**Status:** Docs. **Audience:** Core devs, SDKs, dApp.
**Updated:** 2026-02-07 (P1 remediation — Rule C compliance)

## Common (shared across modules)
- `ACCESS_DENIED` — caller lacks role/admin
- `PAUSED` — module paused by SafetyAutomata
- `ZERO_ADDRESS` — address parameter is zero
- `INVALID_AMOUNT` — amount == 0 or invalid
- `NOT_IMPLEMENTED` — stub path in skeletons
- `DEADLINE_EXPIRED` — user-provided deadline exceeded

## PSM (PegStabilityModule)
- `PSM_ORACLE_MISSING` — oracle not configured via `setOracle()` **(v0.51.x normative)**
- `PSM_DEADLINE_EXPIRED` — `block.timestamp > deadline` on swap; opt-out with `deadline=0` **(v0.51.x normative)**
- `PausedError` — PSM module paused by SafetyAutomata **(v0.51.x normative)**
- `InsufficientOut` — net output below caller's `minOut` slippage guard **(v0.51.x normative)**
- `UNSUPPORTED_ASSET` — (planned, not enforced in v0.51.x)
- `SLIPPAGE` — (legacy alias, see `InsufficientOut`)
- `INSUFFICIENT_LIQUIDITY` — (legacy, not emitted in v0.51.x)
- Oracle guard surfaces (mapped from ORACLE state): `ORACLE_STALE`, `ORACLE_UNHEALTHY`, `DEVIATION_EXCEEDED`

## CollateralVault
- `NOT_AUTHORIZED` — caller not in `authorizedCallers` and not admin; configure via `setAuthorizedCaller(caller, true)` **(v0.51.x normative)**
- `ASSET_NOT_SUPPORTED` — asset not enabled; configure via `setAssetSupported(asset, true)` **(v0.51.x normative)**
- `INSUFFICIENT_VAULT_BALANCE` — withdraw amount exceeds recorded vault balance **(v0.51.x normative)**
- `PAUSED` — VAULT module paused by SafetyAutomata **(v0.51.x normative)**
- `ACCESS_DENIED` — caller is not admin (for config setters) **(v0.51.x normative)**
- `ZERO_ADDRESS` — zero address passed to setter **(v0.51.x normative)**
- `CAP_EXCEEDED` — (planned for v0.52+)
- `FOT_NOT_SUPPORTED` — fee-on-transfer tokens rejected (planned for v0.52+)

## PSMLimits
- `NOT_AUTHORIZED` — caller not in `authorizedCallers` and not DAO; configure via `setAuthorizedCaller(psm, true)` **(v0.51.x normative)**
- `"swap too large"` — amount exceeds `singleTxCap` or `dailyCap` **(v0.51.x normative)**
- `"not DAO"` — non-DAO caller on `setLimits` or `setAuthorizedCaller` **(v0.51.x normative)**

## FeeRouter
- `NotAuthorized` — caller not in `authorizedCallers` (for `routeToTreasury`) or not admin (for config setters); configure via `setAuthorizedCaller(psm, true)` **(v0.51.x normative)**
- `ZeroAddress` — zero address passed to `setAdmin`, `setAuthorizedCaller`, or `routeToTreasury` **(v0.51.x normative)**
- `ZeroAmount` — zero amount passed to `routeToTreasury` **(v0.51.x normative)**

## OracleWatcher
- `HealthUpdated(Status, uint256)` — event emitted on each `updateHealth()`/`refreshState()` call **(v0.51.x normative)**
  - `Status.Healthy` — oracle operational and not paused
  - `Status.Paused` — `safetyAutomata.isPaused(ORACLE_MODULE)` returned true **(v0.51.x normative)**
  - `Status.Stale` — `oracle.isOperational()` returned false **(v0.51.x normative)**

## BuybackVault
- `BUYBACK_ORACLE_UNHEALTHY` — oracle health gate enforced and module reports unhealthy **(v0.51.x normative)**
- `BUYBACK_TREASURY_CAP_EXCEEDED` — per-operation cap exceeded **(v0.51.x normative)**
- `BUYBACK_TREASURY_WINDOW_CAP_EXCEEDED` — rolling window cap exceeded **(v0.51.x normative)**
- `NOT_DAO` — caller is not DAO **(v0.51.x normative)**
- `NO_STRATEGY_CONFIGURED` — strategies enforced but none defined **(v0.51.x normative)**
- `NO_ENABLED_STRATEGY_FOR_ASSET` — asset not in any enabled strategy **(v0.51.x normative)**

## Token (OneKUSD)
- `INSUFFICIENT_ALLOWANCE`
- `INSUFFICIENT_BALANCE`
- `INVALID_SIGNER` (EIP-2612)
- `DEADLINE_EXPIRED` (EIP-2612)
- `ACCESS_DENIED` — caller not minter/burner/admin

## Governance/Registry/Safety
- `GUARDIAN_EXPIRED` (post-sunset)
- `PARAM_NOT_FOUND` / `PARAM_INVALID` (optional, if implemented)
- `QUEUE_ONLY` (if execution is constrained by policy)

## Mapping to UX
- Display short, user-friendly messages.
- Include remediation hints (e.g., "Increase allowance", "Check paused status", "Oracle unhealthy").
- For `NOT_AUTHORIZED` / `NotAuthorized`: "Contract not whitelisted — admin must call setAuthorizedCaller()".
- For `ASSET_NOT_SUPPORTED`: "Asset not enabled — admin must call setAssetSupported()".
- For `PSM_DEADLINE_EXPIRED`: "Transaction expired — resubmit with a later deadline".
- For `PSM_ORACLE_MISSING`: "Oracle not configured — admin must call setOracle()".
