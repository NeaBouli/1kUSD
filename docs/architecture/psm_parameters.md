# PSM Parameters & Registry Map (DEV-50)

Dieses Dokument beschreibt alle aktuell verwendeten PSM- und Oracle-bezogenen
Parameter, insbesondere jene, die über die `ParameterRegistry` gesteuert werden.
Ziel ist, dass Auditoren, Risk-Teams und DAO-Governance klar sehen können,

- welche Schlüssel es gibt,
- in welchen Einheiten sie konfiguriert werden,
- von welchen Modulen sie gelesen werden,
- und welche Fallback-Semantik im Code gilt.

## 1. ParameterRegistry-gestützte Parameter

### 1.1 PSM – Token-Decimals

Die PSM bezieht die Decimals pro Collateral-Asset aus der `ParameterRegistry`.
Im Code existiert dafür ein Prefix-Key und ein per-Token-Key:

- **Prefix-Key (intern):**
  - `KEY_TOKEN_DECIMALS = keccak256("psm:tokenDecimals")`
- **Per-Token-Key (intern):**
  - `_tokenDecimalsKey(token) = keccak256(abi.encode(KEY_TOKEN_DECIMALS, token))`

Die PSM nutzt diese Schlüssel in `_getTokenDecimals(address token)`.

| Kategorie | Human Key / Zweck            | Storage-Key (Solidity)                          | Typ      | Einheit     | Scope       | Gelesen von                  | Verhalten / Beschreibung                                  |
|----------:|------------------------------|--------------------------------------------------|----------|-------------|------------|------------------------------|----------------------------------------------------------|
| Decimals  | Collateral-Token Decimals    | `registry.getUint(_tokenDecimalsKey(token))`     | uint256  | Decimals    | per Token  | `PegStabilityModule`         | Wenn Wert `> 0`: wird als ERC-20 Decimals interpretiert. |

**Fallback-Logik (Code):**

- Wenn `address(registry) == address(0)` → **immer 18 Decimals**.
- Wenn `getUint(...) == 0` → **ebenfalls 18 Decimals**.
- Es wird erzwungen, dass der Rückgabewert `<= type(uint8).max` ist
  (`require(raw <= type(uint8).max, "PSM: bad tokenDecimals")`).

Damit bleibt das System auch ohne Registry voll funktionsfähig und
Chain-/Asset-Migration (z. B. Kaspa L1) wird erleichtert.

---

### 1.2 PSM – Mint/Redeem Fees

Die PSM unterstützt globale Fees sowie per-Token Overrides. Die effektiven
Fees werden im Code über `_getMintFeeBps(address token)` und
`_getRedeemFeeBps(address token)` in folgender Reihenfolge aufgelöst:

1. Per-Token Override (wenn `> 0`)
2. Globaler Registry-Wert (wenn `> 0`)
3. Lokaler PSM-Storage (`mintFeeBps` / `redeemFeeBps`)

Es gelten zusätzlich harte Bounds:  
`require(effectiveFee <= 10_000, "PSM: fee too large");`  
→ maximal 100 % Fee sind erlaubt, darüber wird revertet.

**Globale Keys (BPS):**

- `psm:mintFeeBps`
- `psm:redeemFeeBps`

Typische Implementierung (vereinfacht):

- `KEY_MINT_FEE_BPS   = keccak256("psm:mintFeeBps")`
- `KEY_REDEEM_FEE_BPS = keccak256("psm:redeemFeeBps")`

**Per-Token Overrides (BPS):**

- `keccak256(abi.encode(KEY_MINT_FEE_BPS, token))`
- `keccak256(abi.encode(KEY_REDEEM_FEE_BPS, token))`

| Kategorie | Human Key / Zweck                     | Storage-Key (Solidity, vereinfacht)                                 | Typ     | Einheit | Scope       | Gelesen von                  | Verhalten / Beschreibung                                      |
|----------:|---------------------------------------|---------------------------------------------------------------------|---------|---------|------------|------------------------------|----------------------------------------------------------------|
| Fees      | Globale Mint-Fee in BPS               | `registry.getUint(KEY_MINT_FEE_BPS)`                               | uint256 | BPS     | global     | `PegStabilityModule`         | Wird genutzt, wenn kein per-Token Override gesetzt ist.       |
| Fees      | Globale Redeem-Fee in BPS             | `registry.getUint(KEY_REDEEM_FEE_BPS)`                             | uint256 | BPS     | global     | `PegStabilityModule`         | Wird genutzt, wenn kein per-Token Override gesetzt ist.       |
| Fees      | Mint-Fee Override für ein Asset       | `registry.getUint(keccak256(abi.encode(KEY_MINT_FEE_BPS, token)))` | uint256 | BPS     | per Token  | `PegStabilityModule`         | Überschreibt globalen Wert, wenn `> 0`.                       |
| Fees      | Redeem-Fee Override für ein Asset     | `registry.getUint(keccak256(abi.encode(KEY_REDEEM_FEE_BPS, token)))` | uint256 | BPS   | per Token  | `PegStabilityModule`         | Überschreibt globalen Wert, wenn `> 0`.                       |

