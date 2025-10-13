# Reference dApp — UX & Flows (Specification)
**Scope:** Minimal swap UI for 1kUSD ↔ approved stables via PSM; health banners; wallet handling.  
**Status:** Spec (no code). **Language:** EN.

## Pages / Routes
- `/` Swap: Stable → 1kUSD and 1kUSD → Stable
- `/status` Health: peg, oracle age, paused modules, rate-limit usage
- `/tx/:hash` Tx status (WS + polling fallback)

## Core Flows
1) **Detect & Switch Chain** (EIP-1193 addChain/switchChain)
2) **Wallet Connect** (WalletConnect v2 + EIP-1193)
3) **Quote** (SDK): `quoteTo1kUSD` / `quoteFrom1kUSD` (post-fee, rounding)
4) **Allowance**: `permit` preferred (EIP-2612), fallback `approve`
5) **Simulate**: call-static swap to validate minOut/deadline
6) **Sign & Broadcast**
7) **Track**: WS receipt + indexer confirmation; show `finalityMark`

## Health Banners
- **SEV1 (red):** peg deviation > 100 bps OR oracle stale > maxAge → swaps disabled
- **SEV2 (orange):** paused modules present OR indexer safe-lag > 600 blocks → warn
- **SEV3 (yellow):** rate-limit usage > 90% OR degraded RPC → caution

## UI States
- Loading, Quoted, Needs Approval/Permit, Ready to Swap, Broadcasting, Confirming, Finalized(`safe`)

## Accessibility
- Keyboard-first; aria labels on inputs/buttons; high-contrast theme toggle

## Telemetry Hooks
- `ui_swap_attempts_total{outcome}`; `ui_page_views_total{route}`; request timing
