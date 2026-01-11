// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

// Version 1
contract CounterV1 {
    uint256 public count;
    address public owner;

    function initialize(address _owner) external {
        require(owner == address(0), "Already Initialized");
        owner = _owner;
    }

    function increment() external {
        count += 1;
    }
}

// Version 2 (Upgraded Contract)

contract CounterV2 {
    uint256 count;
    address public owner;

    function initialize(address _owner) external {
        require(owner == address(0), "Already Initialized");
        owner = _owner;
    }

    function increase() external {
        count += 1;
    }

    function decrease() external {
        count -= 1;
    }
}

// Proxy Contract

contract Proxy {
    // EIP 1967 slots

    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    bytes32 private constant ADMIN_SLOT =
        bytes32(uint256(keccak256(("eip1967.proxy.admin"))) - 1);

    constructor(address _implementation) {
        _setAdmin(msg.sender);
        _setImplementation(_implementation);
    }

    modifier onlyAdmin() {
        require(msg.sender == _getAdmin(), "Not Admin");
        _;
    }

    function upgradeTo(address newImplementation) external onlyAdmin {
        _setImplementation(newImplementation);
    }

    fallback() external payable {
        _delegate(_getImplementation());
    }

    receive() external payable {
        _delegate(_getImplementation());
    }

    function _delegate(address impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
    function _setImplementation(address impl) internal {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, impl)
        }
    }

    function _getAdmin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    function _setAdmin(address adm) internal {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, adm)
        }
    }
}
