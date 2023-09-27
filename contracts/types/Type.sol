// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface Type{
    struct Orderbook{
        address quote;
        address base;
        uint price;
        uint fee;
    }

    struct Token {
        address token;
        uint decimals;
        string name;
        string symbol;
    }
}