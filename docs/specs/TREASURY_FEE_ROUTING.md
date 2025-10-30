# Treasury Fee Routing — Spec (Push Model)

**Goal:** Deterministic routing of protocol fees from modules (e.g., PSM) into the TreasuryVault **within the same transaction** using a stateless FeeRouter (push-only).

## Principles
- **Push-only:** Caller already owns tokens; router does not rely on allowances.
- **Stateless Router:** No storage beyond immutable refs; `nonReentrant`.
- **Vault as sink:** Multi-asset sink; outbound transfers require `DAO_ROLE`.
- **Safety:** CEI pattern; `safeTransfer` behavior; optional Pausable compatibility.

## Events (canonical)
- `FeeRouted(address indexed token, address indexed from, uint256 amount, bytes32 indexed tag)`
- `VaultSweep(address indexed token, address indexed to, uint256 amount)`

## Happy Path (PSM → Router → Vault)
1) Module calculates fee and calls `route(token, amount, tag)`.
2) Router transfers `amount` to TreasuryVault and emits `FeeRouted`.
3) Vault records receipt (implementation-specific) and later allows DAO sweep.

## Error Cases
- `token == address(0)` → revert
- `amount == 0` → revert
- ERC-20 transfer returns `false` / fails → revert
- Vault unset/invalid → revert

## Tags
`tag = keccak256("PSM_FEE")`, `keccak256("LIQUIDATION_FEE")`, etc. Used for analytics and accounting.

## Non-Goals
- No approvals/pull mechanics
- No fee accounting inside Router
