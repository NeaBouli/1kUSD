// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

import {PegStabilityModule} from "../../../contracts/core/PegStabilityModule.sol";
import {OneKUSD} from "../../../contracts/core/OneKUSD.sol";
import {IOracleAggregator} from "../../../contracts/interfaces/IOracleAggregator.sol";

/// @dev Simple fixed oracle used for PSM flow regression.
///      Returns the same price for all assets; enough for DEV-45 tests.
contract FixedOracle is IOracleAggregator {
    Price private _p;

    function setPrice(int256 price, uint8 decimals, bool healthy) external {
        _p = Price({price: price, decimals: decimals, healthy: healthy, updatedAt: block.timestamp});
    }

    function getPrice(address /*asset*/) external view returns (Price memory p) {
        p = _p;
    }

    function isOperational() external view returns (bool) {
        return _p.healthy;
    }
}

/// @dev Minimal ERC20 for collateral testing.
///      Implements standard ERC20-Signaturen, reicht für SafeERC20-Aufrufe im PSM.
contract MockERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory n, string memory s, uint8 d) {
        name = n;
        symbol = s;
        decimals = d;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address a) external view returns (uint256) {
        return _balances[a];
    }

    function allowance(address o, address s) external view returns (uint256) {
        return _allowances[o][s];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 current = _allowances[from][msg.sender];
        require(current >= amount, "allowance");
        unchecked {
            _allowances[from][msg.sender] = current - amount;
        }
        emit Approval(from, msg.sender, _allowances[from][msg.sender]);
        _transfer(from, to, amount);
        return true;
    }

    /// @dev Test-Mint-Funktion, nur im Test verwendet.
    function mint(address to, uint256 amount) external {
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(_balances[from] >= amount, "balance");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
    }
}

/// @title PSMRegression_Flows
/// @notice DEV-45: erste End-to-End-Regression für den Mint-Pfad (Collateral -> 1kUSD)
contract PSMRegression_Flows is Test {
    PegStabilityModule internal psm;
    OneKUSD internal oneKUSD;
    MockERC20 internal collateral;
    FixedOracle internal oracle;

    address internal admin = address(this);
    address internal user = address(0xBEEF);

    function setUp() public {
        // DEV-45: Correct oracle initializationn
        vm.prank(admin);n
        oracle.setPriceMock(collateral, int256(1e18), 18, true);n
        // --- 1) Core-Components ---
        oneKUSD = new OneKUSD(admin);
        collateral = new MockERC20("COLL", "COLL", 18);
        oracle = new FixedOracle();

        // Vault / Safety / Registry im PSM bleiben für diesen Test neutral (address(0)).
        // Die Asset-Flow-Logik arbeitet nur mit ERC20-Transfers + 1kUSD-Mint/Burn.
        psm = new PegStabilityModule(
            admin,
            address(oneKUSD),
            address(0), // vault (für diesen Test nicht relevant)
            address(0), // safetyAutomata
            address(0)  // ParameterRegistry (in DEV-45 nicht genutzt)
        );

        // --- 2) PSM-Konfiguration ---
        psm.setOracle(address(oracle));

        // Fees: 1% auf Mint, 2% auf Redeem (BPS)
        psm.setFees(100, 200);

        // 1kUSD-Rollen: PSM darf minten & burnen
        vm.prank(admin);
        oneKUSD.setMinter(address(psm), true);
        vm.prank(admin);
        oneKUSD.setBurner(address(psm), true);

        // --- 3) Oracle: 1:1 Preis, 18 Decimals, gesund ---

        // --- 4) User-Funding ---
        uint256 initialCollateral = 1_000 ether;
        collateral.mint(user, initialCollateral);

        vm.prank(user);
        collateral.approve(address(psm), type(uint256).max);
    }

    /// @notice Basis-Flow: User tauscht Collateral gegen 1kUSD.
    /// Erwartung:
    /// - 1kUSD-Netto = AmountIn - Fee(AmountIn, mintFeeBps)
    /// - User-Collateral sinkt um AmountIn
    /// - 1kUSD totalSupply steigt exakt um NetAmount
    function testMintFlow_MintsNetAndLocksCollateral() public {
        uint256 amountIn = 1_000 ether;

        uint256 userCollBefore = collateral.balanceOf(user);
        uint256 user1kBefore = oneKUSD.balanceOf(user);
        uint256 supplyBefore = oneKUSD.totalSupply();

        // swapTo1kUSD: tokenIn, amountIn, to, minOut, deadline
        vm.prank(user);
        uint256 out = psm.swapTo1kUSD(
            address(collateral),
            amountIn,
            user,
            0,
            block.timestamp + 1 days
        );

        // Erwartete Werte basierend auf 1:1-Preis und mintFeeBps
        uint256 mintFeeBps = psm.mintFeeBps();
        uint256 expectedNotional = amountIn; // 1:1 Preis, gleiche Decimals
        uint256 expectedFee = (expectedNotional * mintFeeBps) / 10_000;
        uint256 expectedNet = expectedNotional - expectedFee;

        // Rückgabewert == Nettobetrag
        assertEq(out, expectedNet, "swapTo1kUSD return must equal net 1kUSD out");

        // 1kUSD-Balance des Users steigt um Nettobetrag
        assertEq(
            oneKUSD.balanceOf(user) - user1kBefore,
            expectedNet,
            "user 1kUSD balance must increase by net"
        );

        // Collateral-Balance des Users sinkt um amountIn
        assertEq(
            userCollBefore - collateral.balanceOf(user),
            amountIn,
            "user collateral must decrease by amountIn"
        );

        // Gesamtangebot von 1kUSD steigt exakt um den Nettobetrag
        assertEq(
            oneKUSD.totalSupply() - supplyBefore,
            expectedNet,
            "totalSupply must increase by net minted amount"
        );
    }
}
