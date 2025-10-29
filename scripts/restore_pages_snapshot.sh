#!/usr/bin/env bash
set -euo pipefail

LOG="docs/logs/restore_pages_snapshot.log"
mkdir -p docs/logs
exec > >(tee -a "$LOG") 2>&1

echo "🩺 1kUSD — GitHub Pages Rollback Utility"
echo "Timestamp: $(date)"
echo "--------------------------------------"

# 1️⃣ Input & context
SNAP_TAG="${1:-v0.11.4-pages-stable}"
REMOTE="origin"
TARGET_BRANCH="gh-pages"

echo "🔖 Target snapshot: $SNAP_TAG"
echo "🌿 Target branch: $TARGET_BRANCH"
echo

# 2️⃣ Confirm tag exists
if ! git rev-parse "$SNAP_TAG" >/dev/null 2>&1; then
  echo "❌ Tag $SNAP_TAG not found locally — fetching from remote..."
  git fetch --tags "$REMOTE"
  if ! git rev-parse "$SNAP_TAG" >/dev/null 2>&1; then
    echo "🚨 Snapshot tag $SNAP_TAG not found on remote either. Aborting!"
    exit 1
  fi
fi

# 3️⃣ Checkout snapshot and rebuild gh-pages
echo "♻️ Restoring snapshot from tag..."
git fetch "$REMOTE" "$TARGET_BRANCH"
git checkout "$TARGET_BRANCH"
git reset --hard "$SNAP_TAG"
git push "$REMOTE" "$TARGET_BRANCH" --force

echo "✅ gh-pages branch restored to $SNAP_TAG."
echo

# 4️⃣ Trigger rebuild via API
echo "🔄 Triggering GitHub Pages rebuild..."
gh api --method POST repos/NeaBouli/1kUSD/pages/builds
echo "✅ GitHub Pages rebuild triggered."

echo "--------------------------------------"
echo "📄 Log saved to $LOG"
