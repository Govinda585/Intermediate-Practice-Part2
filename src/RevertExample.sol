// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

// Write a contract with a require, assert, and revert example

contract RevertExample {
    uint256 public number;
    string public name;

    error NameTooShort(uint256 length);
    error NumberTooSmall(uint256 provided);
    error InternalInvariantFailed();

    // set number greater than 10
    function setNumber(uint256 _number) public {
        require(_number > 10, "Number must be greater than 10");
        number = _number;
    }

    function setName(string calldata _name) public {
        if (bytes(_name).length < 2) revert NameTooShort(bytes(_name).length);
        name = _name;
    }

    function dangarousMath(uint256 x) public pure returns (uint256) {
        uint256 result = x * 100;
        assert(result >= x);
        return result;
    }

    function buggyFunction(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 sum = a + b;
        assert(sum >= a);
        return sum;
    }

    function completeExample(uint256 _num, string calldata _name) public {
        require(_num > 0, "Number cannot be zero");
        if (bytes(_name).length < 3) revert NameTooShort(bytes(_name).length);
        assert(number + _num > number);
        number += _num;
        name = _name;
    }
}
