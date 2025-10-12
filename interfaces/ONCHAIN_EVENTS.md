# On-Chain Event Catalog (Spec Only)

Repository language: EN. No code here. This file defines **event names and fields** for all protocol modules.
Types are language-neutral (uint256, address, bytes32, bool, string, int256, bytes).
All events must be indexed where noted.

## Conventions
- `indexed` fields are marked with `(indexed)`.
- Amounts use 18 decimals unless the underlying token differs.
- Timestamps are UNIX seconds (uint256).

## 1) 1kUSD Token
- Mint(to (indexed) address, amount uint256, module (indexed) string, txId bytes32, ts uint256)
- Burn(from (indexed) address, amount uint256, module (indexed) string, txId bytes32, ts uint256)
- Transfer(from (indexed) address, to (indexed) address, amount uint256)

## 2) CollateralVault
- Deposit(asset (indexed) address, from (indexed) address, amount uint256, ts uint256)
- SystemDeposit(asset (indexed) address, amount uint256, source (indexed) string, ts uint256)
- Withdraw(asset (indexed) address, to (indexed) address, amount uint256, reason (indexed) string, ts uint256)
- ExposureCapSet(asset (indexed) address, cap uint256, ts uint256)
- ExposureBreached(asset (indexed) address, requested uint256, cap uint256, ts uint256)

## 3) PSM
- SwappedTo1kUSD(user (indexed) address, tokenIn (indexed) address, amountIn uint256, amountOut uint256, fee uint256, ts uint256)
- SwappedFrom1kUSD(user (indexed) address, tokenOut (indexed) address, amountIn uint256, amountOut uint256, fee uint256, ts uint256)
- PSMFeeSet(bps uint256, ts uint256)
- PSMCapSet(asset (indexed) address, cap uint256, ts uint256)
- PSMRateLimitSet(windowSec uint256, maxAmount uint256, ts uint256)

## 4) AutoConverter
- ConvertRequested(user (indexed) address, assetIn (indexed) address, amountIn uint256, slippageBps uint256, ts uint256)
- RouteSelected(routeId (indexed) bytes32, aggregator (indexed) address, expectedOut uint256, ts uint256)
- Converted(assetIn (indexed) address, assetOut (indexed) address, amountIn uint256, amountOut uint256, fee uint256, ts uint256)
- AdapterAdded(adapter (indexed) address, ts uint256)
- AdapterRemoved(adapter (indexed) address, ts uint256)

## 5) OracleAggregator
- FeedUpdated(asset (indexed) address, price int256, decimals uint8, ts uint256)
- OracleHealthChanged(asset (indexed) address, healthy bool, reason string, ts uint256)
- DeviationGuardSet(asset (indexed) address, maxBps uint256, ts uint256)
- StalenessGuardSet(asset (indexed) address, maxAgeSec uint256, ts uint256)

## 6) Safety-Automata
- ModulePaused(module (indexed) string, actor (indexed) address, reason string, ts uint256)
- ModuleResumed(module (indexed) string, actor (indexed) address, ts uint256)
- CapSet(target (indexed) string, key (indexed) bytes32, value uint256, ts uint256)
- RateLimitSet(target (indexed) string, windowSec uint256, maxAmount uint256, ts uint256)
- EmergencyTriggered(module (indexed) string, actor (indexed) address, details string, ts uint256)

## 7) DAO / Timelock
- ProposalCreated(id (indexed) uint256, proposer (indexed) address, ipfsHash bytes32, eta uint256)
- VoteCast(voter (indexed) address, proposalId (indexed) uint256, support uint8, weight uint256, reason string)
- ProposalQueued(id (indexed) uint256, eta uint256)
- ProposalExecuted(id (indexed) uint256, txHash (indexed) bytes32, ts uint256)
- ParameterChanged(name (indexed) string, value bytes, ts uint256)

## 8) Treasury
- FeeAccrued(source (indexed) string, asset (indexed) address, amount uint256, ts uint256)
- SpendProposed(id (indexed) uint256, asset (indexed) address, amount uint256, to address, ts uint256)
- SpendExecuted(id (indexed) uint256, asset (indexed) address, amount uint256, to address, ts uint256)

## 9) Bridge Anchor (Prep)
- MessageSent(nonce (indexed) uint256, dstChainId (indexed) uint256, payloadHash (indexed) bytes32, ts uint256)
- MessageReceived(nonce (indexed) uint256, srcChainId (indexed) uint256, payloadHash (indexed) bytes32, success bool, ts uint256)
- BridgePaused(actor (indexed) address, reason string, ts uint256)
