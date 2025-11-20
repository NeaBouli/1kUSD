#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/psm_parameters.md"

echo "== DEV52 DOC02: append PSM spread parameters to psm_parameters.md =="

cat <<'EOL' >> "$FILE"

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
EOL

echo "✓ PSM spread parameters appended to $FILE"
