# PSM Architektur – DEV-43 bis DEV-45

## Rolle des PegStabilityModule

- Kanonische **IPSM-Fassade** für 1kUSD.
- Kapselt:
  - Safety-Gate via `ISafetyAutomata` (Pause/Unpause pro Modul),
  - Limit-Enforcement via `PSMLimits`,
  - Preis-Logik via `IOracleAggregator`,
  - Mint/Burn-Rechte für `OneKUSD`,
  - Vault-Anbindung für Collateral (`CollateralVault` / `MockCollateralVault`),
  - optionale Gebührenweiterleitung via `IFeeRouterV2`.

## DEV-43 – Konsolidierung

- Zusammenführung aller PSM-Funktionalität in **einen** Entry-Point:
  - `PegStabilityModule` implementiert `IPSM` + `IPSMEvents`.
  - SafetyAutomata-Gate (`whenNotPaused`) eingeführt.
  - `PSMLimits` und `IOracleAggregator` als abhängige Komponenten vorbereitet.
- Swap-Logik war noch primitiv; ökonomische Details wurden bewusst für DEV-44/45 reserviert.
- Regression-Skelette (PSMRegression\_*) angelegt.

## DEV-44 – Notional-Layer (Preis-normalisierte 1kUSD-Schicht)

- Einführung einer **preis-normalisierten Notional-Schicht** in 1kUSD (18 Decimals):
  - `_getPrice` holt Preise aus dem `IOracleAggregator`.
  - `_normalizeTo1kUSD` / `_normalizeFrom1kUSD` konvertieren zwischen Token-Units und 1kUSD-Notional.
  - `_computeSwapTo1kUSD` / `_computeSwapFrom1kUSD` berechnen:
    - Brutto-Notional,
    - Fee-Notional,
    - Netto-Notional bzw. Netto-Token-Out.
- `PSMLimits` wird auf **Notional (1kUSD)** angewendet:
  - dailyCap + singleTxCap werden in 1kUSD gemessen.
- `quoteTo1kUSD` / `quoteFrom1kUSD` sind vollständig implementiert.
- Swaps liefern zu diesem Zeitpunkt nur **simulierte** Out-Werte (keine echten Transfers).

## DEV-45 – Reale Token/Vault-Flows + Regression

### Mint-Pfad (`swapTo1kUSD`)

- Aufbauend auf DEV-44-Notional:
  - `safeTransferFrom(user → vault)` für Collateral.
  - `vault.deposit(...)` übernimmt das reine Accounting.
  - `oneKUSD.mint(to, net1k)` mit vorher gesetzten Minter-Rechten.
  - Optionales Gebühren-Routing via `feeRouter.route("PSM_MINT_FEE", address(oneKUSD), fee1k)`.

- Neuer `MockCollateralVault`:
  - `deposit` führt **keinen** zweiten `transferFrom` aus,
  - verwaltet nur `balances[asset]` zur Abbildung des Locked Collateral.

### Regression-Tests

- `PSMRegression_Flows.t.sol`:
  - Testet reale Mint-Flows unter 1:1-Preis Oracle.
  - Invarianten:
    - Δ User-1kUSD-Balance == Rückgabewert von `swapTo1kUSD`.
    - Δ `totalSupply(1kUSD)` == Rückgabewert.
    - Δ Collateral-Lock (PSM + Vault) == `amountIn`.

- `PSMRegression_Limits.t.sol`:
  - SetUp mit realem PSM, `OneKUSD`, `MockCollateralVault`, `ParameterRegistry` und `PSMLimits`.
  - Collateral-Token als `MockERC20` statt Dummy-Adressen.
  - Tests decken ab:
    - singleTxCap-Revert bei zu großem Swap.
    - dailyCap-Revert bei Überschreiten des Tagesvolumens.
    - Reset des dailyCap nach `vm.warp(+1 days)`.

### Teststatus nach DEV-45

- Alle relevanten Suiten grün:
  - PSM-Core, Limits, SwapCore, Regression-Tests, Guardian-/Safety-Tests und Treasury/Router-Platzhalter.
- Insgesamt: **32 Tests, 0 Failures**.

## Offene Aufgaben (Folgeschritte)

- Redeem-Flows (`swapFrom1kUSD`) mit realen Burns & Vault-Withdraws.
- FeeRouter-Assertions und Tests mit nicht-null Fees.
- Dezimal-Integration via `ParameterRegistry` für Collateral mit != 18 Decimals.
- Erweiterte Oracle-Checks (Stale-Detection, Diff-Thresholds).
- Ausführlichere ökonomische Beschreibung (Slippage, Fee-Schedules, etc.).

---

## DEV-46 – Redeem-Flows & Roundtrip-Regression

Mit DEV-46 wurde der PSM von einem „einseitigen“ Mint-Pfad zu einem vollständig bidirektionalen Modul erweitert:

