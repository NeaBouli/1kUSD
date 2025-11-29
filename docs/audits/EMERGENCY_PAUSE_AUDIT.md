# Emergency Pause Audit – Spec (v0.27+)

## Goal
Validate system-wide pause propagation from Guardian to all modules.

## Steps
1. Call guardian.pause()
2. Verify PSM.swapCollateralForStable reverts
3. Verify Vault.deposit/withdraw revert
4. Verify FeeRouter.route() reverts
5. Call guardian.unpause() and re-test (expect success)

```mermaid
sequenceDiagram
Guardian->>PSM: pause()
Guardian->>Vault: pause()
Guardian->>FeeRouter: pause()
