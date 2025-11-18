#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/psm_dev43-45.md"

echo "== DEV46 DOC03: append DEV-46 redeem & roundtrip section to PSM doc =="

mkdir -p "$(dirname "$FILE")"

cat <<'EOM' >> "$FILE"

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

EOM

echo "✓ DEV-46 section appended to $FILE"
