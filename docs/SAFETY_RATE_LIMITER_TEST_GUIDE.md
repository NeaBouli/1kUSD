
Safety Rate-Limiter — Test Guide

Harness

Provide a mock limiter with configurable windowSec, bucketSecs, and maxAmount for different scopes.

Deterministic time

Use a controllable clock (e.g., vm.warp or setNextBlockTimestamp) to model timestamps; avoid dependence on block.timestamp drift.

Assertions

After each op, compute expected sum over (now - windowSec, now] and compare to limiter internal sum.

On reject, assert revert RATE_LIMIT_EXCEEDED.

Rollover

Step time across multiple bucket boundaries; verify that old buckets are reset and no phantom volume persists.

Config changes

When maxAmount or windowSec changes at runtime, ensure next op re-evaluates against the new config.

Fuzz

Random op sequences with random gaps and sizes; invariant I6 must hold.
