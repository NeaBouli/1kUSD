# Trust Model -- v0.51.x

---

## Trusted Entities

### Admin

**Contracts held:** PegStabilityModule (ADMIN_ROLE), SafetyAutomata (ADMIN_ROLE + GUARDIAN_ROLE at construction), CollateralVault (admin), OracleAggregator (admin), ParameterRegistry (admin), FeeRouter (admin), OneKUSD (admin), TreasuryVault (ADMIN_ROLE + DAO_ROLE at construction)

**Powers:**
- Change all protocol dependencies (oracle, registry, vault, limits, feeRouter on PSM)
- Grant/revoke minter and burner roles on OneKUSD
- Pause/unpause OneKUSD mint/burn
- Set oracle prices (via OracleAggregator.setPriceMock)
- Set any parameter in ParameterRegistry (fees, spreads, decimals, oracle thresholds) with no range validation
- Whitelist assets and callers on CollateralVault
- Whitelist callers on FeeRouter
- Grant GUARDIAN_ROLE on SafetyAutomata
- Pause/resume any module via SafetyAutomata
- Transfer admin to any address (single-step, no confirmation)

**Trust level:** Full protocol control. Admin compromise = protocol compromise.

### DAO

**Contracts held:** BuybackVault (dao, immutable), PSMLimits (dao), OracleAdapter (dao), Guardian (dao, immutable), SafetyAutomata (DAO_ROLE, if granted)

**Powers:**
- Execute buybacks via BuybackVault (fund, withdraw, executeBuybackPSM)
- Configure all BuybackVault caps and strategies
- Set daily/single-tx caps on PSMLimits
- Whitelist callers on PSMLimits
- Set oracle prices and heartbeat on OracleAdapter
- Configure Guardian (set operator, safety automata, self-register)
- Pause/resume modules if DAO_ROLE granted on SafetyAutomata

**Trust level:** Economic authority. DAO can drain BuybackVault but cannot directly mint/burn 1kUSD or access CollateralVault.

### Guardian (Time-Limited)

**Contracts held:** SafetyAutomata (GUARDIAN_ROLE)

**Powers:**
- Pause any module via `pauseModule(moduleId)` -- ONLY before `guardianSunset` timestamp
- Cannot resume modules
- Cannot change any configuration

**Trust level:** Emergency brake only. Powers expire at sunset. Designed for automated monitoring systems that need to halt the protocol in response to oracle failures or detected exploits.

### Operator (Guardian Delegate)

**Contracts held:** Guardian contract (`operator` address)

**Powers:**
- Call `Guardian.pauseOracle()` which calls `safetyAutomata.pauseModule(keccak256("ORACLE"))`
- Only works before `guardianSunset`

**Trust level:** Minimal. Can only pause the oracle module. Cannot resume. Cannot change configuration.

---

## Untrusted Entities

### End Users (Swap Callers)

**Entry points:** `PSM.swapTo1kUSD()`, `PSM.swapFrom1kUSD()`, `OneKUSD.transfer/transferFrom/approve/permit`

**Protections:**
- `nonReentrant` on PSM swap functions
- `whenNotPaused` gate
- `_requireOracleHealthy` gate
- `_enforceLimits` rate limiting
- Slippage protection via `minOut` parameter
- Deadline enforcement via `deadline` parameter
- Standard ERC-20 checks (balance, allowance)

### ERC-20 Token Contracts

**Interaction:** PSM transfers collateral tokens; vault holds them; BuybackVault transfers stable/asset tokens

**Protections:**
- SafeERC20 wraps all token interactions (handles non-standard returns)
- `onlySupported` modifier on vault restricts which tokens can be deposited/withdrawn
- `nonReentrant` on PSM prevents callback reentrancy during token transfers

**Remaining trust:** The vault trusts `amount` parameter (no received-amount check). A fee-on-transfer token would cause accounting drift.

### External Oracle Feeds (Future)

Not present in v0.51.x. OracleAggregator uses admin-set mock prices. When external feeds are wired, they become an untrusted data source that the staleness/deviation gates are designed to protect against.

---

## Per-Contract Trust Assumptions

### PegStabilityModule

| What is trusted | What is verified on-chain |
|-----------------|--------------------------|
| Admin sets correct oracle, vault, limits addresses | N/A -- admin can set any address |
| Oracle returns accurate prices | `require(p.healthy && p.price > 0)` |
| CollateralVault correctly records deposits | N/A -- PSM trusts vault accounting |
| OneKUSD correctly mints/burns | N/A -- PSM trusts token contract |
| ParameterRegistry returns valid fee/spread values | `require(raw <= 10_000)` on every fee/spread read |

### CollateralVault

| What is trusted | What is verified on-chain |
|-----------------|--------------------------|
| Admin only whitelists legitimate callers (PSM) | `onlyAuthorized` modifier |
| Admin only whitelists legitimate assets | `onlySupported` modifier |
| `amount` parameter matches actual transfer | NOT VERIFIED -- trusted parameter |
| SafetyAutomata correctly reports pause state | External call to `safety.isPaused()` |

### BuybackVault

| What is trusted | What is verified on-chain |
|-----------------|--------------------------|
| DAO acts rationally (immutable `dao` address) | `onlyDAO` modifier |
| PSM executes swap correctly | Return value used for event emission only |
| OracleHealthModule reports accurately | External call to `isHealthy()` |
| Strategy configuration is reasonable | Caps validated `<= 10_000` bps |

### SafetyAutomata

| What is trusted | What is verified on-chain |
|-----------------|--------------------------|
| Admin grants appropriate roles | OpenZeppelin AccessControl |
| Guardian sunset timestamp is set correctly | Immutable, set at construction |
| Role hierarchy is maintained | `onlyRole` modifiers |

