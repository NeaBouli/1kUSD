# DEV-44 — PSM Price Normalization & Limits Math

## Ziel

DEV-44 schließt die „Preis-Normalisierungs-Phase“ des Peg Stability Module (PSM) ab:

- Alle PSM-Swaps und Quotes laufen jetzt über preis-normalisierte Notional-Beträge in **1kUSD (18 Decimals)**.
- Das Limits-Modul (`PSMLimits`) arbeitet auf diesen 1kUSD-Notionals, nicht mehr auf rohen Tokenmengen.
- Der PSM bleibt bewusst **ohne echte Asset-Flows** (keine ERC-20 Transfers, Vault-Interaktionen oder 1kUSD-Mints/Burns) – diese folgen in DEV-45.

## Technische Kernpunkte

### 1. Oracle-Integration & Health-Gate

- `PegStabilityModule` hält eine Referenz auf `IOracleAggregator oracle`.
- `_requireOracleHealthy(...)` prüft:
  - Falls kein Oracle konfiguriert ist (`oracle == address(0)`), blockiert der PSM **nicht** (Bootstrap-/Dev-Modus).
  - Falls ein Oracle vorhanden ist, muss `oracle.isOperational()` `true` liefern – sonst revertiert der Swap mit `"PSM: oracle not operational"`.

- `_getPrice(asset)` kapselt:
  - `IOracleAggregator.Price` (price, decimals, healthy, updatedAt)
  - Stellt sicher, dass `p.healthy == true` und `p.price > 0`.
  - Gibt `(uint256 price, uint8 priceDecimals)` zurück.

### 2. Preis-Normalisierung: Token → 1kUSD

Helper-Funktion:

- `_normalizeTo1kUSD(amountToken, tokenDecimals, price, priceDecimals)`

Vorgehen:

1. Tokenmenge auf **18 Decimals** normieren:
   - Falls `tokenDecimals < 18` → Aufskalieren.
   - Falls `tokenDecimals > 18` → Abskalieren.
2. Preis anwenden:
   - `amount1k = (amountToken * price) / 10^priceDecimals`.

Damit erhält das System einen konsistenten 1kUSD-Notionalbetrag (`amount1k` mit 18 Decimals), der:
- Für Limits verwendet wird (`PSMLimits.checkAndUpdate(amount1k)`).
- Die Basis für Quotes und Gebührenberechnung bildet.

### 3. Preis-Normalisierung: 1kUSD → Token

Helper-Funktion:

- `_normalizeFrom1kUSD(amount1k, tokenDecimals, price, priceDecimals)`

Vorgehen:

1. Inverse Rechnung zu `_normalizeTo1kUSD`:
   - `tokenAmount18 = (amount1k * 10^priceDecimals) / price`
2. Anpassung der Decimals auf das tatsächliche Token (`tokenDecimals`) durch Auf-/Abskalierung.

Ergebnis: Ein konsistenter Rückweg von 1kUSD-Notional zu Token-Einheiten.

### 4. Swap-Mathematik (ohne Asset-Transfers)

#### swapTo1kUSD (Token → 1kUSD)

- Eingänge:
  - `tokenIn`, `amountIn`, `to`, `minOut`, `deadline`
- Ablauf:
  1. `require(amountIn > 0, "PSM: amountIn=0");`
  2. `_requireOracleHealthy(tokenIn);`
  3. Für DEV-44 wird `tokenInDecimals` pragmatisch auf `18` gesetzt (Registry-Anbindung folgt in späterem DEV).
  4. `_computeSwapTo1kUSD(tokenIn, amountIn, mintFeeBps, tokenInDecimals)`:
     - Liefert `(notional1k, fee1k, net1k)`.
  5. `_enforceLimits(notional1k);` → Limits arbeiten auf 1kUSD-Notional.
  6. `if (net1k < minOut) revert InsufficientOut();`
  7. **Kein** Transfer/Mint/Burn – `netOut = net1k;`
  8. Events:
     - `SwapTo1kUSD(user, tokenIn, notional1k, fee1k, net1k, ts)`
     - `PSMSwapExecuted(user, tokenIn, amountIn, ts)`

