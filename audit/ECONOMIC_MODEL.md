# Economic Model -- v0.51.x

---

## PSM Mint Path (Collateral -> 1kUSD)

```
User approves PSM for tokenIn
  |
  v
PSM.swapTo1kUSD(tokenIn, amountIn, to, minOut, deadline)
  |
  +-- Lookup token decimals from ParameterRegistry (fallback: 18)
  +-- Lookup fee BPS: per-token registry -> global registry -> local mintFeeBps
  +-- Lookup spread BPS: per-token registry -> global registry -> 0
  +-- totalBps = feeBps + spreadBps (require <= 10_000)
  |
  +-- Get oracle price: oracle.getPrice(tokenIn) -> (price, decimals, healthy)
  +-- Normalize to 1kUSD (18 decimals):
  |     amountToken18 = amountIn * 10^(18 - tokenDecimals)   [if tokenDec < 18]
  |     notional1k = (amountToken18 * price) / 10^priceDecimals
  |
  +-- Compute fee: fee1k = (notional1k * totalBps) / 10_000
  +-- Compute net:  net1k = notional1k - fee1k
  |
  +-- Enforce limits: PSMLimits.checkAndUpdate(notional1k)
  +-- Slippage check: require(net1k >= minOut)
  |
  +-- Token transfer: tokenIn moves from user -> CollateralVault
  +-- Vault accounting: vault._balances[tokenIn] += amountIn
  +-- Mint: oneKUSD.mint(to, net1k)
  +-- Fee routing: feeRouter.route(..., fee1k) [no-op if feeRouter == address(0)]
  |
  +-- User receives: net1k of 1kUSD
  +-- Protocol retains: fee1k burned implicitly (not minted) + collateral in vault
```

**Rounding direction:** Integer division in `fee1k = (notional1k * totalBps) / 10_000` truncates (rounds down), meaning the fee is slightly less than the theoretical amount. This favors the user by a dust amount.

---

## PSM Redeem Path (1kUSD -> Collateral)

```
User approves PSM for 1kUSD (via approve or permit)
  |
  v
PSM.swapFrom1kUSD(tokenOut, amountIn1k, to, minOut, deadline)
  |
  +-- notional1k = amountIn1k (the full input)
  +-- fee1k = (notional1k * totalBps) / 10_000
  +-- net1k = notional1k - fee1k
  |
  +-- Reverse normalize to token units:
  |     tokenAmount18 = (net1k * 10^priceDecimals) / price
  |     netTokenOut = tokenAmount18 / 10^(18 - tokenDecimals)   [if tokenDec < 18]
  |
  +-- Enforce limits: PSMLimits.checkAndUpdate(notional1k)
  +-- Slippage check: require(netTokenOut >= minOut)
  |
  +-- Burn: oneKUSD.burn(msg.sender, amountIn1k)   [burns FULL input]
  +-- Vault withdraw: vault.withdraw(tokenOut, psm, netTokenOut, "PSM_REDEEM")
  +-- Token transfer: tokenOut moves from PSM -> user
  |
  +-- User receives: netTokenOut of tokenOut
  +-- Protocol retains: (amountIn1k - net1k) worth of 1kUSD burned permanently
```

**Key insight:** The fee is not collected as 1kUSD tokens. The PSM burns the FULL `amountIn1k` but only withdraws the `netTokenOut` (which corresponds to `net1k`, not `notional1k`). The difference in collateral remains in the vault, effectively increasing the collateral ratio.

---

## Fee Mechanism

### 3-Tier Precedence (per fee/spread type)

```
1. Per-token registry key: keccak256(abi.encode(keccak256("psm:mintFeeBps"), tokenAddress))
   |
   +-- If > 0: use this value (require <= 10_000)
   v
2. Global registry key:   keccak256("psm:mintFeeBps")
   |
   +-- If > 0: use this value (require <= 10_000)
   v
3. Local storage:         PegStabilityModule.mintFeeBps
   |
   +-- Use this value (require <= 10_000)
```

Same pattern for: `redeemFeeBps`, `mintSpreadBps`, `redeemSpreadBps`.

### Combined Validation

