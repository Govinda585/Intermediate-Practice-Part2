//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {PausablePattern} from "../src/PausablePattern.sol";

contract PausablePatternTest is Test {
    PausablePattern public pausablePattern;
    address USER = makeAddr("user");
    address owner;
    function setUp() public {
        owner = makeAddr("owner");
        vm.prank(owner);
        pausablePattern = new PausablePattern();
    }

    function testModifierRevertOnNotOwner() public {
        vm.prank(USER);
        vm.expectRevert(PausablePattern.NotOwner.selector);
        pausablePattern.pauseContract();
    }

    function testRevertOnContractAlreadyPaused() public {
        vm.startPrank(owner);
        pausablePattern.pauseContract(); // set paused true
        vm.expectRevert(PausablePattern.AlreadyPaused.selector);
        pausablePattern.pauseContract();
        vm.stopPrank();
    }

    function testPausedContract() public {
        vm.prank(owner);
        pausablePattern.pauseContract(); // set paused true
        assertTrue(pausablePattern.paused());
    }

    function testRevertOnContractUnpaused() public {
        vm.startPrank(owner);
        vm.expectRevert(PausablePattern.AlreadyUnpaused.selector);
        pausablePattern.unpauseContract();
    }

    function testUnpausedContract() public {
        vm.startPrank(owner);
        pausablePattern.pauseContract();
        pausablePattern.unpauseContract();
        assertFalse(pausablePattern.paused());
        vm.stopPrank();
    }

    function testRevertOnWhenNotPaused() public {
        vm.startPrank(owner);
        pausablePattern.pauseContract();
        vm.expectRevert(PausablePattern.ContractPaused.selector);
        pausablePattern.doSum(5, 10);
        vm.stopPrank();
    }
    function testDoSum() public {
        // default paused is false
        assertEq(pausablePattern.doSum(5, 10), 15);
    }

    function testDoMultiply() public {
        vm.startPrank(owner);
        pausablePattern.pauseContract();
        uint256 result1 = pausablePattern.doMultiply(5, 4);
        assertEq(result1, 20);
        pausablePattern.unpauseContract();
        uint256 result2 = pausablePattern.doMultiply(5, 10);
        assertEq(result2, 50);
        vm.stopPrank();
    }
}
