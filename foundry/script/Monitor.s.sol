// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import {SafetyAutomata} from "../../contracts/core/SafetyAutomata.sol";
import {OracleAggregator} from "../../contracts/core/OracleAggregator.sol";
import {CollateralVault} from "../../contracts/core/CollateralVault.sol";
import {OneKUSD} from "../../contracts/core/OneKUSD.sol";
import {PSMLimits} from "../../contracts/psm/PSMLimits.sol";
import {PegStabilityModule} from "../../contracts/core/PegStabilityModule.sol";
import {IOracleAggregator} from "../../contracts/interfaces/IOracleAggregator.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Monitor
/// @notice Read-only health monitoring script covering all 5 critical monitoring points
///         from TELEMETRY_MODEL.md. Outputs structured health report via console.log.
///         Reverts if any CRITICAL condition is detected (suitable for cron alerting).
/// @dev Usage (read-only, no broadcast needed):
///   SAFETY=0x... ORACLE=0x... VAULT=0x... TOKEN=0x... PSM=0x... LIMITS=0x... COLLATERAL=0x... \
///     forge script foundry/script/Monitor.s.sol --rpc-url $SEPOLIA_RPC_URL
contract Monitor is Script {
    uint256 constant VOLUME_WARN_PCT = 80;
    uint256 constant STALE_WARN_SEC = 3600;

    uint256 private _crits;
    uint256 private _warns;

    function run() external {
        address safetyAddr = vm.envAddress("SAFETY");
        address oracleAddr = vm.envAddress("ORACLE");
        address vaultAddr = vm.envAddress("VAULT");
        address tokenAddr = vm.envAddress("TOKEN");
        address psmAddr = vm.envAddress("PSM");
        address limitsAddr = vm.envAddress("LIMITS");
        address collateralAddr = vm.envAddress("COLLATERAL");

        console.log("=== 1kUSD Protocol Health Monitor ===");
        console.log("Timestamp:          ", block.timestamp);
        console.log("");

        _checkPause(SafetyAutomata(safetyAddr));
        _checkLimits(PSMLimits(limitsAddr));
        _checkOracle(OracleAggregator(oracleAddr), collateralAddr);
        _checkTreasury(OneKUSD(tokenAddr), CollateralVault(vaultAddr), collateralAddr);
        _checkRoles(OneKUSD(tokenAddr), CollateralVault(vaultAddr), PSMLimits(limitsAddr), PegStabilityModule(psmAddr), psmAddr);
        _checkBuyback(tokenAddr);

        console.log("=====================================");
        if (_crits > 0) {
            console.log("OVERALL: CRITICAL");
            console.log("Critical issues:    ", _crits);
        } else if (_warns > 0) {
            console.log("OVERALL: DEGRADED");
            console.log("Warnings:           ", _warns);
        } else {
            console.log("OVERALL: OK");
        }
        console.log("=====================================");

        require(_crits == 0, "MONITOR: CRITICAL issues detected");
    }

    // -----------------------------------------------------------------
    // 1. Emergency Pause Detection
    // -----------------------------------------------------------------
    function _checkPause(SafetyAutomata safety) internal {
        console.log("--- 1. Emergency Pause Detection ---");

        bool psmP = safety.isPaused(keccak256("PSM"));
        bool vaultP = safety.isPaused(keccak256("VAULT"));
        bool oracleP = safety.isPaused(keccak256("ORACLE"));

        if (psmP) { console.log("  [CRITICAL] PSM is PAUSED"); _crits++; }
        else { console.log("  [OK] PSM not paused"); }

        if (vaultP) { console.log("  [CRITICAL] VAULT is PAUSED"); _crits++; }
        else { console.log("  [OK] VAULT not paused"); }

        if (oracleP) { console.log("  [CRITICAL] ORACLE is PAUSED"); _crits++; }
        else { console.log("  [OK] ORACLE not paused"); }

        console.log("");
    }

    // -----------------------------------------------------------------
    // 2. PSM Limits & Volume
    // -----------------------------------------------------------------
    function _checkLimits(PSMLimits limits) internal {
        console.log("--- 2. PSM Limits & Volume ---");

        uint256 volume = limits.dailyVolume();
        uint256 cap = limits.dailyCap();

        console.log("Daily volume:       ", volume);
        console.log("Daily cap:          ", cap);
        console.log("Single-tx cap:      ", limits.singleTxCap());
        console.log("Last active day:    ", limits.lastUpdatedDay());
        console.log("Current day:        ", block.timestamp / 1 days);

        if (cap > 0) {
            uint256 utilPct = (volume * 100) / cap;
            console.log("Utilization:         %", utilPct);
            if (utilPct >= VOLUME_WARN_PCT) {
                console.log("  [DEGRADED] Volume > 80% of daily cap");
                _warns++;
            }
        }

        console.log("");
    }

    // -----------------------------------------------------------------
    // 3. Oracle Health
    // -----------------------------------------------------------------
    function _checkOracle(OracleAggregator oracle, address collateral) internal {
        console.log("--- 3. Oracle Health ---");

        bool operational = oracle.isOperational();
        if (!operational) { console.log("  [CRITICAL] Oracle NOT operational"); _crits++; }
        else { console.log("  [OK] Oracle operational"); }

        IOracleAggregator.Price memory p = oracle.getPrice(collateral);
        console.log("Price (raw):        ", uint256(p.price));
        console.log("Decimals:           ", uint256(p.decimals));
        console.log("Healthy:            ", p.healthy ? "true" : "false");
        console.log("Updated at:         ", p.updatedAt);

        if (!p.healthy) {
            console.log("  [CRITICAL] Price marked unhealthy");
            _crits++;
        }

        if (p.updatedAt > 0 && block.timestamp > p.updatedAt + STALE_WARN_SEC) {
            console.log("  [DEGRADED] Price stale for (sec):", block.timestamp - p.updatedAt);
            _warns++;
        }

        console.log("");
    }

    // -----------------------------------------------------------------
    // 4. Treasury & Supply
    // -----------------------------------------------------------------
    function _checkTreasury(OneKUSD token, CollateralVault vault, address collateral) internal {
        console.log("--- 4. Treasury & Supply ---");

        uint256 supply = token.totalSupply();
        uint256 vaultBal = vault.balanceOf(collateral);

        console.log("1kUSD total supply: ", supply);
        console.log("Vault collateral:   ", vaultBal);

        if (supply > 0) {
            uint256 ratioBps = (vaultBal * 10_000) / supply;
            console.log("Collateral ratio:    bps", ratioBps);
            if (ratioBps < 10_000) {
                console.log("  [DEGRADED] Collateral ratio < 100%");
                _warns++;
            }
        } else {
            console.log("Collateral ratio:   N/A (zero supply)");
        }

        console.log("");
    }

    // -----------------------------------------------------------------
    // 5. Role State
    // -----------------------------------------------------------------
    function _checkRoles(
        OneKUSD token,
        CollateralVault vault,
        PSMLimits limits,
        PegStabilityModule psm,
        address psmAddr
    ) internal {
        console.log("--- 5. Role State ---");
        console.log("Token admin:        ", token.admin());

        bool m = token.isMinter(psmAddr);
        bool b = token.isBurner(psmAddr);
        bool v = vault.authorizedCallers(psmAddr);
        bool l = limits.authorizedCallers(psmAddr);
        bool o = address(psm.oracle()) != address(0);

        if (!m) { console.log("  [CRITICAL] PSM not minter"); _crits++; }
        else { console.log("  [OK] PSM is minter"); }

        if (!b) { console.log("  [CRITICAL] PSM not burner"); _crits++; }
        else { console.log("  [OK] PSM is burner"); }

        if (!v) { console.log("  [CRITICAL] PSM not vault auth"); _crits++; }
        else { console.log("  [OK] PSM vault authorized"); }

        if (!l) { console.log("  [CRITICAL] PSM not limits auth"); _crits++; }
        else { console.log("  [OK] PSM limits authorized"); }

        if (!o) { console.log("  [CRITICAL] Oracle not wired to PSM"); _crits++; }
        else { console.log("  [OK] Oracle wired to PSM"); }

        console.log("");
    }

    // -----------------------------------------------------------------
    // 6. BuybackVault (optional)
    // -----------------------------------------------------------------
    function _checkBuyback(address tokenAddr) internal {
        address buybackAddr = vm.envOr("BUYBACK_VAULT", address(0));
        if (buybackAddr == address(0)) return;

        console.log("--- 6. BuybackVault ---");

        (bool ok1, bytes memory d1) = buybackAddr.staticcall(
            abi.encodeWithSignature("buybackWindowAccumulatedBps()")
        );
        (bool ok2, bytes memory d2) = buybackAddr.staticcall(
            abi.encodeWithSignature("maxBuybackSharePerWindowBps()")
        );

        if (ok1 && ok2) {
            uint256 accumulated = abi.decode(d1, (uint256));
            uint256 windowCap = abi.decode(d2, (uint256));
            uint256 stableBal = IERC20(tokenAddr).balanceOf(buybackAddr);

            console.log("Window accumulated:  bps", accumulated);
            console.log("Window cap:          bps", windowCap);
            console.log("Stable balance:     ", stableBal);

            if (windowCap > 0 && accumulated * 100 >= windowCap * VOLUME_WARN_PCT) {
                console.log("  [DEGRADED] Buyback window > 80% utilized");
                _warns++;
            }
        } else {
            console.log("  [WARN] Could not read BuybackVault state");
            _warns++;
        }

        console.log("");
    }
}
