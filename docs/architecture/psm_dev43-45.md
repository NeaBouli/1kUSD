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

