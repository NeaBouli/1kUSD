#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/psm_dev43-45.md"

echo "== DEV48 DOC02: append DEV-47/48 decimals+fee registry section to PSM architecture doc =="

cat <<'EOL' >> "$FILE"

---

## DEV-47–48: Dezimal- und Fee-Parameter via ParameterRegistry

### DEV-47: Token-Decimals über Registry

- Einführung eines Registry-gestützten Decimals-Lookups im `PegStabilityModule`:
  - Konstante: `KEY_TOKEN_DECIMALS = keccak256("psm:tokenDecimals")`.
  - Helper: `_tokenDecimalsKey(address token)` → `keccak256(abi.encode(KEY_TOKEN_DECIMALS, token))`.
  - `_getTokenDecimals(address token)` liest:
    1. `registry.getUint(_tokenDecimalsKey(token))` (token-spezifisch),
    2. bei `0` oder fehlender Registry Fallback auf `18`.
  - Hardcoded `uint8 tokenInDecimals = 18;` / `tokenOutDecimals = 18;` wurden ersetzt durch `_getTokenDecimals(tokenIn)` bzw. `_getTokenDecimals(tokenOut)`.

- Guardian-/Unpause-Tests:
  - `Guardian_PSMUnpause` konstruiert den PSM bewusst mit `registry = address(0)`.
  - Damit greift der 18-Decimals-Fallback und der bestehende Guardian-Flow bleibt unverändert, trotz Registry-Integration.

### DEV-48: Fee-Konfiguration über ParameterRegistry

- Neue Konstanten im PSM:
  - `KEY_MINT_FEE_BPS   = keccak256("psm:mintFeeBps")`
  - `KEY_REDEEM_FEE_BPS = keccak256("psm:redeemFeeBps")`
- Token-spezifische Keys:
  - `_mintFeeKey(token) = keccak256(abi.encode(KEY_MINT_FEE_BPS, token))`
  - `_redeemFeeKey(token) = keccak256(abi.encode(KEY_REDEEM_FEE_BPS, token))`

- Fee-Resolver:
  - `_getMintFeeBps(token)`:
    1. Wenn `registry != address(0)`:
       - zuerst token-spezifischer Wert via `_mintFeeKey(token)`,
       - falls `0`: globaler Wert via `KEY_MINT_FEE_BPS`,
       - wenn > 0: `require(raw <= 10_000, "PSM: bad mintFeeBps");` → Rückgabe als `uint16`.
    2. Fallback: lokale Storage-Variable `mintFeeBps` mit gleicher 10_000-Boundary.
  - `_getRedeemFeeBps(token)` analog mit `KEY_REDEEM_FEE_BPS` und `redeemFeeBps`.

- Verwendung in den Swaps:
  - `swapTo1kUSD`:
    - vorher: `_computeSwapTo1kUSD(..., uint16(mintFeeBps), ...)`
    - jetzt: `_computeSwapTo1kUSD(..., _getMintFeeBps(tokenIn), ...)`
  - `swapFrom1kUSD`:
    - vorher: `_computeSwapFrom1kUSD(..., uint16(redeemFeeBps), ...)`
    - jetzt: `_computeSwapFrom1kUSD(..., _getRedeemFeeBps(tokenOut), ...)`

- Wichtiges Invarianz-Design:
  - `0` im Registry-Eintrag bedeutet „nicht gesetzt“, **nicht** „0 bps erzwingen“.
  - Effektive Reihenfolge:
    1. Per-Token-Entry (Registry),
    2. globaler Entry (Registry),
    3. lokales `mintFeeBps`/`redeemFeeBps` im PSM-Storage.
  - Alle Pfade enforce `<= 10_000` (max. 100 % Fee).

### DEV-48: Regression-Tests `PSMRegression_Fees`

Neue Suite: `foundry/test/psm/PSMRegression_Fees.t.sol`

- Setup:
  - Realer `OneKUSD`, `ParameterRegistry`, `MockERC20` als Collateral und `MockCollateralVault`.
  - PSM mit:
    - echtem Vault,
    - Registry,
    - `SafetyAutomata = address(0)` und Oracle-Fallback (Preis 1.0).
  - DAO setzt `setMinter`/`setBurner`, User erhält 1_000 COL und erlaubt PSM den Transfer.

- Tests:

1. **`testMintUsesGlobalRegistryFee`**
   - DAO setzt `KEY_MINT_FEE_BPS = 100` (1 % global).
   - Swap: `amountIn = 1_000e18`, 1:1-Preis.
   - Erwartung:
     - `gross = 1_000e18`,
     - `fee = 1 % = 10e18`,
     - `net = 990e18`.
   - Invarianten:
     - Rückgabewert von `swapTo1kUSD` == `net`.
     - `Δ balanceOf(user)` == `net`.
     - `Δ totalSupply(1kUSD)` == `net`.

2. **`testMintPerTokenOverrideBeatsGlobal`**
   - DAO setzt:
     - global `KEY_MINT_FEE_BPS = 100` (1 %),
     - token-spezifisch `_mintFeeKey(COL) = 200` (2 %).
   - Swap: `amountIn = 1_000e18`.
   - Erwartung:
     - Effektive Fee = 2 %; Rückgabewert == `980e18`.
   - Verifiziert, dass der token-spezifische Entry den globalen überschreibt.

3. **`testRedeemUsesGlobalRegistryFee`**
   - DAO setzt `KEY_REDEEM_FEE_BPS = 100` (1 % global Redeem-Fee).
   - DAO ruft `psm.setFees(0, 0)`, um lokale Storage-Fees explizit zu neutralisieren.
   - Phase 1 (Mint, Fee = 0):
     - User swapped 1_000e18 COL → ~1_000e18 1kUSD (nur zum Befüllen).
   - Phase 2 (Redeem, Fee = 1 % global via Registry):
     - User swapped `minted` 1kUSD → COL.
     - Erwartung:
       - `expectedGross = minted`,
       - `expectedFee1k = 1 %`,
       - `expectedNetTokenOut = expectedGross - expectedFee1k`.
     - Invarianten:
       - Rückgabewert von `swapFrom1kUSD` == `expectedNetTokenOut`.
       - `Δ CollateralBalance(user)` == `expectedNetTokenOut`.

### Gesamtstatus nach DEV-48

- PSM-Architektur unterstützt nun:
  - **Preis-Notional-Layer** (DEV-44),
  - **reale Token-/Vault-Flows** inkl. Redeem (DEV-45/46),
  - **token-spezifische Decimals via ParameterRegistry** (DEV-47),
  - **globale + token-spezifische Fees via ParameterRegistry** mit sicherem Fallback (DEV-48).
- Guardian- und Safety-Pfade bleiben voll funktionsfähig.
- Alle PSM-Regression-Suiten (`Flows`, `Limits`, `Fees`) sind grün und bilden einen auditierbaren Rahmen für weitere ökonomische Features.

EOL

echo "✓ DEV-47/48 decimals+fees section appended to $FILE"
