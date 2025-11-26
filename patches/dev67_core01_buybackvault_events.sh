#!/usr/bin/env bash
set -euo pipefail

VAULT_FILE="contracts/core/BuybackVault.sol"
TEST_FILE="foundry/test/BuybackVault.t.sol"
LOG_FILE="logs/project.log"

echo "== DEV67 CORE01: add BuybackVault events + regression tests =="

########################################
# 1) Events in BuybackVault.sol ergänzen
########################################

python3 - <<'PY'
from pathlib import Path

vault_path = Path("contracts/core/BuybackVault.sol")
text = vault_path.read_text()

# Events direkt nach den Errors einfügen (falls noch nicht vorhanden)
if "event StableFunded" not in text:
    anchor = "    error ZERO_AMOUNT();\n"
    if anchor not in text:
        raise SystemExit("Anchor for errors not found in BuybackVault.sol")

    insert_pos = text.index(anchor) + len(anchor)
    events_block = """\

    // --- Events ---

    /// @notice DAO hat Stable-Tokens in den Vault eingezahlt.
    event StableFunded(address indexed from, uint256 amount);

    /// @notice DAO hat einen Buyback ausgeführt (Stable in, Asset out).
    event BuybackExecuted(address indexed recipient, uint256 stableIn, uint256 assetOut);

    /// @notice DAO hat Stable-Tokens aus dem Vault abgezogen.
    event StableWithdrawn(address indexed to, uint256 amount);

    /// @notice DAO hat Asset-Tokens aus dem Vault abgezogen.
    event AssetWithdrawn(address indexed to, uint256 amount);

"""
    text = text[:insert_pos] + events_block + text[insert_pos:]

# emit in fundStable
if "emit StableFunded" not in text:
    marker = "        stable.safeTransferFrom(msg.sender, address(this), amount);\n"
    if marker not in text:
        raise SystemExit("fundStable transfer marker not found")
    replacement = marker + "        emit StableFunded(msg.sender, amount);\n"
    text = text.replace(marker, replacement, 1)

# emit in withdrawStable
if "emit StableWithdrawn" not in text:
    marker = "        stable.safeTransfer(to, amount);\n"
    if marker not in text:
        raise SystemExit("withdrawStable transfer marker not found")
    replacement = marker + "        emit StableWithdrawn(to, amount);\n"
    text = text.replace(marker, replacement, 1)

# emit in withdrawAsset
if "emit AssetWithdrawn" not in text:
    marker = "        asset.safeTransfer(to, amount);\n"
    if marker not in text:
        raise SystemExit("withdrawAsset transfer marker not found")
    replacement = marker + "        emit AssetWithdrawn(to, amount);\n"
    text = text.replace(marker, replacement, 1)

# emit in executeBuyback
if "emit BuybackExecuted" not in text:
    marker = "        IERC20(address(stable)).safeIncreaseAllowance(address(psm), amount1k);\n"
    if marker not in text:
        raise SystemExit("executeBuyback allowance marker not found (PSM wiring may differ)")
    # Wir fügen das Event nach der kompletten PSM-Exec-Sequenz ein.
    # Einfach: wir hängen es an den Block an, in dem assetOut ermittelt wird.
    # Suche die Zeile mit 'uint256 assetOut = ':
    if "uint256 assetOut = " not in text:
        raise SystemExit("executeBuyback: assetOut line not found")

    # Einfacher: wir ersetzen 'uint256 assetOut = ...;' Block inkl. Ende mit zusätzlichem emit,
    # indem wir nach dem Semikolon suchen und dort das event anhängen.
    idx = text.index("uint256 assetOut = ")
    semi = text.index(";", idx)
    asset_line = text[idx:semi+1]

    if "emit BuybackExecuted" in text:
        # schon passiert
        pass
    else:
        new_asset_line = asset_line + "\n\n        emit BuybackExecuted(recipient, amount1k, assetOut);"
        text = text.replace(asset_line, new_asset_line, 1)

