
Rounding Rules (PSM) — Normative

All divisions round DOWN (floor).

Fees are computed in the asset they are charged in:

To1k: fee in tokenIn

From1k: fee in tokenOut

Units conversion:

tokenX → 1kUSD: multiply by 10^(DU) then divide by 10^(D_in)

1kUSD → tokenX: multiply by 10^(D_out) then divide by 10^(DU)

Never round up user-facing netOut.

Slippage checks occur on netOut after fees.

Event amounts are emitted exactly as computed (no off-by-one normalization).
