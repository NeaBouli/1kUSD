# TreasuryVault ↔ PSM Settlement (Spec v0.1)

**Goal:** Define a secure mechanism for transferring fees and collateral
between the Peg Stability Module (PSM) and the TreasuryVault.

## Flow Outline

```mermaid
sequenceDiagram
    participant PSM
    participant Vault
    PSM ->> Vault: depositCollateral(token, amount)
    Vault ->> Vault: update accounting records
    Vault -->> PSM: ack(success)
Key Rules
PSM may only call depositCollateral() on Vault.

Vault must verify caller == authorized PSM.

All transfers use safeTransferFrom.

Reentrancy guard on Vault side.

Guardian may pause both modules independently.

Events
VaultDeposit(address indexed from, address indexed token, uint256 amount)