```
totalBps = feeBps + spreadBps
require(totalBps <= 10_000, "PSM: fee+spread too high")
```

This prevents a scenario where fee = 6,000 and spread = 5,000 would total 110%.

### Fee + Spread Semantics

- **Fee (BPS):** Protocol revenue deducted from notional amount
- **Spread (BPS):** Price adjustment to account for market conditions (added to fee before application)
- Both are applied identically in the math: `totalBps = fee + spread`

---

## Configurable Economic Parameters

| # | Parameter | Storage | Type | Setter | Max | Default | Units |
|---|-----------|---------|------|--------|-----|---------|-------|
| 1 | `mintFeeBps` (local) | PSM | uint256 | `setFees()` ADMIN_ROLE | 10,000 | 0 | bps |
| 2 | `redeemFeeBps` (local) | PSM | uint256 | `setFees()` ADMIN_ROLE | 10,000 | 0 | bps |
| 3 | Per-token mint fee | Registry | uint256 | `setUint()` admin | 10,000 | 0 | bps |
| 4 | Global mint fee | Registry | uint256 | `setUint()` admin | 10,000 | 0 | bps |
| 5 | Per-token redeem fee | Registry | uint256 | `setUint()` admin | 10,000 | 0 | bps |
| 6 | Global redeem fee | Registry | uint256 | `setUint()` admin | 10,000 | 0 | bps |
| 7 | Per-token mint spread | Registry | uint256 | `setUint()` admin | 10,000 | 0 | bps |
| 8 | Global mint spread | Registry | uint256 | `setUint()` admin | 10,000 | 0 | bps |
| 9 | Per-token redeem spread | Registry | uint256 | `setUint()` admin | 10,000 | 0 | bps |
| 10 | Global redeem spread | Registry | uint256 | `setUint()` admin | 10,000 | 0 | bps |
| 11 | `dailyCap` | PSMLimits | uint256 | `setLimits()` DAO | unlimited | constructor | 1kUSD (18 dec) |
| 12 | `singleTxCap` | PSMLimits | uint256 | `setLimits()` DAO | unlimited | constructor | 1kUSD (18 dec) |
| 13 | `maxBuybackSharePerOpBps` | BuybackVault | uint16 | `setMaxBuybackSharePerOpBps()` DAO | 10,000 | 0 | bps of balance |
| 14 | `maxBuybackSharePerWindowBps` | BuybackVault | uint16 | `setBuybackWindowConfig()` DAO | 10,000 | 0 | bps of basis |
| 15 | `buybackWindowDuration` | BuybackVault | uint64 | `setBuybackWindowConfig()` DAO | unlimited | 0 | seconds |
| 16 | Strategy `weightBps` | BuybackVault | uint16 | `setStrategy()` DAO | unlimited | N/A | bps (advisory) |
| 17 | `oracle:maxStale` | Registry | uint256 | `setUint()` admin | unlimited | 0 | seconds |
| 18 | `oracle:maxDiffBps` | Registry | uint256 | `setUint()` admin | unlimited | 0 | bps |
| 19 | Token decimals | Registry | uint256 | `setUint()` admin | 255 | 18 | decimals |
| 20 | OracleAdapter `heartbeat` | OracleAdapter | uint256 | `setHeartbeat()` DAO | unlimited | 3600 | seconds |

**Note:** Parameters 11-12 have no range validation in `setLimits()`. Parameters 17-18 have no range validation in ParameterRegistry. Parameter 16 (`weightBps`) is advisory only -- not enforced in v0.51.x buyback execution.

---

## PSM Limits

### Daily Cap

```solidity
uint256 day = block.timestamp / 1 days;
if (day > lastUpdatedDay) {
    dailyVolume = 0;          // auto-reset on new day
    lastUpdatedDay = day;
}
require(dailyVolume + amount <= dailyCap);
dailyVolume += amount;
```

Both mint and redeem paths contribute to the same daily volume counter. The notional amount (in 1kUSD, 18 decimals) is used, not the raw token amount.

### Single-Transaction Cap

```solidity
require(amount <= singleTxCap);
```

Applied before the daily cap check.

---

## Buyback Path

