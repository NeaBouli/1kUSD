# Treasury & Fee Routing (Push Model)

**Version:** DEV-8 (Treasury & Routing)  
**Contracts:** `FeeRouter.sol`, `TreasuryVault.sol`  
**Ziel:** Deterministisches Push-Modell mit atomarer Buchhaltung.

---

## Designentscheidungen

- **Push-Modell:** Modul (z. B. PSM) überweist Fees sofort in derselben TX an den TreasuryVault.
- **Router-Transfer + Event:** `FeeRouter` hält Tokens nur transient und forwardet sie an `TreasuryVault` (Event: `FeeRouted`).
- **Least Privilege:** `TreasuryVault` braucht keine `ROUTER_ROLE` für Eingänge. Ausgänge nur via `DAO_ROLE`.
- **Multi-Asset:** TreasuryVault akzeptiert beliebige ERC-20 (1kUSD, Wrapped Collateral, …).
- **Auditing:** Bestände via `IERC20.balanceOf(TreasuryVault)` + Events (`Swept`, `FeeRouted`).
- **Pause-Semantik:** SafetyAutomata schützt Eintrittspfade (PSM/Router). `TreasuryVault` bleibt passiv.

---

## Schnittstellen

### FeeRouter
```solidity
event FeeRouted(address indexed token, address indexed from, address indexed to, uint256 amount, bytes32 tag);
function routeToTreasury(address token, address treasury, uint256 amount, bytes32 tag) external;
TreasuryVault
solidity
Code kopieren
event Swept(address indexed token, address indexed to, uint256 amount);
function sweep(address token, address to, uint256 amount) external onlyRole(DAO_ROLE);
Typische Flows
PSM Mint Fee

Modul berechnet Fee f.

Modul transfer(token, address(FeeRouter), f).

Modul ruft FeeRouter.routeToTreasury(token, TreasuryVault, f, keccak256("PSM_MINT_FEE")).

Ergebnis: Treasury erhält f, FeeRouted emittiert.

DAO Auszahlung

DAO ruft TreasuryVault.sweep(token, to, amount).

Ergebnis: Tokenabfluss + Swept Event.

Tests (Foundry)
Router: Event + Transfer (routeToTreasury_emits_and_transfers), Zero-Guards.

Treasury: sweep_requires_DAO_ROLE, sweep_transfers_and_emits.

Smoke: PSM-Integration ruft Router (separat, wenn PSM-Tests bereit).

