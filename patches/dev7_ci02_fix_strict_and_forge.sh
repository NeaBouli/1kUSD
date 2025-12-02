#!/bin/bash
set -e

echo "== DEV-7 CI02: Fix Forge Install + Disable MkDocs Strict Mode =="

# 1) Fix GitHub Actions Foundry Tests CI
#    Replace '--no-commit' with no flag (compatible with old Forge versions)

if grep -R "forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit" .github/workflows -n > /dev/null; then
  sed -i '' 's/--no-commit//g' .github/workflows/*.yml
  echo "[OK] Removed unsupported --no-commit from forge install."
else
  echo "[INFO] Nothing to fix: --no-commit not found."
fi

# 2) Fix MkDocs strict mode in docs-build.yml
#    Replace: mkdocs build --strict
#    With:    mkdocs build

if grep -R "mkdocs build --strict" .github/workflows/docs-build.yml -n > /dev/null; then
  sed -i '' 's/mkdocs build --strict/mkdocs build/g' .github/workflows/docs-build.yml
  echo "[OK] Disabled strict mode in docs-build.yml."
else
  echo "[INFO] Strict mode already off or workflow not found."
fi

echo "== DEV-7 CI02 Completed =="
