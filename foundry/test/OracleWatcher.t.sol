// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/oracle/OracleWatcher.sol";

contract OracleWatcherTest is Test {
    OracleWatcher watcher;
    address dao = address(this);
    address feed = address(0xF00D);
    address backup = address(0xBEEF);

    function setUp() public {
        watcher = new OracleWatcher(dao);
    }

    function testFeedUpdateRecordsTimestamp() public {
        uint256 beforeTs = block.timestamp;
        watcher.updateFeed(feed);
        uint256 stored = watcher.lastUpdate(feed);
        assertGe(stored, beforeTs);
    }

    function testFeedBecomesStaleAfterThreshold() public {
        watcher.updateFeed(feed);
        vm.warp(block.timestamp + 2 days);
        bool ok = watcher.checkFeed(feed);
        assertFalse(ok, "feed should be stale");
    }

    function testSetBackupAndMaxStale() public {
        watcher.setBackup(feed, backup);
        assertEq(watcher.backupFeed(feed), backup);
        watcher.setMaxStale(2 days);
        assertEq(watcher.maxStale(), 2 days);
    }

    function testOnlyDAOCanSetConfig() public {
        vm.prank(address(0xDEAD));
        vm.expectRevert("not DAO");
        watcher.setBackup(feed, backup);

        vm.prank(address(0xDEAD));
        vm.expectRevert("not DAO");
        watcher.setMaxStale(5 days);
    }
}
