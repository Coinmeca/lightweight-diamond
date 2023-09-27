// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DiamondFacade} from "modules/diamond/DiamondFacade.sol";
import {IOrderbook} from "./IOrderbook.sol";
import {Data} from "./Data.sol";

contract Orderbook is DiamondFacade {
    using Data for Data.Storage;

    Data.Storage internal $;

    /*
     * The address of '_app' is the address of the parent diamond. '_app' has all the facet contracts of the corresponding facade,
     * and in order to refer to them in the 'fallback', the app (parent diamond contract) address is
     * passed as a parameter here when the contract's first creation.
     */

    constructor(
        address _base,
        address _quote,
        uint _price,
        address _app
    ) DiamondFacade("orderbook", _app) {
        // It can also be used in other ways such as shown below in other facet contracts.
        // Data.Storage storage $ = $;

        $.base = _base;
        $.quote = _quote;
        $.price = _price;
    }
}
