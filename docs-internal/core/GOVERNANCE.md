# Governance Overview (1kUSD)

## Roles
- **Admin (DAO/Multisig):** Parametrisierung, Timelock-Owner.
- **Timelock:** Erzwingt Delay/Grace für sensitive Änderungen.
- **SafetyAutomata:** Systemweite Pause/Unpause pro Modul-ID.

## Timelock Parameters
- `delay`: Mindestwartezeit bis eine TX `execute`-bar wird.
- `gracePeriod`: Fenster nach Delay; danach verfällt die TX.

## Flow
1) **Queue:** Admin kündigt Operation an → `Queued(txHash, eta)`.
2) **Execute:** Nach `block.timestamp >= eta` und `< eta + gracePeriod`.
3) **Cancel:** Vor `execute` jederzeit möglich → `Cancelled(txHash)`.

## Invariants
- Kein Bypass von Delay/Grace über Admin-Funktionen.
- Jede sensitive Funktion geht über Timelock.
- Modul-ID: `TIMELOCK` (keccak256).

## Security Notes
- Kein einzelnes EOA als Dauer-Owner; Admin = DAO/Multisig.
- Volle On-Chain Auditability via Events.
