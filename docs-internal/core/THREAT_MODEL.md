
Threat Model — 1kUSD (v1)

Scope:

On-chain contracts: OneKUSD, PSM, CollateralVault, OracleAggregator, SafetyAutomata, ParameterRegistry, DAO_Timelock

Off-chain/ops surfaces (advisory): governance proposals, parameter releases, indexer read-only paths

Assets:

Collateral assets in Vault

1kUSD token supply and peg integrity

Governance authority (Timelock)

Oracle integrity (aggregation guards)

Adversaries:

External attackers (smart contract exploits, oracle manipulation, MEV)

Malicious counterparties (non-compliant ERC-20s, FoT tokens, decimals drift)

Governance capture attempts (proposal batching, parameter griefing)

Insider error (misconfig params, wrong caps/rate limits)

Key Risks & Controls (summary):

Unauthorized mint/burn → Role-gated via PSM, Safety pause gates; invariants I1–I4.

Peg drift via mispriced oracle → Staleness/deviation guards; MEDIAN/trimmed-mean; exec snapshot.

Vault accounting drift (FoT/decimals) → received-based deposit; fee accrual separation; vectors.

Rate-limit bypass → rolling window limiter with scopes; events.

Governance abuse → Timelock delay; param writes only; guardian sunset; runbooks.

Reentrancy / CEI violations → nonReentrant; deposit-before-mint/burn-before-withdraw; no callbacks.

ERC-20 quirks → adapter allowlist; decimals metadata; revert on unsupported.

Assumptions:

Oracles provide at least one healthy source most of the time.

Treasury spend path only via Timelock; Vault has no arbitrary spend.

Audit Questions Checklist:

Are all state transitions evented with sufficient data?

Is any USD math done outside PSM? (should be no)

Are fee rounding and unit conversions consistent with vectors?

Can pause or rate-limits be bypassed by alternative paths?

Governance param changes: are ranges validated where needed?
