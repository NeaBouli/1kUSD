
OneKUSD Permit — Test Guide

Domain separator

Compare on-chain DOMAIN_SEPARATOR with ethers TypedDataEncoder.hashDomain(domain).

Happy path

nonce=0 → permit(...) with valid sig → allowance set, Approval emitted, nonce=1.

Replay & wrong nonce

Reuse same sig → revert (nonce mismatch).

Prepare sig with nonce=2 while on-chain nonce=0 → revert.

Expiry

deadline < block.timestamp → revert.

ECDSA checks

Ensure s in lower half, v in {27,28}.

Fuzz

Random owners/spenders/values; ensure no state corruption and nonces monotonic.
