#!/bin/bash
set -e

echo "== DEV-9 09: Create docker-baseline-build workflow =="

# 1) Ensure workflows directory exists
mkdir -p .github/workflows

# 2) Write minimal manual Docker build workflow
cat <<'EOD' > .github/workflows/docker-baseline-build.yml
name: Docker baseline build

on:
  workflow_dispatch:

jobs:
  build-baseline:
    name: Build baseline Docker image
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Build docker/Dockerfile.baseline image
        run: docker build -f docker/Dockerfile.baseline -t 1kusd-dev:baseline .
EOD

# 3) Log message
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 09] ${timestamp} Added docker-baseline-build workflow (manual docker/Dockerfile.baseline build)" >> "$LOG_FILE"

echo "== DEV-9 09 done =="
