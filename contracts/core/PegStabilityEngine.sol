// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {IPSM} from "../interfaces/IPSM.sol";

/// @title PegStabilityEngine (PSE) — Interface-aligned minimal impl
/// @notice Kompilerstabile Stub-Implementierung gegen IPSM v1. Mathe/Transfers folgen in DEV-32+.
///         Ziel dieses Patches ist ausschließlich, die Signaturen und Events exakt an IPSM.sol anzugleichen.
contract PegStabilityEngine is IPSM {
    /// @dev Pure Quote: gibt Beträge in identischer Einheit zurück (keine Preislogik in diesem Stub).
    function quoteTo1kUSD(
        address /* tokenIn */,
        uint256 amountIn,
        uint16 feeBps,
        uint8 /* tokenInDecimals */
    ) external view override returns (QuoteOut memory q) {
        uint256 fee = (amountIn * feeBps) / 10_000;
        uint256 net = amountIn - fee;
        // outDecimals = 18, da Ziel 1kUSD ist (WAD)
        q = QuoteOut({grossOut: amountIn, fee: fee, netOut: net, outDecimals: 18});
    }

    function quoteFrom1kUSD(
        address /* tokenOut */,
        uint256 amountIn1k,
        uint16 feeBps,
        uint8 tokenOutDecimals
    ) external view override returns (QuoteOut memory q) {
        uint256 fee = (amountIn1k * feeBps) / 10_000;
        uint256 net = amountIn1k - fee;
        // outDecimals = tokenOutDecimals, da Ziel-Asset variable Decimals hat
        q = QuoteOut({grossOut: amountIn1k, fee: fee, netOut: net, outDecimals: tokenOutDecimals});
    }

    /// @dev State-changing Stubs: emittieren nur normierte Events mit korrekten Parametern.
    function swapTo1kUSD(
        address tokenIn,
        uint256 amountIn,
        address /* to */,
        uint256 /* minOut */,
        uint256 /* deadline */
    ) external override returns (uint256 netOut) {
        // Minimal-CEI-Stub: keine Transfers; nur deterministische Ausgabe
        uint16 feeBps = 0; // echte Fee wird in DEV-32+ aus Registry geholt
        uint256 fee = (amountIn * feeBps) / 10_000;
        netOut = amountIn - fee;

        emit SwapTo1kUSD(
            msg.sender,   // user
            tokenIn,      // tokenIn
            amountIn,     // amountIn
            fee,          // fee
            netOut,       // netOut
            block.timestamp
        );
    }

    function swapFrom1kUSD(
        address tokenOut,
        uint256 amountIn1k,
        address /* to */,
        uint256 /* minOut */,
        uint256 /* deadline */
    ) external override returns (uint256 netOut) {
        uint16 feeBps = 0; // echte Fee folgt in DEV-32+
        uint256 fee = (amountIn1k * feeBps) / 10_000;
        netOut = amountIn1k - fee;

        emit SwapFrom1kUSD(
            msg.sender,   // user
            tokenOut,     // tokenOut
            amountIn1k,   // amountIn
            fee,          // fee
            netOut,       // netOut
            block.timestamp
        );
    }
}
