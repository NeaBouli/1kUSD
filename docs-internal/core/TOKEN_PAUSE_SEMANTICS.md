
OneKUSD — Pause Semantics (Final v1)

Policy:

Pause affects only mint and burn. Regular ERC-20 transfer and transferFrom remain allowed.

pause() / unpause() are governed by Safety/DAO. Guardian may only pause (if policy set) and only before sunset.

Normative Rules:

paused == true ⇒ mint() and burn() MUST revert PAUSED().

transfer* MUST NOT consult pause flag (ensures market liquidity during incidents).

Events: Paused(by), Unpaused(by) are emitted on state change (idempotent-safe).

Invariants: Supply changes (mint/burn) must be 0 while paused.

Interplay:

PSM swaps rely on mint/burn; pausing token effectively freezes PSM state changes while allowing normal transfers.

SafetyAutomata remains the control-plane; token enforces local rule.
