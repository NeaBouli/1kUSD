#!/usr/bin/env bash
set -euo pipefail

LOG="docs/logs/auto_deploy_verify.log"
mkdir -p docs/logs
exec > >(tee -a "$LOG") 2>&1

echo "🚀 1kUSD — Automated GitHub Pages Deploy + Verify"
echo "Timestamp: $(date)"
echo "---------------------------------------------"

# 1️⃣ Lock & Cache Cleanup
echo "🧹 Cleaning stale mkdocs/git locks..."
rm -rf /private/tmp/gh ~/.cache/mkdocs ~/.mkdocs || true
pkill -f "mkdocs gh-deploy" || true
echo "✅ Cleanup complete."
echo

# 2️⃣ Local Build + Deploy
echo "🏗️ Building and deploying documentation..."
mkdocs gh-deploy --force
echo "✅ MkDocs deployment completed."
echo

# 3️⃣ Cache Invalidation (dummy file)
echo "🌀 Forcing GitHub Pages cache invalidation..."
git fetch origin gh-pages
git checkout gh-pages
git pull origin gh-pages
echo "invalidate-$(date +%s)" > .invalidate
git add .invalidate
git commit -m "chore: invalidate cache for fresh GitHub Pages rebuild" || true
git push origin gh-pages
echo "✅ Invalidation file pushed."
echo

# 4️⃣ Trigger manual rebuild via GitHub API
echo "🔄 Triggering rebuild via GitHub API..."
gh api --method POST repos/NeaBouli/1kUSD/pages/builds
echo "✅ API rebuild request sent."
echo

# 5️⃣ Wait for propagation
echo "⏳ Waiting 60s for CDN propagation..."
sleep 60

# 6️⃣ Verify pages
echo "🔍 Verifying live page status..."
urls=(
  "https://neabouli.github.io/1kUSD/"
  "https://neabouli.github.io/1kUSD/GOVERNANCE/"
  "https://neabouli.github.io/1kUSD/DEV9_ASSIGNMENT/"
)
for url in "${urls[@]}"; do
  echo "🌍 Checking $url"
  curl -I -L --max-time 20 "$url" | head -n 6
  echo
done

echo "✅ Verification complete."
echo "📄 Log saved to $LOG"
echo "---------------------------------------------"
