// Compose calldata for ParameterRegistry writes from proposal JSON
// Usage: node scripts/compose-param-change.ts ops/proposals/param_change.sample.json > ops/proposals/param_change.calldata.json

import fs from "node:fs";
import { Interface } from "ethers";

const abi = [
"function setUint(bytes32 key, uint256 value)",
"function setAddress(bytes32 key, address value)"
];
const REG_IFACE = new Interface(abi);

type Operation = {
op: "setUint" | "setAddress";
keySeed: string;
keyBytes32: string;
valueUint?: string;
valueAddress?: string;
};

type Proposal = {
chainId: number;
registry: 0x${string};
timelock: 0x${string};
eta?: number;
operations: Operation[];
title?: string;
description?: string;
};

function main() {
const file = process.argv[2];
if (!file) {
console.error("Usage: node scripts/compose-param-change.ts <proposal.json>");
process.exit(1);
}
const raw = fs.readFileSync(file, "utf8");
const p: Proposal = JSON.parse(raw);

const calls = p.operations.map((op) => {
if (op.op === "setUint") {
if (!op.valueUint) throw new Error("valueUint required");
const data = REG_IFACE.encodeFunctionData("setUint", [op.keyBytes32, op.valueUint]);
return { target: p.registry, value: "0", data, op: op.op, keySeed: op.keySeed };
} else if (op.op === "setAddress") {
if (!op.valueAddress) throw new Error("valueAddress required");
const data = REG_IFACE.encodeFunctionData("setAddress", [op.keyBytes32, op.valueAddress]);
return { target: p.registry, value: "0", data, op: op.op, keySeed: op.keySeed };
} else {
throw new Error(unknown op ${op.op});
}
});

const out = {
title: p.title || "",
description: p.description || "",
chainId: p.chainId,
timelock: p.timelock,
eta: p.eta || 0,
calls
};
console.log(JSON.stringify(out, null, 2));
}

main();
