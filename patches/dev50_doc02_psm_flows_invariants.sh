#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/psm_flows_invariants.md"

echo "== DEV50 DOC02: write PSM Flows & Invariants =="

mkdir -p "$(dirname "$FILE")"

cat <<'EOL' > "$FILE"
# PSM Flows & Invariants (DEV-50)

Dieses Dokument beschreibt die zentralen **End-to-End-Flows** des
`PegStabilityModule` (PSM) und die dazugehörigen **Invarianten**, wie sie
durch die aktuelle Implementierung (DEV-43 → DEV-49) und die
Regression-Tests (`PSMRegression_*`) erzwungen werden.

---

## 1. High-Level Überblick

Der PSM agiert als Fassade mit folgenden Schichten:

1. **Safety & Guardian Gate**
   - `SafetyAutomata` (module-basiertes Pausing),
   - Guardian/Watcher/Oracle-Health-Signale.

2. **Preis- & Notional-Layer**
   - `OracleAggregator` liefert `Price` (inkl. Health).
   - `_normalizeTo1kUSD` / `_normalizeFrom1kUSD` rechnen Tokens ↔ 1kUSD-Notional
     (immer 18 Decimals für 1kUSD).

3. **Limits-Layer**
   - `PSMLimits.checkAndUpdate(notional1k)` erzwingt Single-Tx- und Daily-Caps
     auf 1kUSD-Notional-Basis.

4. **Fee-Layer**
   - Fees (Mint/Redeem) werden über `ParameterRegistry` aufgelöst:
     - Global (`psm:mintFeeBps`, `psm:redeemFeeBps`),
     - Per-Token Overrides,
     - Fallback auf lokale PSM-Storage-Werte.

5. **Asset-Flow-Layer**
   - Collateral wird in `CollateralVault` deponiert/abgezogen.
   - `OneKUSD` wird gemint/burnt.
   - Optionales Fees-Routing via `FeeRouterV2`.

---

## 2. Flow: `swapTo1kUSD` (Mint-Seite)

### 2.1 Sequenz (konzeptionell)

