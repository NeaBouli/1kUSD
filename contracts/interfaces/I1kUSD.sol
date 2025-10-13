// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title I1kUSD — canonical stable token interface (mint/burn gated by protocol)
interface I1kUSD {
    // ERC-20 minimal
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    // Controlled supply
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;

    // Optional: EIP-2612
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
