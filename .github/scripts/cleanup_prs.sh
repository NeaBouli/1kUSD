#!/bin/bash
# ------------------------------------------------------------------
# GitHub PR Cleanup Utility
# Marks stale feature branches & old PRs as archived (local only)
# ------------------------------------------------------------------

set -euo pipefail
echo "🔧 Cleaning up local and remote stale branches..."

# 1️⃣ Remove merged local feature branches
for b in $(git branch --merged main | grep dev | grep -v main); do
  echo "🗑️ Removing merged branch: $b"
  git branch -d "$b" || true
done

# 2️⃣ Suggest remote cleanup
echo ""
echo "ℹ️  To remove remote stale branches manually, run:"
echo "    git fetch -p && git push origin --delete <branch>"
echo ""
echo "✅ Local cleanup complete (no impact on PR history)."
