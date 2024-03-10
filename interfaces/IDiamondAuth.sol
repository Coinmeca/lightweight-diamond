// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.24;

/******************************************************************************\
* Author: Coinmeca Team <dev@coinmeca.net>
* Lightweight version of EIP-2535 Diamonds
\******************************************************************************/

interface IDiamondAuth {
    function owner() external returns (address);

    function setOwner(address _owner) external;

    function setAccess(address _owner, bool _access) external;

    function checkAccess(address _owner) external view returns (bool);
}
