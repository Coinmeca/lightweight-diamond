// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* Modifier : Coinmeca Team <dev@coinmeca.net>
* Lightweight version of EIP-2535 Diamonds
\******************************************************************************/

import {IDiamond} from "./interfaces/IDiamond.sol";

import {DiamondBase} from "./utils/DiamondBase.sol";
import {DiamondAuth} from "./utils/DiamondAuth.sol";
import {DiamondLoupe} from "./utils/DiamondLoupe.sol";

import {DiamondContractManager} from "./DiamondContractManager.sol";

abstract contract DiamondContract is DiamondAuth, DiamondLoupe {
    using DiamondContractManager for bytes32;
    using DiamondContractManager for DiamondContractManager.Data;

    constructor(
        string memory _key,
        IDiamond.Cut[] memory _diamondCut,
        IDiamond.Args memory _args
    ) payable DiamondBase(_key) DiamondAuth(true) DiamondLoupe(true) {
        _this.setOwner(_args.owner);
        _this.setAccess(address(this), true);
        _this.diamond().addr = payable(address(this));

        DiamondContractManager.diamondCut(
            _diamondCut,
            _args.init,
            _args.initCalldata
        );
    }

    function facet(bytes4 _funct) public virtual returns (address) {
        return _this.diamond().funct[_funct].facet;
    }

    function facet(
        bytes32 _contract,
        bytes4 _funct
    ) public virtual returns (address) {
        return _contract.diamond().funct[_funct].facet;
    }
}
