#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_DIR="docs/governance/proposals"
TEMPLATE_FILE="$TEMPLATE_DIR/psm_parameter_change_template.json"
LOG="logs/project.log"

echo "== DEV58 DOC01: add Governance proposal template for PSM parameter changes =="

mkdir -p "$TEMPLATE_DIR"
mkdir -p "$(dirname "$LOG")"

cat <<'EOL' > "$TEMPLATE_FILE"
{
  "$schema": "https://example.com/schemas/governance/psm_parameter_change.schema.json",

  "meta": {
    "proposalId": "TR-PSM-YYYYMMDD-XXX",
    "version": "1.0.0",
    "network": "testnet",
    "createdAt": "2025-01-01T00:00:00Z",
    "author": "wallet:0xYourAddress",
    "contact": "tg:@handle_or_email",
    "language": "de"
  },

  "title": "Anpassung der PSM-Parameter für Collateral X",
  "summary": "Kurzbeschreibung der Änderung (z. B. Erhöhung von mintFeeBps und dailyCap für Collateral X).",

  "rationale": {
    "problem": "Welches Risiko / Problem soll adressiert werden?",
    "analysis": "Kurze Risikoanalyse (Volatilität, Liquidität, Konzentration, Gegenparteirisiko).",
    "alternatives": "Welche Alternativen wurden geprüft?",
    "justification": "Warum ist diese Parametrisierung aktuell die beste Wahl?"
  },

  "riskAssessment": {
    "userImpact": "Niedrig / Mittel / Hoch – Auswirkung auf Endnutzer.",
    "liquidityImpact": "Niedrig / Mittel / Hoch – Auswirkung auf PSM-Liquidität.",
    "oracleDependence": "Beschreibung, wie stark die Änderung von Oracles abhängt.",
    "failureModesMitigated": [
      "Beispiel: Begrenzung des Risikos bei stark fallenden Collateral-Preisen.",
      "Beispiel: Schutz vor übermäßigem Mint-Volumen in illiquiden Märkten."
    ]
  },

  "parameters": [
    {
      "module": "PSM",
      "scope": "global",
      "key": "psm:mintFeeBps",
      "type": "uint256",
      "oldValue": 0,
      "newValue": 50,
      "unit": "bps",
      "direction": "increase",
      "reason": "Einführung einer globalen Mint-Fee von 0.5 % zur Deckung von Betriebskosten."
    },
    {
      "module": "PSM",
      "scope": "global",
      "key": "psm:redeemFeeBps",
      "type": "uint256",
      "oldValue": 0,
      "newValue": 100,
      "unit": "bps",
      "direction": "increase",
      "reason": "Einführung einer globalen Redeem-Fee von 1 % zur Dämpfung von Bankrun-Dynamiken."
    },
    {
      "module": "PSM",
      "scope": "per-token",
      "asset": "0xCollateralTokenAddress",
      "key": "psm:mintSpreadBps",
      "type": "uint256",
      "oldValue": 0,
      "newValue": 75,
      "unit": "bps",
      "direction": "increase",
      "reason": "Token-spezifische Spread-Erhöhung für risikoreicheres Collateral."
    },
    {
      "module": "PSM",
      "scope": "limits",
      "contract": "PSMLimits",
      "key": "dailyCap",
      "type": "uint256",
      "oldValue": "1_000_000e18",
      "newValue": "500_000e18",
      "unit": "1kUSD",
      "direction": "decrease",
      "reason": "Reduktion des täglichen Volumens zur Begrenzung des systemischen Risikos."
    },
    {
      "module": "ORACLE",
      "scope": "global",
      "key": "oracle:maxDiffBps",
      "type": "uint256",
      "oldValue": 500,
      "newValue": 300,
      "unit": "bps",
      "direction": "decrease",
      "reason": "Strengere Grenze für Preis-Sprünge, um manipulative Spikes zu dämpfen."
    },
    {
      "module": "ORACLE",
      "scope": "global",
      "key": "oracle:maxStale",
      "type": "uint256",
      "oldValue": 1800,
      "newValue": 900,
      "unit": "seconds",
      "direction": "decrease",
      "reason": "Kürzere Max-Stale-Dauer für höhere Preis-Frische."
    }
  ],

  "governanceFlow": {
    "submission": "Wer reicht den Vorschlag wo ein?",
    "discussionChannels": [
      "Forum: https://gov.example.org/t/...",
      "Discord: #governance-psm",
      "TG: @tr-1kusd-governance"
    ],
    "votingMechanism": "z. B. Token-gewichtete Abstimmung, Quadratic Voting, Delegation.",
    "quorum": "z. B. 10 % der zirkulierenden Governance-Power.",
    "threshold": "z. B. einfache Mehrheit, 60 % Supermajority.",
    "timelock": "z. B. 48h Verzögerung vor Ausführung.",
    "executionPath": "z. B. DAO-Timelock → ParameterRegistry / PSMLimits / andere Module."
  },

  "implementationNotes": {
    "onchainSteps": [
      "1. DAO-Timelock-Transaktion vorbereiten, die setUint(...) auf ParameterRegistry aufruft.",
      "2. Falls Limits betroffen sind: call auf PSMLimits-Admin-Funktionen.",
      "3. Verifikation, dass neue Parameter mit Guardian / Safety-Modulen konsistent sind."
    ],
    "monitoring": [
      "Überwachung von PSM-Volumen vor/nach Änderung.",
      "Überwachung von Oracle-Health-Status (stale/diff)."
    ],
    "rollbackPlan": "Wie wird im Fehlerfall zurückgerollt? (Gegenproposal, Notfall-Timelock, Pause des PSM)."
  }
}
EOL

cat <<EOL >> "$LOG"
[DEV-58] $(date -u +"%Y-%m-%dT%H:%M:%SZ") Governance: added JSON template for PSM/Oracle parameter change proposals under docs/governance/proposals/psm_parameter_change_template.json.
EOL

echo "✓ Governance proposal template written to $TEMPLATE_FILE and log updated."
