# Access Control — Specification
**Scope:** Role model & authorization surfaces across protocol modules; integration with DAO/Timelock and Safety-Automata.  
**Status:** Spec (no code). **Language:** EN.

## 1. Roles (concept)
- `ROLE_MINTER` — allowed to call `Token.mint`.
- `ROLE_BURNER` — allowed to call `Token.burn`.
- `ROLE_PARAMS` — allowed to set parameters via Safety (Timelock executor).
- `ROLE_PAUSE` — Safety guardian (temporary, sunset).
- `ROLE_VAULT_MOVE` — only for **Timelock** to instruct `Vault.withdraw` with `"GOV_SPEND"` reason.

## 2. Assignment & Governance
- Roles are **owned by Timelock**; changes scheduled via proposals.
- Safety acts as **policy gate**: module must be registered/enabled to receive operational roles.
- Guardian `ROLE_PAUSE` has **expiry** (sunset timestamp) per Safety spec.

## 3. Enforcement Points
- Token: `mint/burn` check `ROLE_MINTER`/`ROLE_BURNER`.
- PSM: operational calls require **module enabled** in Safety; reads unrestricted.
- Vault: `withdraw` requires `ROLE_VAULT_MOVE` with `reason` in allowed set (`GOV_SPEND`, `REBALANCE` if added).
- Oracle/Safety/Registry: setters only via Timelock → Safety.

## 4. Events
- `RoleGranted(role, account, sender)`
- `RoleRevoked(role, account, sender)`
- `RoleAdminChanged(role, previousAdmin, newAdmin)`
- Guardian sunset: `GuardianSunset(ts)` (emitted by Safety).

## 5. Errors
- `ACCESS_DENIED`
- `ROLE_EXPIRED` (for guardian)
- `MODULE_NOT_ENABLED` (Safety registry)

## 6. Testing
- Grant/revoke lifecycle via Timelock.
- Guardian cannot pause after sunset.
- Vault withdraw only via Timelock (happy path + deny EOA).