**Fallback-Logik (zusammengefasst):**

- Wenn per-Token Override `> 0` → dieser Wert wird genutzt.
- Sonst, wenn globaler Registry-Wert `> 0` → globaler Wert aktiv.
- Sonst → lokaler PSM-Storage (`mintFeeBps` / `redeemFeeBps`).

Damit kann die DAO:

- global einheitliche Fees setzen,
- einzelne Collaterals mit spezifischen Fees belegen,
- und im Extremfall sogar ohne Registry weiterarbeiten (lokale Defaults).

---

### 1.3 OracleAggregator – Health-Thresholds

Der `OracleAggregator` verwendet zwei Schwellenwerte aus der Registry, um
die Health des Preisfeeds zu bestimmen:

- maximale Preisänderung zwischen zwei Updates (Diff),
- maximale zulässige Stale-Zeit eines Preises.

Typische Keys:

- `oracle:maxDiffBps`  → maximale Preisänderung in Basis-Punkten
- `oracle:maxStale`    → maximale Alterung in Sekunden

Im Code werden diese Werte (vereinfacht) etwa so gelesen:

- `uint256 maxDiffBps = registry.getUint(keccak256("oracle:maxDiffBps"));`
- `uint256 maxStale   = registry.getUint(keccak256("oracle:maxStale"));`

**Bedeutung:**

- `maxDiffBps`:
  - Wenn `maxDiffBps == 0` → **Diff-Check deaktiviert**.
  - Wenn `maxDiffBps > 0`:
    - Ein neues Price-Update wird mit dem letzten Wert verglichen.
    - Überschreitet die relative Änderung (in BPS) diesen Wert,
      markiert der Aggregator den Feed als **unhealthy**.
- `maxStale`:
  - Wenn `maxStale == 0` → **Stale-Check deaktiviert**.
  - Wenn `maxStale > 0`:
    - `block.timestamp - lastUpdated > maxStale` → Feed gilt als **unhealthy**.

Der `OracleWatcher` und die Guardian-/Safety-Pfade benutzen dieses
Health-Signal, um den PSM oder andere Module zu stoppen, wenn:

- der Feed zu alt ist,
- der letzte Sprung zu groß war,
- oder das Modul über SafetyAutomata global pausiert wurde.

---

## 2. Modul-lokale Parameter (ohne Registry)

Neben der Registry existieren Parameter, die direkt in Modulen gehalten
werden. Wichtig für das PSM-Ökosystem sind:

### 2.1 PegStabilityModule – lokale Fee-Defaults

Auch wenn die Fees heute primär über die Registry gesteuert werden, hält
die PSM noch lokale Storage-Werte bereit:

- `uint256 mintFeeBps;`
- `uint256 redeemFeeBps;`

Diese Werte dienen als Fallback, wenn **weder** per-Token-Override noch
globale Registry-Werte gesetzt sind. Sie können vom Admin (DAO / Timelock)
über `setFees(uint256 mintFee, uint256 redeemFee)` gepflegt werden.

### 2.2 PSMLimits – Notional-Caps

`PSMLimits` verwaltet eigenständige Limits (nicht über die Registry),
insbesondere:

- `singleTxCap` (max. Notional pro Transaktion),
- `dailyCap` (aggregiertes Tagesvolumen),
- Mapping pro Asset (z. B. `limits[asset]`).

Die Limits werden in der PSM auf **1kUSD-Notional-Basis (18 Decimals)**
geprüft:

- `notional1k` wird über den Preis und die Decimals berechnet,
- `limits.checkAndUpdate(notional1k)` erzwingt:
  - kein Swap oberhalb `singleTxCap`,
  - kein tägliches Volumen oberhalb `dailyCap`.

Konfiguriert werden diese Werte über Admin-Funktionen des `PSMLimits`
Contracts, nicht über die Registry.

---

## 3. Governance-Rollen & Verantwortlichkeiten

Eine typische Rollenaufteilung für diese Parameter kann wie folgt aussehen:

- **DAO / Timelock**
  - Setzt globale Fees (`psm:mintFeeBps`, `psm:redeemFeeBps`).
  - Bestimmt `oracle:maxDiffBps`, `oracle:maxStale`.
  - Pflegt PSMLimits (singleTxCap, dailyCap).

- **Risk Council / Treasury**
  - Schlägt Fee-Änderungen vor (über Governance).
  - Definiert Collateral-spezifische Overrides (z. B. höheres Risiko → höhere Fee).

