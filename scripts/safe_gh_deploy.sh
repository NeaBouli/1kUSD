#!/usr/bin/env bash
set -e

echo "🔍 Checking for stale gh-pages locks..."
if [ -d "/private/tmp/gh" ]; then
  echo "🧹 Removing stale /private/tmp/gh directory..."
  rm -rf /private/tmp/gh
fi

echo "🚀 Running safe mkdocs deploy..."
mkdocs gh-deploy --force
echo "✅ Deploy completed without stale lock."

