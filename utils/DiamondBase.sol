// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* Modifier : Coinmeca Team <dev@coinmeca.net>
* Lightweight version of EIP-2535 Diamonds
\******************************************************************************/

import {IDiamond} from "../interfaces/IDiamond.sol";
import {DiamondContractManager} from "../DiamondContractManager.sol";

abstract contract DiamondBase {
    using DiamondContractManager for bytes32;
    using DiamondContractManager for DiamondContractManager.Data;

    bytes32 immutable _this;

    constructor(string memory _key) payable {
        _this = keccak256(abi.encodePacked(_key));
    }

    fallback() external payable virtual {
        address f = _this.diamond().funct[msg.sig].facet;
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

    receive() external payable virtual {}
}
