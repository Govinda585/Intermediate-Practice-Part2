// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

//Build a contract that limits function calls to once per block.

contract LimitCall {
    uint256 public lastCallBlock;

    error BlockNumberSame();

    modifier oneCallPerBlock() {
        if (block.number == lastCallBlock) revert BlockNumberSame();
        _;
        lastCallBlock = block.number;
    }

    function sum(
        uint256 a,
        uint256 b
    ) external oneCallPerBlock returns (uint256) {
        return a + b;
    }

    function canCallNow() external view returns (bool) {
        return block.number != lastCallBlock;
    }
}
