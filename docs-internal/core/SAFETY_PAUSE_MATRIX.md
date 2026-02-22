# Safety Pause Matrix (v1)
**Status:** Docs (normative). **Audience:** Core devs, dApp/SDK, ops.

## Purpose
Define which state-changing actions must be blocked when a module is paused by SafetyAutomata.

## Module IDs (canonical)
- `PSM` — PegStabilityModule
- `VAULT` — CollateralVault
- `ORACLE` — OracleAggregator
- `TOKEN` — OneKUSD (mint/burn only)
- `REGISTRY` — ParameterRegistry
- `GOV` — DAO/Timelock (execution paths)
> Exact byte32 values: see `docs/MODULE_IDS.md`.

## Matrix
| Module paused | Blocked calls (non-exhaustive) | Allowed reads |
|---|---|---|
| PSM | `swapTo1kUSD`, `swapFrom1kUSD` | `quote*`, `isSupportedToken`, getters |
| VAULT | `deposit`, `withdraw`, `sweepFees` | `balanceOf`, `isAssetSupported` |
| ORACLE | `setPriceMock` (dev), any mutating feed adapters | `getPrice` (read-only) |
| TOKEN | `mint`, `burn` | `transfer`, `approve`, `transferFrom`, views |
| REGISTRY | parameter set/update fns | reads of parameters |
| GOV | (if applied) `execute()` fast-paths | `queue()`, `read` (policy-dependent) |

## Rules
- Pausing **PSM** must be sufficient to halt mint/redeem flows (even if TOKEN is not paused).
- **TOKEN** pause gates only `mint/burn`, **never** user transfers (unless specified by governance policy).
- Reads are always allowed; no side effects.

## Event consistency
- `ModulePaused(moduleId, actor, reason, ts)`
- `ModuleUnpaused(moduleId, actor, ts)`
Clients should reflect current pause state per module using SafetyAutomata getters.
