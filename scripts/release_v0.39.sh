#!/usr/bin/env bash
set -euo pipefail

# Version argument (default = v0.39)
VERSION=${1:-v0.39}
TAG_MESSAGE="Release $VERSION"
LOGFILE="logs/project.log"

echo "== 🧩 Starting automated release for $VERSION =="

# 1️⃣ Preconditions
if [[ -n "$(git status --porcelain)" ]]; then
  echo "❌ Uncommitted changes detected. Commit or stash first."
  exit 1
fi

if git rev-parse "$VERSION" >/dev/null 2>&1; then
  echo "❌ Tag $VERSION already exists. Aborting."
  exit 1
fi

if ! forge build >/dev/null 2>&1; then
  echo "❌ Build failed. Fix errors before tagging."
  exit 1
fi

if ! forge test --match-path 'foundry/test/Guardian_OraclePropagation.t.sol' >/dev/null 2>&1; then
  echo "❌ Tests failed. Aborting release."
  exit 1
fi

# 2️⃣ Create tag
git tag -a "$VERSION" -m "$TAG_MESSAGE"
git push origin "$VERSION"

# 3️⃣ Log entry
mkdir -p logs
printf "%s %s released: OracleAggregator + Guardian stable [Fix-Dev-39]\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$VERSION" >> "$LOGFILE"

git add "$LOGFILE"
git commit -m "chore: log $VERSION release [Fix-Dev-39]"
git push

echo "✅ Release $VERSION completed successfully!"
echo "   → Tag pushed: $VERSION"
echo "   → Log updated: $LOGFILE"