```
DAO calls: BuybackVault.executeBuybackPSM(amount1k, recipient, minOut, deadline)
  |
  +-- Pre-checks: recipient != 0, amount1k > 0, bal >= amount1k
  |
  +-- Per-op cap: amount1k <= (bal * maxBuybackSharePerOpBps) / 10_000
  |   (0 = disabled)
  |
  +-- Window cap:
  |   +-- If window expired: reset {start=now, accumulated=0, basis=bal}
  |   +-- deltaBps = ceil(amount1k * 10_000 / basis)
  |   +-- accumulated + deltaBps <= maxBuybackSharePerWindowBps
  |   (dur=0 or cap=0 = disabled)
  |
  +-- Oracle health: IOracleHealthModule.isHealthy() must return true
  |   (oracleHealthGateEnforced=false = disabled)
  |
  +-- Strategy: at least one enabled strategy for the buyback asset
  |   (strategiesEnforced=false = disabled)
  |
  +-- Approve PSM, call psm.swapFrom1kUSD(asset, amount1k, recipient, minOut, deadline)
  |
  +-- Result: 1kUSD burned from vault, asset sent to recipient
```

### Window Cap Math Detail

Ceiling division prevents rounding bypass:
```solidity
uint256 deltaBps = (amountStable * 10_000 + (basis - 1)) / basis;
```

Example: basis = 1000e18, amount = 1e18
- Floor: `(1e18 * 10_000) / 1000e18 = 10` (exactly 0.1%)
- Ceiling: `(1e18 * 10_000 + 999999999999999999) / 1000e18 = 10` (same when exact)
- Sub-BPS amounts round up to 1 BPS minimum

---

## Worst-Case Scenarios

### 1. All Fees Set to Zero

**Impact:** No protocol revenue. Users swap at oracle price with no deduction.
**Risk:** None. Zero fees are a valid configuration. Collateral ratio remains 1:1.

### 2. Oracle Returns Stale/Unhealthy Price

**Impact:** All PSM swaps revert at `_requireOracleHealthy` or `require(p.healthy)`.
**Risk:** Protocol halted until price is refreshed. This is the intended safety behavior.

### 3. maxBuybackSharePerOpBps Set to 10,000 (100%)

**Impact:** A single buyback can spend the entire vault balance.
**Risk:** DAO can drain BuybackVault in one transaction. Window cap provides secondary defense if configured.

### 4. Token Decimals Misconfigured

**Impact:** Silent scaling error. For USDC (6 decimals) treated as 18 decimals: a 1e6 deposit (1 USDC) would be normalized as if it were 1e-12 tokens, producing ~1e-12 1kUSD. The swap would succeed but output a negligible amount.
**Risk:** Economic loss to users. No on-chain revert. Detectable only by comparing expected vs actual outputs.

### 5. PSMLimits Caps Set to Zero

**Impact:** `require(amount <= 0)` and `require(dailyVolume + amount <= 0)` -- all swaps revert.
**Risk:** Protocol halted. Recoverable by DAO calling `setLimits()` with non-zero values.

### 6. Admin Compromised

**Impact:** Attacker can grant self minter role, mint arbitrary 1kUSD, swap for collateral via PSM (if within limits), drain vault.
**Risk:** Full protocol compromise. See THREAT_MODEL.md T7.

---

## Economic Invariants

1. **Supply conservation:** `1kUSD.totalSupply() == sum(mints via PSM) - sum(burns via PSM)`
2. **Collateral backing:** `vault.balanceOf(asset) >= sum(deposits) - sum(withdrawals)` per asset
3. **Fee bounds:** `fee + spread <= 10,000 bps` (enforced per swap)
4. **Rate limit:** `PSMLimits.dailyVolume <= dailyCap` (enforced per swap)
5. **Per-op buyback:** `amount <= (balance * capBps) / 10_000` (enforced per buyback)
6. **Window buyback:** `accumulated BPS <= maxBuybackSharePerWindowBps` (enforced per buyback)
7. **Rounding direction:** Fee computation truncates (rounds down), net output truncates (rounds down). Protocol never underpays itself by more than 1 wei per swap.
