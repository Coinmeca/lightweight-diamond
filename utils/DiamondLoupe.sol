// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com>, Twitter/Github: @mudgen
* Modifier : Coinmeca Team <dev@coinmeca.net>
* Lightweight version of EIP-2535 Diamonds
\******************************************************************************/

import {DiamondBase} from "./DiamondBase.sol";
import {DiamondContractManager} from "../DiamondContractManager.sol";

abstract contract DiamondLoupe is DiamondBase {
    using DiamondContractManager for bytes32;
    using DiamondContractManager for DiamondContractManager.Data;

    constructor(bool _diamond) {
        if (_diamond) {
            bytes4[] memory selectors = new bytes4[](12);
            selectors[0] = bytes4(0x82431dab);
            selectors[1] = bytes4(0xcdffacc6);
            selectors[2] = bytes4(0x52ef6b2c);
            selectors[3] = bytes4(0xf69f473c);
            selectors[4] = bytes4(0xadfca15e);
            selectors[5] = bytes4(0xf28401a9);
            selectors[6] = bytes4(0x59d96799);
            selectors[7] = bytes4(0x7a0ed627);
            selectors[8] = bytes4(0x8257735f);
            selectors[9] = bytes4(0xc0a43a7c);
            selectors[10] = bytes4(0x01ffc9a7);
            selectors[11] = bytes4(0xc33470d3);
            DiamondContractManager.internalCut(selectors);
        }
    }

    function facets()
        public
        view
        virtual
        returns (DiamondContractManager.Facet[] memory)
    {
        address payable diamond = _this.diamond().addr;
        return
            diamond == address(this)
                ? _this.getFacets()
                : DiamondLoupe(diamond).facets(_this);
    }

    function facets(
        bytes32 _contract
    ) public view virtual returns (DiamondContractManager.Facet[] memory) {
        return _contract.getFacets();
    }

    function facetFunctionSelectors(
        address _facet
    ) public view virtual returns (bytes4[] memory) {
        address payable diamond = _this.diamond().addr;
        return
            diamond == address(this)
                ? _this.functs(_facet)
                : DiamondLoupe(diamond).facetFunctionSelectors(_this, _facet);
    }

    function facetFunctionSelectors(
        bytes32 _contract,
        address _facet
    ) public view virtual returns (bytes4[] memory) {
        return _contract.functs(_facet);
    }

    function facetAddresses() public view virtual returns (address[] memory) {
        address payable diamond = _this.diamond().addr;
        return
            diamond == address(this)
                ? _this.facets()
                : DiamondLoupe(diamond).facetAddresses(_this);
    }

    function facetAddresses(
        bytes32 _contract
    ) public view virtual returns (address[] memory) {
        return _contract.facets();
    }

    function facetAddress(bytes4 _funct) public view virtual returns (address) {
        address payable diamond = _this.diamond().addr;
        return
            diamond == address(this)
                ? _this.facet(_funct)
                : DiamondLoupe(diamond).facetAddress(_this, _funct);
    }

    function facetAddress(
        bytes32 _contract,
        bytes4 _funct
    ) public view virtual returns (address) {
        return _contract.facet(_funct);
    }

    function supportsInterface(
        bytes4 _interface
    ) public view virtual returns (bool) {
        address payable diamond = _this.diamond().addr;
        return
            diamond == address(this)
                ? _this.checkInterface(_interface)
                : DiamondLoupe(diamond).supportsInterface(_this, _interface);
    }

    function supportsInterface(
        bytes32 _contract,
        bytes4 _interface
    ) public view virtual returns (bool) {
        return _contract.checkInterface(_interface);
    }

    function setInterface(bytes4 _interface, bool _state) public virtual {
        address payable diamond = _this.diamond().addr;
        return
            diamond == address(this)
                ? _this.setInterface(_this, _interface, _state)
                : DiamondLoupe(diamond).setInterface(_this, _interface, _state);
    }

    function setInterface(
        bytes32 _contract,
        bytes4 _interface,
        bool _state
    ) public virtual {
        return _this.setInterface(_contract, _interface, _state);
    }
}
