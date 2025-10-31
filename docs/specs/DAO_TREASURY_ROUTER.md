# DAO Treasury Router Integration (Spec v0.1)

**Goal:**  
Unify routing of all protocol fees and DAO-controlled treasuries.

## Core Responsibilities
- Receives fees from FeeRouterV2
- Forwards assets to TreasuryVault
- Allows DAO to trigger sweeping or redistribution via VaultSweeper
- Maintains internal ledger for received tokens
- Enforces DAO-only governance calls

## Security
- Pausable + NonReentrant enforced
- Zero-amount forwards revert
- Protected collateral whitelist shared with VaultSweeper
- Emits `TreasuryForwarded(token, amount, to)`

## Flow Diagram
```mermaid
sequenceDiagram
participant FeeRouterV2
participant TreasuryRouter
participant TreasuryVault
participant VaultSweeper
FeeRouterV2->>TreasuryRouter: route(tag, token, amount)
TreasuryRouter->>TreasuryVault: forward(token, amount)
TreasuryVault->>VaultSweeper: sweep(token, amount, DAO)
Note over all: DAO-controlled end-to-end fee settlement
