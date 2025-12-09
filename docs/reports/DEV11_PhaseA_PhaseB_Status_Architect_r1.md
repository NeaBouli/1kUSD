# DEV-11 – BuybackVault Advanced Safety  
## Statusreport Phase A + Phase B (Start) – to Architecture

**From:** DEV-11 (Economic Advanced / BuybackVault)  
**To:** Architecture / Economic Layer / Governance  
**Repo:** `NeaBouli/1kUSD` (branch: `main`, including PRs #47–#51)

---

## 1. Scope of this work block

In this block, the following topics for the **BuybackVault** have been implemented or completed:

1. **Phase A – Safety Layer A01–A03**
   - A01: Per-operation treasury cap (hard safety feature)
   - A02: Oracle / health gate (configurable safety feature)
   - A03: Rolling window cap (time-based aggregation limit)

2. **Phase A – Governance & Telemetry onboarding**
   - Official Phase A status report
   - Governance playbook for buyback parameters
   - Telemetry / indexer guides for BuybackVault

3. **Phase B – Start: telemetry & tests**
   - Phase B telemetry / test plan
   - First telemetry-oriented tests for the oracle health gate (A02)

All work has been carried out such that:

- **`forge test` is fully green** (74 tests),
- **`mkdocs build` is green**,
- the economic layer baseline v0.51 remains reconfigurable.

---

## 2. Phase A – Technical state A01–A03

### A01 – Per-operation treasury cap

**On-chain:**

- Field: `uint16 maxBuybackSharePerOpBps`
- Setter: `setMaxBuybackSharePerOpBps(uint16 newCapBps)`  
  - DAO only (`onlyDAO`)
  - Bounds: `newCapBps <= 10_000`, otherwise `INVALID_AMOUNT()`
  - Event: `BuybackTreasuryCapUpdated(oldCapBps, newCapBps)`
- Check in buyback paths:
  - `executeBuybackPSM(...)`
  - (any further advanced path would use the same check)
- Semantics:
  - Cap in bps over the **current stable balance of the vault**
  - `capBps == 0` ⇒ check disabled
  - Exceeding the cap ⇒ `revert BUYBACK_TREASURY_CAP_EXCEEDED()`

**Tests:**

- `testExecuteBuybackPSMRespectsPerOpTreasuryCap()`
  - Enforces a revert when a single operation would exceed the cap.
- `testExecuteBuybackPSMWithinPerOpCapSucceeds()`
  - Ensures that buybacks below the cap succeed.

**Architect conclusion A01:**

- A01 is a **hard treasury-share based safety feature per operation**.
- Fully integrated, tested, documented.
- Can be fully disabled via cap = 0 (legacy mode).

---

### A02 – Oracle / health gate

**On-chain:**

- Interface:  
  `interface IOracleHealthModule { function isHealthy() external view returns (bool); }`
- Fields in the vault:
  - `address public oracleHealthModule;`
  - `bool public oracleHealthGateEnforced;`
- Setter:
  - `setOracleHealthGateConfig(address newModule, bool newEnforced) external onlyDAO`
    - If `newEnforced == true` and `newModule == address(0)` ⇒ `revert ZERO_ADDRESS()`
    - Event:  
      `BuybackOracleHealthGateUpdated(oldModule, newModule, oldEnforced, newEnforced)`

- Hook in buyback path:
  - `executeBuybackPSM(...)` calls `_checkOracleHealthGate()`.

- Logic of `_checkOracleHealthGate()`:
  - If `oracleHealthGateEnforced == false` ⇒ **no-op** (legacy-compatible).
  - If `oracleHealthGateEnforced == true`:
    - `oracleHealthModule == address(0)` ⇒ `revert BUYBACK_ORACLE_UNHEALTHY()`
    - `IOracleHealthModule(module).isHealthy() == false` ⇒ `revert BUYBACK_ORACLE_UNHEALTHY()`

**Tests (Phase B / step 01):**

- Positive path:
  - `testExecuteBuybackPSM_OracleGate_HealthyModuleAllowsBuyback()`
    - Health module returns `true`, gate enforced ⇒ buyback proceeds.
- Negative path:
  - `testExecuteBuybackPSM_OracleGate_UnhealthyModuleReverts()`
    - Health module returns `false`, gate enforced ⇒ revert with `BUYBACK_ORACLE_UNHEALTHY`.
- Config semantics:
  - `testSetOracleHealthGateConfig_EnforcedWithZeroModuleReverts()`
    - Enforces that enabling the gate with a zero module reverts via `ZERO_ADDRESS` at config level.

**Architect conclusion A02:**

- A02 is a **configurable health layer**:
  - **Legacy mode**: `oracleHealthGateEnforced = false` ⇒ behaviour ≈ v0.51
  - **Strict mode**: `oracleHealthGateEnforced = true` ⇒ oracle health decides buyback permission.
- Telemetry documentation and indexer guides are in place (see section 3).

---

### A03 – Rolling window cap

**On-chain fields:**

- `uint16 public maxBuybackSharePerWindowBps;`
- `uint64 public buybackWindowDuration;`
- `uint64 public buybackWindowStart;`
- `uint128 public buybackWindowAccumulatedBps;`

**Config function:**

- `setBuybackWindowConfig(uint64 newDuration, uint16 newCapBps) external onlyDAO`
  - `newCapBps <= 10_000`, else `"WINDOW_CAP_BPS_TOO_HIGH"`
  - Sets:
    - `buybackWindowDuration = newDuration;`
    - `maxBuybackSharePerWindowBps = newCapBps;`
  - Resets:
    - `buybackWindowStart = 0;`
    - `buybackWindowAccumulatedBps = 0;`
  - Event:  
    `BuybackWindowConfigUpdated(oldDuration, newDuration, oldCapBps, newCapBps)`

**Enforcement logic (A03):**

- The enforcement function (rolling window accounting + check) is integrated into the buyback path (DEV-11 A03 patch).  
- High-level principle (as documented in the DEV-11 backlog/plan):
  - If `maxBuybackSharePerWindowBps == 0` or `buybackWindowDuration == 0` ⇒ window cap **disabled**.
  - Else:
    - If current timestamp is outside the active window ⇒ window is reset.
    - For each buyback, a share in bps is added to the window accumulator.
    - Exceeding the cap ⇒ revert with the A03 window cap error.

> ✳️ **Parked note (explicit):**  
> Extended tests for the rolling window cap logic at time boundaries (boundary / reset cases) are **explicitly parked** for a later Phase B/C test wave.  
> Examples:
> - “Last operation just before window reset”
> - “First operation right after reset”
> - “Multiple small buybacks that in sum exactly hit the cap”
>
> The core logic is implemented, but these **fine-grained tests** are currently planned as “nice-to-have / additional verification”, not as blockers.

---

## 3. Governance & telemetry – new artefacts

### 3.1 Phase A status report

**New:** `docs/reports/DEV11_PhaseA_BuybackSafety_Status_r1.md` (PR #47)

- Overview of:
  - A01 / A02 / A03 features,
  - activatable parameters & flags,
  - modes:
    - `LEGACY_COMPAT` (all caps/gates off),
    - `PHASE_A_STRICT` (conservative safety configuration).
- Reference for:
  - Governance (DEV-87),
  - Risk / Security (DEV-8),
  - Release management (DEV-94).

---

### 3.2 Governance playbook for buyback safety

**New:** `docs/governance/buybackvault_parameter_playbook_phaseA.md` (PR #48)

- Covers parameters:
  - `maxBuybackSharePerOpBps` (A01),
  - `maxBuybackSharePerWindowBps` + `buybackWindowDuration` (A03),
  - `oracleHealthModule` + `oracleHealthGateEnforced` (A02).
- Governance profiles (examples):
  - **Legacy / minimal safety**
  - **Conservative mainnet launch**
  - **Aggressive / testnet profile**
- For each profile:
  - Intention,
  - mitigated risks,
  - new risks / operational care points (e.g. oracle dependencies).

---

### 3.3 Telemetry & indexer guides

**New / extended:**

- `docs/integrations/buybackvault_observer_guide.md` (PR #49)
  - Mapping: **events / reason codes → meaning → recommended ops reaction**.
- `docs/indexer/indexer_buybackvault.md` (PR #49)
  - How indexers should interpret buyback events & reverts.
  - Which fields should be logged (asset, amount, mode, reason code, etc.).
  - Basis for alerts / monitoring (e.g. “rolling window cap triggered”, “oracle unhealthy”).

These guides are in sync with `docs/dev/DEV11_Telemetry_Events_Outline_r1.md` and reflect the current A01–A03 state.

---

## 4. Phase B – Start: telemetry & tests

### 4.1 Telemetry / test plan (planning artefact)

**New:** `docs/dev/DEV11_PhaseB_Telemetry_TestPlan_r1.md` (PR #50)

- Defines Phase B goals:
  - Tests along the reason codes for A01–A03.
  - Clear matrix of:
    - configuration,
    - operation,
    - expected reaction (success / revert + reason code).
- Extension of the existing backlog file:
  - `docs/dev/DEV11_Implementation_Backlog_SolidityTrack_r1.md` now has a **Phase B section** that describes the next test waves.

---

### 4.2 Oracle health gate tests (Step B01 – implemented)

**New in code:** (PR #51)

- Changes in `foundry/test/BuybackVault.t.sol`:
  - Reorganized test section for A02,
  - Added tests:
    - `testExecuteBuybackPSM_OracleGate_HealthyModuleAllowsBuyback()`
    - `testExecuteBuybackPSM_OracleGate_UnhealthyModuleReverts()`
    - `testSetOracleHealthGateConfig_EnforcedWithZeroModuleReverts()`
- Forge test run:
  - **All 74 tests green**, no regressions in PSM / oracle / guardian tests,
  - Build artefacts updated.

---

## 5. System state after this block

- **Code:**
  - `main` compiles cleanly.
  - BuybackVault contains:
    - Custody layer,
    - PSM execution layer,
    - safety layers A01–A03 including oracle hook.

- **Tests (`forge test`):**
  - 74 tests, all green.
  - BuybackVault tests cover:
    - constructor guards,
    - custody access control,
    - pause semantics,
    - per-op cap (A01),
    - oracle gate base behaviour (A02),
    - strategy config,
    - treasury withdrawals.
  - Fine-grained rolling window cap tests are **explicitly parked** (see open items).

- **Docs (`mkdocs build`):**
  - Build is green.
  - New docs are wired (reports index, governance index, integration / indexer sections).

---

## 6. Open items / explicitly parked topics

1. **A03 rolling window cap – boundary/reset tests**
   - Still **not** implemented:
     - Tests for:
       - window rollover (reset on new time window),
       - edge cases (“exactly at cap”, “cap+1” across multiple operations),
       - combinations of A01 + A03 caps.
   - Classification:
     - **Not** considered an immediate bug/blocker,
     - kept as **recommended** work for a later Phase B/C test wave.

2. **Further telemetry refinement**
   - Options for later phases:
     - more explicit reason codes / events,
     - tighter coupling with guardian / safety events.

3. **Release integration (DEV-94)**
   - Phase A buyback safety should be made visible in **release checklists** (DEV-94):
     - “Are A01–A03 parameters configured sensibly?”
     - “Is the intended mode (legacy / strict / Phase A profile) documented?”

---

## 7. Suggested architect next steps (high level)

1. **Architect acceptance of this status report**
   - Confirm that:
     - A01–A03 + governance + telemetry docs are treated as **Phase A completed**.
   - Optional feedback:
     - Prioritisation of when the parked A03 tests should be implemented.

2. **Planning Phase B (further)**
   - If desired:
     - Phase B test wave for:
       - rolling window boundary cases,
       - combinations A01 + A03,
       - further integration with guardian / safety signals.

3. **Potential “Phase C – Strategy layer” preparation**
   - Depending on architect go:
     - multi-asset strategies,
     - weighted buybacks,
     - closer alignment with economic layer objectives.

---

> **Short take for architecture:**
>
> - BuybackVault now has **three activatable safety layers (A01–A03)**,  
>   including oracle gate hook and initial telemetry tests.
> - Governance and indexers / integrations are **onboarded in docs**.
> - System is **stable, tests green, docs green**.  
> - The only consciously open item is: **fine-grained rolling window tests (A03)**,  
>   marked as “nice-to-have” for a later phase.

