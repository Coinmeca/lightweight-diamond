// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IDiamond} from "modules/diamond/interfaces/IDiamond.sol";
import {DiamondContract} from "modules/diamond/DiamondContract.sol";

import {IOrderbook} from "contracts/services/orderbook/IOrderbook.sol";

import {Data} from "./Data.sol";

contract Market is DiamondContract {
    using Data for Data.Storage;

    Data.Storage internal $;

    /*
     * At the time of creation, the parent diamond must also receive the facets of the child (facade) through 'diamondCut' here.
     */

    constructor(
        IDiamond.Cut[] memory _diamondCut,
        IDiamond.Args memory _args
    ) DiamondContract("market", _diamondCut, _args) {
        $.permission[msg.sender] = true;

        setInterface(
            keccak256("orderbook"),
            type(IOrderbook).interfaceId,
            true
        );
    }
}
