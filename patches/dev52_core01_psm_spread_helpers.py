#!/usr/bin/env python3
from pathlib import Path

FILE = Path("contracts/core/PegStabilityModule.sol")

print("== DEV52 CORE01: inject registry-driven spread helpers into PSM ==")

text = FILE.read_text()

marker = "}\n"
idx = text.rfind(marker)
if idx == -1:
    raise SystemExit("ERROR: closing brace for PegStabilityModule not found")

snippet = """
    // -------------------------------------------------------------
    // 🔧 DEV-52: registry-driven directional spread helpers (basis points)
    // -------------------------------------------------------------

    function _globalMintSpreadKey() internal pure returns (bytes32) {
        return keccak256("psm:mintSpreadBps");
    }

    function _globalRedeemSpreadKey() internal pure returns (bytes32) {
        return keccak256("psm:redeemSpreadBps");
    }

    function _mintSpreadKey(address token) internal pure returns (bytes32) {
        bytes32 base = keccak256("psm:mintSpreadBps:token");
        return keccak256(abi.encode(base, token));
    }

    function _redeemSpreadKey(address token) internal pure returns (bytes32) {
        bytes32 base = keccak256("psm:redeemSpreadBps:token");
        return keccak256(abi.encode(base, token));
    }

    /// @dev Resolve mint-side spread (bps) from registry with per-token override,
    ///      then global default. Returns 0 if no entry configured.
    function _getMintSpreadBps(address token) internal view returns (uint16) {
        if (address(registry) == address(0)) {
            return 0;
        }

        uint256 perToken = registry.getUint(_mintSpreadKey(token));
        if (perToken > 0) {
            require(perToken <= 10_000, "PSM: mintSpread too high");
            return uint16(perToken);
        }

        uint256 globalVal = registry.getUint(_globalMintSpreadKey());
        if (globalVal > 0) {
            require(globalVal <= 10_000, "PSM: mintSpread too high");
            return uint16(globalVal);
        }

        return 0;
    }

    /// @dev Resolve redeem-side spread (bps) from registry with per-token override,
    ///      then global default. Returns 0 if no entry configured.
    function _getRedeemSpreadBps(address token) internal view returns (uint16) {
        if (address(registry) == address(0)) {
            return 0;
        }

        uint256 perToken = registry.getUint(_redeemSpreadKey(token));
        if (perToken > 0) {
            require(perToken <= 10_000, "PSM: redeemSpread too high");
            return uint16(perToken);
        }

        uint256 globalVal = registry.getUint(_globalRedeemSpreadKey());
        if (globalVal > 0) {
            require(globalVal <= 10_000, "PSM: redeemSpread too high");
            return uint16(globalVal);
        }

        return 0;
    }
"""

FILE.write_text(text[:idx] + snippet + text[idx:])

print("✓ DEV52 CORE01: spread helpers injected into PegStabilityModule.sol")
