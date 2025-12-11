#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python - << 'PY'
from pathlib import Path

path = Path("docs/reports/REPORTS_INDEX.md")
text = path.read_text(encoding="utf-8").splitlines()

entry = "- [ARCHITECT_BULLETIN_OracleRequired_Impact_v2](ARCHITECT_BULLETIN_OracleRequired_Impact_v2.md)"

# Duplikate vermeiden
if any("ARCHITECT_BULLETIN_OracleRequired_Impact_v2" in line for line in text):
    raise SystemExit("entry already present, nothing to do")

idx = None
for i, line in enumerate(text):
    if "Architect" in line and "Bulletin" in line:
        idx = i
        break

if idx is not None:
    # Nach der Überschrift (und evtl. Leerzeilen) einfügen
    insert_pos = idx + 1
    while insert_pos < len(text) and text[insert_pos].strip() == "":
        insert_pos += 1
    text.insert(insert_pos, entry)
else:
    # Falls es noch keinen Block für Architect Bulletins gibt, am Ende anlegen
    if text and text[-1].strip() != "":
        text.append("")
    text.append("## Architect Bulletins")
    text.append("")
    text.append(entry)

path.write_text("\n".join(text) + "\n", encoding="utf-8")
PY

echo "[DEV-49] $(date -u +"%Y-%m-%dT%H:%M:%SZ") link OracleRequired architect bulletin in REPORTS_INDEX" >> logs/project.log

echo "== DEV-49 step05: reports index updated with OracleRequired bulletin =="