#### swapFrom1kUSD (1kUSD → Token)

- Eingänge:
  - `tokenOut`, `amountIn1k`, `to`, `minOut`, `deadline`
- Ablauf:
  1. `require(amountIn1k > 0, "PSM: amountIn=0");`
  2. `_requireOracleHealthy(tokenOut);`
  3. `tokenOutDecimals` vorerst hart auf `18` gesetzt (DEV-44 Stub).
  4. `_computeSwapFrom1kUSD(tokenOut, amountIn1k, redeemFeeBps, tokenOutDecimals)`:
     - Liefert `(notional1k, fee1k, netTokenOut)`.
  5. `_enforceLimits(notional1k);`
  6. `if (netTokenOut < minOut) revert InsufficientOut();`
  7. **Kein** Burn/Withdraw – `netOut = netTokenOut;`
  8. Events:
     - `SwapFrom1kUSD(user, tokenOut, notional1k, fee1k, netTokenOut, ts)`
     - `PSMSwapExecuted(user, tokenOut, amountIn1k, ts)`

### 5. Quotes

- `quoteTo1kUSD(...)` und `quoteFrom1kUSD(...)` verwenden dieselben Helper-Funktionen:
  - `_computeSwapTo1kUSD` bzw. `_computeSwapFrom1kUSD`.
- Rückgabe:
  - `QuoteOut { grossOut, fee, netOut, outDecimals }`
- `outDecimals`:
  - Bei `quoteTo1kUSD`: immer `18` (1kUSD).
  - Bei `quoteFrom1kUSD`: `tokenOutDecimals`.

### 6. Limits-Verhalten in PSM-Regressionstests

- `PSMRegression_Limits.t.sol` validiert:
  - Single-Transaction-Cap:
    - Swaps größer als `singleTxCap` revertieren.
  - Daily-Cap:
    - Summe mehrerer Swaps > `dailyCap` revertiert wie erwartet.
  - Daily-Reset:
    - Nach `+1 days` wird das Tagesvolumen zurückgesetzt, neue Swaps sind wieder möglich.
- Für DEV-44 laufen diese Tests über den PSM mit Mock-Umgebung (MockOneKUSD, MockVault, MockRegistry) und den implementierten Notional-Pfad.

## Einschränkungen & Follow-Up (DEV-45)

- **Keine echten Asset-Flows**:
  - Weder ERC-20-Transfers noch Vault-Interaktionen noch 1kUSD-Mint/Burn sind in DEV-44 aktiv.
  - Alle Swaps sind rein logisch/notional.
- **Decimals & Registry**:
  - In DEV-44 werden Token-Decimals pragmatisch als 18 behandelt.
  - DEV-45/46 wird die Anbindung an `ParameterRegistry` bzw. ein Asset-Metadaten-Modell nachziehen.
- **Oracle-Spezifika**:
  - DEV-44 geht davon aus, dass der Oracle-Preis bereits so skaliert wird, dass die Umrechnung sauber in 18-Decimal-1kUSD stattfindet.
  - Erweiterte Checks (Stale-Erkennung, Deviation-Limits) sind für spätere DEV-Schritte vorgesehen.

## Ergebnis

- Der PSM arbeitet jetzt intern mit **preis-normalisierten 1kUSD-Notionals**.
- `PSMLimits` werden auf stabilen Einheiten (1kUSD) und nicht auf rohen Tokenmengen durchgesetzt.
- Swaps und Quotes sind über Helper-Funktionen konsolidiert:
  - `_getPrice`, `_normalizeTo1kUSD`, `_normalizeFrom1kUSD`,
  - `_computeSwapTo1kUSD`, `_computeSwapFrom1kUSD`.
- Das System bleibt test- und auditsicher, da:
  - Alle sicherheitskritischen Checks (Pause, Oracle Health, Limits) bereits auf der finalen Notional-Ebene arbeiten.
  - Die ökonomisch-scharfen Asset-Flows in DEV-45 nachgezogen werden können, ohne die Notional-Schicht erneut anzufassen.
