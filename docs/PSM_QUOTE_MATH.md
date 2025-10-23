
PSM Quote Math (v1)

Status: Normative. Language: EN.

1) Symbols

feeBps ∈ [0,10000]

Q = quote()

DU = decimals(1kUSD) = 18

D_in = decimals(tokenIn)

D_out = decimals(tokenOut)

2) swapTo1kUSD (tokenIn -> 1kUSD)

Inputs: amountIn (tokenIn units), feeBps
Steps:

fee = floor(amountIn * feeBps / 10_000)

netIn = amountIn - fee

grossOut_1k = netIn * 10^(DU) / 10^(D_in)

netOut_1k = grossOut_1k
Output: (grossOut = grossOut_1k, fee_tokenIn = fee, netOut = netOut_1k)

Notes:

Fee is taken in tokenIn.

No rounding upward on user amounts; floor at each division.

3) swapFrom1kUSD (1kUSD -> tokenOut)

Inputs: amountIn_1k (1kUSD units), feeBps
Steps:

grossOut_token = amountIn_1k * 10^(D_out) / 10^(DU)

fee = floor(grossOut_token * feeBps / 10_000)

netOut_token = grossOut_token - fee
Output: (grossOut = grossOut_token, fee_tokenOut = fee, netOut = netOut_token)

Notes:

Fee is taken in tokenOut.

Floor rounding at each division preserves conservative outputs.

4) Slippage & MinOut

Execution MUST check: netOut >= minOut or revert SLIPPAGE.

minOut provided by user/off-chain router.

5) Sanity with Oracles (advisory)

Quotes do not require price feeds; Oracle is advisory for deviation/liveness guards.

Indexer may compute USD equivalents off-chain using oracle snapshots.

6) Event Semantics

FeeAccrued(asset, fee) reflects units of the asset the fee was taken in.

SwapTo1kUSD: (user, tokenIn, amountIn, fee, netOut)

SwapFrom1kUSD: (user, tokenOut, amountIn, fee, netOut)

7) Edge Cases

amountIn == 0 → revert ZERO_AMOUNT

feeBps == 10_000 → netOut == 0 (allowed if governance decides; generally avoid)

Decimal paths: all scale conversions use integer math; no floating points.

8) Validation

Cross-check with tests/vectors/psm_quote_vectors.json via scripts/quote-eval.ts
