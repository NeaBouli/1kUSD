# UX Flows & Text Wireframes

**Scope:** User journeys and minimal wireframes (text) for the reference dApp.  
**Status:** Spec (no code). **Language:** EN.

## 1) Swap (to 1kUSD)
Flow:
1. Connect wallet → detect network → fetch `psm.getParams()`, `safety.getState()`.
2. User selects `tokenIn=USDC` amount=100.
3. Preflight: module not paused, cap headroom, rate limit headroom, oracle healthy.
4. Show fee (bps), expected out, minOut with slippage.
5. `Simulate` → sign → broadcast → toast pending → receipt → success panel with events.

Wireframe (text):
- Header: Peg: 0.9998 ✅ | Safety: Active
- Card: Swap USDC → 1kUSD
  - Amount: [100.00]
  - Fee: 0.10% (0.10 USDC)
  - You receive: 99.90 1kUSD (min: 99.85)
  - [Swap] [Simulate]

Errors:
- `MODULE_PAUSED`, `CAP_EXCEEDED`, `RATE_LIMIT_EXCEEDED`, `ORACLE_UNHEALTHY`, `INSUFFICIENT_OUTPUT_AMOUNT`.

## 2) Redeem (from 1kUSD)
Similar flow; burn path; payout stable with fee retained as stable.

## 3) Proof of Reserves
- Table with assets, normalized amounts, USD totals, caps.
- Finality badge: `safe`/`recent`; last update timestamp.

## 4) Governance
- List proposals: status badges (active/queued/executed).
- Detail: ETA countdown from Timelock; calls preview; events timeline.

## 5) Safety State
- Paused modules list; caps table; rate limits with usage bar.
- Oracle health per asset (age/deviation).

## 6) Error Handling (UI)
- Map SDK errors to banners/toasts with retry hints (xref: COMMON_ERRORS.md).
- Reorg: mark affected tx entries and auto-refresh.

## 7) Accessibility & i18n (see ACCESSIBILITY_I18N.md)
- Forms accessible with labels/help text; keyboard and screen reader friendly.
- Numbers localized; 1kUSD displayed with 2–4 decimals.
