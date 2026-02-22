
Vault Test Guide — Implementation Hints

Mock FoT ERC-20:

Override transferFrom to reduce sent amount by fotBps and send remainder to to.

Ingress tests:

Assert Deposit(asset, from, received) uses post-pre delta.

Assert cap checks apply to received, not amountIn.

Assert egress unaffected by FoT semantics.

Event & state:

After N deposits with FoT, balance == Σ received.

Sweeps reduce pendingFees[asset] and emit FeeSwept.

Reentrancy & CEI:

Keep vault with no external callbacks; use CEI on PSM side for deposit→mint atomicity.

Fuzz:

Random fotBps in [0, 500] and random amountIn; ensure invariants hold.
