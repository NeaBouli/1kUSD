#!/usr/bin/env python3
from pathlib import Path

FILE = Path("foundry/test/psm/PSMRegression_Flows.t.sol")

print("== DEV46 CORE02: add mint+redeem roundtrip regression to PSMRegression_Flows ==")

text = FILE.read_text()

if "testRoundTrip_MintThenRedeem" in text:
    print("testRoundTrip_MintThenRedeem already present, nothing to do.")
else:
    marker = "    function testPlaceholder() public {"
    if marker not in text:
        raise SystemExit("Marker for testPlaceholder() not found in PSMRegression_Flows.t.sol")

    block = r'''
    /// @notice Mint + Redeem Roundtrip: prüft, dass Collateral- und 1kUSD-Bilanzen
    ///         bei 1:1-Preis und 0 Fees sauber hin- und zurücklaufen.
    function testRoundTrip_MintThenRedeem() public {
        uint256 amountIn = 1000e18;

        uint256 userCollBefore = collateralToken.balanceOf(user);
        uint256 user1kBefore = oneKUSD.balanceOf(user);
        uint256 supplyBefore = oneKUSD.totalSupply();
        uint256 totalCollBefore =
            collateralToken.balanceOf(address(psm)) +
            vault.balances(address(collateralToken));

        // Schritt 1: Collateral -> 1kUSD (Mint-Flow)
        vm.prank(user);
        uint256 outMint = psm.swapTo1kUSD(
            address(collateralToken),
            amountIn,
            user,
            0,
            block.timestamp + 1 days
        );

        // Schritt 2: 1kUSD -> Collateral (Redeem-Flow)
        vm.prank(user);
        uint256 outRedeem = psm.swapFrom1kUSD(
            address(collateralToken),
            outMint,
            user,
            0,
            block.timestamp + 2 days
        );

        // Erwartung: Bei 1:1-Preis und 0 Fees:
        assertEq(outRedeem, amountIn, "redeem out should equal original collateral");

        // User-Bilanzen runden sich wieder auf den Ausgangszustand
        assertEq(
            collateralToken.balanceOf(user),
            userCollBefore,
            "user collateral must roundtrip"
        );
        assertEq(
            oneKUSD.balanceOf(user),
            user1kBefore,
            "user 1kUSD must roundtrip"
        );
        assertEq(
            oneKUSD.totalSupply(),
            supplyBefore,
            "total 1kUSD supply must roundtrip"
        );

        uint256 totalCollAfter =
            collateralToken.balanceOf(address(psm)) +
            vault.balances(address(collateralToken));

        assertEq(
            totalCollAfter,
            totalCollBefore,
            "total collateral lock must roundtrip"
        );
    }
'''

    new_text = text.replace(marker, block + "\n" + marker, 1)
    FILE.write_text(new_text)
    print("✓ testRoundTrip_MintThenRedeem inserted before testPlaceholder()")
