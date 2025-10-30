# DEV 9 — DAO Timelock & Governance Sweep

## Scope
- Review/Hardening: `contracts/core/DAO_Timelock.sol`
- Konsolidierung Admin-Konzept: SafetyAutomata / ParameterRegistry
- Saubere Events, Fehler, IDs (bytes32)
- Minimaltests: Queue/Execute/Cancel + Delay/Grace Checks
- Governance-Doku

## Muss-Kriterien
- `onlyAdmin` nutzt *ein* zentrales Admin-Prinzip (kein Shadow-Owner).
- `queue(tx)` -> `execute(tx)` erst **nach** Delay; `cancel(tx)` jederzeit vor Ablauf.
- `gracePeriod` nach Delay: Transaktionen verfallen nach Ende der Grace.
- Events: `Queued`, `Executed`, `Cancelled` mit Param-Hash.
- Fehler: `ACCESS_DENIED()`, `INVALID_DELAY()`, `EXEC_TOO_EARLY()`, `TX_EXPIRED()`.
- Konstanten: `MODULE_ID = keccak256("TIMELOCK")`.

## Tests (Minimal)
- `testQueueThenExecuteAfterDelay()`
- `testExecuteTooEarlyReverts()`
- `testCancelPreventsExecute()`
- `testExpiredTxReverts()`

## Deliverables
1. Contracts: minimal nötige Änderungen (keine Funktionslawine).
2. Tests: Foundry, grün.
3. Docs: `docs/GOVERNANCE.md` (Kurz, präzise).
4. CHANGELOG-Eintrag.
5. Logeintrag `docs/logs/project.log`.

## Definition of Done
- Foundry CI: grün
- Solidity CI: grün
- Keine neuen Lint-Warnungen zu Naming/Imports (wenn möglich)
