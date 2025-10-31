// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title PSMLimits
/// @notice Tracks per-swap and daily volume caps; exposes internal _updateVolume().
contract PSMLimits {
    address public dao;
    uint256 public maxSingleSwap;
    uint256 public maxDailySwap;
    uint256 public dailyVolume;
    uint256 public lastDay;

    event LimitsUpdated(uint256 maxSingle, uint256 maxDaily);
    event DailyReset(uint256 day, uint256 volume);

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    constructor(address _dao, uint256 _maxSingle, uint256 _maxDaily) {
        dao = _dao;
        maxSingleSwap = _maxSingle;
        maxDailySwap = _maxDaily;
        lastDay = block.timestamp / 1 days;
    }

    function setLimits(uint256 single, uint256 daily) external onlyDAO {
        maxSingleSwap = single;
        maxDailySwap = daily;
        emit LimitsUpdated(single, daily);
    }

    /// @dev Internal hook to be called by PSM swap before accounting/minting.
    function _updateVolume(uint256 amount) internal {
        uint256 currentDay = block.timestamp / 1 days;
        if (currentDay > lastDay) {
            emit DailyReset(currentDay, dailyVolume);
            dailyVolume = 0;
            lastDay = currentDay;
        }
        require(amount <= maxSingleSwap, "swap too large");
        require(dailyVolume + amount <= maxDailySwap, "daily limit");
        dailyVolume += amount;
    }
}
