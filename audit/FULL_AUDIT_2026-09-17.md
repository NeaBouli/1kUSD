# 1kUSD Full Security & Quality Audit

**Date:** 2026-09-17
**Auditor:** Claude Code (Opus 4.6, targeted specialist review)
**Repo:** `NeaBouli/1kUSD` -- HEAD `2a5ec38` (Branch `main`)
**Stack:** Solidity 0.8.30, Foundry, OpenZeppelin v4.8 + v5.4, EVM Paris
**Scope:** 18 core contracts, 1,896 SLoC, 40 Solidity files, 198 test cases, deploy pipeline, infrastructure
**Cross-Ref:** `audit/AUDIT_SCOPE.md`, `audit/THREAT_MODEL.md`, `audit/TRUST_MODEL.md`, `audit/INVARIANTS.md`, `audit/ROLE_MATRIX.md`

---

## Executive Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 5 |
| HIGH | 10 |
| MEDIUM | 16 |
| LOW | 18 |
| INFO | 7+ |

The 1kUSD protocol has a solid architectural foundation with well-structured separation of concerns (PSM, CollateralVault, Oracle, Safety, Guardian). However, **the governance layer is non-functional** (DAO_Timelock is a skeleton), **several critical token-handling bugs exist** in PSM and BuybackVault, and **the infrastructure contains tracked build artifacts, compiler mismatches, and hardcoded keys**. The test suite (198 tests) has good coverage of core flows but critical gaps in permit(), TreasuryVault, and negative-path testing.

---

## CRITICAL Findings

### C-01: DAO_Timelock Is a Non-Functional Skeleton

- **File:** `contracts/core/DAO_Timelock.sol`
- **Severity:** CRITICAL

`execute()` unconditionally reverts with `"NOT_IMPLEMENTED"`. The DAO_Timelock is the intended eventual owner of all admin functions (per TRUST_MODEL.md), but it cannot execute any operation. This means:

1. **No on-chain governance path exists** -- all admin power remains with the deployer EOA indefinitely
2. The claimed "DAO migration path" in documentation is aspirational, not functional
3. Any transfer of admin roles to the Timelock would **permanently brick the protocol**

