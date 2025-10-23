// Example usage of SDK event decoders
import { decodeAny, toEthersLog, MinimalLog } from "../sdk/events";

// Example log (fill with real topics/data from a node or archive)
const example: MinimalLog = {
topics: [
// keccak256("SwapTo1kUSD(address,address,uint256,uint256,uint256,uint256)")
"0x6b0f6a3b6c4c8ce2c8f0d7d5fbe0000000000000000000000000000000000000000"
],
data: "0x",
address: "0x0000000000000000000000000000000000000000"
};

const decoded = decodeAny(toEthersLog(example));
console.log(decoded);
