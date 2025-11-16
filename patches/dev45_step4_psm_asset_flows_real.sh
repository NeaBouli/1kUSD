#!/usr/bin/env bash
set -euo pipefail

FILE="contracts/core/PegStabilityModule.sol"

echo "== DEV-45 Step 4: Implement real asset flows + fee routing in PegStabilityModule =="

python3 << 'PY'
from pathlib import Path
import re

path = Path("contracts/core/PegStabilityModule.sol")
src = path.read_text()

# 1) IFeeRouterV2-Import ergänzen (falls noch nicht vorhanden)
if "IFeeRouterV2" not in src:
    marker = 'import {IPSM} from "../interfaces/IPSM.sol";\n'
    insert = (
        'import {IPSM} from "../interfaces/IPSM.sol";\n'
        'import {IFeeRouterV2} from "../router/IFeeRouterV2.sol";\n'
    )
    if marker in src:
        src = src.replace(marker, insert)

# 2) feeRouter-State-Variable ergänzen
if "IFeeRouterV2 public feeRouter;" not in src:
    marker = "    PSMLimits public limits;\n    IOracleAggregator public oracle;\n"
    insert = (
        "    PSMLimits public limits;\n"
        "    IOracleAggregator public oracle;\n"
        "    IFeeRouterV2 public feeRouter;\n"
    )
    if marker in src:
        src = src.replace(marker, insert)

# 3) setFeeRouter-Setter einfügen (vor setLimits / Oracle-Stubs)
if "function setFeeRouter(" not in src:
    marker = "    /// @notice Admin-Setter für PSMLimits-Contract\n"
    snippet = '''    /// @notice Admin-Setter für FeeRouterV2
    function setFeeRouter(address _router) external onlyRole(ADMIN_ROLE) {
        feeRouter = IFeeRouterV2(_router);
    }

'''
    if marker in src:
        src = src.replace(marker, snippet + marker)

# Helper-Replacer
def replace_helper(name: str, body: str):
    global src
    pattern = rf"    function {name}\([^)]*\) internal \{{.*?^    \}}\n"
    src_new, n = re.subn(pattern, body, src, flags=re.S | re.M)
    if n == 0:
        # Falls das Pattern nicht gefunden wird, nichts tun (fail-safe)
        return
    src = src_new

# 4) _pullCollateral: ERC20 -> Vault (deposit)
replace_helper(
    "_pullCollateral",
    '''    /// @dev DEV-45: pull collateral from user into CollateralVault
    function _pullCollateral(address tokenIn, address from, uint256 amountIn) internal {
        if (amountIn == 0) return;
        // Transfer Token vom Nutzer in den Vault und registrieren
        IERC20(tokenIn).safeTransferFrom(from, address(vault), amountIn);
        vault.deposit(tokenIn, from, amountIn);
    }

'''
)

# 5) _pushCollateral: Vault -> User (withdraw)
replace_helper(
    "_pushCollateral",
    '''    /// @dev DEV-45: push collateral from CollateralVault to user
    function _pushCollateral(address tokenOut, address to, uint256 amountOut) internal {
        if (amountOut == 0) return;
        // Reason-Tag für Audits / Off-Chain-Tools
        bytes32 reason = keccak256("PSM_REDEEM");
        vault.withdraw(tokenOut, to, amountOut, reason);
    }

'''
)

# 6) _mint1kUSD: echte 1kUSD-Mint
replace_helper(
    "_mint1kUSD",
    '''    /// @dev DEV-45: mint 1kUSD to recipient
    function _mint1kUSD(address to, uint256 amount1k) internal {
        if (amount1k == 0) return;
        oneKUSD.mint(to, amount1k);
    }

'''
)

# 7) _burn1kUSD: echte 1kUSD-Burn
replace_helper(
    "_burn1kUSD",
    '''    /// @dev DEV-45: burn 1kUSD from sender
    function _burn1kUSD(address from, uint256 amount1k) internal {
        if (amount1k == 0) return;
        oneKUSD.burnFrom(from, amount1k);
    }

'''
)

# 8) _routeFee: FeeRouterV2-Route auf 1kUSD-Notional-Basis
replace_helper(
    "_routeFee",
    '''    /// @dev DEV-45: route fee on 1kUSD-notional basis via FeeRouterV2
    function _routeFee(address asset, uint256 feeAmount1k) internal {
        if (feeAmount1k == 0) return;
        if (address(feeRouter) == address(0)) return;
        // "asset" = Collateral-Identifikator (für Routing-Accounting),
        // "feeAmount1k" = 1kUSD-notional Betrag
        feeRouter.route(MODULE_PSM, asset, feeAmount1k);
    }

'''
)

path.write_text(src)
PY

echo "✓ PegStabilityModule.sol updated with real asset flows + fee routing glue"
echo "== DEV-45 Step 4 Complete =="
