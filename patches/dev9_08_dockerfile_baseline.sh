#!/bin/bash
set -e

echo "== DEV-9 08: Create docker/Dockerfile.baseline =="

# 1) Ensure docker directory exists
mkdir -p docker

# 2) Write baseline Dockerfile for local use (no CI integration yet)
cat <<'EOD' > docker/Dockerfile.baseline
# Baseline Dockerfile for 1kUSD local tooling
#
# This image is intended for manual, local use (e.g. running foundry
# tests or docs builds inside a container). It is NOT wired into CI by
# DEV-9 08. Any CI integration must be done in a separate, explicit
# patch and with Architect approval.

FROM ubuntu:22.04

# Basic OS setup
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      build-essential \
      python3 \
      python3-venv \
      python3-pip && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Notes for local use:
#
# - Mount the 1kUSD repo into /app when running this container, e.g.:
#     docker run --rm -it -v "\$PWD:/app" 1kusd-dev:baseline bash
#
# - Inside the container you can:
#     - create a Python venv and install mkdocs + plugins
#     - install Foundry using the official installer:
#         curl -L https://foundry.paradigm.xyz | bash
#         foundryup
#
# - DEV-9 will NOT modify this file automatically in future patches
#   without a dedicated ticket. Any CI workflows that use this Dockerfile
#   will be introduced in separate, explicit patches (e.g. DEV-9 09).
EOD

# 3) Log message
LOG_FILE="logs/project.log"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-9 08] ${timestamp} Added docker/Dockerfile.baseline for local use" >> "$LOG_FILE"

echo "== DEV-9 08 done =="
