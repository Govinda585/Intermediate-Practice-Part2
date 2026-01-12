// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {LimitCall} from "../src/LimitCall.sol";
contract LimiCallTest is Test {
    LimitCall public limitCall;
    function setUp() public {
        limitCall = new LimitCall();
        vm.roll(100);
    }

    function testRevertWhenSameBlock() public {
        limitCall.sum(4, 5);
        vm.expectRevert(LimitCall.BlockNumberSame.selector);
        limitCall.sum(4, 5);
    }

    function testSum() public {
        uint256 result = limitCall.sum(5, 7);
        assertEq(result, 12);
    }

    function testCanCallNowRetunFalse() public {
        limitCall.sum(4, 5);
        assertFalse(limitCall.canCallNow());
    }
    function testCanCallNowRetunTrue() public {
        assertTrue(limitCall.canCallNow());
    }
}
