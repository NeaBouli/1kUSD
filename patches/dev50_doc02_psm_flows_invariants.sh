#!/usr/bin/env bash
set -euo pipefail

FILE="docs/architecture/psm_flows_invariants.md"

echo "== DEV50 DOC02: write PSM flows & invariants doc =="

mkdir -p "$(dirname "$FILE")"

cat <<'EOL' > "$FILE"
# PSM Flows & Invariants (DEV-43 → DEV-49)

Dieses Dokument beschreibt die funktionalen Flows und die wichtigsten
Invarianten des PegStabilityModule (PSM), wie sie durch DEV-43 bis DEV-49
implementiert und durch die Foundry-Regressionstests abgesichert sind.

Zielgruppe:
- Auditoren
- Governance / Risk Council
- Core-Dev, der neue Features (Spread, komplexere Fees, weitere Collaterals)
  auf den bestehenden PSM-Stack aufsetzen will.

---

## 1. Überblick

Der PSM stellt eine Fassade bereit, um zwischen einem Collateral-Token
(z. B. `COL`) und dem Stablecoin `1kUSD` zu swappen:

- **Mint-Seite**: `COL` → `1kUSD`
- **Redeem-Seite**: `1kUSD` → `COL`

Dabei greifen folgende Layer ineinander:

1. **OracleAggregator** (Preis + Health, DEV-49):
   - liefert `Price { price, decimals, healthy, timestamp }`,
   - Health wird über `maxDiffBps` und `maxStale` aus der `ParameterRegistry`
     gesteuert.

2. **Notional-Layer (DEV-44)**:
   - Normalisiert Collateral-Amounts in eine **1kUSD-Notional-Einheit (18 Decimals)**,
   - Berechnet Fees in Bps (Mint/Redeem),
   - Leitet Limits in 1kUSD weiter an `PSMLimits`.

3. **PSMLimits**:
   - Erzwingt `singleTxCap` und `dailyCap` in 1kUSD-Notional.

4. **Asset-Flows (DEV-45/46)**:
   - Reale ERC-20-Transfers + Vault-Deposits/Withdraws,
   - Mint/Burn von `OneKUSD`.

5. **ParameterRegistry (DEV-47/48)**:
   - Collateral-Decimals (`psm:tokenDecimals`),
   - Fees (`psm:mintFeeBps`, `psm:redeemFeeBps` + per-Token-Overrides).

6. **Guardian / SafetyAutomata**:
   - Pausiert PSM und Oracle-Layer,
   - Stellt sicher, dass bei pausierten Modulen keine Swaps ausgeführt werden.

Die wichtigsten Tests dazu sind:

- `foundry/test/psm/PSMRegression_Flows.t.sol`
- `foundry/test/psm/PSMRegression_Limits.t.sol`
- `foundry/test/psm/PSMRegression_Fees.t.sol`
- `foundry/test/oracle/OracleRegression_Health.t.sol`
- `foundry/test/Guardian_*` (Propagation, Enforcement, Unpause, Integration)

---

## 2. Mint-Flow (COL → 1kUSD)

### 2.1 High-Level Flow

Aus Sicht eines Users:

1. User besitzt `COL` und ruft  
   `swapTo1kUSD(collateralToken, amountIn, user, minOut, deadline)` auf.
2. PSM:
   - prüft Pause-Status (`SafetyAutomata`),
   - liest Preis + Health aus `OracleAggregator`,
   - normalisiert `amountIn` in eine 1kUSD-Notional-Menge,
   - berechnet Mint-Fee (Registry + Fallback),
   - prüft Limits,
   - zieht Collateral ein (Transfer + Vault-Deposit),
   - mintet `1kUSD` an `user`,
   - routed ggf. Fees an `FeeRouter`.

### 2.2 Detail-Steps

Im Code (vereinfacht):