- **Guardian / Safety Module**
  - Nutzt die Health-Signale des Oracles.
  - Pausiert Module, wenn Health-Invarianten verletzt sind oder Governance eingreift.

Dieses Dokument ist die Referenz dafür, **welche numerischen Parameter**
konkret existieren, wo sie gespeichert werden und wie sie im PSM-Stack
interpretiert werden.

---

## 4. Spread-Parameter im PSM (DEV-52)

Neben den klassischen Fees (Mint/Redeem) unterstützt der PSM eine zusätzliche
**Spread-Schicht**, die ebenfalls über die `ParameterRegistry` konfiguriert wird.
Spreads werden in **Basis-Punkten (Bps)** angegeben und **auf die Fees aufaddiert**.
Die Summe aus `feeBps + spreadBps` ist auf `<= 10_000` (100 %) begrenzt.

### 4.1 Globale Spread-Keys

- `psm:mintSpreadBps`  
  - Typ: `uint256` (interpretiert als Bps, 1 % = 100)  
  - Ebene: global  
  - Verwendung:
    - Wird von `_getMintSpreadBps()` als Default-Spread beim Mint verwendet,
      wenn kein token-spezifischer Eintrag gesetzt ist.
  - Wirkung:
    - Erhöht die effektive Mint-Kosten (on-top zu `psm:mintFeeBps`), z. B. für
      systemweite Marktphasen mit erhöhtem Risiko.

- `psm:redeemSpreadBps`  
  - Typ: `uint256` (Bps)  
  - Ebene: global  
  - Verwendung:
    - Wird von `_getRedeemSpreadBps()` als Default-Spread beim Redeem verwendet,
      wenn kein token-spezifischer Eintrag gesetzt ist.
  - Wirkung:
    - Erhöht die effektive Redeem-Kosten (on-top zu `psm:redeemFeeBps`).

### 4.2 Token-spezifische Spread-Keys

Analog zu den Fees existieren **per-Asset-Overrides**, die die globalen
Spreads überschreiben, falls ungleich Null.

- Mint-Spread Override:
  - Key-Schema:
    - Basis-Schlüssel: `KEY_MINT_SPREAD_BPS = keccak256("psm:mintSpreadBps")`
    - Token-spezifischer Key:
      - `keccak256(abi.encode(KEY_MINT_SPREAD_BPS, tokenAddress))`
  - Verwendung:
    - `_getMintSpreadBps(token)` prüft zuerst den token-spezifischen Eintrag.
    - Falls `> 0`, wird dieser verwendet; ansonsten fällt die Logik auf den
      globalen Wert zurück.

- Redeem-Spread Override:
  - Key-Schema:
    - Basis-Schlüssel: `KEY_REDEEM_SPREAD_BPS = keccak256("psm:redeemSpreadBps")`
    - Token-spezifischer Key:
      - `keccak256(abi.encode(KEY_REDEEM_SPREAD_BPS, tokenAddress))`
  - Verwendung:
    - `_getRedeemSpreadBps(token)` prüft zuerst den token-spezifischen Eintrag.
    - Falls `> 0`, wird dieser verwendet; ansonsten fällt die Logik auf den
      globalen Wert zurück.

### 4.3 Effektive Anwendung im Swap

Im PSM werden Fees und Spreads zu einer Gesamtbasis gebündelt:

- Mint-Seite (`swapTo1kUSD`):
  - `feeBps = _getMintFeeBps(tokenIn)`
  - `spreadBps = _getMintSpreadBps(tokenIn)`
  - `totalBps = feeBps + spreadBps`
  - `totalBps` wird an `_computeSwapTo1kUSD(...)` übergeben.
  - Invariante:
    - `require(totalBps <= 10_000, "PSM: fee+spread too high");`

- Redeem-Seite (`swapFrom1kUSD`):
  - `feeBps = _getRedeemFeeBps(tokenOut)`
  - `spreadBps = _getRedeemSpreadBps(tokenOut)`
  - `totalBps = feeBps + spreadBps`
  - `totalBps` wird an `_computeSwapFrom1kUSD(...)` übergeben.
  - Invariante:
    - `require(totalBps <= 10_000, "PSM: fee+spread too high");`

### 4.4 Governance-Implikationen

- **DAO / Timelock**
  - Kann globale Spreads setzen (z. B. während Stressphasen).
  - Kann einzelne Collaterals mit höheren Spreads belegen.

- **Risk Council**
  - Definiert pro-Collateral-Profile (Fee + Spread) in Abstimmung mit
    Liquiditäts- und Marktbedingungen.

In Kombination mit den bestehenden Fee-Parametern erlaubt die Spread-Schicht
eine feinere Steuerung der effektiven Swap-Kosten, ohne die Limit- oder
Oracle-Logik zu verändern.
