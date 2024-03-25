// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.24;

/******************************************************************************\
* Author: Coinmeca Team <dev@coinmeca.net>
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
        DiamondContractManager.initialOwner(_args.owner);
        DiamondContractManager.diamondCut(
            _diamondCut,
            _args.init,
            _args.initCalldata
        );

        _this.diamond().addr = payable(address(this));
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
