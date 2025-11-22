#!/usr/bin/env bash
set -euo pipefail

PLAYBOOK="docs/governance/parameter_playbook.md"
README="README.md"

echo "== DEV58 DOC02: link proposal template from governance docs and README =="

# 1) Hinweis im Governance Parameter Playbook anhängen
cat <<'EOL' >> "$PLAYBOOK"

---

## Proposal-Template

Für formale Änderungsanträge zu PSM- und Oracle-Parametern kann folgendes JSON-Template verwendet werden:

- \`docs/governance/proposals/psm_parameter_change_template.json\`

Dieses Template beschreibt:
- Meta-Daten (ID, Netzwerk, Autor),
- Motivation und Risikoanalyse,
- konkrete Parameter-Änderungen (Fees, Spreads, Limits, Oracle-Health),
- sowie Governance- und Ausführungspfad.
EOL

# 2) Kurze Referenz im README ergänzen
cat <<'EOL' >> "$README"

### Governance-Proposal-Template

Für PSM-/Oracle-Parameter-Änderungen existiert ein JSON-Template unter:

- \`docs/governance/proposals/psm_parameter_change_template.json\`

Es kann als Basis für On-Chain-Governance-Vorschläge und Off-Chain-Reviews dienen.
EOL

echo "✓ Governance proposal template linked from parameter_playbook and README"
