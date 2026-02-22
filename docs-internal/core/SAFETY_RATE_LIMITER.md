
Safety Rate-Limiter — Rolling Window (v1)

Status: Docs (normative). Language: EN. Audience: Core devs, auditors, SDK.

0) Scope

Enforces gross flow limits over a rolling window for sensitive actions:

PSM: swapTo1kUSD (ingress) and swapFrom1kUSD (egress)

Vault: deposit/withdraw (as needed)

Per-asset and/or per-module limits

1) Parameters

windowSec — rolling window length (registry: PARAM_RATE_WINDOW_SEC)

maxAmount[scope] — maximum gross amount over windowSec

Scope can be: global, per-module, per-asset

Values stored in token units (not USD)

Clock source: block.timestamp

2) Semantics

Given an operation with amount, we must ensure:

Σ gross(amount) for ops with ts in (now - windowSec, now]  + amount  <= maxAmount


If violated → revert RATE_LIMIT_EXCEEDED.

3) Data Structure (implementation hint)

Use fixed-size time buckets to approximate sliding window with O(1) ops:

bucketSecs = gcd-like small divisor of window (e.g., 60s)

numBuckets = ceil(windowSec / bucketSecs)

Circular buffer: each bucket record {sum, bucketStart}

On update:

Roll current index by (now / bucketSecs) % numBuckets

If bucketStart != currentStart, reset sum=0; bucketStart=currentStart

Sum all buckets with bucketStart > now - windowSec

Check sum + amount <= maxAmount then add to current sum += amount

This yields tight upper bound; exact sliding window allowed if gas permits.

4) Scopes & Keys

Derive keys consistently (see PARAM_KEYS_CANON):

per-asset: PARAM_RATE_MAX_AMOUNT + asset

per-module: PARAM_RATE_MAX_AMOUNT + MODULE_ID

global: PARAM_RATE_MAX_AMOUNT

Evaluation order:

If per-asset exists → enforce

Else if per-module exists → enforce

Else if global exists → enforce

Missing key → unlimited (0 = unlimited) unless policy forbids

5) Units & Decimals

Always store/enforce in token units (not USD).

For 1kUSD limits, use du=18 units.

6) Events (recommended)

RateLimitUpdated(scopeKey, maxAmount, windowSec, ts)

RateLimitHit(scopeKey, amountTried, sumWindow, maxAmount, ts) (optional)

7) Errors

RATE_LIMIT_EXCEEDED()

INVALID_WINDOW() if windowSec == 0

8) Invariants

I6: Sliding-window gross flow ≤ configured maxAmount for active scope.

Rate-limit never blocks view functions; only state changes.

9) Test Scenarios

Burst under the cap: multiple ops sum < max → pass

Exactly at cap → pass

Exceed by 1 unit → revert

Buckets roll-over: old bucket drops, new ops allowed

Mixed assets: enforce per-asset even if global allows more

Window change at runtime: ensure next op re-evaluates with new config

See tests/vectors/rate_limiter_vectors.json for machine-readable cases.
