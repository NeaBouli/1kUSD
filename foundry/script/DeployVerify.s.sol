// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {OracleAggregator} from "../../contracts/core/OracleAggregator.sol";
import {CollateralVault} from "../../contracts/core/CollateralVault.sol";
import {OneKUSD} from "../../contracts/core/OneKUSD.sol";
import {PSMLimits} from "../../contracts/psm/PSMLimits.sol";
import {PegStabilityModule} from "../../contracts/core/PegStabilityModule.sol";

/// @title DeployVerify
/// @notice Standalone Phase 7 verification script. Reads deployed addresses from
///         environment variables and runs all 10 DEPLOYMENT_CHECKLIST_v051 state checks.
/// @dev Usage:
///   SAFETY=0x... ORACLE=0x... VAULT=0x... TOKEN=0x... PSM=0x... LIMITS=0x... COLLATERAL=0x... \
///     forge script foundry/script/DeployVerify.s.sol --rpc-url $SEPOLIA_RPC_URL
contract DeployVerify is Script {
    function run() external view {
        address safetyAddr = vm.envAddress("SAFETY");
        address oracleAddr = vm.envAddress("ORACLE");
        address vaultAddr = vm.envAddress("VAULT");
        address tokenAddr = vm.envAddress("TOKEN");
        address psmAddr = vm.envAddress("PSM");
        address limitsAddr = vm.envAddress("LIMITS");
        address collateralAddr = vm.envAddress("COLLATERAL");

        SafetyAutomata safety = SafetyAutomata(safetyAddr);
        OracleAggregator oracle = OracleAggregator(oracleAddr);
        CollateralVault vault = CollateralVault(vaultAddr);
        OneKUSD oneKUSD = OneKUSD(tokenAddr);
        PegStabilityModule psm = PegStabilityModule(psmAddr);
        PSMLimits limits = PSMLimits(limitsAddr);

        console.log("=== Phase 7 Verification ===");
        console.log("SafetyAutomata:     ", safetyAddr);
        console.log("OracleAggregator:   ", oracleAddr);
        console.log("CollateralVault:    ", vaultAddr);
        console.log("OneKUSD:            ", tokenAddr);
        console.log("PegStabilityModule: ", psmAddr);
        console.log("PSMLimits:          ", limitsAddr);
        console.log("Collateral Token:   ", collateralAddr);

        // 1. Oracle wired
        require(address(psm.oracle()) != address(0), "FAIL: oracle not wired");
        console.log("[PASS] 1. Oracle wired");

        // 2. Oracle operational
        require(oracle.isOperational(), "FAIL: oracle not operational");
        console.log("[PASS] 2. Oracle operational");

        // 3. PSM is minter
        require(oneKUSD.isMinter(psmAddr), "FAIL: PSM not minter");
        console.log("[PASS] 3. PSM is minter");

        // 4. PSM is burner
        require(oneKUSD.isBurner(psmAddr), "FAIL: PSM not burner");
        console.log("[PASS] 4. PSM is burner");

        // 5. Collateral supported
        require(vault.isAssetSupported(collateralAddr), "FAIL: collateral not supported");
        console.log("[PASS] 5. Collateral supported");

        // 6. PSM authorized on vault
        require(vault.authorizedCallers(psmAddr), "FAIL: PSM not authorized on vault");
        console.log("[PASS] 6. PSM authorized on vault");

        // 7. PSM authorized on limits
        require(limits.authorizedCallers(psmAddr), "FAIL: PSM not authorized on limits");
        console.log("[PASS] 7. PSM authorized on limits");

        // 8. PSM not paused
        require(!safety.isPaused(keccak256("PSM")), "FAIL: PSM is paused");
        console.log("[PASS] 8. PSM not paused");

        // 9. VAULT not paused
        require(!safety.isPaused(keccak256("VAULT")), "FAIL: VAULT is paused");
        console.log("[PASS] 9. VAULT not paused");

        // 10. ORACLE not paused
        require(!safety.isPaused(keccak256("ORACLE")), "FAIL: ORACLE is paused");
        console.log("[PASS] 10. ORACLE not paused");

        console.log("============================");
        console.log("All 10 checks PASSED");

        // Bonus: log guardian sunset
        console.log("Guardian sunset:    ", safety.guardianSunset());
    }
}
