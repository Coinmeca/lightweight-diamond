// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* Modifier : Coinmeca Team <dev@coinmeca.net>
* Lightweight version of EIP-2535 Diamonds
\******************************************************************************/

import {DiamondBase} from "./DiamondBase.sol";
import {DiamondContractManager} from "../DiamondContractManager.sol";

abstract contract DiamondAuth is DiamondBase {
    using DiamondContractManager for bytes32;
    using DiamondContractManager for DiamondContractManager.Data;

    constructor(bool _diamond) {
        if (_diamond) {
            bytes4[] memory f = new bytes4[](4);
            f[0] = 0x57d3a786;
            f[1] = 0x8da5cb5b;
            f[2] = 0x13af4035;
            f[3] = 0xec6263c0;
            DiamondContractManager.internalCut(f, "auth");
        }
    }

    function owner() public virtual returns (address) {
        address payable diamond = _this.diamond().addr;
        return
            diamond == address(this)
                ? _this.owner()
                : DiamondAuth(diamond).owner();
    }

    function setOwner(address _owner) public virtual {
        address payable diamond = _this.diamond().addr;
        diamond == address(this)
            ? _this.setOwner(_owner)
            : DiamondAuth(diamond).setOwner(_owner);
    }

    function setPermission(address _owner, bool _permission) public virtual {
        address payable diamond = _this.diamond().addr;
        diamond == address(this)
            ? _this.setPermission(_owner, _permission)
            : DiamondAuth(diamond).setPermission(_owner, _permission);
    }

    function checkPermission(
        address _owner
    ) public view virtual returns (bool) {
        address payable diamond = _this.diamond().addr;
        return
            diamond == address(this)
                ? _this.checkPermission(_owner)
                : DiamondAuth(diamond).checkPermission(_owner);
    }
}
