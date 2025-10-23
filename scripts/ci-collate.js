// Collate CI artifacts and enforce red/green criteria
// Usage: node scripts/ci-collate.js reports > reports/ci-summary.json
const fs = require('fs');
const path = require('path');

function safeRead(p) {
try { return JSON.parse(fs.readFileSync(p,'utf8')); } catch { return null; }
}
function findFile(dir, name) {
const p = path.join(dir, name);
return fs.existsSync(p) ? p : null;
}

const dir = process.argv[2] || 'reports';
const out = { ok: true, reasons: [], files: {} };

// Unit
const unitP = findFile(dir, 'unit.json');
if (unitP) {
const j = safeRead(unitP); out.files.unit = j;
if (!j || j.failed > 0) { out.ok = false; out.reasons.push('unit failed>0 or unreadable'); }
} else { out.ok = false; out.reasons.push('unit.json missing'); }

// Invariants
const invP = findFile(dir, 'invariants.json');
if (invP) {
const j = safeRead(invP); out.files.invariants = j;
if (!j || !Array.isArray(j.invariants)) { out.ok = false; out.reasons.push('invariants unreadable'); }
else if (j.invariants.some(x => (x.violations ?? 0) > 0)) { out.ok = false; out.reasons.push('invariants violations>0'); }
} else { out.ok = false; out.reasons.push('invariants.json missing'); }

// Static
const slitherP = findFile(dir, 'slither.json');
const mythrilP = findFile(dir, 'mythril.json');
if (slitherP) {
const j = safeRead(slitherP); out.files.slither = j;
if (!j) { out.ok = false; out.reasons.push('slither unreadable'); }
else if (Array.isArray(j.findings) && j.findings.some(f => ['CRITICAL','HIGH','critical','high'].includes(String(f.severity||'').toUpperCase()))) {
out.ok = false; out.reasons.push('slither CRITICAL/HIGH findings');
}
} else { out.ok = false; out.reasons.push('slither.json missing'); }

if (mythrilP) {
const j = safeRead(mythrilP); out.files.mythril = j;
if (!j) { out.ok = false; out.reasons.push('mythril unreadable'); }
else if (Array.isArray(j.findings) && j.findings.some(f => ['CRITICAL','HIGH','critical','high'].includes(String(f.severity||'').toUpperCase()))) {
out.ok = false; out.reasons.push('mythril CRITICAL/HIGH findings');
}
} else { out.ok = false; out.reasons.push('mythril.json missing'); }

// Gas (only presence check)
const gasP = findFile(dir, 'gas.json');
if (gasP) {
const j = safeRead(gasP); out.files.gas = j;
if (!j) { out.ok = false; out.reasons.push('gas unreadable'); }
} else { out.ok = false; out.reasons.push('gas.json missing'); }

// Security rollup (optional)
const secP = findFile(dir, 'security-findings.json');
if (secP) out.files.security = safeRead(secP);

// Output summary
const summary = JSON.stringify(out, null, 2);
console.log(summary);
if (!out.ok) process.exit(2);
