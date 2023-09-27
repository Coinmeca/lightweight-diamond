// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IMarket {
    function create(
        address _base,
        address _quote,
        uint _initialPrice
    ) external returns (address);

    function getAllMarkets() external view returns (address[] memory);

    function getMarketsFor(
        address _token
    ) external view returns (address[] memory);

    function getOrderbook(
        address _base,
        address _quote
    ) external view returns (address);
}
