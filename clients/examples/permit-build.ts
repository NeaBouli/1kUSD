// Build EIP-2612 permit digest & signature (ethers v6)
import { keccak256, toUtf8Bytes, AbiCoder, Wallet, TypedDataEncoder } from "ethers";
import fs from "node:fs";

type Domain = { name: string; version: string; chainId: number; verifyingContract: 0x${string}; };
type Input = {
domain: Domain;
owner: 0x${string}; spender: 0x${string};
value: bigint; nonce: bigint; deadline: bigint;
privateKey: 0x${string};
};

const EIP712_TYPES = {
Permit: [
{ name: "owner", type: "address" },
{ name: "spender", type: "address" },
{ name: "value", type: "uint256" },
{ name: "nonce", type: "uint256" },
{ name: "deadline", type: "uint256" }
]
};

function buildDigest(input: Input) {
const domain = input.domain;
const message = {
owner: input.owner,
spender: input.spender,
value: input.value,
nonce: input.nonce,
deadline: input.deadline
};
const digest = TypedDataEncoder.hash(domain, EIP712_TYPES as any, message);
return { domain, message, digest };
}

function sign(input: Input) {
const { digest } = buildDigest(input);
const w = new Wallet(input.privateKey);
const sig = w.signingKey.sign(digest);
// Normalize v to 27/28
const v = sig.v >= 27 ? sig.v : (sig.v + 27);
return { v, r: sig.r, s: sig.s, digest };
}

// Example: load vectors and produce signature for the first case
if (require.main === module) {
const vectors = JSON.parse(fs.readFileSync("tests/vectors/permit_vectors.json", "utf8"));
const c = vectors.cases[0];
const out = sign({
domain: vectors.domain,
owner: c.owner,
spender: c.spender,
value: BigInt(c.value),
nonce: BigInt(c.nonce),
deadline: BigInt(c.deadline),
privateKey: c.privateKey
});
console.log(JSON.stringify(out, null, 2));
}
