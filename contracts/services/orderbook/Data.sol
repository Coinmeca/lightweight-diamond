// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Type} from "contracts/types/Type.sol";

library Data {
    bytes32 constant key = keccak256("orderbook.storage");

    struct Storage {
        address base;
        address quote;
        uint tick;
        uint price;
    }
}
