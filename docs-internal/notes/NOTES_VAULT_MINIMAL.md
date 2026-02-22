# Vault Minimal Notes (DEV41)
**Scope:** Batch getter for supported assets; `balanceOf` remains dummy (0). No transfers/accounting.

## What changed
- Added `areAssetsSupported(address[]) -> bool[]` to support UIs/SDKs without on-chain iteration assumptions.
- Kept `isAssetSupported(address)` for simple checks.
- No storage of asset lists (no enumeration), avoiding extra state & complexity at this stage.

## Rationale
- Enables dApp/SDK token pickers to validate multiple assets in one call.
- Keeps the minimal surface stable until real accounting is added.
