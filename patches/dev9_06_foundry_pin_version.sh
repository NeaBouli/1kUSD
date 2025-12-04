#!/bin/bash
set -e

echo "== DEV-9 06: Pin Foundry version in foundry-test workflow =="

WORKFLOW_FILE=".github/workflows/foundry-test.yml"

if [ ! -f "$WORKFLOW_FILE" ]; then
  echo "ERROR: Workflow file '$WORKFLOW_FILE' not found." >&2
  exit 1
fi

python3 <<'PY'
import os
import sys

path = ".github/workflows/foundry-test.yml"

if not os.path.isfile(path):
    print(f"ERROR: {path} does not exist.", file=sys.stderr)
    sys.exit(1)

with open(path, "r", encoding="utf-8") as f:
    lines = f.readlines()

changed = False
target = "foundry-rs/foundry-toolchain"

i = 0
while i < len(lines):
    line = lines[i]
    if target in line:
        indent = line[: len(line) - len(line.lstrip())]

        # Suche nach einem vorhandenen 'with:'-Block auf gleicher Ebene
        with_idx = None
        j = i + 1
        while j < len(lines):
            next_line = lines[j]
            stripped = next_line.strip()

            # Kommentare/Leerzeilen überspringen
            if stripped == "" or stripped.startswith("#"):
                j += 1
                continue

            # Wenn die Einrückung <= indent ist und keine 'with:'-Zeile, ist der Block vorbei
            if (len(next_line) - len(next_line.lstrip())) <= len(indent) and not next_line.startswith(indent + "with:"):
                break

            if next_line.startswith(indent + "with:"):
                with_idx = j
                break

            j += 1

        version_line = indent + "  version: nightly-2024-05-21\n"

        if with_idx is None:
            # Kein 'with:' vorhanden → wir fügen 'with:' + 'version:' direkt nach der uses-Zeile ein
            insert_pos = i + 1
            lines.insert(insert_pos, indent + "with:\n")
            lines.insert(insert_pos + 1, version_line)
            changed = True
            i = insert_pos + 2
            continue
        else:
            # Es gibt einen 'with:'-Block → prüfe, ob eine 'version:'-Zeile existiert
            k = with_idx + 1
            version_idx = None
            while k < len(lines):
                l2 = lines[k]
                stripped2 = l2.strip()

                if stripped2 == "" or stripped2.startswith("#"):
                    k += 1
                    continue

                # Blockende, wenn Einrückung <= indent
                if (len(l2) - len(l2.lstrip())) <= len(indent):
                    break

                if l2.lstrip().startswith("version:"):
                    version_idx = k
                    break

                k += 1

            if version_idx is not None:
                lines[version_idx] = version_line
            else:
                lines.insert(with_idx + 1, version_line)

            changed = True
            i = k + 1
            continue
    i += 1

if not changed:
    print(f"WARNING: No '{target}' step found in {path}; no changes applied.", file=sys.stderr)

with open(path, "w", encoding="utf-8") as f:
    f.writelines(lines)
PY

LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 06] ${timestamp} Pinned Foundry version in foundry-test workflow (nightly-2024-05-21)" >> "$LOG_FILE"

echo "== DEV-9 06 done =="
