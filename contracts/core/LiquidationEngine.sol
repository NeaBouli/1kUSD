// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {OracleAggregator} from "./OracleAggregator.sol";
import {CollateralVault} from "./CollateralVault.sol";
import {OneKUSD} from "./OneKUSD.sol";
import {ISafetyAutomata} from "../interfaces/ISafetyAutomata.sol";
import {IPegStabilityModule} from "../interfaces/IPegStabilityModule.sol";

interface IParameterRegistry {
    function getUint(bytes32 key) external view returns (uint256);
}

contract LiquidationEngine is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DAO_ROLE   = keccak256("DAO_ROLE");

    OracleAggregator public aggregator;
    CollateralVault public vault;
    OneKUSD public oneKUSD;
    ISafetyAutomata public safety;
    IParameterRegistry public registry;
    IPegStabilityModule public psm; // optional wiring

    // assets monitored (must be supported in vault)
    address[] public assets;

    event OracleSet(address indexed aggregator);
    event VaultSet(address indexed vault);
    event SafetySet(address indexed safety);
    event RegistrySet(address indexed registry);
    event PSMSet(address indexed psm);

    event HealthCheck(uint256 collateralValueWad, uint256 supply1k, int256 diffBps);
    event RebalanceTriggered(int256 diffBps, uint256 newMintFeeBps, uint256 newRedeemFeeBps, bool feesApplied, bool pauseAttempted);

    constructor(
        address admin,
        address agg,
        address v,
        address ok,
        address saf,
        address reg,
        address psmAddr
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);

        aggregator = OracleAggregator(agg);
        vault = CollateralVault(v);
        oneKUSD = OneKUSD(ok);
        safety = ISafetyAutomata(saf);
        registry = IParameterRegistry(reg);
        psm = IPegStabilityModule(psmAddr);

        emit OracleSet(agg);
        emit VaultSet(v);
        emit SafetySet(saf);
        emit RegistrySet(reg);
        emit PSMSet(psmAddr);
    }

    // --- admin wiring ---

    function addAsset(address asset) external {
        require(hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender), "unauthorized");
        assets.push(asset);
    }

    function setPSM(address p) external {
        require(hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender), "unauthorized");
        psm = IPegStabilityModule(p);
        emit PSMSet(p);
    }

    // --- views ---

    function assetsCount() external view returns (uint256) {
        return assets.length;
    }

    /// @return collateralValueWad total value in WAD, supply total 1kUSD supply, diffBps= ((collateralValue/supply)-1)*10000
    function checkHealth() public view returns (uint256 collateralValueWad, uint256 supply, int256 diffBps) {
        uint256 val = 0;
        for (uint256 i = 0; i < assets.length; i++) {
            address a = assets[i];
            uint256 bal = vault.balances(a); // public mapping
            if (bal == 0) continue;
            (uint256 p,) = aggregator.getPriceWad(a);
            if (p == 0) {
                // fallback: registry price if aggregator has none
                bytes memory prefix = bytes("PSM_ORACLE_PRICE_WAD_");
                bytes memory packed = abi.encodePacked(prefix, a);
                p = registry.getUint(keccak256(packed));
                if (p == 0) continue; // skip if truly unknown
            }
            // value = balance (units) * priceWad / 1e18  (we keep WAD here to compare vs supply (1e18 * supply))
            // Since OneKUSD has 18 decimals and supply is in 1e18, compare both in WAD:
            val += bal * p / 1e18;
        }

        supply = oneKUSD.totalSupply(); // 1e18-scaled
        if (supply == 0) {
            return (val, 0, int256(0));
        }

        // diffBps = ((val/supply)-1)*10000
        // compute in wad to keep precision: valWad / supplyWad
        int256 ratioWad = int256((val * 1e18) / supply);
        int256 diff = (ratioWad - int256(1e18)) * 10000 / int256(1e18);
        diffBps = diff;

        return (val, supply, diffBps);
    }

    // --- actions ---

    /// @notice If undercollateralized beyond threshold, try soft-rebalance by increasing PSM fees; else lower slightly.
    function triggerRebalance() external nonReentrant {
        (uint256 val, uint256 supply, int256 diffBps) = checkHealth();
        emit HealthCheck(val, supply, diffBps);

        uint256 th = _regOrDefault("LIQ_THRESHOLD_BPS", 200); // 2%
        uint256 step = _regOrDefault("LIQ_ADJ_STEP_BPS", 10); // 0.10%

        // read current fees (fallback to 0)
        uint256 currMint = _regOrDefault("PSM_MINT_FEE_BPS", 0);
        uint256 currRedm = _regOrDefault("PSM_REDEEM_FEE_BPS", 0);

        uint256 newMint = currMint;
        uint256 newRedm = currRedm;

        bool attemptPause = false;
        bool feesApplied = false;

        if (diffBps < 0) {
            // undercollateralized
            uint256 deficit = uint256(-diffBps);
            if (deficit > th) {
                // increase redeem fee to slow redemptions; optionally also mint fee
                newRedm = currRedm + step;
                newMint = currMint + (step / 2);
                // optional: attempt pause via safety if very large deficit
                if (deficit > th * 3) {
                    // best-effort low-level call (will succeed only if roles are granted)
                    (bool ok,) = address(safety).call(abi.encodeWithSignature("pause()"));
                    attemptPause = ok;
                }
            }
        } else if (diffBps > int256(th) && (currMint > 0 || currRedm > 0)) {
            // overcollateralized enough → lower fees slightly toward 0
            if (currRedm > 0) newRedm = currRedm > step ? currRedm - step : 0;
            if (currMint > 0) newMint = currMint > (step/2) ? currMint - (step/2) : 0;
        }

        if (newMint != currMint || newRedm != currRedm) {
            // best-effort: call PSM.setFees; if unauthorized, do not revert
            if (address(psm) != address(0)) {
                (bool ok,) = address(psm).call(abi.encodeWithSignature("setFees(uint256,uint256)", newMint, newRedm));
                feesApplied = ok;
            }
        }

        emit RebalanceTriggered(diffBps, newMint, newRedm, feesApplied, attemptPause);
    }

    // --- helpers ---

    function _regOrDefault(string memory name, uint256 dflt) internal view returns (uint256) {
        uint256 v = registry.getUint(keccak256(bytes(name)));
        return v == 0 ? dflt : v;
    }
}
