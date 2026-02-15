# Threat Model -- v0.51.x

**Scope:** All contracts in `contracts/core/`, `contracts/psm/`, `contracts/oracle/`, `contracts/security/`, `contracts/router/`

---

## Assets at Risk

1. **Collateral tokens** held in CollateralVault (USDC, USDT, DAI, etc.)
2. **1kUSD supply integrity** -- unauthorized mint inflates supply, breaking peg
3. **Protocol governance authority** -- admin/DAO key compromise
4. **Oracle integrity** -- manipulated prices enable arbitrage extraction

---

## Attack Surface

### T1: Unauthorized Mint

| Field | Detail |
|-------|--------|
| **Vector** | Attacker calls `OneKUSD.mint()` directly, bypassing PSM |
| **Precondition** | Attacker address must have `isMinter[attacker] == true` |
| **Mitigation** | `mint()` checks `isMinter[msg.sender]`; only admin can call `setMinter()`. In production, only the PSM contract should hold minter role |
| **Residual risk** | Admin compromise allows granting minter to arbitrary address. No timelock on `setMinter()` in v0.51.x |
| **Telemetry** | `MinterSet(address, bool)` on role change; `Transfer(address(0), to, amount)` on every mint |

### T2: Unauthorized Burn

| Field | Detail |
|-------|--------|
| **Vector** | Attacker calls `OneKUSD.burn(victim, amount)` to destroy victim's tokens |
| **Precondition** | Attacker address must have `isBurner[attacker] == true` |
| **Mitigation** | `burn()` checks `isBurner[msg.sender]`; only admin can call `setBurner()`. In production, only the PSM contract should hold burner role |
| **Residual risk** | Same as T1 -- admin compromise |
| **Telemetry** | `BurnerSet(address, bool)` on role change; `Transfer(from, address(0), amount)` on every burn |

### T3: Oracle Price Manipulation

| Field | Detail |
|-------|--------|
| **Vector** | Admin (or compromised admin) calls `setPriceMock()` with manipulated price, enabling arbitrage swaps at incorrect rates |
| **Precondition** | Caller must be `admin` of OracleAggregator |
| **Mitigation** | (1) Deviation gate: `oracle:maxDiffBps` in ParameterRegistry limits per-update price jumps. (2) Staleness gate: `oracle:maxStale` marks old prices unhealthy. (3) SafetyAutomata can pause ORACLE module. (4) `setPriceMock` itself is gated by `notPaused` |
| **Residual risk** | Admin can set `maxDiffBps = 0` (disable deviation check) then push arbitrary price. Mock oracle is a v0.51.x design choice; production feeds would introduce external oracle risk |
| **Telemetry** | `OracleUpdated(asset, price, decimals, healthy)` on every price push |

### T4: Vault Drain via Unauthorized Withdraw

| Field | Detail |
|-------|--------|
| **Vector** | Attacker calls `CollateralVault.withdraw()` directly to extract collateral |
| **Precondition** | Caller must be in `authorizedCallers` mapping or be `admin` |
| **Mitigation** | `onlyAuthorized` modifier on deposit/withdraw. `setAuthorizedCaller` is `onlyAdmin`. `onlySupported` restricts which assets can move |
| **Residual risk** | Admin compromise allows whitelisting attacker. Vault trusts `amount` parameter (no received-amount check) -- a fee-on-transfer token would cause accounting drift (not supported in v0.51.x) |
| **Telemetry** | `AuthorizedCallerSet(caller, bool)` on whitelist change; `Withdraw(asset, to, amount, reason)` on every withdrawal |

### T5: Rate Limit Bypass

| Field | Detail |
|-------|--------|
| **Vector** | Attacker executes many swaps to drain collateral before daily cap triggers |
| **Precondition** | PSMLimits must be configured and wired (`psm.setLimits(limitsAddress)` + `limits.setAuthorizedCaller(psm, true)`) |
| **Mitigation** | `PSMLimits.checkAndUpdate()` enforces `singleTxCap` and `dailyCap`. Day boundary auto-resets at `block.timestamp / 1 days` |
| **Residual risk** | If `psm.limits() == address(0)`, all limit enforcement is skipped (by design -- limits are optional). Caps are DAO-configurable with no range validation |
| **Telemetry** | **Gap:** PSMLimits emits no events. Volume state only observable via direct contract reads |

### T6: BuybackVault Treasury Drain

| Field | Detail |
|-------|--------|
| **Vector** | Compromised DAO executes large buybacks to drain vault treasury |
| **Precondition** | Caller must be `dao` (immutable in BuybackVault constructor) |
| **Mitigation** | (1) Per-op cap: `maxBuybackSharePerOpBps` limits single buyback. (2) Window cap: `maxBuybackSharePerWindowBps` limits cumulative within rolling window. (3) Oracle health gate: blocks buyback if oracle unhealthy. (4) Strategy enforcement: restricts buyback to configured asset |
| **Residual risk** | DAO can set caps to max (10_000 bps = 100%) or disable them (set to 0). DAO can also call `withdrawStable()` / `withdrawAsset()` directly. All BuybackVault state is DAO-writable |
| **Telemetry** | `BuybackExecuted(recipient, stableIn, assetOut)`, `BuybackTreasuryCapUpdated(old, new)`, `BuybackWindowConfigUpdated(...)` |

