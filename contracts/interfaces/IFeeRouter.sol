// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFeeRouter {
    /**
     * @dev Emittiert, wenn eine Fee an den TreasuryVault geroutet wurde.
     * @param token  ERC20-Token-Adresse der Fee
     * @param from   Modul/Absender, der die Fee liefert
     * @param to     TreasuryVault-Adresse (Ziel)
     * @param amount Höhe der Fee
     * @param tag    Kontext-Tag (z. B. keccak256("PSM_MINT_FEE"))
     */
    event FeeRouted(address indexed token, address indexed from, address indexed to, uint256 amount, bytes32 tag);

    /**
     * @notice Routet bereits auf dem Router liegende Tokens (push) an den TreasuryVault und emittiert ein Event.
     * @dev Das aufrufende Modul muss die Tokens vorab an den Router transferieren (kein transferFrom nötig).
     */
    function routeToTreasury(address token, address treasury, uint256 amount, bytes32 tag) external;
}
