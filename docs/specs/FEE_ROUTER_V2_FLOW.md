# FeeRouter V2 Flow (Spec v0.1)

**Goal:** Enable dynamic routing of fees across multiple destinations.

## Features
- Supports multiple fee tags (POOL, DAO, BUYBACK, TREASURY)
- Each tag resolves to a registered vault address
- DAO can update routing map via governance call
- Emits `FeeRouted(tag, token, amount, to)`

## Core Flow
```mermaid
sequenceDiagram
participant Token
participant FeeRouterV2
participant Vault
Token->>FeeRouterV2: transfer(fee)
FeeRouterV2->>Vault: routeFee(tag, token, amount)
Vault->>Vault: updateAccounting()
Security
onlyDAO can modify routing map

Pausable + ReentrancyGuard enforced

zero-amount routes revert

Uses safeTransfer() for all ERC20 moves