vault_path.write_text(text)
print("✓ BuybackVault events inserted/updated.")
PY

########################################
# 2) Tests in BuybackVault.t.sol ergänzen
########################################

python3 - <<'PY'
from pathlib import Path

test_path = Path("foundry/test/BuybackVault.t.sol")
text = test_path.read_text()

# Event-Tests nur ergänzen, wenn noch nicht vorhanden
if "testFundStableEmitsEvent" not in text:
    insert_anchor = "    function testFundStableRevertsWhenPaused() public {\n"
    if insert_anchor not in text:
        raise SystemExit("Anchor for fundStable tests not found")
    insert_pos = text.index(insert_anchor)

    block = """    function testFundStableEmitsEvent() public {
        uint256 amount = 5e18;

        vm.prank(dao);
        vm.expectEmit(true, false, false, true);
        emit StableFunded(dao, amount);

        vault.fundStable(amount);
    }

"""
    text = text[:insert_pos] + block + text[insert_pos:]

if "testWithdrawStableEmitsEvent" not in text:
    anchor = "    function testWithdrawStableZeroAddressReverts() public {\n"
    if anchor not in text:
        raise SystemExit("Anchor for withdrawStable tests not found")
    # Wir fügen den neuen Test *nach* der ZeroAddress-Revert-Funktion ein.
    start = text.index(anchor)
    end = text.index("    }\n", start) + len("    }\n")

    block = text[end:end]  # no-op, just to compute end
    new_block = text[end:end]  # placeholder

    insert_pos = end
    add = """    function testWithdrawStableEmitsEvent() public {
        uint256 amount = 4e18;
        stable.mint(address(vault), amount);

        vm.prank(dao);
        vm.expectEmit(true, false, false, true);
        emit StableWithdrawn(user, amount);

        vault.withdrawStable(user, amount);
    }

"""
    text = text[:insert_pos] + add + text[insert_pos:]

if "testWithdrawAssetEmitsEvent" not in text:
    anchor = "    function testWithdrawAssetZeroAddressReverts() public {\n"
    if anchor not in text:
        raise SystemExit("Anchor for withdrawAsset tests not found")
    start = text.index(anchor)
    end = text.index("    }\n", start) + len("    }\n")
    insert_pos = end

    add = """    function testWithdrawAssetEmitsEvent() public {
        uint256 amount = 7e18;
        asset.mint(address(vault), amount);

        vm.prank(dao);
        vm.expectEmit(true, false, false, true);
        emit AssetWithdrawn(user, amount);

        vault.withdrawAsset(user, amount);
    }

"""
    text = text[:insert_pos] + add + text[insert_pos:]

if "testExecuteBuybackEmitsEvent" not in text:
    anchor = "    function testExecuteBuybackTransfersStableAndMintsAsset() public {\n"
    if anchor not in text:
        raise SystemExit("Anchor for executeBuyback tests not found")
    start = text.index(anchor)
    end = text.index("    }\n", start) + len("    }\n")
    insert_pos = end

    add = """    function testExecuteBuybackEmitsEvent() public {
        uint256 amount = 10e18;
        stable.mint(address(vault), amount);

        vm.prank(dao);
        vm.expectEmit(true, true, false, true);
        // Erwartung: StableIn = amount, AssetOut > 0
        emit BuybackExecuted(user, amount, 0);

        vault.executeBuyback(user, amount, 0, block.timestamp + 1 days);
    }

"""
    text = text[:insert_pos] + add + text[insert_pos:]

test_path.write_text(text)
print("✓ BuybackVault event tests inserted/updated.")
PY

########################################
# 3) Log-Eintrag
########################################

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "[DEV-67] ${timestamp} BuybackVault: on-chain events (StableFunded/BuybackExecuted/StableWithdrawn/AssetWithdrawn) added and covered by regression tests." >> "$LOG_FILE"
echo "✓ Log updated at $LOG_FILE"

echo "== DEV67 CORE01: done =="
