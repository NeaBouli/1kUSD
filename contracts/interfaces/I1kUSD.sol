// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

/// @title I1kUSD — controlled supply token (interface)
interface I1kUSD {
    // ERC20 subset
    function totalSupply() external view returns (uint256);
    function balanceOf(address a) external view returns (uint256);
    function allowance(address o, address s) external view returns (uint256);
    function approve(address s, uint256 a) external returns (bool);
    function transfer(address to, uint256 a) external returns (bool);
    function transferFrom(address f, address t, uint256 a) external returns (bool);

    // Controlled supply hooks (gated by roles in implementation)
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}
