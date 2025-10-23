/**

1kUSD SDK (minimal stubs)

Address book loader

EIP-2612 permit builder/sign helper

Oracle aggregation helper (apply vectors)
*/
import fs from "node:fs";
import { TypedDataEncoder, Wallet } from "ethers";

export type AddressBook = {
version: string;
generatedAt?: string;
chains: { chainId: number; network: string; contracts: { name: string; address: 0x${string} }[] }[];
};

export function loadAddressBook(path: string): AddressBook {
const j = JSON.parse(fs.readFileSync(path, "utf8"));
return j as AddressBook;
}

export function addressesForChain(book: AddressBook, chainId: number): Record<string, 0x${string}> {
const c = book.chains.find((x) => x.chainId === chainId);
if (!c) throw new Error(chainId ${chainId} not found);
const map: Record<string, 0x${string}> = {};
for (const k of c.contracts) map[k.name.toUpperCase()] = k.address;
return map;
}

// ---- EIP-2612 Permit helpers ----
export type PermitDomain = { name: string; version: string; chainId: number; verifyingContract: 0x${string}; };
export type PermitMsg = { owner: 0x${string}; spender: 0x${string}; value: bigint; nonce: bigint; deadline: bigint; };

export function buildPermitDigest(domain: PermitDomain, msg: PermitMsg): string {
const types = {
Permit: [
{ name: "owner", type: "address" },
{ name: "spender", type: "address" },
{ name: "value", type: "uint256" },
{ name: "nonce", type: "uint256" },
{ name: "deadline", type: "uint256" }
]
} as const;
return TypedDataEncoder.hash(domain as any, types as any, msg as any);
}

export function signPermit(domain: PermitDomain, msg: PermitMsg, privateKey: 0x${string}) {
const digest = buildPermitDigest(domain, msg);
const w = new Wallet(privateKey);
const sig = w.signingKey.sign(digest);
const v = sig.v >= 27 ? sig.v : (sig.v + 27);
return { digest, v, r: sig.r, s: sig.s };
}

// ---- Oracle helpers (vector application only) ----
export type OracleSource = { price: string; decimals: number; updatedAt: number; healthy: boolean };
export type OracleOpts = { mode: "MEDIAN" | "TRIMMED_MEAN"; trim?: number; decimalsOut: number; now: number; maxAgeSec: number; maxDeviationBps: number };

function normalize(price: bigint, inDec: number, outDec: number): bigint {
if (outDec === inDec) return price;
if (outDec > inDec) return price * BigInt(10) ** BigInt(outDec - inDec);
return price / (BigInt(10) ** BigInt(inDec - outDec));
}

export function aggregateOracle(sources: OracleSource[], opts: OracleOpts) {
const accepted: bigint[] = [];
let minUpdated = Number.MAX_SAFE_INTEGER;

for (const s of sources) {
if (!s.healthy) continue;
if (opts.now - s.updatedAt > opts.maxAgeSec) continue;
const p = BigInt(s.price);
if (p <= 0n) continue;
const n = normalize(p, s.decimals, opts.decimalsOut);
accepted.push(n);
if (s.updatedAt < minUpdated) minUpdated = s.updatedAt;
}
if (accepted.length === 0) return { healthy: false };

accepted.sort((a, b) => (a < b ? -1 : a > b ? 1 : 0));
const median = (arr: bigint[]) => {
const n = arr.length;
return n % 2 === 1 ? arr[(n - 1) / 2] : (arr[n / 2 - 1] + arr[n / 2]) / 2n;
};
const mid = median(accepted);

// deviation guard
for (const a of accepted) {
const devBps = (a > mid ? (a - mid) : (mid - a)) * 10000n / (mid === 0n ? 1n : mid);
if (devBps > BigInt(opts.maxDeviationBps)) return { healthy: false };
}

let price: bigint;
if (opts.mode === "MEDIAN") {
price = mid;
} else {
const t = Math.min(opts.trim ?? Math.floor(accepted.length / 4), Math.floor(accepted.length / 4));
if (accepted.length < 2 * t + 1) {
price = mid;
} else {
const sliced = accepted.slice(t, accepted.length - t);
let sum = 0n;
for (const x of sliced) sum += x;
price = sum / BigInt(sliced.length);
}
}

return { healthy: true, price: price.toString(), decimals: opts.decimalsOut, updatedAt: minUpdated, accepted: accepted.length };
}
