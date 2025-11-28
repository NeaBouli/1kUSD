// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IBuybackStrategy
/// @notice Interface for external strategy modules that compute buyback targets
///         for BuybackVault. This is forward-looking for v0.52+ and is not yet
///         wired into BuybackVault.executeBuyback().
interface IBuybackStrategy {
    /// @notice Describes a single buyback leg for a given asset.
    /// @dev weightBps is expressed in basis points (1e4 = 100%).
    struct BuybackLeg {
        address asset;
        uint256 weightBps;
        bool enabled;
    }

    /// @notice Returns the desired buyback allocation for a given vault and
    ///         amount of available stable.
    /// @param vault Address of the calling BuybackVault.
    /// @param availableStable Amount of 1kUSD available for buyback.
    /// @return legs Array of buyback legs (asset/weight/enabled).
    function planBuyback(address vault, uint256 availableStable)
        external
        view
        returns (BuybackLeg[] memory legs);
}
