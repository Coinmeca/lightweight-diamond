// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

interface IDiamondAuth {
    function owner() external returns (address);

    function setOwner(address _owner) external;

    function setAccess(address _owner, bool _access) external;

    function checkAccess(address _owner) external view returns (bool);
}
