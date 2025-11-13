# DEV-20 – TreasuryVault Withdraw Functionality

**Scope**
- Add `withdrawCollateral()` with DAO-only, nonReentrant, and whenNotPaused guards
- Implements safeTransfer() using IERC20
- Updates balances with revert on insufficient/zero
- Full test coverage (happy path + guards)
- Spec reference: `VAULT_WITHDRAW_RULES.md`

**Tests**
✅ DAO-only access  
✅ Zero amount revert  
✅ Insufficient balance revert  
✅ Successful withdrawal updates balance  

