// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Modifiers} from "../shared/Modifiers.sol";
import {Data} from "../Data.sol";

contract Get is Modifiers {
    function getPrice() public view returns (uint) {
        return $.price;
    }

    function getTick() public view returns (uint) {
        return $.tick;
    }
}
