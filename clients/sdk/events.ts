// SDK Event Decoders for 1kUSD protocol (PSM, Vault, Token)
// Language: EN. Runtime: Node 18+/TS 5+/ethers v6.

import fs from "node:fs";
import { Interface, Log } from "ethers";

// Load canonical ABIs
const psmAbi = JSON.parse(fs.readFileSync("abi/psm.events.json", "utf8"));
const vaultAbi = JSON.parse(fs.readFileSync("abi/vault.events.json", "utf8"));
const tokenAbi = JSON.parse(fs.readFileSync("abi/token.events.json", "utf8"));

export const PSM_IFACE = new Interface(psmAbi);
export const VAULT_IFACE = new Interface(vaultAbi);
export const TOKEN_IFACE = new Interface(tokenAbi);

export type Decoded =
| { name: "SwapTo1kUSD"; args: { user: string; tokenIn: string; amountIn: bigint; fee: bigint; minted: bigint; ts: bigint } }
| { name: "SwapFrom1kUSD"; args: { user: string; tokenOut: string; amountIn: bigint; fee: bigint; paidOut: bigint; ts: bigint } }
| { name: "FeeAccrued"; args: { asset: string; amount: bigint } }
| { name: "Deposit"; args: { asset: string; from: string; amount: bigint } }
| { name: "Withdraw"; args: { asset: string; to: string; amount: bigint; reason: string } }
| { name: "FeeSwept"; args: { asset: string; to: string; amount: bigint } }
| { name: "Transfer"; args: { from: string; to: string; value: bigint } }
| { name: "Approval"; args: { owner: string; spender: string; value: bigint } };

export function decodePSM(log: Log): Decoded | null {
try {
const parsed = PSM_IFACE.parseLog(log);
const a = parsed.args;
switch (parsed.name) {
case "SwapTo1kUSD":
return { name: "SwapTo1kUSD", args: { user: a.user, tokenIn: a.tokenIn, amountIn: a.amountIn, fee: a.fee, minted: a.minted, ts: a.ts } };
case "SwapFrom1kUSD":
return { name: "SwapFrom1kUSD", args: { user: a.user, tokenOut: a.tokenOut, amountIn: a.amountIn, fee: a.fee, paidOut: a.paidOut, ts: a.ts } };
case "FeeAccrued":
return { name: "FeeAccrued", args: { asset: a.asset, amount: a.amount } };
default:
return null;
}
} catch { return null; }
}

export function decodeVault(log: Log): Decoded | null {
try {
const parsed = VAULT_IFACE.parseLog(log);
const a = parsed.args;
switch (parsed.name) {
case "Deposit":
return { name: "Deposit", args: { asset: a.asset, from: a.from, amount: a.amount } };
case "Withdraw":
return { name: "Withdraw", args: { asset: a.asset, to: a.to, amount: a.amount, reason: a.reason } };
case "FeeSwept":
return { name: "FeeSwept", args: { asset: a.asset, to: a.to, amount: a.amount } };
default:
return null;
}
} catch { return null; }
}

export function decodeToken(log: Log): Decoded | null {
try {
const parsed = TOKEN_IFACE.parseLog(log);
const a = parsed.args;
switch (parsed.name) {
case "Transfer":
return { name: "Transfer", args: { from: a.from, to: a.to, value: a.value } };
case "Approval":
return { name: "Approval", args: { owner: a.owner, spender: a.spender, value: a.value } };
default:
return null;
}
} catch { return null; }
}

/** Try all known decoders; returns first match or null */
export function decodeAny(log: Log): Decoded | null {
return decodePSM(log) || decodeVault(log) || decodeToken(log);
}

// Narrow Log shape used by ethers v6; keep minimal for compatibility
export type MinimalLog = {
topics: readonly string[];
data: string;
address?: string;
blockNumber?: number | bigint;
transactionHash?: string;
logIndex?: number;
};

export function toEthersLog(x: MinimalLog): Log {
return {
...x,
blockHash: "",
blockNumber: (x.blockNumber ?? 0) as any,
transactionHash: x.transactionHash ?? "",
index: x.logIndex ?? 0,
transactionIndex: 0,
removed: false
} as unknown as Log;
}
