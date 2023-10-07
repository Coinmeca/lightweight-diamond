// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

import {DiamondContractManager} from "../DiamondContractManager.sol";

interface IDiamondLoupe {
    function facets()
        external
        view
        returns (DiamondContractManager.Facet[] memory);

    function facets(
        bytes32 _contract
    ) external view returns (DiamondContractManager.Facet[] memory);

    function facetFunctionSelectors(
        address _facet
    ) external view returns (bytes4[] memory);

    function facetFunctionSelectors(
        bytes32 _contract,
        address _facet
    ) external view returns (bytes4[] memory);

    function facetAddresses() external view returns (address[] memory);

    function facetAddresses(
        bytes32 _contract
    ) external view returns (address[] memory);

    function facetAddress(bytes4 _funct) external view returns (address);

    function facetAddress(
        bytes32 _contract,
        bytes4 _funct
    ) external view returns (address);

    function supportsInterface(bytes4 _interface) external view returns (bool);

    function supportsInterface(
        bytes32 _contract,
        bytes4 _interface
    ) external view returns (bool);

    function setInterface(bytes4 _interface, bool _state) external;

    function setInterface(
        bytes32 _contract,
        bytes4 _interface,
        bool _state
    ) external;
}
