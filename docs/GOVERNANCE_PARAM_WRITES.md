
Governance Param Writes — Timelock Flow (v1)

Status: Docs (normative). Language: EN.

Objective

Define how governance changes protocol parameters via Timelock to the on-chain Parameter Registry. All writes are executed by the Timelock; regular EOAs cannot write.

Roles

Governor: creates proposals (off-chain coordination / on-chain governor contract)

Timelock: schedules and executes transactions after delay

ParameterRegistry: authoritative key/value map

Required Write Surface (Registry)

The Parameter Registry MUST expose Timelock-restricted setters:

function setUint(bytes32 key, uint256 value) external;
function setAddress(bytes32 key, address value) external;

Reads remain public (getUint/getAddress). Only the Timelock is authorized to call setters.

Canonical Flow

Propose: governor prepares a param-change bundle (JSON) with one or more set operations.

Queue: governor queues calldata through Timelock with target=ParameterRegistry, value=0.

Delay: Timelock enforces minDelay (e.g., 48–96h).

Execute: after delay, Timelock executes queued ops; events emitted by Registry.

Verify: indexer and ops verify post-state and announce.

Calldata Encoding (EVM)

Target: ParameterRegistry address

Selector setUint: bytes4(keccak256("setUint(bytes32,uint256)"))

Selector setAddress: bytes4(keccak256("setAddress(bytes32,address)"))

Arguments ABI-encoded

Event Expectations

Registry emits ParamUintSet(key, value, actor)

Registry emits ParamAddressSet(key, value, actor)

Timelock emits CallScheduled/CallExecuted (implementation-specific)

Safety Notes

Never batch unrelated risk domains in one proposal.

For caps/rate limits, stage values upward/downward with monitoring windows.

Emergency pause remains in Safety-Automata; it does not write params.

References

docs/PARAM_KEYS_CANON.md

ops/schemas/param_change.schema.json

ops/proposals/param_change.sample.json

scripts/compose-param-change.ts
