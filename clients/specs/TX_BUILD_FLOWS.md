# Transaction Build/Sign/Broadcast/Simulate — Flows

Build: ABI+calldata, gas estimate (+margin), nonce, EIP-1559 fees, chainId  
Sign: HW-wallet friendly, never expose keys  
Simulate: eth_call at pending; surface revert reason & domain  
Broadcast & Wait: RBF handling, status/confirmations  
Error mapping: align to COMMON_ERRORS.md
