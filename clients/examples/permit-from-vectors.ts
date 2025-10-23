import fs from "node:fs";
import { signPermit } from "../ts/src/index.js";

const vectors = JSON.parse(fs.readFileSync("tests/vectors/permit_vectors.json","utf8"));
const c = vectors.cases[0];

const out = signPermit(
vectors.domain,
{
owner: c.owner,
spender: c.spender,
value: BigInt(c.value),
nonce: BigInt(c.nonce),
deadline: BigInt(c.deadline)
},
c.privateKey
);

console.log(JSON.stringify(out, null, 2));
