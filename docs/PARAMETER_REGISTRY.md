
Parameter Registry — Final (v1)

Purpose

Canonical on-chain key→value map for protocol parameters.

Read-only for modules; writes performed via DAO/Timelock executor.

Access Patterns

Uint params: getUint(bytes32 key) → uint256

Address params: getAddress(bytes32 key) → address

Key derivation (per-asset): keccak256(abi.encodePacked(KEY, asset))

Update Flow

Proposal created in DAO with key/value changes

Timelock delay elapses

Executor writes new values; events emitted on-chain

Off-chain indexer mirrors changes with block number + timestamp

Guards

SafetyAutomata may READ params but not write

Param ranges validated inside writer (executor), not in Registry

References

Interface: contracts/interfaces/IParameterRegistry.sol

Keys catalog: docs/PARAM_KEYS_CATALOG.md

JSON schema + samples: schemas/params.schema.json, tests/vectors/params.sample.json
