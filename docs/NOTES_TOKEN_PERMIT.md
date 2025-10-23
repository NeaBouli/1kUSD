# Token Permit Notes (DEV43)
**Scope:** Added EIP-2612 `permit` with EIP-712 domain separator; optional surface via `IERC2612`.

## What changed
- New interface `contracts/interfaces/IERC2612.sol`.
- Token now implements `permit`, `nonces`, and dynamic `DOMAIN_SEPARATOR()` (chainId-aware).
- Existing roles/pause semantics unchanged: pause gates only mint/burn, transfers unaffected.

## Integration Hints
- EIP-712 domain: name=`1kUSD`, version=`1`, chainId=current, verifyingContract=token address.
- Typehash: `Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)`.
- For SDKs: read `DOMAIN_SEPARATOR()` at runtime; do not cache across chainId changes.

## Next steps
- Add typed-data examples to client SDK specs.
- Optional: `permit` negative tests in DEV13/CI once tests exist.
