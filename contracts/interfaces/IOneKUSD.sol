// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title IOneKUSD — ERC20-compatible stable token with EIP-2612 Permit and gated mint/burn
/// @notice Transfers are always allowed; pause only gates mint/burn (policy driven via SafetyAutomata)
interface IOneKUSD {
// -------- ERC20 --------
function name() external view returns (string memory);
function symbol() external view returns (string memory);
function decimals() external pure returns (uint8);
function totalSupply() external view returns (uint256);
function balanceOf(address) external view returns (uint256);
function allowance(address owner, address spender) external view returns (uint256);
function approve(address spender, uint256 value) external returns (bool);
function transfer(address to, uint256 value) external returns (bool);
function transferFrom(address from, address to, uint256 value) external returns (bool);

// -------- Permit (EIP-2612) --------
function nonces(address owner) external view returns (uint256);
function DOMAIN_SEPARATOR() external view returns (bytes32);
function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v, bytes32 r, bytes32 s
) external;

// -------- Protocol (roles) --------
function mint(address to, uint256 amount) external;
function burn(address from, uint256 amount) external;

// -------- Pause (mint/burn only) --------
function paused() external view returns (bool);
function pause() external;     // policy: Safety/DAO
function unpause() external;   // policy: Safety/DAO

// -------- Events --------
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Paused(address indexed by);
event Unpaused(address indexed by);

// -------- Errors --------
error PAUSED();        // mint/burn while paused
error ACCESS_DENIED(); // role missing
error ZERO_ADDRESS();


}