### T7: Governance / Admin Key Compromise

| Field | Detail |
|-------|--------|
| **Vector** | Attacker obtains admin private key |
| **Impact** | Can change oracle, registry, vault admin, OneKUSD roles, fees -- effectively full protocol control |
| **Mitigation** | v0.51.x: No on-chain timelock enforcement (DAOTimelock is a skeleton). Guardian sunset limits guardian powers over time. Multi-sig recommended at deployment |
| **Residual risk** | Single admin address across most contracts. No enforced delay on admin actions. `setAdmin()` is single-step (no two-step transfer pattern) |
| **Telemetry** | `AdminChanged(old, new)` on every contract that supports admin transfer |

### T8: Reentrancy

| Field | Detail |
|-------|--------|
| **Vector** | Malicious token callback during PSM swap or vault transfer re-enters protocol |
| **Mitigation** | PSM: `nonReentrant` modifier (OpenZeppelin ReentrancyGuard) on both `swapTo1kUSD` and `swapFrom1kUSD`. BuybackVault: `onlyDAO` makes reentrant calls from untrusted source impossible |
| **Residual risk** | CollateralVault has no `ReentrancyGuard`. Its `withdraw()` calls `safeTransfer()` which could invoke a callback on a malicious token. Mitigated by: only PSM (which is `nonReentrant`) can call vault, and only admin-whitelisted assets are supported. BuybackVault writes state before external PSM call (G2 -- accepted risk, `onlyDAO` mitigated) |
| **Telemetry** | N/A (reentrancy attacks do not generate distinct events) |

### T9: ERC-20 Token Quirks

| Field | Detail |
|-------|--------|
| **Vector** | Fee-on-transfer (FoT) tokens, rebasing tokens, tokens with non-standard return values |
| **Mitigation** | SafeERC20 used for all `transfer`/`transferFrom`/`approve` calls. CollateralVault tracks `_balances` via trusted `amount` parameter |
| **Residual risk** | If a FoT token is whitelisted, vault accounting drifts: `_balances[asset]` records the requested amount, not the actually received amount. Redeems would eventually fail with `INSUFFICIENT_VAULT_BALANCE`. This is a known limitation (v0.52+ item) |
| **Telemetry** | No specific telemetry. Drift detectable by comparing `vault.balanceOf(asset)` vs `IERC20(asset).balanceOf(address(vault))` |

### T10: Decimal Mismatch / Scaling Error

| Field | Detail |
|-------|--------|
| **Vector** | Admin fails to configure `psm:tokenDecimals` in ParameterRegistry for a non-18-decimal token (e.g., USDC = 6 decimals) |
| **Impact** | Silent 1e12 scaling error. A 1 USDC deposit (1e6) would be treated as 1e6 tokens with 18 decimals instead of 6, producing a 1e-12 1kUSD output instead of ~1.0 |
| **Mitigation** | Deployment checklist requires setting token decimals for every non-18-decimal collateral. `_getTokenDecimals` falls back to 18 if unset |
| **Residual risk** | No on-chain validation that registry decimals match actual `IERC20.decimals()`. Configuration error produces silently wrong amounts, not reverts |
| **Telemetry** | No specific telemetry. Detectable by comparing swap outputs against expected values |

---

## Trust Assumptions

1. **Admin keys are honestly controlled** (multi-sig recommended, not enforced on-chain)
2. **DAO multisig acts rationally** for BuybackVault operations
3. **Whitelisted collateral tokens are standard ERC-20** (no FoT, no rebasing, no callback exploits)
4. **Oracle prices are set accurately** (mock oracle in v0.51.x -- admin-controlled)
5. **Block timestamps are approximately correct** (relevant for staleness, deadline, guardian sunset)
6. **Guardian sunset timestamp is set to a reasonable future date** at deployment

---

## Audit Questions Checklist

1. Can any path mint 1kUSD without depositing equivalent collateral into the vault?
2. Can any path withdraw collateral without burning equivalent 1kUSD?
3. Are fee/spread rounding directions consistent? (fee favors protocol, net output favors protocol)
4. Can PSMLimits be bypassed via alternative swap paths?
5. Can paused modules be circumvented by calling internal functions or different entry points?
6. Is the guardian sunset boundary strictly enforced? (block.timestamp >= sunset, not >)
7. Can the `ParameterRegistry` be used to set parameters that bypass validation in consumer contracts?
8. What happens if `setFees(10_000, 10_000)` is called? (100% fee -- net output = 0, swap succeeds with 0 output if `minOut == 0`)
9. Can `executeBuybackPSM` be called when the vault has 0 stable balance? (Should revert `INSUFFICIENT_BALANCE`)
10. Does the window cap ceiling division correctly prevent rounding bypass?
