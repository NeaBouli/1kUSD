// Evaluate Vault vectors (received-based deposit, pending fees spendable)
import fs from "node:fs";

type Case = any;

function received(pre: bigint, post: bigint) {
const r = post - pre;
if (r <= 0n) throw new Error("FOT_ZERO_RECEIVED");
return r;
}

function spendable(ledger: bigint, pending: bigint) {
if (pending > ledger) throw new Error("FEE_OVERFLOW");
return ledger - pending;
}

function main() {
const f = process.argv[2] || "tests/vectors/vault_fot_vectors.json";
const vec = JSON.parse(fs.readFileSync(f, "utf8"));
const out: any[] = [];

for (const c of vec.cases as Case[]) {
try {
if ("preBalance" in c) {
const r = received(BigInt(c.preBalance), BigInt(c.postBalance));
out.push({ case: c.case, received: r.toString(), ok: true });
} else if ("ledgerBefore" in c) {
const s = spendable(BigInt(c.ledgerBefore), BigInt(c.pendingFeesBefore));
const w = BigInt(c.withdraw);
if (w > s) throw new Error("INSUFFICIENT_LIQUIDITY");
out.push({ case: c.case, spendable: s.toString(), withdrawOk: true, ok: true });
} else {
out.push({ case: c.case, note: "unhandled vector shape" });
}
} catch (e:any) {
out.push({ case: c.case, error: String(e.message || e), ok: false });
}
}

console.log(JSON.stringify(out, null, 2));
}
main();
