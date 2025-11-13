#!/usr/bin/env bash
set -euo pipefail
echo "== DEV-42 Patch 3: Interfaces =="

# IOracleAggregator
cat > contracts/interfaces/IOracleAggregator.sol <<"EOL"
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

interface IOracleAggregator {
    struct Price {
        int256 price;
        uint8 decimals;
        bool healthy;
        uint256 updatedAt;
    }
    function getPrice(address asset) external view returns (Price memory p);
    function isOperational() external view returns (bool);
}
EOL

# ISafetyAutomata
cat > contracts/interfaces/ISafetyAutomata.sol <<"EOL"
// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.30;

interface ISafetyAutomata {
    function isPaused(bytes32 moduleId) external view returns (bool);
    function isModuleEnabled(bytes32 moduleId) external view returns (bool);
    function grantGuardian(address guardian) external;
    function pauseModule(bytes32 moduleId) external;
    function resumeModule(bytes32 moduleId) external;
}
EOL
echo "✅ Interfaces updated."
