// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Modifiers} from "../shared/Modifiers.sol";
import {Internals} from "../shared/Internals.sol";
import {Data} from "../Data.sol";

contract Cancel is Modifiers {
    using Internals for Data.Storage;

    function cancel() public {
        if ($.tick > 0) --$.tick;
        $.price = 0;
    }

    function liquidation(uint _price) public {
        $.matching(_price);
    }
}
