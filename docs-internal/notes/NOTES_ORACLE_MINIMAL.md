# Oracle Minimal Notes (DEV42)
**Scope:** Admin-gated mock prices for dev/staging; no real aggregation.

## What changed
- Added storage `mapping(address => Price) _mockPrice`.
- Added `setPriceMock(asset, price, decimals, healthy)` (onlyAdmin, notPaused).
- `getPrice(asset)` returns the stored mock, default zero struct if unset.

## Operational Guidance
- **Do not use on mainnet**. Replace with real aggregators (Chainlink/Pyth/TWAP).
- For dev/staging scripts, set mocks at deploy time to unblock flows (PSM quotes, UI).
- Keep `healthy=false` to simulate oracle-down scenarios during drills.

## Next steps
- Implement adapter policy & median/trimmed-mean per `ORACLE_AGGREGATOR_SPEC.md`.
