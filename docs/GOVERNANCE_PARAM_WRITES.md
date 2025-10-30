# Governance Parameter Writes (Catalog)

Purpose: Single source of truth for all **writable** parameters. Writes are executed **only** via Timelock/DAO (min. 72h delay). Each change must include an impact analysis and a rollback plan.

## A. Peg Stability Module (PSM)
| Key | Type | Units | Min | Max | Default | Guard Notes |
|---|---|---:|---:|---:|---:|---|
| psm.feeInBps | uint16 | bps | 0 | 300 | 20 | Fee income → TreasuryVault (via FeeRouter) |
| psm.priceBandBps | uint16 | bps | 0 | 500 | 50 | Acceptance band around $1 to resist oracle noise |
| psm.mintLimitDaily | uint256 | 1kUSD | 0 | 1e12 | 1e9 | Rolling window; anti-bank-run throttle |
| psm.redeemLimitDaily | uint256 | 1kUSD | 0 | 1e12 | 1e9 | Symmetric to mint side |
| psm.router | address | - | - | - | 0x0 | Must be a whitelisted FeeRouter |
| psm.paused | bool | - | - | - | false | Guardian/DAO per Runbook |

## B. TreasuryVault
| Key | Type | Units | Min | Max | Default | Guard Notes |
|---|---|---:|---:|---:|---:|---|
| vault.sweepThreshold[token] | uint256 | token units | 0 | 1e50 | 0 | Prevents dust movements |
| vault.daoRole | bytes32 | - | - | - | keccak("DAO_ROLE") | Outbound transfers DAO-only |
| vault.allowedSink[token] | bool | - | - | - | false | Whitelist inbound assets |

## C. Oracle Aggregator
| Key | Type | Units | Min | Max | Default | Guard Notes |
|---|---|---:|---:|---:|---:|---|
| oracle.minAnswers | uint8 | count | 1 | 25 | 5 | Robustness against outliers |
| oracle.heartbeatSec | uint32 | sec | 10 | 86400 | 300 | Data freshness |
| oracle.deviationBps | uint16 | bps | 0 | 1000 | 200 | Trigger for re-checks |

## D. Safety/Automata
| Key | Type | Units | Min | Max | Default | Guard Notes |
|---|---|---:|---:|---:|---:|---|
| safety.circuitBreakerLevel | uint8 | enum(0..3) | 0 | 3 | 0 | Graduated limits by level |
| safety.killSwitchArmed | bool | - | - | - | false | DAO-only; Guardian never |
| safety.maxSlippageBps | uint16 | bps | 0 | 2000 | 300 | Upper bound for trades |

**Write rules:** One parameter per proposal (except tightly coupled pairs). Mirror changes into `docs/logs/CHANGE_RECORD.md`.
