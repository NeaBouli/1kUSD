// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IExternalPriceFeed} from "../interfaces/IExternalPriceFeed.sol";

interface IParameterRegistry {
    function getUint(bytes32 key) external view returns (uint256);
}

/// @title OracleAggregator
/// @notice Aggregates multiple price feeds into a single WAD (1e18) price per asset.
///         Applies staleness checks and deviation guard around $1 (1e18) for stable assets.
contract OracleAggregator is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant DAO_ROLE   = keccak256("DAO_ROLE");

    IParameterRegistry public registry;

    struct Feed {
        address source;
        bool active;
    }

    // assetKey is keccak256(abi.encodePacked(assetAddress))
    mapping(bytes32 => Feed[]) public feeds;

    // last aggregated price per asset (WAD) and timestamp
    mapping(bytes32 => uint256) public lastPriceWad;
    mapping(bytes32 => uint256) public lastUpdateTs;

    event RegistryUpdated(address indexed oldAddr, address indexed newAddr);
    event FeedAdded(bytes32 indexed assetKey, address indexed source);
    event FeedDeactivated(bytes32 indexed assetKey, uint256 indexed index, address source);
    event PriceAggregated(bytes32 indexed assetKey, uint256 priceWad, uint256 at, uint256 numFeeds);

    error NoActiveFeeds();
    error StaleFeed();
    error HighDeviation();

    constructor(address admin, address registryAddr) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        registry = IParameterRegistry(registryAddr);
    }

    function setRegistry(address newRegistry) external {
        require(hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender), "unauthorized");
        address old = address(registry);
        registry = IParameterRegistry(newRegistry);
        emit RegistryUpdated(old, newRegistry);
    }

    function _assetKey(address asset) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(asset));
    }

    function addFeed(address asset, address source) external {
        require(hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender), "unauthorized");
        bytes32 key = _assetKey(asset);
        feeds[key].push(Feed({source: source, active: true}));
        emit FeedAdded(key, source);
    }

    function deactivateFeed(address asset, uint256 index) external {
        require(hasRole(ADMIN_ROLE, msg.sender) || hasRole(DAO_ROLE, msg.sender), "unauthorized");
        bytes32 key = _assetKey(asset);
        require(index < feeds[key].length, "bad index");
        Feed storage f = feeds[key][index];
        f.active = false;
        emit FeedDeactivated(key, index, f.source);
    }

    /// @notice Returns aggregated price WAD for asset if available; 0 otherwise.
    function getPriceWad(address asset) external view returns (uint256 priceWad, uint256 updatedAt) {
        bytes32 key = _assetKey(asset);
        return (lastPriceWad[key], lastUpdateTs[key]);
    }

    /// @notice Pull all active feeds and compute median WAD price. Applies staleness and deviation guard.
    function updatePrice(address asset) external returns (uint256 priceWad) {
        bytes32 key = _assetKey(asset);
        Feed[] storage list = feeds[key];

        // Try external feeds; if none active, fall back to registry constant price
        uint256[] memory vals = new uint256[](list.length);
        uint256 n = 0;

        uint256 maxStale = _regOrDefault("ORACLE_MAX_STALENESS_SEC", 300);
        uint256 maxDevBps = _regOrDefault("ORACLE_MAX_DEVIATION_BPS", 100); // 1%

        unchecked {
            for (uint256 i = 0; i < list.length; i++) {
                if (!list[i].active) continue;
                (int256 p, uint256 ts, uint8 dec) = IExternalPriceFeed(list[i].source).latestPrice();
                if (p <= 0) continue;
                if (block.timestamp > ts && block.timestamp - ts > maxStale) revert StaleFeed();
                // normalize to WAD
                uint256 u = uint256(p);
                uint256 normalized = _toWad(u, dec);
                vals[n++] = normalized;
            }
        }

        if (n == 0) {
            // fallback: registry constant
            uint256 fallbackPrice = _regPriceWadForAsset(asset);
            require(fallbackPrice > 0, "no price");
            _checkDeviationAroundOne(fallbackPrice, maxDevBps);
            lastPriceWad[key] = fallbackPrice;
            lastUpdateTs[key] = block.timestamp;
            emit PriceAggregated(key, fallbackPrice, block.timestamp, 0);
            return fallbackPrice;
        }

        // median
        _inPlaceSort(vals, n);
        uint256 median = vals[n / 2];
        _checkDeviationAroundOne(median, maxDevBps);

        lastPriceWad[key] = median;
        lastUpdateTs[key] = block.timestamp;
        emit PriceAggregated(key, median, block.timestamp, n);
        return median;
    }

    // --- helpers ---

    function _regOrDefault(string memory name, uint256 dflt) internal view returns (uint256) {
        uint256 v = registry.getUint(keccak256(bytes(name)));
        return v == 0 ? dflt : v;
    }

    function _regPriceWadForAsset(address asset) internal view returns (uint256) {
        bytes memory prefix = bytes("PSM_ORACLE_PRICE_WAD_");
        bytes memory packed = abi.encodePacked(prefix, asset);
        return registry.getUint(keccak256(packed));
    }

    function _toWad(uint256 value, uint8 dec) internal pure returns (uint256) {
        if (dec == 18) return value;
        if (dec < 18) return value * (10 ** (18 - dec));
        // if dec > 18: downscale
        return value / (10 ** (dec - 18));
    }

    function _checkDeviationAroundOne(uint256 priceWad, uint256 maxDevBps) internal pure {
        // guard around 1e18
        uint256 upper = (1e18 * (10_000 + maxDevBps)) / 10_000;
        uint256 lower = (1e18 * (10_000 - maxDevBps)) / 10_000;
        if (priceWad > upper || priceWad < lower) revert HighDeviation();
    }

    function _inPlaceSort(uint256[] memory arr, uint256 n) internal pure {
        // simple insertion sort for small N (feeds count)
        for (uint256 i = 1; i < n; i++) {
            uint256 key = arr[i];
            uint256 j = i;
            while (j > 0 && arr[j - 1] > key) {
                arr[j] = arr[j - 1];
                j--;
            }
            arr[j] = key;
        }
    }
}