### Redeem-Flow (swapFrom1kUSD)

Der Redeem-Pfad ist nun real verdrahtet und spiegelt den Mint-Flow symmetrisch wider:

- User ruft `swapFrom1kUSD(tokenOut, amountIn1k, to, minOut, deadline)` auf.
- PSM:
  - prüft Oracle-Gesundheit und Limits (wie auf der Mint-Seite),
  - ruft `oneKUSD.burn(msg.sender, amountIn1k)` auf,
  - zieht Collateral via `vault.withdraw(tokenOut, address(this), netTokenOut, "PSM_REDEEM")` aus dem Vault,
  - transferiert das Collateral final mit `IERC20(tokenOut).safeTransfer(to, netTokenOut)` an den Empfänger.

Damit gilt bei neutralen Parametern (1:1-Preis, 0 Fees):

> Mint:  User gibt Collateral, erhält 1kUSD  
> Redeem: User gibt 1kUSD, erhält Collateral zurück

### Roundtrip-Regression (Mint → Redeem)

In `PSMRegression_Flows.t.sol` wurde ein Roundtrip-Test ergänzt, der sicherstellt, dass:

- User-Collateral nach „Mint → Redeem“ exakt auf den Ausgangswert zurückkehrt.
- User-1kUSD-Balance nach dem Roundtrip wieder dem Startwert entspricht.
- `totalSupply(1kUSD)` sich über den Gesamtzyklus nicht ändert.
- Das gesamte Collateral-Lock (`PSM + Vault`) vor und nach dem Roundtrip identisch ist.

Für einen 1:1-Preis ohne Fees gilt im Test:

- `outRedeem == amountIn`
- Collateral- und 1kUSD-Bestände des Users sind nach Roundtrip unverändert.
- Die PSM/Vault-Bilanz bleibt global konsistent.

### Teststatus nach DEV-46

Nach DEV-46 ergibt sich folgender Konsistenz-Status:

- PSM-Core, Limits, SwapCore, Guardian-Propagation und die neuen PSM-Regressionen (Flows & Limits) sind grün.
- Insgesamt: **33 Tests, 0 Failures**.


---

## DEV-47 – Token-Decimals via ParameterRegistry

**Ziel:**  
Die PSM-Notional-Mathe sollte nicht länger implizit von `18` Token-Decimals ausgehen, sondern die tatsächlichen Decimals pro Collateral-Asset aus einer on-chain Registry ziehen.

### Umsetzung

- Neue Konstante und Helper in `PegStabilityModule`:
  - `KEY_TOKEN_DECIMALS = keccak256("psm:tokenDecimals")`
  - `_tokenDecimalsKey(address token)` → `bytes32`-Key pro Asset.
  - `_getTokenDecimals(address token)`:
    - Wenn `registry == address(0)` → Fallback auf `18`.
    - Sonst: `registry.getUint(_tokenDecimalsKey(token))`.
    - Wenn Wert `0` → ebenfalls Fallback auf `18`.
    - Guard: `raw <= type(uint8).max` (sonst Revert `"PSM: bad tokenDecimals"`).

- `swapTo1kUSD`:
  - Statt fix `uint8 tokenInDecimals = 18;`
  - Jetzt: `uint8 tokenInDecimals = _getTokenDecimals(tokenIn);`

- `swapFrom1kUSD`:
  - Statt fix `uint8 tokenOutDecimals = 18;`
  - Jetzt: `uint8 tokenOutDecimals = _getTokenDecimals(tokenOut);`

### Guardian-/Safety-Kompatibilität

- `Guardian_PSMUnpause.t.sol` wurde bewusst **registry-frei** gehalten:
  - PSM-Konstruktor erhält als letztes Argument `address(0)` für die Registry.
  - Damit nutzt `_getTokenDecimals()` im Test immer den 18-Decimals-Fallback.
  - Der Test prüft weiterhin ausschließlich:
    - Pause/Unpause über `SafetyAutomata`.
    - Dass ein Swap nach `resumeModule()` **nicht reverted**.

### Auswirkungen auf spätere Integrationen

- Collateral-Assets mit != 18 Decimals (z. B. 6 oder 8) können nun sauber verdrahtet werden, indem der DAO/Timelock:
  - Für jedes Asset `registry.setUint(_tokenDecimalsKey(asset), decimals)` setzt.
- Die bestehende Notional-Mathe (DEV-44) bleibt unverändert:
  - `_normalizeTo1kUSD` / `_normalizeFrom1kUSD` nutzen jetzt nur noch die Registry-Decimals statt eines Fixwerts.
- L1-Migration bleibt unkritisch:
  - Registry-Keys sind rein logisch; der Mapping-Ansatz funktioniert auch jenseits von EVM, solange eine Key→Value-Map existiert.


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

