// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {I1kUSD} from "../interfaces/I1kUSD.sol";

/// @title OneKUSD — minimal ERC-20-compatible token with gated mint/burn and pause interop
/// @notice DEV31 kickoff: no permit; transfers always allowed; pause blocks only mint/burn.
/// @dev Admin is expected to be a Timelock later; for now a single admin EOA/contract.
contract OneKUSD is I1kUSD {
    // --- Metadata ---
    string private constant _NAME   = "1kUSD";
    string private constant _SYMBOL = "1kUSD";
    uint8  private constant _DECIMALS = 18;

    // --- Admin & Roles ---
    address public admin;                      // expected to be Timelock in production
    mapping(address => bool) public isMinter;  // ROLE_MINTER
    mapping(address => bool) public isBurner;  // ROLE_BURNER

    // --- Pause (mint/burn only) ---
    bool public paused; // if true → mint/burn blocked; transfers unaffected

    // --- ERC20 state ---
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // --- Events (ERC20 standard) ---
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // --- Admin/Role Events ---
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event MinterSet(address indexed account, bool enabled);
    event BurnerSet(address indexed account, bool enabled);
    event Paused(address indexed by);
    event Unpaused(address indexed by);

    // --- Errors ---
    error ACCESS_DENIED();
    error PAUSED();
    error INSUFFICIENT_BALANCE();
    error INSUFFICIENT_ALLOWANCE();
    error ZERO_ADDRESS();

    // --- Constructor ---
    constructor(address _admin) {
        if (_admin == address(0)) revert ZERO_ADDRESS();
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    // --- Modifiers ---
    modifier onlyAdmin() {
        if (msg.sender != admin) revert ACCESS_DENIED();
        _;
    }

    modifier notPaused() {
        if (paused) revert PAUSED();
        _;
    }

    // --- ERC20 view ---
    function name() external pure returns (string memory) { return _NAME; }
    function symbol() external pure returns (string memory) { return _SYMBOL; }
    function decimals() external pure returns (uint8) { return _DECIMALS; }
    function totalSupply() external view returns (uint256) { return _totalSupply; }
    function balanceOf(address a) external view returns (uint256) { return _balances[a]; }
    function allowance(address o, address s) external view returns (uint256) { return _allowances[o][s]; }

    // --- ERC20 write ---
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 current = _allowances[from][msg.sender];
        if (current < amount) revert INSUFFICIENT_ALLOWANCE();
        unchecked { _allowances[from][msg.sender] = current - amount; }
        emit Approval(from, msg.sender, _allowances[from][msg.sender]);
        _transfer(from, to, amount);
        return true;
    }

    // --- Controlled supply (gated) ---
    function mint(address to, uint256 amount) external notPaused {
        if (!isMinter[msg.sender]) revert ACCESS_DENIED();
        if (to == address(0)) revert ZERO_ADDRESS();
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) external notPaused {
        if (!isBurner[msg.sender]) revert ACCESS_DENIED();
        if (_balances[from] < amount) revert INSUFFICIENT_BALANCE();
        _balances[from] -= amount;
        _totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    // --- Admin & Pause (wire to Safety/Timelock later) ---
    function setMinter(address account, bool enabled) external onlyAdmin {
        if (account == address(0)) revert ZERO_ADDRESS();
        isMinter[account] = enabled;
        emit MinterSet(account, enabled);
    }

    function setBurner(address account, bool enabled) external onlyAdmin {
        if (account == address(0)) revert ZERO_ADDRESS();
        isBurner[account] = enabled;
        emit BurnerSet(account, enabled);
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert ZERO_ADDRESS();
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }

    function pause() external onlyAdmin {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyAdmin {
        paused = false;
        emit Unpaused(msg.sender);
    }

    // --- Internal helpers ---
    function _approve(address owner_, address spender, uint256 amount) internal {
        if (owner_ == address(0) || spender == address(0)) revert ZERO_ADDRESS();
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        if (to == address(0) || from == address(0)) revert ZERO_ADDRESS();
        uint256 bal = _balances[from];
        if (bal < amount) revert INSUFFICIENT_BALANCE();
        unchecked {
            _balances[from] = bal - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    // --- I1kUSD optional surface (not implemented here) ---
    function nonces(address) external pure returns (uint256) { return 0; }
    function DOMAIN_SEPARATOR() external pure returns (bytes32) { return bytes32(0); }
}
