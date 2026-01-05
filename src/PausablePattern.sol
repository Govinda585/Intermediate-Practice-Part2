// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// Create a contract that pauses all functionality (Pausable pattern).
contract PausablePattern {
    bool public paused;
    address public owner;

    error AlreadyPaused();
    error AlreadyUnpaused();
    error NotOwner();
    error ContractPaused();

    constructor() {
        owner = msg.sender;
        paused = false; // explicitly unpaused
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    function pauseContract() external onlyOwner {
        if (paused) revert AlreadyPaused();
        paused = true;
    }

    function unpauseContract() external onlyOwner {
        if (!paused) revert AlreadyUnpaused();
        paused = false;
    }

    // Pausable function (blocked when paused)
    function doSum(
        uint256 a,
        uint256 b
    ) external view whenNotPaused returns (uint256) {
        return a + b;
    }

    // Non-pausable function (always works)
    function doMultiply(uint256 a, uint256 b) external pure returns (uint256) {
        return a * b;
    }
}