**Recommendation:** Either implement a minimal TimelockController (e.g., OZ's) or remove the skeleton entirely and document that governance migration is a future milestone. Do NOT transfer any roles to this contract.

---

### C-02: PegStabilityModule -- Burn Without Allowance Check

- **File:** `contracts/core/PegStabilityModule.sol:redeem()`
- **Severity:** CRITICAL

In `redeem()`, the PSM calls `oneKUSD.burn(msg.sender, burnAmount)` to burn the user's 1kUSD tokens. However, `OneKUSD.burn()` is a privileged function callable by `MINTER_ROLE` holders -- it does **not** check or consume an ERC-20 allowance from `msg.sender` to the PSM.

This means the PSM can burn tokens from `msg.sender` without the user having approved the PSM contract. While the user initiates the call (so `msg.sender` is the token holder), this pattern:

1. Violates the ERC-20 allowance model users and integrators expect
2. Makes it impossible for smart contract wallets / multisigs to use `redeem()` through intermediary contracts
3. Any contract with `MINTER_ROLE` can burn tokens from any address without approval

**Recommendation:** Use `oneKUSD.burnFrom(msg.sender, burnAmount)` which consumes allowance, or add an explicit `transferFrom` to the PSM followed by a `burn` of PSM-held tokens.

---

### C-03: BuybackVault -- Unused Allowance Accumulation

- **File:** `contracts/core/BuybackVault.sol:executeBuyback()`
- **Severity:** CRITICAL

`executeBuyback()` calls `collateral.approve(strategy, amount)` before the external strategy call, but if the strategy consumes less than `amount`, the leftover allowance persists. Over multiple partial buybacks, a malicious or compromised strategy contract could accumulate and later drain a large allowance in a single call.

**Recommendation:** After the strategy call, reset the allowance to zero:
```solidity
collateral.approve(strategy, amount);
strategy.execute(amount);
collateral.approve(strategy, 0);
```

Or use `safeIncreaseAllowance` / `safeDecreaseAllowance` patterns. Verify the `amount` actually transferred post-call.

---

### C-04: Admin Can Brick the Protocol via Single-Step Role Transfer

- **Files:** `contracts/core/PegStabilityModule.sol`, `contracts/core/OneKUSD.sol`, `contracts/core/CollateralVault.sol`, all AccessControl-inheriting contracts
- **Severity:** CRITICAL

All contracts use OpenZeppelin `AccessControl`, which allows `grantRole()` + `renounceRole()` in a single transaction. If the admin grants `DEFAULT_ADMIN_ROLE` to the DAO_Timelock (which is non-functional, see C-01) and renounces their own admin role, **all admin functions become permanently inaccessible**. This would:

1. Freeze all parameter changes (fees, limits, oracle config)
2. Prevent emergency pause/unpause (if SafetyAutomata admin is also transferred)
3. Lock the protocol in its current state permanently with no recovery path

Combined with C-01, this is the most dangerous admin error path.

**Recommendation:** Implement a two-step admin transfer pattern (propose + accept) similar to OpenZeppelin's `Ownable2Step`. Add a guard that prevents transferring admin to contracts that don't implement an acceptance interface.

---

### C-05: Build Artifacts (`out/`) Tracked in Git

- **File:** `out/` directory (100+ JSON files)
- **Severity:** CRITICAL (Infrastructure)

The entire Foundry `out/` build directory is tracked in git. This:

1. **Bloats the repository** with regenerable artifacts (megabytes of ABI JSON)
2. **Creates constant merge conflicts** on every compilation
3. **May contain sensitive build metadata** (paths, compiler settings)
4. Violates standard Foundry `.gitignore` practice

**Recommendation:** Add `out/` to `.gitignore` and remove from tracking:
```bash
echo "out/" >> .gitignore
git rm -r --cached out/
```

---

## HIGH Findings

### H-01: Fee Revenue Never Captured by Protocol

- **Files:** `contracts/core/PegStabilityModule.sol:mint()`, `contracts/core/PegStabilityModule.sol:redeem()`
- **Severity:** HIGH

`mint()` calculates `feeAmount` and subtracts it from the user's deposit to determine `mintAmount`. But the fee tokens are never transferred to a fee receiver -- they simply remain in the user's wallet (never taken) or are absorbed into the vault balance without accounting.

In `redeem()`, `redeemFee` is deducted from the collateral returned, but the fee portion stays in the CollateralVault without explicit fee-accounting, making it impossible to distinguish fee revenue from user collateral.

**Impact:** The protocol generates no extractable fee revenue despite charging fees. Fee parameters exist but are economically inert.

**Recommendation:** Transfer fee amounts to a dedicated `feeReceiver` address (e.g., FeeRouter or TreasuryVault) with explicit accounting.

---

### H-02: PSM Constructor Missing Zero-Address Validation

- **File:** `contracts/core/PegStabilityModule.sol:constructor()`
- **Severity:** HIGH

The constructor accepts `_oneKUSD`, `_collateral`, `_vault`, `_oracle`, `_safety`, `_feeRouter`, `_limits`, `_registry` without checking any for `address(0)`. Deploying with a zero address for any critical dependency would create a non-functional or partially bricked PSM that would need to be redeployed.

**Recommendation:** Add `require(addr != address(0))` for all constructor parameters.

---

### H-03: Fee Rounding Favors Zero-Fee on Small Amounts

- **File:** `contracts/core/PegStabilityModule.sol:_calculateFee()`
- **Severity:** HIGH

```solidity
uint256 fee = (amount * feeRate) / FEE_DENOMINATOR;
```

For small `amount * feeRate` values, integer division truncates to zero. An attacker could split a large mint into many small transactions, each below the rounding threshold, effectively paying zero fees.

**Recommendation:** Enforce a minimum fee of 1 wei when `feeRate > 0 && amount > 0`:
```solidity
uint256 fee = (amount * feeRate) / FEE_DENOMINATOR;
if (fee == 0 && feeRate > 0 && amount > 0) fee = 1;
```

---

### H-04: Decimals Fallback to 18 Without Verification

- **File:** `contracts/core/PegStabilityModule.sol`
- **Severity:** HIGH

The PSM assumes 18-decimal collateral tokens. If a non-18-decimal token (e.g., USDC with 6 decimals) is used, all amount calculations would be off by 10^12, causing:

1. Massive over-minting on deposits (1 USDC = 10^12 1kUSD)
2. Or inability to redeem (amounts too small after scaling)

The code contains no `decimals()` call or scaling logic.

**Recommendation:** Query `IERC20Metadata(collateral).decimals()` in constructor, store the scaling factor, and apply it in all mint/redeem calculations.

---

### H-05: ParameterRegistry Has No Value Validation

- **File:** `contracts/core/ParameterRegistry.sol:setParameter()`
- **Severity:** HIGH

`setParameter()` accepts any `uint256` value for any key without bounds checking. An admin (or compromised admin key) could set:

- `mintFee` to 100% (blocks all minting)
- `redeemFee` to 100% (blocks all redemption)
- `dailyMintLimit` to 0 (blocks all minting)
- `oracleDeviation` to type(uint256).max (disables oracle safety)

**Recommendation:** Add per-parameter min/max bounds. Store allowed ranges in the registry itself.

---

### H-06: PSMLimits Has No Range Validation on setLimits()

- **File:** `contracts/psm/PSMLimits.sol:setLimits()`
- **Severity:** HIGH

Accepts any values for daily/transaction limits without validation:
- `dailyLimit = 0` effectively pauses the PSM
- `txLimit > dailyLimit` is contradictory but allowed
- `txLimit = type(uint256).max` effectively disables per-tx limits

**Recommendation:** Validate `txLimit <= dailyLimit`, `dailyLimit > 0` (or use a separate pause mechanism), and set reasonable upper bounds.

---

### H-07: OracleWatcher Constructor Missing Zero-Address Check

- **File:** `contracts/core/OracleWatcher.sol:constructor()`
- **Severity:** HIGH

Accepts `_oracle` and `_registry` without zero-address validation. A zero-address oracle would cause all price checks to revert, potentially bricking dependent contracts.

---

### H-08: Compiler Version Mismatch Between Foundry and Hardhat

- **File:** `foundry.toml` (solc 0.8.30) vs `hardhat.config.ts` (solc 0.8.24)
- **Severity:** HIGH (Infrastructure)

The Foundry config compiles with Solidity 0.8.30, while Hardhat uses 0.8.24. This can cause:

1. **Silent behavior differences** between test environments
2. **Bytecode mismatch** if deploying from different tools
3. Solidity 0.8.30 features used in code may not compile under 0.8.24

**Recommendation:** Align both to the same compiler version (0.8.30 if that's the target).

---

### H-09: Duplicate `remappings` Key in foundry.toml

- **File:** `foundry.toml`
- **Severity:** HIGH (Infrastructure)

The `remappings` key appears twice in foundry.toml. TOML spec says the last value wins, meaning the first set of remappings is silently ignored. This can cause import resolution failures or wrong library versions being linked.

**Recommendation:** Merge into a single `remappings` array.

---

### H-10: Hardcoded Anvil Private Key in Deploy Script

- **File:** `scripts/10_deploy_skeleton.ts`
- **Severity:** HIGH (Infrastructure)

Contains the well-known Anvil default private key (`0xac0974bec...`) as a fallback when `DEPLOYER_PRIVATE_KEY` is not set. While this key is publicly known and only for local testing, the pattern is dangerous:

1. Copy-paste errors could deploy to mainnet with this key
2. The key provides a false sense of "it works" during deployment testing

**Recommendation:** Fail closed when `DEPLOYER_PRIVATE_KEY` is not set. Never provide a fallback key.

---

## MEDIUM Findings

### M-01: Fee-on-Transfer Token Accounting Desync

- **File:** `contracts/core/CollateralVault.sol:deposit()`
- **Severity:** MEDIUM

`deposit()` trusts the `amount` parameter for internal accounting without checking the actual tokens received:
```solidity
balances[token][msg.sender] += amount;
IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
```

If the collateral token has a fee-on-transfer mechanism, the vault will credit more than actually received, allowing the depositor to withdraw more than they deposited (phantom balance attack).

**Recommendation:** Measure `balanceOf` before and after transfer; credit only the actual delta.

---

### M-02: SafetyAutomata Guardian Precedence After Sunset

- **File:** `contracts/core/SafetyAutomata.sol`
- **Severity:** MEDIUM

The Guardian has a `sunsetTimestamp` after which its emergency powers should expire. However, `SafetyAutomata.pause()` checks `hasRole(PAUSER_ROLE, msg.sender)` without checking whether the Guardian's sunset has passed. A Guardian that should have lost its powers can still pause the protocol indefinitely.

**Recommendation:** Check `block.timestamp < guardian.sunsetTimestamp` in the pause path when `msg.sender` is the Guardian.

---

### M-03: OneKUSD permit() Completely Untested

- **File:** `contracts/core/OneKUSD.sol:permit()`
- **Severity:** MEDIUM

The `permit()` function (EIP-2612) is inherited from OpenZeppelin ERC20Permit but has zero test coverage. `permit()` is a critical function for gasless approvals and is frequently targeted in exploits (signature replay, domain separator issues).

**Recommendation:** Add tests covering:
- Valid permit execution
- Expired deadline rejection
- Wrong signer rejection
- Nonce replay rejection
- Cross-chain domain separator

---

### M-04: TreasuryVault Has Zero Test Coverage

- **File:** `contracts/core/TreasuryVault.sol`, `test/TreasuryVault.t.sol`
- **Severity:** MEDIUM

TreasuryVault is a critical component that holds protocol revenue, but the test file contains only placeholder/stub tests. No actual withdrawal, access control, or accounting logic is tested.

---

### M-05: Window Basis Change Can Reset Daily Limits Mid-Day

- **File:** `contracts/psm/PSMLimits.sol`
- **Severity:** MEDIUM

If `setWindowBasis()` is called mid-day, the daily usage counter resets because the window calculation changes. An attacker monitoring the mempool could frontrun a window basis change to effectively double their daily limit.

---

### M-06: Multi-Collateral Fuzz Testing Gap

- **Severity:** MEDIUM

All fuzz tests use a single collateral type (MockERC20 with 18 decimals). No fuzz coverage for:
- 6-decimal tokens (USDC, USDT)
- Fee-on-transfer tokens
- Rebasing tokens
- Token-with-blocklist (USDC admin freeze)

---

### M-07: Oracle Price Range Not Bounded

- **File:** `contracts/core/OracleAggregator.sol`
- **Severity:** MEDIUM

No sanity bounds on oracle prices. A compromised or malfunctioning oracle feed could report:
- Price = 0 (division by zero in PSM calculations)
- Price = type(uint256).max (overflow in multiplication)
- Negative deviation (if using signed math)

**Recommendation:** Add configurable min/max price bounds. Reject prices outside expected range.

---

### M-08: Admin Transfer Has No Timelock/Delay

- **Files:** All AccessControl contracts
- **Severity:** MEDIUM

`grantRole(DEFAULT_ADMIN_ROLE, newAdmin)` takes effect immediately. No timelock, no community notification, no cancellation window. Combined with the power to change all protocol parameters, this makes admin key compromise instantly catastrophic.

---

### M-09: 11 Placeholder Tests Count as "Passing"

- **File:** Various test files
- **Severity:** MEDIUM

11 test functions contain only placeholder logic (e.g., `assertTrue(true)`) but count toward the "198 tests passing" metric. This inflates test coverage statistics and creates false confidence.

**Affected tests:**
- TreasuryVault: 5 placeholders
- DAO_Timelock: 3 placeholders
- Various integration: 3 placeholders

---

### M-10: No Slither or Static Analysis in CI

- **File:** `.github/workflows/`
- **Severity:** MEDIUM

The CI pipeline runs Foundry tests but no static analysis tool (Slither, Mythril, Aderyn). Static analysis catches common vulnerability patterns that unit tests miss (reentrancy, unchecked return values, gas griefing).

**Recommendation:** Add a Slither job to the CI workflow.

---

### M-11: No package-lock.json / Reproducible JS Dependencies

- **Severity:** MEDIUM (Infrastructure)

The Hardhat/JS tooling has no lockfile, meaning `npm install` resolves to whatever versions are currently latest. This makes builds non-reproducible and vulnerable to dependency confusion attacks.

**Recommendation:** Generate and commit `package-lock.json`. Use `npm ci` in CI.

---

### M-12: Stale .bak and Patch Files in Repository

- **Files:** Multiple `.bak`, `.patch`, `.bak_*` files throughout the repo
- **Severity:** MEDIUM (Infrastructure)

Numerous backup and patch files from development remain in the repository, including in the `archive/` directory. These add noise and may contain outdated/vulnerable code patterns.

---

### M-13: Debug console.log Imports in Test Files

- **File:** Various test files
- **Severity:** MEDIUM (Infrastructure)

Multiple test files import `forge-std/console.sol` with active `console.log()` statements. While these don't affect production bytecode, they slow test execution and add noise to CI output.

---

### M-14: Security Checks Disabled in CI

- **File:** `.github/workflows/`
- **Severity:** MEDIUM (Infrastructure)

The `security-check` job in CI is currently disabled or configured to always pass. This means known vulnerability patterns are not caught before merge.

---

### M-15: Junk Files at Repository Root

- **Files:** `1kUSD.png`, `1kusd_400x400.jpg`, `BACKLOG.md` (untracked)
- **Severity:** MEDIUM (Infrastructure)

Image files and planning documents at the repository root that should be in `docs/assets/` or `.github/` respectively.

---

### M-16: OpenZeppelin Dual Version (v4.8 + v5.4)

- **Files:** `lib/openzeppelin-contracts/` (v4.8), import paths referencing v5.4
- **Severity:** MEDIUM

Using two different OpenZeppelin versions simultaneously creates confusion about which version's security patches apply, and can lead to subtle incompatibilities (e.g., AccessControl behavior changes between v4 and v5).

**Recommendation:** Consolidate to a single OZ version.

---

## LOW Findings

| # | Finding | File |
|---|---------|------|
| L-01 | `renounceRole(DEFAULT_ADMIN_ROLE)` not overridden to prevent accidental loss | All AccessControl contracts |
| L-02 | PSM events emit `amount` before fee deduction (misleading) | `PegStabilityModule.sol` |
| L-03 | No `receive()` / `fallback()` on contracts that shouldn't accept ETH | Multiple core contracts |
| L-04 | Guardian sunset timestamp not validated against deployment time | `Guardian.sol` |
| L-05 | FeeRouter destination addresses not validated on construction | `FeeRouter.sol` |
| L-06 | OracleAggregator `updatePrice()` has no staleness check | `OracleAggregator.sol` |
| L-07 | Mock contracts deployed in test share addresses with production | Various test files |
| L-08 | No EIP-165 `supportsInterface()` on core contracts | Multiple |
| L-09 | Missing NatSpec on 12 public/external functions | Various |
| L-10 | `SafetyNet.sol` redundant with `SafetyAutomata.sol` | `contracts/core/` |
| L-11 | `PegStabilityEngine.sol` appears to be a deprecated duplicate of PSM | `contracts/core/` |
| L-12 | Test helper contracts in `contracts/mocks/` could be moved to `test/` | `contracts/mocks/` |
| L-13 | No explicit Solidity version range in contracts (uses exact `0.8.30`) | All contracts |
| L-14 | `unchecked` block in `OneKUSD._transfer()` -- safe but obscures intent | `OneKUSD.sol` |
| L-15 | GuardianMonitor has no test coverage | `contracts/core/GuardianMonitor.sol` |
| L-16 | FeeRouterV2 exists alongside FeeRouter with unclear migration path | `contracts/core/` |
| L-17 | 1kUSD-wiki-backup directory untracked at root | Repository root |
| L-18 | `.claude/` directory untracked at root (agent config leakage) | Repository root |

---

## INFO Findings

| # | Finding |
|---|---------|
| I-01 | 40 Solidity files total; 18 are in-scope core contracts per AUDIT_SCOPE.md |
| I-02 | KNOWN_LIMITATIONS.md already documents some accepted risks (good practice) |
| I-03 | INVARIANTS.md documents 40 invariants (E1-E7, S1-S5, F1-F18, P1-P10) -- excellent |
| I-04 | THREAT_MODEL.md covers 10 attack classes (T1-T10) -- comprehensive |
| I-05 | TRUST_MODEL.md and ROLE_MATRIX.md provide clear role documentation |
| I-06 | Test naming convention is consistent and descriptive |
| I-07 | Foundry fuzz testing configured: 256 runs x 64 depth |

---

## Test Coverage Summary

| Metric | Value |
|--------|-------|
| Test files | ~15 |
| Test cases | 198 (all pass) |
| Placeholder tests | 11 (count as passing but test nothing) |
| Effective test cases | ~187 |
| Fuzz tests | Present (256 runs, 64 depth) |
| Invariant tests | Present but limited to single-collateral |
| Static analysis (Slither) | **Not in CI** |

### Critical Untested Paths

| Path | Risk |
|------|------|
| `OneKUSD.permit()` | **HIGH** -- EIP-2612 gasless approval, signature replay |
| `TreasuryVault.*` | **HIGH** -- protocol revenue storage |
| `DAO_Timelock.*` | **CRITICAL** -- governance (though currently non-functional) |
| `GuardianMonitor.*` | **MEDIUM** -- monitoring automation |
| `SafetyNet.*` | **LOW** -- appears redundant with SafetyAutomata |
| Multi-collateral scenarios | **HIGH** -- all tests use 18-decimal MockERC20 |
| Fee-on-transfer tokens | **MEDIUM** -- phantom balance attack vector |
| Admin role transfer sequences | **HIGH** -- C-04 brick scenario |

---

## Positive Findings

The 1kUSD codebase demonstrates several strong security practices:

- **Comprehensive audit documentation**: AUDIT_SCOPE, THREAT_MODEL, TRUST_MODEL, INVARIANTS, ROLE_MATRIX -- rare for pre-audit codebases
- **Separation of concerns**: PSM, Vault, Oracle, Safety, Guardian are cleanly separated
- **ReentrancyGuard** applied consistently on state-changing external functions
- **SafeERC20** used for all token transfers (safeTransfer, safeTransferFrom)
- **Pausable** pattern with dedicated SafetyAutomata for emergency stops
- **Guardian time-limited powers** with sunset mechanism (conceptually sound, needs M-02 fix)
- **Fuzz testing** with meaningful invariants
- **CEI pattern** followed in most functions (BuybackVault exception acknowledged in KNOWN_LIMITATIONS)
- **Immutable state variables** used where appropriate

---

## Prioritized Remediation Plan

| Priority | Action | Estimated Effort |
|----------|--------|------------------|
| **P0** | C-01: Implement or remove DAO_Timelock -- document governance gap | 4h |
| **P0** | C-02: Fix burn-without-allowance in PSM redeem() | 1h |
| **P0** | C-03: Reset BuybackVault allowance after strategy call | 30min |
| **P0** | C-04: Implement two-step admin transfer + renounce guard | 3h |
| **P0** | C-05: Remove `out/` from git tracking, add to .gitignore | 15min |
| **P1** | H-01: Implement fee capture to FeeRouter/Treasury | 2h |
| **P1** | H-02: Add zero-address checks to PSM constructor | 30min |
| **P1** | H-03: Fix fee rounding (enforce minimum 1 wei) | 30min |
| **P1** | H-04: Add decimal scaling for non-18-decimal tokens | 2h |
| **P1** | H-05/H-06: Add bounds validation to ParameterRegistry + PSMLimits | 2h |
| **P1** | H-07: Add zero-address check to OracleWatcher constructor | 15min |
| **P1** | H-08/H-09: Fix compiler mismatch + duplicate remappings | 30min |
| **P1** | H-10: Remove hardcoded Anvil key fallback | 15min |
| **P2** | M-01: Balance-delta pattern for FoT tokens in CollateralVault | 1h |
| **P2** | M-02: Guardian sunset check in SafetyAutomata.pause() | 30min |
| **P2** | M-03/M-04: Write tests for permit() and TreasuryVault | 4h |
| **P2** | M-09: Replace 11 placeholder tests with real tests | 3h |
| **P2** | M-10: Add Slither to CI | 1h |
| **P2** | M-11: Generate and commit package-lock.json | 15min |
| **P2** | M-16: Consolidate to single OZ version | 2h |
| **P3** | M-05 through M-08: Window basis, fuzz gaps, oracle bounds, admin delay | 4h |
| **P3** | M-12 through M-15: Repository cleanup (stale files, debug logs, junk) | 1h |
| **P3** | L-01 through L-18: Low severity items | 4h |

---

## Cross-Reference with Existing Audit Documentation

| Document | Status |
|----------|--------|
| `audit/AUDIT_SCOPE.md` | Accurate -- 18 contracts, 1,896 SLoC confirmed |
| `audit/THREAT_MODEL.md` | Good coverage (T1-T10), but missing: admin key compromise (C-04), FoT tokens (M-01) |
| `audit/TRUST_MODEL.md` | Accurate roles, but DAO_Timelock trust assumption is invalid (C-01) |
| `audit/INVARIANTS.md` | 40 invariants documented; ~30 have test coverage, ~10 untested |
| `audit/ROLE_MATRIX.md` | Accurate function-level access control mapping |
| `audit/KNOWN_LIMITATIONS.md` | BuybackVault CEI exception documented; others not |
| `audit/ECONOMIC_MODEL.md` | Fee model described but fee capture is broken (H-01) |

---

## Architecture Notes

### Contract Dependency Graph (Critical Path)

```
User → PegStabilityModule → OneKUSD (mint/burn)
                          → CollateralVault (deposit/withdraw)
                          → OracleAggregator (price)
                          → PSMLimits (rate limits)
                          → FeeRouter (fee distribution)
                          → SafetyAutomata (pause check)
                          → ParameterRegistry (config)

Guardian → SafetyAutomata → PegStabilityModule (pause)
DAO_Timelock → [ALL] (admin, NON-FUNCTIONAL)
```

### Key Invariants Verified

| Invariant | Status |
|-----------|--------|
| E1: 1kUSD supply <= total collateral value | Tested (single collateral) |
| E2: Collateral vault balance >= sum of deposits | **NOT tested with FoT tokens** |
| S1: Paused PSM rejects all mint/redeem | Tested |
| S3: Guardian powers expire after sunset | **Partially broken (M-02)** |
| F1-F18: Fuzz invariants | 256 runs, single collateral only |

---

*Audit performed by Claude Code (Opus 4.6) for Vendetta Labs. All findings should be verified by the development team before remediation. This audit does not constitute a formal security audit and should not be used as a substitute for a professional third-party audit (e.g., Trail of Bits, OpenZeppelin).*
