# PSM ↔ FeeRouter ↔ TreasuryVault Flow (Spec v0.1)

**Objective:** Define deterministic path of collateral fees and stable outflow between modules.

```mermaid
sequenceDiagram
    participant User
    participant PSM
    participant FeeRouter
    participant TreasuryVault

    User->>PSM: swapCollateralForStable(amountIn)
    PSM->>FeeRouter: route(collateralToken, fee)
    FeeRouter->>TreasuryVault: deposit(fee)
    PSM->>User: transfer(stableToken, netAmount)
Core Assumptions
Router is stateless, Vault is sink

Fee = (amountIn × feeBps / 10 000)

PSM may be paused by Guardian on abnormal oracle deviation

All transfers follow CEI (Checks–Effects–Interactions)

Events
Swapped(address sender, uint256 amountIn, uint256 amountOut, address to)

FeeSent(address token, uint256 feeAmount)

FeeRouted(address token, address from, uint256 amount, bytes32 tag)

Safety
amountIn == 0 → revert

token == address(0) → revert

Non-reentrant

Uses safeTransfer semantics
