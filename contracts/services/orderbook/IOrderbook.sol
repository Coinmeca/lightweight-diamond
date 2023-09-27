// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IOrderbook {
    function order(uint _price) external;
}