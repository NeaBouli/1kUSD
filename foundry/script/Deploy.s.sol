// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {ParameterRegistry} from "../../contracts/core/ParameterRegistry.sol";
import {OracleAggregator} from "../../contracts/core/OracleAggregator.sol";
import {CollateralVault} from "../../contracts/core/CollateralVault.sol";
import {OneKUSD} from "../../contracts/core/OneKUSD.sol";
import {PSMLimits} from "../../contracts/psm/PSMLimits.sol";
import {FeeRouter} from "../../contracts/core/FeeRouter.sol";
import {PegStabilityModule} from "../../contracts/core/PegStabilityModule.sol";
import {ISafetyAutomata} from "../../contracts/interfaces/ISafetyAutomata.sol";
import {IParameterRegistry} from "../../contracts/interfaces/IParameterRegistry.sol";

import {MockERC20} from "../test/mocks/MockERC20.sol";

/// @title Deploy
/// @notice Full 1kUSD protocol deployment following DEPLOYMENT_CHECKLIST_v051.md Phases 1-5.
///         Deploys all core contracts, wires authorized callers, sets oracle/PSM config,
///         and logs all deployed addresses. Use with `forge script --broadcast` for real deploy.
/// @dev Usage:
///   Dry-run (local):  forge script foundry/script/Deploy.s.sol --rpc-url http://localhost:8545
///   Broadcast:         forge script foundry/script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast
///   With verification: forge script foundry/script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
contract Deploy is Script {
    // --- Deployment Parameters ---
    uint256 constant GUARDIAN_SUNSET_OFFSET = 365 days;
    uint256 constant DAILY_CAP = 1_000_000e18;
    uint256 constant SINGLE_TX_CAP = 100_000e18;
    uint256 constant MINT_FEE_BPS = 10;
    uint256 constant REDEEM_FEE_BPS = 10;
    uint256 constant INITIAL_USDC_MINT = 1_000_000e18;

    // --- Deployed Contracts ---
    SafetyAutomata public safety;
    ParameterRegistry public registry;
    OracleAggregator public oracle;
    CollateralVault public vault;
    OneKUSD public oneKUSD;
    PSMLimits public limits;
    FeeRouter public feeRouter;
    PegStabilityModule public psm;
    MockERC20 public testUSDC;

    function run() external {
        address deployer = msg.sender;

        vm.startBroadcast();

        // =====================================================================
        // Phase 1: Core Infrastructure Deploy (exact checklist order)
        // =====================================================================

        // Step 1: SafetyAutomata
        safety = new SafetyAutomata(deployer, block.timestamp + GUARDIAN_SUNSET_OFFSET);

        // Step 2: ParameterRegistry
        registry = new ParameterRegistry(deployer);

        // Step 3: OracleAggregator
        oracle = new OracleAggregator(deployer, ISafetyAutomata(address(safety)), IParameterRegistry(address(registry)));

        // Step 4: CollateralVault
        vault = new CollateralVault(deployer, ISafetyAutomata(address(safety)), IParameterRegistry(address(registry)));

        // Step 5: OneKUSD
        oneKUSD = new OneKUSD(deployer);

        // Step 6: PSMLimits
        limits = new PSMLimits(deployer, DAILY_CAP, SINGLE_TX_CAP);

        // Step 7: FeeRouter
        feeRouter = new FeeRouter(deployer);

        // Step 8: PegStabilityModule
        psm = new PegStabilityModule(
            deployer,
            address(oneKUSD),
            address(vault),
            address(safety),
            address(registry)
        );

        // Test collateral token (testnet only)
        testUSDC = new MockERC20("Test USDC", "tUSDC");

        // =====================================================================
        // Phase 2: Authorized Caller Whitelist
        // =====================================================================

        // 2.1 OneKUSD mint/burn roles
        oneKUSD.setMinter(address(psm), true);
        oneKUSD.setBurner(address(psm), true);

        // 2.2 CollateralVault caller + asset auth
        vault.setAuthorizedCaller(address(psm), true);
        vault.setAssetSupported(address(testUSDC), true);

        // 2.3 PSMLimits caller auth
        limits.setAuthorizedCaller(address(psm), true);

        // 2.4 FeeRouter caller auth
        feeRouter.setAuthorizedCaller(address(psm), true);

        // =====================================================================
        // Phase 3: Oracle Configuration
        // =====================================================================

        // 3.1 Wire oracle to PSM
        psm.setOracle(address(oracle));

        // 3.2 Set initial price for test USDC: $1.00, 18 decimals, healthy
        oracle.setPriceMock(address(testUSDC), int256(1e18), 18, true);

        // =====================================================================
        // Phase 4: PSM Configuration
        // =====================================================================

        // 4.1 Fees: 10 bps mint, 10 bps redeem
        psm.setFees(MINT_FEE_BPS, REDEEM_FEE_BPS);

        // 4.2 Wire limits
        psm.setLimits(address(limits));

        // 4.3 Token decimals in registry (testUSDC = 18 decimals)
        bytes32 decimalsKey = keccak256(
            abi.encode(keccak256("psm:tokenDecimals"), address(testUSDC))
        );
        registry.setUint(decimalsKey, 18);

        // =====================================================================
        // Phase 5: Safety-Automata
        // =====================================================================
        // Deployer already has ADMIN_ROLE + GUARDIAN_ROLE from constructor.
        // No additional setup needed for testnet.

        // =====================================================================
        // Testnet: Mint test USDC to deployer for integration testing
        // =====================================================================
        testUSDC.mint(deployer, INITIAL_USDC_MINT);

        vm.stopBroadcast();

        // =====================================================================
        // Phase 7: Post-Deployment Verification (read-only, no broadcast)
        // =====================================================================
        _verify();

        // =====================================================================
        // Log Deployed Addresses
        // =====================================================================
        console.log("=== 1kUSD Protocol Deployed ===");
        console.log("SafetyAutomata:       ", address(safety));
        console.log("ParameterRegistry:    ", address(registry));
        console.log("OracleAggregator:     ", address(oracle));
        console.log("CollateralVault:      ", address(vault));
        console.log("OneKUSD:              ", address(oneKUSD));
        console.log("PSMLimits:            ", address(limits));
        console.log("FeeRouter:            ", address(feeRouter));
        console.log("PegStabilityModule:   ", address(psm));
        console.log("TestUSDC:             ", address(testUSDC));
        console.log("Deployer:             ", deployer);
        console.log("Guardian Sunset:      ", safety.guardianSunset());
        console.log("===============================");
    }

    /// @notice Phase 7 state checks from DEPLOYMENT_CHECKLIST_v051.md.
    ///         All 10 checks must pass or the deployment is misconfigured.
    function _verify() internal view {
        // 1. psm.oracle() != address(0) -- oracle wired
        require(address(psm.oracle()) != address(0), "VERIFY: oracle not wired");

        // 2. oracle.isOperational() == true -- oracle not paused
        require(oracle.isOperational(), "VERIFY: oracle not operational");

        // 3. oneKUSD.isMinter(psm) == true -- PSM can mint
        require(oneKUSD.isMinter(address(psm)), "VERIFY: PSM not minter");

        // 4. oneKUSD.isBurner(psm) == true -- PSM can burn
        require(oneKUSD.isBurner(address(psm)), "VERIFY: PSM not burner");

        // 5. vault.isAssetSupported(testUSDC) == true -- collateral accepted
        require(vault.isAssetSupported(address(testUSDC)), "VERIFY: tUSDC not supported");

        // 6. vault.authorizedCallers(psm) == true -- PSM can deposit/withdraw
        require(vault.authorizedCallers(address(psm)), "VERIFY: PSM not authorized on vault");

        // 7. limits.authorizedCallers(psm) == true -- PSM can update limits
        require(limits.authorizedCallers(address(psm)), "VERIFY: PSM not authorized on limits");

        // 8. PSM not paused
        require(!safety.isPaused(keccak256("PSM")), "VERIFY: PSM is paused");

        // 9. VAULT not paused
        require(!safety.isPaused(keccak256("VAULT")), "VERIFY: VAULT is paused");

        // 10. ORACLE not paused
        require(!safety.isPaused(keccak256("ORACLE")), "VERIFY: ORACLE is paused");

        console.log("Phase 7: All 10 state checks PASSED");
    }
}
