#!/usr/bin/env bash
set -euo pipefail

ARCH="docs/architecture/psm_parameters.md"
README="README.md"
LOG="logs/project.log"

echo "== DEV53 DOC01: document PSM spreads in parameter map and README =="

if [ ! -f "$ARCH" ]; then
  echo "ERROR: $ARCH not found" >&2
  exit 1
fi

# --- 1) Spreads in PSM Parameter & Registry Map dokumentieren ---
cat <<'EOL' >> "$ARCH"

---

## 4. Mint/Redeem Spreads (DEV-52)

Neben den Fees stellt der PSM eine zweite ökonomische Stellschraube bereit:
**Spreads**. Sie erlauben z.B. zusätzliche Basis-Punkte auf bestimmte Collaterals
(z.B. illiquide oder riskantere Assets), ohne die globale Fee-Politik zu ändern.

### 4.1 Registry Keys

- **Globale Spreads**
  - `psm:mintSpreadBps` — zusätzlicher Spread in Basis-Punkten auf der Mint-Seite
    (on top of `psm:mintFeeBps`).
  - `psm:redeemSpreadBps` — zusätzlicher Spread in Basis-Punkten auf der Redeem-Seite
    (on top of `psm:redeemFeeBps`).

- **Per-Token Spreads**
  - `keccak256(abi.encode("psm:mintSpreadBps", token))`
  - `keccak256(abi.encode("psm:redeemSpreadBps", token))`

### 4.2 Auflösungs-Reihenfolge (Resolution Order)

Für einen gegebenen Swap gelten folgende Regeln:

1. Wenn ein **per-Token Spread** (`token`-spezifischer Key) > 0 konfiguriert ist,
   wird dieser verwendet.
2. Sonst, wenn ein **globaler Spread** (`psm:mintSpreadBps` / `psm:redeemSpreadBps`)
   > 0 konfiguriert ist, wird dieser verwendet.
3. Falls weder per-Token noch globale Spreads gesetzt sind, wird implizit **0 bps**
   angenommen.

Der effektive Spread wird immer **zusätzlich** zum Fee-Layer gerechnet:

- Mint: `totalBps = mintFeeBps + mintSpreadBps`
- Redeem: `totalBps = redeemFeeBps + redeemSpreadBps`

### 4.3 Invarianten & Safety

- Der PSM erzwingt, dass `feeBps + spreadBps <= 10_000` (max. 100 %),
  um Fehlkonfigurationen zu verhindern.
- Spreads wirken sowohl in **`swapTo1kUSD` / `swapFrom1kUSD`** als auch in den
  zugehörigen **Quote-Funktionen**, so dass Frontends konsistente Werte anzeigen können.
- Die Testsuite **`PSMRegression_Spreads`** verifiziert u.a.:
  - Mint-Spreads pro Token (per-Token Override),
  - Redeem-Spreads pro Token,
  - Korrekte Anwendung auf 1:1 Collateral bei Oracle-Fallback (Preis = 1.0).
EOL

# --- 2) README-Kurzabschnitt zu Spreads anhängen ---
cat <<'EOL' >> "$README"

### PSM spreads (DEV-52)

On top of the registry-driven fee layer, the PSM supports **mint/redeem spreads**:

- Global keys: `psm:mintSpreadBps`, `psm:redeemSpreadBps`
- Per-token overrides via `keccak256(abi.encode("psm:mintSpreadBps", token))` and
  `keccak256(abi.encode("psm:redeemSpreadBps", token))`
- Resolution: per-token > global > implicit 0
- Safety: the contract enforces `feeBps + spreadBps <= 10_000`

Regression suite:
- `PSMRegression_Spreads` covers mint/redeem behavior with spreads on top of fees.
EOL

# --- 3) Log-Eintrag für DEV-53 ---
mkdir -p "$(dirname "$LOG")"
cat <<EOL >> "$LOG"
[DEV-53] $(date -u +"%Y-%m-%dT%H:%M:%SZ") Docs: documented PSM mint/redeem spreads (registry keys, resolution order, invariants) in psm_parameters.md and README; Economic Layer docs aligned with v0.50.0.
EOL

echo "✓ PSM spreads documented in $ARCH and $README, log updated at $LOG"
