
OneKUSD — EIP-2612 Permit (Final Spec v1)

Status: Normative doc. Language: EN.

1) Objective

Support gasless approvals via permit in compliance with EIP-2612. Nonces are per-owner. Signature is EIP-712 typed data.

2) Domain (EIP-712)

EIP712Domain fields (exact casing):

name: "OneKUSD"

version: "1"

chainId: uint256 (runtime)

verifyingContract: address (token address)

Domain separator:
DOMAIN_SEPARATOR = keccak256(abi.encode( keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"), keccak256(bytes(name)), keccak256(bytes(version)), chainId, address(this) ))

MUST update dynamically if chainId changes (per EIP-2612 guidance) or implement EIP-5267 getter.

3) Permit struct & digest

Type hash:
PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")

Struct (exact order/types):

owner: address

spender: address

value: uint256

nonce: uint256 (current nonce of owner)

deadline: uint256 (unix seconds)

Digest:
digest = keccak256("\x19\x01" || DOMAIN_SEPARATOR || keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline)))

4) Function

function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

Rules:

require(block.timestamp <= deadline) (deadline inclusive).

Recover signer; must equal owner.

Nonce check: use nonces[owner] in struct; after success nonces[owner]++.

Emit standard Approval(owner, spender, value).

Set allowance to value (not add); mirrors OpenZeppelin ERC20Permit.

5) Security & Validations

Malleability: enforce s in lower half order; v in {27,28}.

Zero address: owner/spender can be zero if ERC-20 semantics allow (discouraged); keep parity with OZ.

Replay protection: per-owner nonces only.

Chain replay: protected by chainId in domain.

Signature over empty deadline (0) is allowed only if explicitly documented; RECOMMENDED: require deadline > 0.

6) Views & Events

function nonces(address owner) external view returns (uint256)

function DOMAIN_SEPARATOR() external view returns (bytes32)

Events: standard Approval.

7) Test Coverage

Valid permit updates allowance; emits Approval; nonce increments.

Expired deadline reverts.

Wrong signer reverts.

Replay (same sig) reverts due to nonce change.

Domain separator correctness (matches off-chain EIP-712).

ChainId change behavior (see EIP-2612 notes).

8) References

EIP-2612, EIP-712, OpenZeppelin ERC20Permit
