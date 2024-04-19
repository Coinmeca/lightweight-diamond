// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.24;

/******************************************************************************\
* Author: Coinmeca Team <dev@coinmeca.net>
* Lightweight version of EIP-2535 Diamonds
\******************************************************************************/

import {IDiamond} from "./interfaces/IDiamond.sol";

library DiamondContractManager {
    using DiamondContractManager for bytes32;
    using DiamondContractManager for DiamondContractManager.Data;

    bytes32 constant base = keccak256("diamond");

    struct Facet {
        address addr;
        bytes4[] functs;
    }

    struct Funct {
        address facet;
        uint16 position;
    }

    struct Data {
        address payable addr;
        address owner;
        address[] facets;
        mapping(address => uint16) index;
        mapping(address => Facet) facet;
        mapping(bytes4 => Funct) funct;
        mapping(bytes4 => bool) interfaces;
        mapping(address => bool) access;
    }

    function diamond(bytes32 _key) internal pure returns (Data storage $) {
        assembly {
            $.slot := _key
        }
    }

    /* Ownable */

    function initialOwner(address _owner) internal {
        diamond(base).owner = _owner;
    }

    function setOwner(address _owner) internal {
        Data storage $ = diamond(base);
        enforceIsContractOwner();
        $.owner = _owner;
        emit OwnershipTransferred($.owner, _owner);
    }

    function owner() internal view returns (address _owner) {
        _owner = diamond(base).owner;
    }

    function enforceIsContractOwner() internal view {
        Data storage $ = diamond(base);
        if ($.owner != msg.sender)
            revert IDiamond.NotContractOwner(msg.sender, $.owner);
    }

    /* Access */

    function setAccess(bytes32 _key, address _owner, bool _access) internal {
        _key.checkAccess(msg.sender);
        diamond(_key).access[_owner] = _access;
    }

    function checkAccess(
        bytes32 _key,
        address _owner
    ) internal view returns (bool check) {
        Data storage $ = diamond(_key);
        if (diamond(base).owner == _owner || $.access[_owner]) check = true;
        if (!check) revert IDiamond.AccessDenied(_owner);
        return check;
    }

    /* Loupe */

    function functs(
        bytes32 _key,
        address _facet
    ) internal view returns (bytes4[] memory _functs) {
        _functs = diamond(_key).facet[_facet].functs;
        return
            _functs.length == 0 ? diamond(base).facet[_facet].functs : _functs;
    }

    function facet(
        bytes32 _key,
        bytes4 _funct
    ) internal view returns (address _facet) {
        _facet = diamond(_key).funct[_funct].facet;
        return
            _facet == address(0) ? diamond(base).funct[_funct].facet : _facet;
    }

    function facets(
        bytes32 _key
    ) internal view returns (address[] memory _facets) {
        address[] memory f = diamond(_key).facets;
        uint l = f.length;
        if (f.length > 0)
            for (uint i; i < l; ++i) {
                _facets[i] = f[i];
            }
        f = diamond(base).facets;
        if (f.length > 0)
            for (uint i; i < f.length; ++i) {
                _facets[i + l] = f[i];
            }
    }

    function getFacets(
        bytes32 _key
    ) internal view returns (Facet[] memory facets_) {
        Data storage $ = diamond(_key);
        uint length = $.facets.length;
        facets_ = new Facet[](length + 1);
        for (uint i; i < length; ++i) {
            address facet_ = $.facets[i];
            facets_[i] = Facet(facet_, $.facet[facet_].functs);
        }
        facets_[length] = Facet(
            address(this),
            diamond(base).facet[address(this)].functs
        );
    }

    function setInterface(
        bytes32 _key,
        bytes4 _interface,
        bool _state
    ) internal {
        checkAccess(_key, msg.sender);
        diamond(_key).interfaces[_interface] = _state;
    }

    function checkInterface(
        bytes32 _key,
        bytes4 _interface
    ) internal view returns (bool) {
        return diamond(_key).interfaces[_interface];
    }

    /* DiamondCut */

    event DiamondCut(
        IDiamond.Data[] _diamondCut,
        address _init,
        bytes _calldata
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    // Internal function version of diamondCut
    function diamondCut(
        IDiamond.Cut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        for (uint i; i < _diamondCut.length; ++i) {
            bytes32 key = keccak256(abi.encodePacked(_diamondCut[i].key));
            checkAccess(key, msg.sender);
            Data storage $ = diamond(key);
            for (uint j; j < _diamondCut[i].data.length; ++j) {
                bytes4[] memory functs_ = _diamondCut[i]
                    .data[j]
                    .functionSelectors;
                address facet_ = _diamondCut[i].data[j].facetAddress;
                if (functs_.length == 0)
                    revert IDiamond.NoSelectorsProvidedForFacetForCut(facet_);
                IDiamond.Action action = _diamondCut[i].data[j].action;
                if (action == IDiamond.Action.Add)
                    $.addFunctions(facet_, functs_);
                else if (action == IDiamond.Action.Replace)
                    $.replaceFunctions(facet_, functs_);
                else if (action == IDiamond.Action.Remove)
                    $.removeFunctions(facet_, functs_);
                else revert IDiamond.IncorrectFacetCutAction(uint8(action));
            }
            emit DiamondCut(_diamondCut[i].data, _init, _calldata);
        }
        initializeDiamondCut(_init, _calldata);
    }

    function internalCut(
        bytes4[] memory _functs,
        bytes memory _calldata
    ) internal {
        diamond(base)._addFunctions(address(this), _functs, true);
        IDiamond.Data[] memory _cut = new IDiamond.Data[](1);
        _cut[0] = IDiamond.Data(address(this), IDiamond.Action.Add, _functs);
        emit DiamondCut(_cut, address(this), _calldata);
    }

    function _addFunctions(
        Data storage $,
        address _facet,
        bytes4[] memory _functs,
        bool _internal
    ) internal {
        uint16 position = uint16($.facet[_facet].functs.length);
        if (position == 0) {
            $.facets.push(_facet);
            $.index[_facet] = uint16($.facets.length);
        }
        for (uint i; i < _functs.length; ++i) {
            if ($.funct[_functs[i]].facet != address(0)) {
                if (!_internal)
                    revert IDiamond.CannotAddFunctionToDiamondThatAlreadyExists(
                        _functs[i]
                    );
                if ($.funct[_functs[i]].facet != address(this)) {
                    $.funct[_functs[i]].facet = _facet;
                }
            }
            $.facet[_facet].functs.push(_functs[i]);
            $.funct[_functs[i]] = Funct(_facet, position);
            ++position;
        }
    }

    function addFunctions(
        Data storage $,
        address _facet,
        bytes4[] memory _functs
    ) internal {
        if (_facet == address(0))
            revert IDiamond.CannotAddSelectorsToZeroAddress(_functs);
        enforcedFacetHasCode(_facet, "DiamondCut: Add facet has no code");
        $._addFunctions(_facet, _functs, false);
    }

    function replaceFunctions(
        Data storage $,
        address _facet,
        bytes4[] memory _functs
    ) internal {
        if (_facet == address(0))
            revert IDiamond.CannotReplaceFunctionsFromFacetWithZeroAddress(
                _functs
            );
        enforcedFacetHasCode(_facet, "DiamondCut: Replace facet has no code");
        uint16 position = uint16($.facet[_facet].functs.length);
        for (uint i; i < _functs.length; ++i) {
            Funct memory old = $.funct[_functs[i]];

            if (old.facet == address(0))
                revert IDiamond.CannotReplaceFunctionThatDoesNotExists(
                    _functs[i]
                );

            // can't replace immutable functions -- functions defined directly in the diamond in this case
            if (old.facet == address(this))
                revert IDiamond.CannotReplaceImmutableFunction(_functs[i]);

            // delete old functions
            if ($.facet[old.facet].functs.length > 1) {
                uint last = $.facet[old.facet].functs.length - 1;
                $.facet[old.facet].functs[old.position] = $
                    .facet[old.facet]
                    .functs[last];
                $.facet[old.facet].functs.pop();
            } else {
                $.facets[$.index[old.facet]] = $.facets[$.facets.length - 1];
                $.facets.pop();
                delete $.facet[old.facet];
                delete $.index[old.facet];
            }

            // regist new functions
            $.funct[_functs[i]].facet = _facet;
            $.funct[_functs[i]].position = position;
            $.facet[_facet].functs.push(_functs[i]);
            ++position;
        }
        if ($.index[_facet] == 0) {
            $.facets.push(_facet);
            $.index[_facet] = uint16($.facets.length);
        }
    }

    function removeFunctions(
        Data storage $,
        address _facet,
        bytes4[] memory _functs
    ) internal {
        uint position = $.facet[_facet].functs.length;
        if (position == 0)
            revert IDiamond
                .CannotRemoveFunctionFromFacetAddressThatDoesNotExist(_facet);
        for (uint i; i < _functs.length; ++i) {
            bytes4 funct_ = _functs[i];
            Funct memory old = $.funct[funct_];
            if (old.facet == address(0))
                revert IDiamond.CannotRemoveFunctionThatDoesNotExist(funct_);
            // can't remove immutable functions -- functions defined directly in the diamond
            if (old.facet == address(this))
                revert IDiamond.CannotRemoveImmutableFunction(funct_);
            // replace funct with last funct
            if ($.facet[_facet].functs.length > 1) {
                --position;
                if (old.position != position) {
                    bytes4 last = $.facet[_facet].functs[position];
                    $.facet[_facet].functs[old.position] = last;
                    $.funct[last].position = old.position;
                }
                // delete last funct
                $.facet[_facet].functs.pop();
                delete $.funct[funct_];
            } else {
                $.facets[$.index[old.facet]] = $.facets[$.facets.length];
                $.facets.pop();
                delete $.facet[old.facet];
                delete $.index[old.facet];
            }
        }
    }

    function initializeDiamondCut(
        address _init,
        bytes memory _calldata
    ) internal {
        if (_init == address(0)) return;
        enforcedFacetHasCode(_init, "DiamondCut: _init address has no code");
        (bool success, bytes memory error) = _init.delegatecall(_calldata);
        if (!success)
            if (error.length > 0) {
                // bubble up error
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(error)
                    revert(add(32, error), returndata_size)
                }
            } else {
                revert IDiamond.InitializationFunctionReverted(
                    _init,
                    _calldata
                );
            }
    }

    function enforcedFacetHasCode(
        address _facet,
        string memory _errorMessage
    ) internal view {
        uint size;
        assembly {
            size := extcodesize(_facet)
        }
        if (size == 0)
            revert IDiamond.NoBytecodeAtAddress(_facet, _errorMessage);
    }
}
