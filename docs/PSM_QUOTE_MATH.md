
PSM Quote Math — Rounding, Decimals, Fee Order (v1)

Status: Docs (normative). Language: EN. Audience: Core devs, auditors, SDK.

0) Notation

ai: amountIn (integer, token units with d_i decimals)

ao: amountOut (integer, token units with d_o decimals)

p: price (USD per 1 token, integer with d_p decimals)

du: USD normalization decimals (PARAM_DECIMALS_PAD_USD, default 18)

feeBps: basis points fee (0..10_000)

All arithmetic is integer, using floor rounding at each step unless stated.

1) Direction: token → 1kUSD (To1kUSD)

Inputs: tokenIn (d_i), p (d_p), ai, du, feeBps.

1.1 USD value (scaled to du=18)
usdValue = floor( ai * p * 10^du / (10^d_i * 10^d_p) )

1.2 Gross 1kUSD out (18 decimals)
grossOut = usdValue
feeOut = floor( grossOut * feeBps / 10_000 )
netOut  = grossOut - feeOut

1.3 Fee accounting in asset units (recommended)

To accrue fees in the asset (for FeeAccrued(asset, amount)), convert feeOut (USD units, du) back to asset using the same snapshot (p, d_p):

feeAsset = floor( feeOut * 10^d_i * 10^d_p / (p * 10^du) )


Accounting conservation (ignoring tiny residual dust due to floors):

Vault receives: ai (from user)

Treasury accrual: feeAsset

Effective inventory backing minted 1kUSD: ai - feeAsset

Invariant: netOut corresponds to USD value of (ai - feeAsset) under the same snapshot, up to ≤ 1 wei 1kUSD drift from rounding.

2) Direction: 1kUSD → token (From1kUSD)

Inputs: amountIn1k (du=18), tokenOut (d_o), p (d_p), feeBps.

2.1 Gross token out (token units)
grossOut = floor( amountIn1k * 10^d_o * 10^d_p / ( p * 10^du ) )
feeOut   = floor( grossOut * feeBps / 10_000 )
netOut   = grossOut - feeOut

2.2 Fee accounting in asset units

For FeeSwept/Accrued in asset units, feeAsset == feeOut (already in tokenOut units).

3) Fee order & CEI

Fee computed on grossOut (not on USD value pre-scaling).

For To1kUSD: fee is quoted in output units (1kUSD), converted to asset for accrual using the same snapshot.

For From1kUSD: fee units are tokenOut.

4) Rounding strategy

Use floor at every division.

SDKs should pre-calc minimum outputs using these exact steps to avoid execution slippage reverts.

Any alternative rounding MUST be signalled as a breaking change.

5) Slippage checks

Execution MUST assert: netOut >= minOut. Quotes should already supply exact values under the same snapshot.

Deadline gating is mandatory.

6) Examples (see tests/vectors/psm_quote_vectors.json)

USDC (6) @ 1.00000000 USD (d_p=8), fee 10 bps (0.1%):

ai=1_000_000 → grossOut=1_000_000_000_000_000_000, feeOut=1_000_000_000_000_000, netOut=998_999_000_000_000_000

feeAsset=1_000 (USDC units)

WETH (18) @ 1800.00000000 USD (d_p=8), fee 20 bps (0.2%):

ai=1_000_000_000_000_000_000 → results computed in vectors file.

7) Overflow notes

Use 256-bit safe math; multiplication order should minimize overflow risk:

Prefer ai * p using 256-bit, then multiply by 10^du only if safe; otherwise rearrange with fraction reduction.

Implementations MAY use checked libraries or mulDiv primitives.

8) Conformance

quote* MUST return values exactly equal to execution under the same snapshot.

Any price/snapshot ID returned by quotes MUST be verified at execution (or a strict re-read rule applied).