```text
User
  │
  │ swapTo1kUSD(tokenIn, amountIn, to, minOut, deadline)
  ▼
PegStabilityModule
  │ 1) Safety + Oracle-Health prüfen
  │ 2) Decimals + Preis laden → Notional in 1kUSD
  │ 3) Limits prüfen (PSMLimits)
  │ 4) Fee bestimmen (Registry + Override + Fallback)
  │ 5) Collateral aus User → Vault transferieren
  │ 6) 1kUSD für `to` minten
  │ 7) Fee in 1kUSD-Notional zum FeeRouter routen (optional)
  ▼
User erhält 1kUSD
CollateralVault hält Collateral
FeeRouter (optional) erhält 1kUSD-Fee
2.2 Detail-Schritte (Implementierung)
Preconditions

require(amountIn > 0, "PSM: amountIn=0");

whenNotPaused (PSM selbst),

SafetyAutomata / Oracle-Health via _requireOracleHealthy(tokenIn).

Decimals & Preis

tokenInDecimals = _getTokenDecimals(tokenIn):

Registry-Lookup mit Fallback auf 18 Decimals.

(px, pxDec) = _getPrice(tokenIn):

OracleAggregator.getPrice(tokenIn) mit Health-Checks
(stale/diff + Safety).

Notional-Berechnung

_computeSwapTo1kUSD:

notional1k = _normalizeTo1kUSD(amountIn, tokenInDecimals, px, pxDec);

fee1k = (notional1k * feeBps) / 10_000;

net1k = notional1k - fee1k;

Limits

_enforceLimits(notional1k);

PSMLimits.checkAndUpdate(notional1k) erzwingt:

singleTxCap (pro Swap),

dailyCap (aggregierte Tagesnotional).

Slippage-Check

if (net1k < minOut) revert InsufficientOut();

Asset-Flows

Collateral:

IERC20(tokenIn).safeTransferFrom(msg.sender, address(vault), amountIn);

vault.deposit(tokenIn, msg.sender, amountIn);

1kUSD:

oneKUSD.mint(to, net1k);

Fee-Routing (optional)

Falls fee1k > 0 und feeRouter != address(0):

feeRouter.route("PSM_MINT_FEE", address(oneKUSD), fee1k);

Rückgabewert

netOut = net1k;

Events:

SwapTo1kUSD(...),

PSMSwapExecuted(...).

3. Flow: swapFrom1kUSD (Redeem-Seite)
3.1 Sequenz (konzeptionell)
text
Code kopieren
User mit 1kUSD
  │
  │ swapFrom1kUSD(tokenOut, amountIn1k, to, minOut, deadline)
  ▼
PegStabilityModule
  │ 1) Safety + Oracle-Health prüfen
  │ 2) Preis + Decimals laden
  │ 3) Limits prüfen (Notional = amountIn1k)
  │ 4) Fee berechnen (Registry, per-Token, Fallback)
  │ 5) 1kUSD vom User burnen
  │ 6) Collateral aus Vault abziehen
  │ 7) Collateral an `to` transferieren
  ▼
User erhält Collateral
1kUSD-Supply sinkt
CollateralVault reduziert Collateral
FeeRouter (optional) erhält 1kUSD-Fees (in Notional)
3.2 Detail-Schritte (Implementierung)
Preconditions

require(amountIn1k > 0, "PSM: amountIn=0");

whenNotPaused,

_requireOracleHealthy(tokenOut).

Decimals & Preis

tokenOutDecimals = _getTokenDecimals(tokenOut);

(px, pxDec) = _getPrice(tokenOut);

Notional & Fees

_computeSwapFrom1kUSD:

notional1k = amountIn1k;

fee1k = (notional1k * feeBps) / 10_000;

net1k = notional1k - fee1k;

netTokenOut = _normalizeFrom1kUSD(net1k, tokenOutDecimals, px, pxDec);

Limits

_enforceLimits(notional1k);

Erneut auf 1kUSD-Notional-Basis.

Slippage-Check

if (netTokenOut < minOut) revert InsufficientOut();

Asset-Flows

1kUSD:

oneKUSD.burn(msg.sender, amountIn1k);

Collateral:

vault.withdraw(tokenOut, address(this), netTokenOut, bytes32("PSM_REDEEM"));

IERC20(tokenOut).safeTransfer(to, netTokenOut);

Fee-Routing

Redeem-Fees werden aktuell als 1kUSD-Notional in fee1k erfasst und
können analog zur Mint-Seite geroutet werden (Erweiterungspotenzial).

Rückgabewert

netOut = netTokenOut;

Events:

SwapFrom1kUSD(...),

PSMSwapExecuted(...).

4. Invarianten (funktionale Sicherheit)
Die wichtigsten Invarianten werden in den Regression-Tests explizit
abgebildet:

4.1 Supply & Balances – Mint-Seite
Aus PSMRegression_Flows.t.sol:

Δ balanceOf(user, 1kUSD) == return value of swapTo1kUSD(...)

Δ totalSupply(1kUSD) == return value of swapTo1kUSD(...)

Δ CollateralVault-Lock (PSM + Vault) == amountIn (bei 1:1-Preis)

Diese Invarianten stellen sicher, dass:

kein „unsichtbares“ Minting stattfindet,

der PSM keine Tokens verschluckt oder erschafft,

Vault-Accounting mit 1kUSD-Supply synchron ist.

4.2 Supply & Balances – Redeem-Seite
Aus testRoundTrip_MintThenRedeem():

Roundtrip (collateral → 1kUSD → collateral) unter 1:1-Preis:

Ohne Fees: User erhält exakt amountIn zurück.

Mit Redeem-Fee:

out == expectedNetTokenOut,

Δ collateralBalance(user) == expectedNetTokenOut.

Damit wird abgesichert:

die Redeem-Flows erzeugen keine „Extra“-Tokens,

Fees werden korrekt abgezogen,

Vault-Balances und User-Balances passen zusammen.

4.3 Limits & Notional
Aus PSMRegression_Limits.t.sol:

Swaps über singleTxCap revertieren deterministisch.

Tages-Volumen über dailyCap revertiert.

vm.warp(+1 days) resetet die dailyCap sauber.

Wichtig:
Alle Limits operieren auf 1kUSD-Notional (18 Decimals), wodurch
Decimals-Unterschiede zwischen Collaterals keinen Einfluss auf die
Risiko-Logik haben.

4.4 Fees – Registry & Fallbacks
Aus PSMRegression_Fees.t.sol:

testMintUsesGlobalRegistryFee

Setzt psm:mintFeeBps und erzwingt, dass Mint-Flow diese Fee nutzt
(auch bei setFees(0, 0) im PSM selbst).

testMintPerTokenOverrideBeatsGlobal

Per-Token Override überschreibt den globalen Wert, wenn > 0.

testRedeemUsesGlobalRegistryFee

Redeem-Flow nutzt den globalen Registry-Wert für Redeem-Fee.

Damit ist garantiert:

Registry-basierte Konfiguration ist führend,

per-Token-Overrides funktionieren wie erwartet,

PSM-Storage dient nur als letzter Fallback.

4.5 Oracle-Health & Safety
Aus OracleRegression_Health.t.sol und OracleRegression_Watcher.t.sol:

maxDiffBps begrenzt die relative Preisänderung je Update.

maxStale begrenzt die Lebensdauer eines Preises.

Bei Verletzung:

Oracle wird als unhealthy markiert.

OracleWatcher meldet schlechten Zustand.

Guardian-/Safety-Pfade können den PSM pausieren.

Dadurch ist sichergestellt, dass:

PSM-Swaps nicht auf extrem alten oder manipulierten Preisen basieren,

Pausierungsketten (Safety → Oracle → PSM) funktionieren,

der PSM in kritischen Situationen deterministisch stoppt.

5. Zusammenfassung
Der aktuelle Stand (DEV-43 → DEV-49) implementiert:

vollständige Mint- und Redeem-Flows mit Vault-Integration,

Registry-gesteuerte Decimals und Fees,

Notional-basiertes Limit-Checking,

Oracle-Health-Gates mit stale/diff-Checks,

und eine Serie von Regression-Tests, die die oben beschriebenen
Invarianten explizit kodieren.

Dieses Dokument dient als Referenz für Auditoren und Governance, um die
Flow-Logik und die garantierten Invarianten des PSM-Stacks nachvollziehen
zu können.
EOL

echo "✓ PSM Flows & Invariants written to $FILE"