### OneKUSD

| What is trusted | What is verified on-chain |
|-----------------|--------------------------|
| Admin only grants minter/burner to PSM | `isMinter`/`isBurner` checks |
| EIP-2612 signatures are valid | `ecrecover` + nonce + deadline |
| `_transfer` arithmetic is safe | `unchecked` block (see B1 in KNOWN_LIMITATIONS) |

---

## Immutable vs Mutable State Inventory

### Immutable State (Set at Construction, Cannot Change)

| Contract | Variable | Type |
|----------|----------|------|
| BuybackVault | `stable` | IERC20 |
| BuybackVault | `asset` | IERC20 |
| BuybackVault | `dao` | address |
| BuybackVault | `safety` | ISafetyAutomata |
| BuybackVault | `psm` | IPegStabilityModuleLike |
| BuybackVault | `moduleId` | bytes32 |
| SafetyAutomata | `guardianSunset` | uint256 |
| Guardian | `dao` | address |
| Guardian | `guardianSunset` | uint256 |
| CollateralVault | `safety` | ISafetyAutomata |
| OracleAggregator | `safety` | ISafetyAutomata |
| OneKUSD | `_INITIAL_CHAIN_ID` | uint256 |
| OneKUSD | `_INITIAL_DOMAIN_SEPARATOR` | bytes32 |

### Mutable State (Admin/DAO-Changeable)

| Contract | Variable | Changed by |
|----------|----------|------------|
| PegStabilityModule | `oneKUSD`, `vault`, `safetyAutomata`, `registry` | Constructor only (no setter) |
| PegStabilityModule | `limits` | `setLimits()` -- ADMIN_ROLE |
| PegStabilityModule | `oracle` | `setOracle()` -- ADMIN_ROLE |
| PegStabilityModule | `feeRouter` | `setFeeRouter()` -- ADMIN_ROLE |
| PegStabilityModule | `mintFeeBps`, `redeemFeeBps` | `setFees()` -- ADMIN_ROLE |
| CollateralVault | `admin` | `setAdmin()` -- onlyAdmin |
| CollateralVault | `registry` | `setRegistry()` -- onlyAdmin |
| CollateralVault | `authorizedCallers` | `setAuthorizedCaller()` -- onlyAdmin |
| CollateralVault | `_isSupported` | `setAssetSupported()` -- onlyAdmin |
| OracleAggregator | `admin` | `setAdmin()` -- onlyAdmin |
| OracleAggregator | `registry` | `setRegistry()` -- onlyAdmin |
| OracleAggregator | `_mockPrice` | `setPriceMock()` -- onlyAdmin |
| ParameterRegistry | `admin` | `setAdmin()` -- onlyAdmin |
| ParameterRegistry | `_uints`, `_addresses`, `_bools` | `set*()` -- onlyAdmin |
| OneKUSD | `admin` | `setAdmin()` -- onlyAdmin |
| OneKUSD | `isMinter`, `isBurner` | `setMinter()`/`setBurner()` -- onlyAdmin |
| OneKUSD | `paused` | `pause()`/`unpause()` -- onlyAdmin |
| FeeRouter | `admin` | `setAdmin()` -- onlyAdmin |
| FeeRouter | `authorizedCallers` | `setAuthorizedCaller()` -- onlyAdmin |
| PSMLimits | `dailyCap`, `singleTxCap` | `setLimits()` -- onlyDAO |
| PSMLimits | `authorizedCallers` | `setAuthorizedCaller()` -- onlyDAO |
| BuybackVault | all config fields | Various setters -- onlyDAO |
| Guardian | `safety` | `setSafetyAutomata()` -- onlyDAO |
| Guardian | `operator` | `setOperator()` -- onlyDAO |

### Effectively Immutable (Set in Constructor, No Setter Exposed)

| Contract | Variable | Note |
|----------|----------|------|
| PegStabilityModule | `oneKUSD`, `vault`, `safetyAutomata`, `registry` | Set in constructor, no setter functions exist |
| OracleWatcher | `oracle`, `safetyAutomata` | Set in constructor, no setter functions exist |

---

## Guardian Sunset Mechanism

The guardian sunset is a time-lock on guardian emergency powers:

1. `guardianSunset` is an immutable `uint256` timestamp set at `SafetyAutomata` and `Guardian` construction
2. Before sunset: guardians can call `pauseModule()` to halt any module
3. At/after sunset: `pauseModule()` reverts with `GuardianExpired()` for guardian callers
4. After sunset: only ADMIN_ROLE or DAO_ROLE can pause modules
5. Guardian can NEVER resume modules (regardless of sunset)

**Design rationale:** Initial deployment uses guardians for rapid incident response. Once the protocol is mature, guardian powers expire and all emergency actions require DAO governance.

---

## Authorized Caller Pattern

CollateralVault, PSMLimits, and FeeRouter use a whitelist pattern rather than role-based access control:

```solidity
mapping(address => bool) public authorizedCallers;

modifier onlyAuthorized() {
    if (!authorizedCallers[msg.sender] && msg.sender != admin) revert NOT_AUTHORIZED();
    _;
}
```

**Implication:** The trust boundary is: admin whitelists caller address -> whitelisted address can invoke protected functions. If the whitelisted contract (e.g., PSM) is replaced, the admin must update the whitelist.

**CollateralVault special case:** `onlyAuthorized` also allows `admin` directly (fallback for emergency operations).

**PSMLimits difference:** `onlyAuthorized` also allows `dao` directly.
