// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title PSMLimits — Daily and Single-Transaction Caps
/// @notice DEV-35a.4 : _updateVolume jetzt public für Harness-Kompatibilität
contract PSMLimits {
    address public dao;
    uint256 public dailyCap;
    uint256 public singleTxCap;
    uint256 public lastUpdatedDay;
    uint256 public dailyVolume;

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    constructor(address _dao, uint256 _daily, uint256 _single) {
        dao = _dao;
        dailyCap = _daily;
        singleTxCap = _single;
        lastUpdatedDay = block.timestamp / 1 days;
    }

    function setLimits(uint256 _daily, uint256 _single) external onlyDAO {
        dailyCap = _daily;
        singleTxCap = _single;
    }

    function checkAndUpdate(uint256 amount) public {
        uint256 day = block.timestamp / 1 days;
        if (day > lastUpdatedDay) {
            dailyVolume = 0;
            lastUpdatedDay = day;
        }
        if (amount > singleTxCap) revert("swap too large");
        if (dailyVolume + amount > dailyCap) revert("swap too large");
        dailyVolume += amount;
    }

    // Legacy aliases for test compatibility
    function _updateVolume(uint256 amount) public { checkAndUpdate(amount); }
    function lastDay() external view returns (uint256) { return lastUpdatedDay; }
    function dailyVolumeView() external view returns (uint256) { return dailyVolume; }
}
