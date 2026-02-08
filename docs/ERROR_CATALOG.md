# Error Catalog (v1)
**Status:** Docs. **Audience:** Core devs, SDKs, dApp.

## Common (shared across modules)
- `ACCESS_DENIED` — caller lacks role/admin
- `PAUSED` — module paused by SafetyAutomata
- `ZERO_ADDRESS` — address parameter is zero
- `INVALID_AMOUNT` — amount == 0 or invalid
- `NOT_IMPLEMENTED` — stub path in skeletons
- `DEADLINE_EXPIRED` — user-provided deadline exceeded

## PSM
- `UNSUPPORTED_ASSET`
- `SLIPPAGE`
- `INSUFFICIENT_LIQUIDITY`
- Oracle guard surfaces (mapped from ORACLE state): `ORACLE_STALE`, `ORACLE_UNHEALTHY`, `DEVIATION_EXCEEDED`

## Vault
- `ASSET_NOT_SUPPORTED`
- `CAP_EXCEEDED`
- `INSUFFICIENT_BALANCE`
- `FOT_NOT_SUPPORTED` (fee-on-transfer tokens rejected)

## Token (OneKUSD)
- `INSUFFICIENT_ALLOWANCE`
- `INSUFFICIENT_BALANCE`
- `INVALID_SIGNER` (EIP-2612)
- `DEADLINE_EXPIRED` (EIP-2612)

## Governance/Registry/Safety
- `GUARDIAN_EXPIRED` (post-sunset)
- `PARAM_NOT_FOUND` / `PARAM_INVALID` (optional, if implemented)
- `QUEUE_ONLY` (if execution is constrained by policy)

## Mapping to UX
- Display short, user-friendly messages.
- Include remediation hints (e.g., “Increase allowance”, “Check paused status”, “Oracle unhealthy”).
