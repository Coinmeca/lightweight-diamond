// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Modifiers} from "../shared/Modifiers.sol";
import {Data} from "../Data.sol";

contract Get is Modifiers {
    function getAllMarkets() public view returns (address[] memory) {
        return $.all_markets;
    }

    function getMarkets(address _token) public view returns (address[] memory) {
        return $.markets[_token];
    }

    function getOrderbook(
        address _base,
        address _quote
    ) public view returns (address) {
        return $.market[_base][_quote];
    }
}
