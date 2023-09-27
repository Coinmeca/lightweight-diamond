// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Data} from "../Data.sol";

library Internals {
    using Data for Data.Storage;
    using Internals for Data.Storage;

    function matching(Data.Storage storage $, uint _price) internal {
        $.price = _price * 2;
    }

    function fill(Data.Storage storage $) internal {
        ++$.tick;
    }

    function execute(Data.Storage storage $, uint _price) internal {
        $.matching(_price);
        $.fill();
    }
}
