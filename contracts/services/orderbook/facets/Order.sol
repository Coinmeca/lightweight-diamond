// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Modifiers} from "../shared/Modifiers.sol";
import {Internals} from "../shared/Internals.sol";
import {Data} from "../Data.sol";

contract Order is Modifiers {
    using Internals for Data.Storage;

    function order(uint8 _type, uint _price) public {
        if (_type == 0) {
            $.price = 100;
        } else if (_type == 1) {
            $.execute(_price);
        }
        ++$.tick;
    }
}
