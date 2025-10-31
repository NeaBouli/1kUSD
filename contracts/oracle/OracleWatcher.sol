// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "./OracleAdapter.sol";

contract OracleWatcher {
    address public dao;
    uint256 public maxStale = 1 days;
    mapping(address => uint256) public lastUpdate;
    mapping(address => address) public backupFeed;

    event FeedUpdated(address feed, uint256 timestamp);
    event FeedStale(address feed, uint256 lastUpdate);
    event BackupSet(address feed, address backup);
    event MaxStaleSet(uint256 newLimit);

    modifier onlyDAO() {
        require(msg.sender == dao, "not DAO");
        _;
    }

    constructor(address _dao) {
        dao = _dao;
    }

    function updateFeed(address feed) external {
        uint256 updated = block.timestamp;
        lastUpdate[feed] = updated;
        emit FeedUpdated(feed, updated);
    }

    function checkFeed(address feed) external view returns (bool ok) {
        uint256 last = lastUpdate[feed];
        if (block.timestamp > last + maxStale) {
            ok = false;
        } else {
            ok = true;
        }
    }

    function setBackup(address feed, address backup) external onlyDAO {
        backupFeed[feed] = backup;
        emit BackupSet(feed, backup);
    }

    function setMaxStale(uint256 newLimit) external onlyDAO {
        maxStale = newLimit;
        emit MaxStaleSet(newLimit);
    }
}
