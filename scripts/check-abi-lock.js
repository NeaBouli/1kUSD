// Check that compiled PSM event ABI matches lock file (best-effort placeholder)
// Usage: node scripts/check-abi-lock.js abi/locks/PSM.events.json out/PSM.json
const fs = require('fs');

function main() {
const [lockPath, compiledPath] = process.argv.slice(2);
if (!lockPath) { console.error('Usage: node scripts/check-abi-lock.js <lock.json> <compiledAbi.json>'); process.exit(1); }
const lock = JSON.parse(fs.readFileSync(lockPath,'utf8'));
let compiled = null;
if (compiledPath && fs.existsSync(compiledPath)) {
compiled = JSON.parse(fs.readFileSync(compiledPath,'utf8'));
}
console.log('Lock events:', lock.events.map(e=>e.name));
if (!compiled) {
console.warn('Compiled ABI not provided; lock check skipped (informational).');
process.exit(0);
}
const compiledEvents = (compiled.abi || []).filter(x=>x.type==='event').map(e=>e.name);
const lockEvents = lock.events.map(e=>e.name);
const missing = lockEvents.filter(x=>!compiledEvents.includes(x));
const extra = compiledEvents.filter(x=>!lockEvents.includes(x));
if (missing.length || extra.length) {
console.error('ABI lock mismatch. Missing:', missing, 'Extra:', extra);
process.exit(2);
}
console.log('ABI lock OK.');
}
main();
