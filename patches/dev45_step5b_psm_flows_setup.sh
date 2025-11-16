#!/usr/bin/env bash
set -euo pipefail

TEST_FILE="foundry/test/psm/PSMRegression_Flows.t.sol"

echo "== DEV-45 Step 5b: Implement full setup() wiring for PSM flow regression =="

# Replace the empty skeleton setup() with real wiring
sed -i '' '/function setUp() public {/,/}/c\
    function setUp() public {\n\
        /* --- 1) Deploy core components --- */\n\
        oneKUSD = new OneKUSD(address(this));\n\
        vault = new CollateralVault(address(this));\n\
        limits = new PSMLimits(address(this));\n\
        psm = new PegStabilityModule(\n\
            address(this),\n\
            address(oneKUSD),\n\
            address(vault),\n\
            address(limits)\n\
        );\n\
\n\
        /* --- 2) Deploy mocks for oracle, safety & router --- */\n\
        oracle = IOracleAggregator(address(new MockOracleAggregator()));\n\
        safety = ISafetyAutomata(address(new MockSafetyAutomata()));\n\
        feeRouter = IFeeRouterV2(address(new FeeRouterV2()));\n\
\n\
        /* --- 3) Wire external modules to PSM --- */\n\
        psm.setOracle(address(oracle));\n\
        psm.setSafety(address(safety));\n\
        psm.setFeeRouter(address(feeRouter));\n\
\n\
        /* --- 4) DAO sets roles for mint & burn --- */\n\
        oneKUSD.setMinter(address(psm), true);\n\
        oneKUSD.setBurner(address(psm), true);\n\
\n\
        /* --- 5) Oracle: stable 1:1 mock price, always healthy --- */\n\
        MockOracleAggregator(address(oracle)).setHealth(true);\n\
        MockOracleAggregator(address(oracle)).setPrice(1e18);\n\
\n\
        /* --- 6) SafetyAutomata: always operational for now --- */\n\
        MockSafetyAutomata(address(safety)).setPaused(false);\n\
\n\
        /* --- 7) FeeRouter: basic accounting mock --- */\n\
        // No config needed – FeeRouterV2 handles routing by module + asset\n\
\n\
        /* --- 8) Register collateral asset & decimals --- */\n\
        psm.registerCollateral(collateral, 18, true);\n\
\n\
        /* --- 9) Limits – set relaxed caps for tests --- */\n\
        limits.setDailyCap(collateral, 1_000_000 ether);\n\
        limits.setSingleTxCap(collateral, 1_000_000 ether);\n\
\n\
        /* --- 10) Base assertions (setup sanity) --- */\n\
        assertEq(oneKUSD.totalSupply(), 0, \"initial supply must be zero\");\n\
        assertTrue(MockOracleAggregator(address(oracle)).healthy(), \"oracle healthy\");\n\
        assertFalse(MockSafetyAutomata(address(safety)).paused(), \"safety operational\");\n\
    }\n\
' "$TEST_FILE"

echo "✓ DEV-45 Step 5b: PSM flow-regression setup implemented"
