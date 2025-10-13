# Reference dApp — Components (Specification)
**Scope:** Component contracts, props, and SDK usage.  
**Status:** Spec (no code). **Language:** EN.

## Components
- `WalletGate` — connect, chain-switch, account display; emits `onConnected(chainId, account)`
- `HealthBanner` — consumes `/status` API; maps to SEV1/2/3 UI
- `TokenInput` — amount, token selector (approved stables + 1kUSD), balance fetch
- `QuotePanel` — shows gross/fee/net, minOut, deadline countdown
- `SwapButton` — disabled states with reason (paused, stale, allowance missing)
- `TxToast` — pending/confirmed/safe notifications; deep-link to `/tx/:hash`

## SDK Integration (clients/specs)
- `getAddresses(stage)` from `ops/config/addresses.*.json`
- `psm.quoteTo1kUSD(tokenIn, amountIn)` → { grossOut, fee, netOut }
- `psm.quoteFrom1kUSD(tokenOut, amountIn)` → { grossOut, fee, netOut }
- `psm.swapTo1kUSD(...)` / `psm.swapFrom1kUSD(...)` with `deadline`
- `token.permit(...)` (optional); fallback `approve(spender, amount)`
- Error taxonomy aligned to `clients/specs/COMMON_ERRORS.md`

## Error → UX Mapping
- `MODULE_PAUSED` → disable swap, red banner
- `ORACLE_UNHEALTHY`/`STALE` → disable mint path, red banner
- `RATE_LIMIT_EXCEEDED` → show ETA to window reset
- `CAP_EXCEEDED` → suggest alternate stable
- `SLIPPAGE_EXCEEDED` → prompt to adjust minOut
- `DEADLINE_EXPIRED` → auto-refresh quote/deadline

## Security UX
- Always show `spender` and `amount` for approvals
- Highlight chain & contract addresses; copy-to-clipboard; explorer links
