// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.24;

/******************************************************************************\
* Author: Coinmeca Team <dev@coinmeca.net>
* Lightweight version of EIP-2535 Diamonds
\******************************************************************************/

import {IDiamondAuth} from "./IDiamondAuth.sol";
import {IDiamondLoupe} from "./IDiamondLoupe.sol";

interface IDiamondContract is IDiamondAuth, IDiamondLoupe {
    function facet(bytes4 _funct) external returns (address);

    function facet(bytes32 _contract, bytes4 _funct) external returns (address);
}
