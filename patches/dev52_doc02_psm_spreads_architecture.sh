#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/psm_parameters.md"

echo "== DEV52 DOC02: append PSM spread parameters to psm_parameters.md =="

cat <<'EOL' >> "$FILE"

---

## 4. Spreads (DEV-52) — Fee-Layer-Erweiterung

Zusätzlich zu den klassischen Fees (`mintFeeBps`, `redeemFeeBps`) unterstützt der PSM
einen separaten **Spread-Layer**, der auf denselben 10_000-Basis (100 %) operiert und
**additiv** zu den Fees angewendet wird.

### 4.1 Registry-Keys für Spreads

- **Globale Spreads**
  - `psm:mintSpreadBps`
    - Typ: `uint256` (0–10_000)
    - Bedeutung: zusätzlicher Aufschlag in Basis-Punkten auf der **Mint-Seite**
      (Collateral → 1kUSD).
  - `psm:redeemSpreadBps`
    - Typ: `uint256` (0–10_000)
    - Bedeutung: zusätzlicher Abschlag in Basis-Punkten auf der **Redeem-Seite**
      (1kUSD → Collateral).

- **Per-Token Spreads**
  - `keccak256(abi.encode(KEY_MINT_SPREAD_BPS, token))`
    - Typ: `uint256` (0–10_000)
    - Bedeutung: Asset-spezifischer Mint-Spread für ein bestimmtes Collateral.
  - `keccak256(abi.encode(KEY_REDEEM_SPREAD_BPS, token))`
    - Typ: `uint256` (0–10_000)
    - Bedeutung: Asset-spezifischer Redeem-Spread für ein bestimmtes Collateral.

### 4.2 Auflösungsreihenfolge (Resolution Order)

Für jeden Swap-Pfad (Mint/Redeem) werden die effektiven Spreads wie folgt bestimmt:

1. **Per-Token-Entry** (`> 0`):  
   Wenn ein token-spezifischer Spread gesetzt ist, wird dieser verwendet.
2. **Globaler Spread** (`> 0`):  
   Falls kein per-Token-Spread, aber ein globaler Spread definiert ist, wird dieser verwendet.
3. **Fallback**:  
   Wenn weder global noch per-Token ein Wert (`> 0`) konfiguriert ist, gilt:
   - effektiver Spread = `0`.

Anschließend werden **Fee + Spread** addiert und es gilt die Invariante:

> `feeBps + spreadBps <= 10_000` (max. 100 % Abzug)

Ein Verstoß gegen diese Invariante führt zu einem Revert (`"PSM: fee+spread too high"`).

### 4.3 Wirtschaftliche Interpretation

- **Mint-Seite (Collateral → 1kUSD)**
  - `mintFeeBps` kann z. B. Treasury-Einnahmen abbilden.
  - `mintSpreadBps` kann Risikoaufschläge pro Asset (z. B. volatileres Collateral)
    modellieren, ohne die globale Fee-Politik zu ändern.

- **Redeem-Seite (1kUSD → Collateral)**
  - `redeemFeeBps` bildet z. B. Standard-Redeem-Kosten ab.
  - `redeemSpreadBps` kann genutzt werden, um in Stressphasen
    gezielt bestimmte Collaterals teurer zu machen (z. B. Illiquidität).

### 4.4 Testabdeckung

- `PSMRegression_Fees`
  - Verifiziert globale und per-Token Fees über die Registry.
- `PSMRegression_Spreads`
  - Verifiziert, dass sowohl Mint- als auch Redeem-Pfade die konfigurierten
    Spreads korrekt anwenden und der effektive `netOut` exakt mit der
    Summe aus Fee- und Spread-Belastung übereinstimmt.
EOL

echo "✓ PSM spread parameters appended to $FILE"
