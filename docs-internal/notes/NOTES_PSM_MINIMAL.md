# PSM Minimal Notes (DEV40)
**Scope:** Token whitelist + dummy quotes. No economic logic, no transfers, no mint/burn.

## What changed
- Added `setSupportedToken(asset,bool)` and `isSupportedToken(asset)` in PSM.
- `quoteTo1kUSD/quoteFrom1kUSD` now return `(amountIn, 0, amountIn)` if `asset` is supported, else revert `UNSUPPORTED_ASSET`.
- `swap*` functions remain `NOT_IMPLEMENTED`.

## Rationale
- Unblocks dApp/SDK integration and status pages without exposing unfinished mint/burn.
- Keeps safety invariant: no state changes, no funds movement at this stage.
