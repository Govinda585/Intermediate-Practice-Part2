// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Lottery {
    address public owner;

    mapping(address => bool) public isEntered;
    address[] public participants;

    uint256 public constant TOTAL_NUMBER_OF_PARTICIPANTS = 3;
    uint256 public constant ENTRY_FEE = 5 ether;

    // Errors
    error InvalidAmount();
    error LotteryClosed();
    error NotOwner();
    error AlreadyEntered();
    error NoParticipants();

    // Events
    event EnteredLottery(address indexed user);
    event WinnerSelected(address indexed winner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function entry() external payable {
        if (msg.value != ENTRY_FEE) revert InvalidAmount();
        if (participants.length >= TOTAL_NUMBER_OF_PARTICIPANTS)
            revert LotteryClosed();
        if (isEntered[msg.sender]) revert AlreadyEntered();

        isEntered[msg.sender] = true;
        participants.push(msg.sender);

        emit EnteredLottery(msg.sender);
    }

    function selectWinner() external onlyOwner returns (address) {
        if (participants.length == 0) revert NoParticipants();

        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    address(this)
                )
            )
        );
 .
        uint256 winnerIndex = randomNumber % participants.length;
        address winner = participants[winnerIndex];

        emit WinnerSelected(winner);
        return winner;
    }

    function participantsLength() external view returns (uint256) {
        return participants.length;
    }
}
