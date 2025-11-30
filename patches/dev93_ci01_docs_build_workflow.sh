#!/usr/bin/env bash
set -euo pipefail

echo "== DEV93 CI01: add docs build CI workflow =="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

WORKFLOW_DIR=".github/workflows"
WORKFLOW_FILE="${WORKFLOW_DIR}/docs-build.yml"
LOG_FILE="logs/project.log"

mkdir -p "$WORKFLOW_DIR"

cat > "$WORKFLOW_FILE" <<'YAML'
name: Docs Build

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build-docs:
    name: Build MkDocs documentation
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install MkDocs dependencies
        run: |
          python -m pip install --upgrade pip
          pip install mkdocs mkdocs-material

      - name: Build documentation
        run: mkdocs build
YAML

echo "✓ docs-build.yml written to ${WORKFLOW_FILE}"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-93] ${timestamp} CI: added standalone docs-build workflow (mkdocs build on push/PR to main)." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV93 CI01: done =="
