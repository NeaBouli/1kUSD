# Docs Watchdog — Usage Guide

Run locally:
\`\`\`bash
bash docs/scripts/scan_docs.sh
\`\`\`

Exit code ≠ 0 if required docs are missing (mkdocs.yml, index.md).  
Warnings do not fail the run. Designed for manual pre-commit checks.
