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

interface IDiamondContract {
    function facet(bytes32, bytes4) external view returns (address);
}

abstract contract DiamondFacade is DiamondAuth, DiamondLoupe {
    using DiamondContractManager for bytes32;

    constructor(
        string memory _key,
        address _diamond
    ) payable DiamondBase(_key) DiamondAuth(false) DiamondLoupe(false) {
        _this.diamond().addr = payable(_diamond);
    }

    fallback() external payable virtual override {
        address f = IDiamondContract(_this.diamond().addr).facet(
            _this,
            msg.sig
        );
        if (f == address(0)) revert IDiamond.FunctionNotFound(msg.sig);
        assembly {
            calldatacopy(0, 0, calldatasize())
            let r := delegatecall(gas(), f, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            switch r
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