1. **Pause-Check**

   ```solidity
   whenNotPaused nonReentrant
Oracle-Preis & Health

solidity
Code kopieren
(uint256 px, uint8 pxDec) = _getPrice(tokenIn);
// OracleAggregator prüft selbst Stale / Diff via Registry
Token-Decimals

solidity
Code kopieren
uint8 tokenInDecimals = _getTokenDecimals(tokenIn);
// registry.getUint(psm:tokenDecimals, tokenIn) oder Fallback 18
Notional-Berechnung + Fee

solidity
Code kopieren
(uint256 notional1k, uint256 fee1k, uint256 net1k) =
    _computeSwapTo1kUSD(tokenIn, amountIn, feeBps, tokenInDecimals);
Limits

solidity
Code kopieren
_enforceLimits(notional1k); // PSMLimits.checkAndUpdate(...)
Asset-Fluss + Mint

solidity
Code kopieren
IERC20(tokenIn).safeTransferFrom(msg.sender, address(vault), amountIn);
vault.deposit(tokenIn, msg.sender, amountIn);
oneKUSD.mint(to, net1k);
Fee-Routing

solidity
Code kopieren
if (fee1k > 0 && address(feeRouter) != address(0)) {
    feeRouter.route("PSM_MINT_FEE", address(oneKUSD), fee1k);
}
2.3 Invarianten (Mint)
Die wichtigsten Invarianten, wie sie u. a. in
PSMRegression_Flows.t.sol::testMintFlow_1to1() abgebildet sind:

Bei 1:1-Preis (1 COL = 1 1kUSD, 18 Decimals) und Fee = 0:

Δ 1kUSD.totalSupply == netOut

Δ 1kUSD.balanceOf(user) == netOut

Vault-Balance des Collateral-Assets steigt genau um amountIn.

Bei Fee > 0 (vgl. PSMRegression_Fees):

fee1k == notional1k * feeBps / 10_000

net1k == notional1k - fee1k

psm.swapTo1kUSD(...) gibt exakt net1k zurück.

3. Redeem-Flow (1kUSD → COL)
3.1 High-Level Flow
Aus Sicht eines Users:

User hält 1kUSD und ruft
swapFrom1kUSD(collateralToken, amountIn1k, user, minOut, deadline) auf.

PSM:

prüft Pause-Status,

liest Preis + Health,

nimmt amountIn1k als Notional-Input,

berechnet Redeem-Fee (Registry + Fallback),

berechnet Collateral-Amount über _normalizeFrom1kUSD,

prüft Limits,

burn’t 1kUSD beim User,

zieht Collateral aus dem Vault ab und sendet es an user.

3.2 Detail-Steps
Im Code (vereinfacht):

Pause-Check & Oracle

solidity
Code kopieren
require(amountIn1k > 0, "PSM: amountIn=0");
_requireOracleHealthy(tokenOut);
(uint256 px, uint8 pxDec) = _getPrice(tokenOut);
Decimals + Fee

solidity
Code kopieren
uint8 tokenOutDecimals = _getTokenDecimals(tokenOut);

(uint256 notional1k, uint256 fee1k, uint256 netTokenOut) =
    _computeSwapFrom1kUSD(tokenOut, amountIn1k, feeBps, tokenOutDecimals);
Limits

solidity
Code kopieren
_enforceLimits(notional1k);
Burn + Vault-Withdraw

solidity
Code kopieren
oneKUSD.burn(msg.sender, amountIn1k);
vault.withdraw(tokenOut, address(this), netTokenOut, bytes32("PSM_REDEEM"));
IERC20(tokenOut).safeTransfer(to, netTokenOut);
3.3 Invarianten (Redeem)
In PSMRegression_Flows.t.sol::testRoundTrip_MintThenRedeem():

Bei 1:1-Preis, Fee = 0:

Der Roundtrip COL → 1kUSD → COL stellt die Collateral-Balance des Users
wieder auf den Ursprungswert her (abzüglich evtl. Test-Dust).

1kUSD.totalSupply kehrt auf den ursprünglichen Wert zurück.

In PSMRegression_Fees.t.sol::testRedeemUsesGlobalRegistryFee():

Bei Redeem-Fee > 0:

expectedFee1k = amountIn1k * feeBps / 10_000

netTokenOut == amountIn1k - expectedFee1k (bei 1:1-Preis).

Die Collateral-Balance des Users steigt genau um netTokenOut.

4. Limits & Notional-Layer
PSMLimits arbeitet immer auf der 1kUSD-Notional-Ebene:

singleTxCap:

maximaler 1kUSD-Wert pro Transaktion.

dailyCap:

maximaler 1kUSD-Wert pro Tag (aufsummiert).

Die Regressions-Tests in PSMRegression_Limits.t.sol prüfen u. a.:

testSingleTxLimitReverts():

Swaps oberhalb singleTxCap revertieren.

testDailyCapReverts():

Wiederholte Swaps, die kumuliert dailyCap überschreiten, revertieren.

testDailyReset():

Nach vm.warp(+1 days) wird das Tagesvolumen zurückgesetzt.

5. Oracle-Health & Guardian-Integration
5.1 OracleAggregator Health (DEV-49)
Der OracleAggregator markiert Preise als unhealthy, wenn:

die Zeit seit p.timestamp größer als oracle:maxStale ist (sofern > 0), oder

der relative Preis-Sprung größer als oracle:maxDiffBps ist.

Die Tests in OracleRegression_Health.t.sol decken folgende Szenarien ab:

testMaxDiffBpsAllowsSmallJump()

testMaxDiffBpsMarksLargeJumpUnhealthy()

testMaxStaleMarksOldPriceUnhealthy()

testMaxStaleZeroDoesNotAlterHealth()

5.2 Guardian / SafetyAutomata
Die Guardian-Tests stellen sicher, dass:

Pausieren des ORACLE-Moduls die Watcher-Health beeinflusst und
über Guardian-Pfade propagiert wird.

Pausieren des PSM-Moduls Swaps blockiert (Guardian_PSMEnforcement).

Guardian_PSMUnpause nach einem resumeModule() den PSM-Betrieb wieder
erlaubt; verifiziert u. a. mit einem erfolgreichen swapTo1kUSD.

6. Test-Matrix (Kurzreferenz)
Flows:

foundry/test/psm/PSMRegression_Flows.t.sol

Limits:

foundry/test/psm/PSMRegression_Limits.t.sol

Fees:

foundry/test/psm/PSMRegression_Fees.t.sol

Oracle Health:

foundry/test/oracle/OracleRegression_Health.t.sol

foundry/test/oracle/OracleRegression_Watcher.t.sol

Guardian:

foundry/test/Guardian_OraclePropagation.t.sol

foundry/test/Guardian_PSMEnforcement.t.sol

foundry/test/Guardian_PSMUnpause.t.sol

foundry/test/Guardian_Integration.t.sol

Dieses Dokument dient als Referenz, welche Flows existieren, welche
Invarianten gelten und wo sie in den Tests verankert sind. Neue Features
(weitere Collaterals, Spread-Modelle, komplexere Fees) sollten ihre eigenen
Invarianten klar gegenüber diesem Kern definieren.
EOL

echo "✓ PSM flows & invariants written to $FILE"
