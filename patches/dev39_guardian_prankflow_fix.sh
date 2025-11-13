#!/usr/bin/env bash
set -euo pipefail

echo "== DEV-39: Guardian/Oracle Prank-Flow Fix (Option B) =="

FILE="foundry/test/Guardian_OraclePropagation.t.sol"
TMP="${FILE}.tmp"

if [[ ! -f "$FILE" ]]; then
  echo "Fehler: Datei '$FILE' nicht gefunden." >&2
  exit 1
fi

# Ersetze den Body von function setUp() durch einen einzigen, durchgehenden DAO-Prank-Block
awk '
  function print_new_setup_body() {
    print "function setUp() public {"
    print "    vm.startPrank(dao);"
    print "    safety   = new SafetyAutomata(dao, 1000000);"
    print "    guardian = new Guardian(dao, 1000000);"
    print "    guardian.setSafetyAutomata(safety);"
    print "    safety.grantGuardian(address(guardian));"
    print "    vm.stopPrank();"
    print ""
    print "    MockRegistry reg = new MockRegistry();"
    print "    oracle = new OracleAggregator("
    print "        dao,"
    print "        ISafetyAutomata(address(safety)),"
    print "        IParameterRegistry(address(reg))"
    print "    );"
    print "}"
  }

  BEGIN { in_func=0; depth=0; replaced=0 }

  # Finde Funktionskopf von setUp()
  /^function[[:space:]]+setUp[[:space:]]*\\(\\)[[:space:]]*public[[:space:]]*{/ {
    in_func=1
    depth=1
    # Überspringe Originalkörper und setze gleich unsere neue Version
    print_new_setup_body()
    replaced=1
    next
  }

  # Falls Kopfzeile ohne { am Ende (z.B. Zeilenumbruch-Stil)
  /^function[[:space:]]+setUp[[:space:]]*\\(\\)[[:space:]]*public[[:space:]]*$/ {
    in_func=1
    next
  }

  # Wenn wir im Funktionskörper sind, tracke Klammern und überspringe bis zum Ende
  in_func {
    if (index($0, "{")>0) depth++
    if (index($0, "}")>0) depth--
    if (depth<=0) {
      # Am Ende des Originalkörpers: unsere neue Version drucken, dann weiter
      if (!replaced) { print_new_setup_body(); replaced=1 }
      in_func=0
    }
    next
  }

  { print }
' "$FILE" > "$TMP"

mv "$TMP" "$FILE"

# Kurzvalidierung
grep -n "vm.startPrank(dao);" "$FILE" >/dev/null || { echo "Validierung fehlgeschlagen: neuer setUp()-Body nicht gefunden." >&2; exit 1; }

# Log-Eintrag (UTC, Single-Line)
mkdir -p logs
printf "%s DEV-39 prankflow fix: unified vm.startPrank(dao) block in setUp() [DEV-6A]\n" "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" >> logs/project.log

echo "✅ Patch angewendet. Bitte testen:"
echo "   forge clean && forge test --match-path 'foundry/test/Guardian_OraclePropagation.t.sol' -vvvv"
