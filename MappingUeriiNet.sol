// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WalletMap {
    address owner;
    address permittedAddress;
    mapping (address => address) childToParent;
    mapping (address => address[]) parentToChildren;

    constructor() {
        owner = msg.sender;
        permittedAddress = owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this function");
        _;
    }

    modifier onlyPermitted() {
        require(msg.sender == permittedAddress, "Only the permitted address can execute this function");
        _;
    }

    function addParent(address parent, address child) public onlyPermitted {
        require(parent != child, "Parent and child cannot be the same wallet");
        require(childToParent[child] == address(0), "Child wallet already associated with another parent wallet");

        // Controllo che il wallet figlio non sia già un wallet padre
        require(getChildren(child).length == 0, "The child wallet is already a parent of another wallet");

        childToParent[child] = parent;
        parentToChildren[parent].push(child);
    }

    function getParent(address child) public view returns (address) {
        return childToParent[child];
    }

    function getChildren(address parent) public view returns (address[] memory) {
        return parentToChildren[parent];
    }

    function getChildCount(address parent) public view returns (uint256) {
        return parentToChildren[parent].length;
    }

    function setPermission(address newPermittedAddress) public onlyOwner {
        require(newPermittedAddress != address(0), "Invalid new permitted address");
        permittedAddress = newPermittedAddress;
    }
}
