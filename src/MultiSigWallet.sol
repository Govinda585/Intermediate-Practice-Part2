// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MultiSigWallet {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error NotOwner();
    error InvalidOwner();
    error DuplicateOwner();
    error AlreadyConfirmed();
    error TxAlreadyExecuted();
    error InsufficientConfirmations();
    error ExecutionFailed();

    /*//////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/
    uint256 public constant REQUIRED_CONFIRMATIONS = 2;

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    address[3] public owners;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        uint256 confirmations;
        bool executed;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public isConfirmed;

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyOwner() {
        if (
            msg.sender != owners[0] &&
            msg.sender != owners[1] &&
            msg.sender != owners[2]
        ) revert NotOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address[3] memory _owners) {
        for (uint256 i; i < 3; i++) {
            if (_owners[i] == address(0)) revert InvalidOwner();
        }

        if (
            _owners[0] == _owners[1] ||
            _owners[0] == _owners[2] ||
            _owners[1] == _owners[2]
        ) revert DuplicateOwner();

        owners = _owners;
    }

    /*//////////////////////////////////////////////////////////////
                          TRANSACTION LOGIC
    //////////////////////////////////////////////////////////////*/
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                confirmations: 0,
                executed: false
            })
        );
    }

    function confirmTransaction(uint256 _txIndex) external onlyOwner {
        Transaction storage tx_ = transactions[_txIndex];

        if (tx_.executed) revert TxAlreadyExecuted();
        if (isConfirmed[_txIndex][msg.sender]) revert AlreadyConfirmed();

        isConfirmed[_txIndex][msg.sender] = true;
        tx_.confirmations++;
    }

    function executeTransaction(uint256 _txIndex) external onlyOwner {
        Transaction storage tx_ = transactions[_txIndex];

        if (tx_.executed) revert TxAlreadyExecuted();
        if (tx_.confirmations < REQUIRED_CONFIRMATIONS)
            revert InsufficientConfirmations();

        tx_.executed = true;

        (bool success, ) = tx_.to.call{value: tx_.value}(tx_.data);
        if (!success) revert ExecutionFailed();
    }

    /*//////////////////////////////////////////////////////////////
                            RECEIVE ETHER
    //////////////////////////////////////////////////////////////*/
    receive() external payable {}
}
